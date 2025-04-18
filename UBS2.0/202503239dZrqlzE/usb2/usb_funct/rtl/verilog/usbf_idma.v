/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Internal DMA Engine                                        ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/usb/       ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000 Rudolf Usselmann                         ////
////                    rudi@asics.ws                            ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

//  CVS Log
//
//  $Id: usbf_idma.v,v 1.1 2001/08/03 05:30:09 rudi Exp $
//
//  $Date: 2001/08/03 05:30:09 $
//  $Revision: 1.1 $
//  $Author: rudi $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: usbf_idma.v,v $
//               Revision 1.1  2001/08/03 05:30:09  rudi
//
//
//               1) Reorganized directory structure
//
//               Revision 1.2  2001/03/31 13:00:51  rudi
//
//               - Added Core configuration
//               - Added handling of OUT packets less than MAX_PL_SZ in DMA mode
//               - Modified WISHBONE interface and sync logic
//               - Moved SSRAM outside the core (added interface)
//               - Many small bug fixes ...
//
//               Revision 1.0  2001/03/07 09:17:12  rudi
//
//
//               Changed all revisions to revision 1.0. This is because OpenCores CVS
//               interface could not handle the original '0.1' revision ....
//
//               Revision 0.1.0.1  2001/02/28 08:10:50  rudi
//               Initial Release
//
//                            

`include "usbf_defines.v"

module usbf_idma(	clk, rst,

		// Packet Disassembler/Assembler interface
		rx_data_st, rx_data_valid, rx_data_done, 
		send_data, tx_data_st, rd_next,

		// Protocol Engine
		rx_dma_en, tx_dma_en,
		abort, idma_done,
		buf_size, dma_en,

		// Register File Manager Interface
		adr, size, sizu_c,

		// Memory Arb interface
		madr, mdout, mdin, mwe, mreq, mack
		);

parameter	SSRAM_HADR = 14;

// Packet Disassembler/Assembler interface
input		clk, rst;
input	[7:0]	rx_data_st;
input		rx_data_valid;
input		rx_data_done;
output		send_data;
output	[7:0]	tx_data_st;
input		rd_next;

// Protocol Engine
input		rx_dma_en;	// Allows the data to be stored
input		tx_dma_en;	// Allows for data to be retrieved
input		abort;		// Abort Transfer (time_out, crc_err or rx_error)
output		idma_done;	// DMA is done
input	[13:0]	buf_size;	// Actual buffer size
input		dma_en;		// External DMA enabled

// Register File Manager Interface
input	[SSRAM_HADR + 2:0]	adr;	// Byte Address
input	[13:0]	size;		// Size in bytes
output	[10:0]	sizu_c;		// Up and Down counting size registers, used to update

// Memory Arb interface
output	[SSRAM_HADR:0]	madr;	// word address
output	[31:0]	mdout;
input	[31:0]	mdin;
output		mwe;
output		mreq;
input		mack;

///////////////////////////////////////////////////////////////////
//
// Local Wires and Registers
//

parameter	[7:0]	// synopsys enum state
		IDLE		= 8'b00000001,
		WAIT_MRD	= 8'b00000010,
		MEM_WR		= 8'b00000100,
		MEM_WR1		= 8'b00001000,
		MEM_WR2		= 8'b00010000,
		MEM_RD1		= 8'b00100000,
		MEM_RD2		= 8'b01000000,
		MEM_RD3		= 8'b10000000;

reg	[7:0]	/* synopsys enum state */ state, next_state;
// synopsys state_vector state

reg		tx_dma_en_r, rx_dma_en_r;

reg	[SSRAM_HADR:0]	adr_cw;		// Internal word address counter
reg	[2:0]	adr_cb;			// Internal byte address counter
reg	[SSRAM_HADR:0]	adrw_next;	// next address
reg	[SSRAM_HADR:0]	adrw_next1;	// next address (after overrun check)
reg	[SSRAM_HADR:0]	last_buf_adr;	// Last Buffer Address
reg	[2:0]	adrb_next;		// next byte address
reg	[13:0]	sizd_c;			// Internal size counter
reg	[10:0]	sizu_c;			// Internal size counter
wire		adr_incw;
wire		adr_incb;
wire		siz_dec;
wire		siz_inc;

reg		word_done;		// Indicates that a word has been
					// assembled
reg		mreq_d;			// Memory request from State Machine
reg	[31:0]	dtmp_r;			// Temp data assembly register
reg	[31:0]	dout_r;			// Data output register
reg		mwe_d;			// Memory Write enable
reg		dtmp_sel;		// Selects tmp data register for pre-fetch

reg		sizd_is_zero;		// Indicates when all bytes have been
					// transferred
wire		sizd_is_zero_d;

reg	[7:0]	tx_data_st;		// Data output to packet assembler
reg	[31:0]	rd_buf0, rd_buf1;	// Mem Rd. buffers for TX
reg		rd_buf_full;		// Indicates buffers are full
reg		rd_first;		// Indicates initial fill of buffers

reg		idma_done;		// DMA transfer is done

reg		mack_r;
reg		send_data;		// Enable UTMI Transmitter

reg		word_done_r;
reg		wr_last;
reg		wr_last_en;
reg		wr_done;
reg		wr_done_r;
reg		dtmp_sel_r;
reg		mwe;
reg		rx_data_done_r2;
wire		fill_buf0, fill_buf1;
wire		adrb_is_3;

reg		rx_data_done_r;
reg		rx_data_valid_r;
reg	[7:0]	rx_data_st_r;

///////////////////////////////////////////////////////////////////
//
// Memory Arb interface
//

// Memory Request
assign mreq = (mreq_d & !mack_r) | word_done_r;

// Output Data
assign mdout = dout_r;

// Memory Address
assign madr = adr_cw;

always @(posedge clk)
	mwe <= #1 mwe_d;

always @(posedge clk)
	mack_r <= #1 mreq & mack;

///////////////////////////////////////////////////////////////////
//
// Misc Logic
//

always @(posedge clk)
	rx_data_valid_r <= #1 rx_data_valid;

always @(posedge clk)
	rx_data_st_r <= #1 rx_data_st;

always @(posedge clk)
	rx_data_done_r <= #1 rx_data_done;

always @(posedge clk)
	rx_data_done_r2 <= #1 rx_data_done_r;

// Generate one cycle pulses for tx and rx dma enable
always @(posedge clk)
	tx_dma_en_r <= #1 tx_dma_en;

always @(posedge clk)
	rx_dma_en_r <= #1 rx_dma_en;

// address counter
always @(posedge clk)
	if(rx_dma_en_r | tx_dma_en_r)	adr_cw <= #1 adr[SSRAM_HADR + 2:2];
	else				adr_cw <= #1 adrw_next1;

always @(posedge clk)
	last_buf_adr <= #1 adr + buf_size;

always @(dma_en or adrw_next or last_buf_adr)
	if(adrw_next == last_buf_adr & dma_en)	adrw_next1 = 0;
	else					adrw_next1 = adrw_next;

always @(adr_incw or adr_cw)
	if(adr_incw)	adrw_next = adr_cw + 1;
	else		adrw_next = adr_cw;

always @(posedge clk)
	if(!rst)			adr_cb <= #1 0;
	else
	if(rx_dma_en_r | tx_dma_en_r)	adr_cb <= #1 adr[2:0];
	else				adr_cb <= #1 adrb_next;

always @(adr_incb or adr_cb)
	if(adr_incb)	adrb_next = adr_cb + 1;
	else		adrb_next = adr_cb;

assign adr_incb = rx_data_valid_r | rd_next;
assign adr_incw = !dtmp_sel_r & mack_r;

// Size Counter (counting backward from input size)
always @(posedge clk)
	if(tx_dma_en_r)		sizd_c <= #1 size;
	else
	if(siz_dec)		sizd_c <= #1 sizd_c - 1;

assign siz_dec = (rd_first & mack_r) | (rd_next & sizd_c!=0);

assign sizd_is_zero_d = sizd_c == 0 ;

always @(posedge clk)
	sizd_is_zero <= #1 sizd_is_zero_d;

// Size Counter (counting up from zero)
always @(posedge clk)
	if(rx_dma_en_r)		sizu_c <= #1 0;
	else
	if(siz_inc)		sizu_c <= #1 sizu_c + 1;

assign siz_inc = rx_data_valid_r;

// DMA Done Indicator
always @(posedge clk)
	idma_done <= #1 rx_data_done_r | sizd_is_zero_d;

///////////////////////////////////////////////////////////////////
//
// RX Logic
//

always @(posedge clk)
	dtmp_sel_r <= #1 dtmp_sel;

// Memory data input
always @(posedge clk)
	if(dtmp_sel_r)			dtmp_r <= #1 mdin;
	else
	if(rx_data_valid_r)
	   begin
		if(adr_cb[1:0]==0)	dtmp_r[07:00] <= #1 rx_data_st_r;
		if(adr_cb[1:0]==1)	dtmp_r[15:08] <= #1 rx_data_st_r;
		if(adr_cb[1:0]==2)	dtmp_r[23:16] <= #1 rx_data_st_r;
		if(adr_cb[1:0]==3)	dtmp_r[31:24] <= #1 rx_data_st_r;
	   end

always @(posedge clk)
	word_done <= #1 (adr_cb[1:0]==3 & rx_data_valid_r) | wr_last;

always @(posedge clk)
	word_done_r <= #1 word_done & !word_done_r;

// Store output data and address when we got a word
always @(posedge clk)
	if(word_done)	dout_r <= #1 dtmp_r;

always @(posedge clk)
	wr_last <= #1 adr_cb[1:0] != 0 & !rx_data_valid_r & wr_last_en;

always @(posedge clk)
	wr_done_r <= #1 rx_data_done_r;

always @(posedge clk)
	wr_done <= #1 wr_done_r;

///////////////////////////////////////////////////////////////////
//
// TX Logic
//

// Fill TX Buffers
always @(posedge clk)
	if(fill_buf0)	rd_buf0 <= #1 mdin;

always @(posedge clk)
	if(fill_buf1)	rd_buf1 <= #1 mdin;

always @(adrb_next or rd_buf0 or rd_buf1)
	case(adrb_next[2:0])	// synopsys full_case parallel_case
	   0: tx_data_st = rd_buf0[07:00];
	   1: tx_data_st = rd_buf0[15:08];
	   2: tx_data_st = rd_buf0[23:16];
	   3: tx_data_st = rd_buf0[31:24];
	   4: tx_data_st = rd_buf1[07:00];
	   5: tx_data_st = rd_buf1[15:08];
	   6: tx_data_st = rd_buf1[23:16];
	   7: tx_data_st = rd_buf1[31:24];
	endcase

assign fill_buf0 = !adr_cw[0] & mack_r;
assign fill_buf1 =  adr_cw[0] & mack_r;

assign	adrb_is_3 = adr_cb[1:0] == 3;


always @(posedge clk)
	if(!rst)		send_data <= #1 0;
	else
	if(rd_first)		send_data <= #1 1;
	else
	if((sizd_c==1 & rd_next) | sizd_c==0)	send_data <= #1 0;

///////////////////////////////////////////////////////////////////
//
// IDMA Load/Store State Machine
//

// store incoming data to memory until rx_data done
// First pre-fetch data from memory, so that bytes can be stuffed properly

always @(posedge clk)
	if(!rst)	state <= #1 IDLE;
	else		state <= #1 next_state;

always @(state or mack_r or abort or rx_dma_en_r or tx_dma_en_r or rd_buf_full or
	sizd_is_zero or wr_last or wr_done or rx_data_done_r2 or adr_cb or
	rd_next or adrb_is_3)
   begin
	next_state = state;	// Default do not change state
	mreq_d = 0;
	mwe_d = 0;
	rd_first = 0;
	dtmp_sel = 0;
	wr_last_en = 0;

	case(state)	// synopsys full_case parallel_case
	   IDLE:
		   begin
			if(rx_dma_en_r & !abort)
			   begin
				next_state = WAIT_MRD;
			   end
			if(tx_dma_en_r & !abort)
			   begin
				next_state = MEM_RD1;
			   end
		   end

	   WAIT_MRD:	// Pre-fetch a word from memory
		   begin
			if(abort)	next_state = IDLE;
			else
			if(mack_r)	next_state = MEM_WR;
			else
			   begin
				dtmp_sel = 1;
				mreq_d = 1;
			   end
		   end

	   MEM_WR:
		   begin

			mwe_d = 1;
			if(abort)			next_state = IDLE;
			else
			if(rx_data_done_r2)	
			   begin
				wr_last_en = 1;
				next_state = MEM_WR1;
			   end

		   end
	   MEM_WR1:
		   begin
			mwe_d = 1;
			wr_last_en = 1;
			if(abort)			next_state = IDLE;
			else
			if(wr_last)			next_state = MEM_WR2;
			else
			if(wr_done)			next_state = IDLE;
		   end

	   MEM_WR2:
		   begin
			mwe_d = 1;
			if(mack_r)			next_state = IDLE;
		   end

	   MEM_RD1:
		   begin
			mreq_d = 1;
			if(mack_r)		rd_first = 1;
			if(abort)		next_state = IDLE;
			else
			if(mack_r)		next_state = MEM_RD2;
		   end
	   MEM_RD2:
		   begin
			mreq_d = 1;
			if(abort)		next_state = IDLE;
			else
			if(mack_r)		next_state = MEM_RD3;
		   end
	   MEM_RD3:
		   begin
			if(sizd_is_zero | abort)	next_state = IDLE;
			else
			if(adrb_is_3 & rd_next)		next_state = MEM_RD2;
		   end
	endcase

   end

endmodule

