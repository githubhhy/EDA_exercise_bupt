/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Endpoint register File                                     ////
////  This module contains all registers for ONE endpoint        ////
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
//  $Id: usbf_ep_rf.v,v 1.1 2001/08/03 05:30:09 rudi Exp $
//
//  $Date: 2001/08/03 05:30:09 $
//  $Revision: 1.1 $
//  $Author: rudi $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: usbf_ep_rf.v,v $
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
//               Revision 0.1.0.1  2001/02/28 08:10:44  rudi
//               Initial Release
//
//                            

`include "usbf_defines.v"

// Endpoint register File
module usbf_ep_rf(clk, wclk, rst,

		// Wishbone Interface
		adr, re, we, din, dout, inta, intb,
		dma_req, dma_ack,

		// Internal Interface

		idin,
		ep_sel, ep_match,
		buf0_rl, buf0_set, buf1_set,
		uc_bsel_set, uc_dpd_set,

		int_buf1_set, int_buf0_set, int_upid_set,
		int_crc16_set, int_to_set, int_seqerr_set,
		out_to_small,

		csr, buf0, buf1, dma_in_buf_sz1, dma_out_buf_avail
		);

input		clk, wclk, rst;
input	[1:0]	adr;
input		re;
input		we;
input	[31:0]	din;
output	[31:0]	dout;
output		inta, intb;
output		dma_req;
input		dma_ack;

input	[31:0]	idin;		// Data Input
input	[3:0]	ep_sel;		// Endpoint Number Input
output		ep_match;	// Asserted to indicate a ep no is matched
input		buf0_rl;	// Reload Buf 0 with original values

input		buf0_set;	// Write to buf 0
input		buf1_set;	// Write to buf 1
input		uc_bsel_set;	// Write to the uc_bsel field
input		uc_dpd_set;	// Write to the uc_dpd field
input		int_buf1_set;	// Set buf1 full/empty interrupt
input		int_buf0_set;	// Set buf0 full/empty interrupt
input		int_upid_set;	// Set unsupported PID interrupt
input		int_crc16_set;	// Set CRC16 error interrupt
input		int_to_set;	// Set time out interrupt
input		int_seqerr_set;	// Set PID sequence error interrupt
input		out_to_small;	// OUT packet was to small for DMA operation

output	[31:0]	csr;		// Internal CSR Output
output	[31:0]	buf0;		// Internal Buf 0 Output
output	[31:0]	buf1;		// Internal Buf 1 Output
output		dma_in_buf_sz1;	// Indicates that the DMA IN buffer has 1 max_pl_sz
				// packet available
output		dma_out_buf_avail;// Indicates that there is space for at least
				// one MAX_PL_SZ packet in the buffer

///////////////////////////////////////////////////////////////////
//
// Local Wires and Registers
//

reg	[31:0]	dout;

// CSR
reg	[12:0]	csr0;
reg		ots_stop;
reg	[12:0]	csr1;
reg	[1:0]	uc_bsel, uc_dpd;

reg	[5:0]	iena, ienb;	// Interrupt enables
reg	[6:0]	is;		// Interrupt status

wire		we0, we1, we2, we3;
reg	[31:0]	buf0;
reg	[31:0]	buf1;
reg	[31:0]	buf0_orig;

reg		inta, intb;

// DMA Logic Registers
reg	[11:0]	dma_out_cnt;
wire		dma_out_cnt_is_zero;
reg		dma_out_buf_avail;
reg	[11:0]	dma_out_left;

reg	[11:0]	dma_in_cnt;
reg		dma_in_buf_sz1;

reg		dma_req_r;
wire		dma_req_d;
wire		dma_req_in_d;
wire		dma_req_out_d;
reg		r1, r2, r4, r5;
wire		r3;
wire		dma_ack_i;
reg		dma_req_out_hold, dma_req_in_hold ;
reg	[11:0]	buf0_orig_m3;
wire		dma_req_hold;
reg		set_r;
reg		ep_match_r; 

// Aliases
wire	[31:0]	csr;
wire	[31:0]	int;
wire		dma_en;
wire	[10:0]	max_pl_sz;
wire		ep_in;
wire		ep_out;

assign csr = {uc_bsel, uc_dpd, csr1, 1'h0, ots_stop, csr0};
assign int = { 2'h0, iena, 2'h0,ienb, 9'h0, is};
assign dma_en = csr[15];
assign max_pl_sz = csr[10:0];
assign ep_in  = csr[27:26]==2'b01;
assign ep_out = csr[27:26]==2'b10;

///////////////////////////////////////////////////////////////////
//
// WISHBONE Access
//

always @(adr or csr or int or buf0 or buf1)
	case(adr)	// synopsys full_case parallel_case
	   0: dout = csr;
	   1: dout = int;
	   2: dout = buf0;
	   3: dout = buf1;
	endcase

assign we0 = (adr==0) & we;
assign we1 = (adr==1) & we;
assign we2 = (adr==2) & we;
assign we3 = (adr==3) & we;

// Endpoint CSR Register
always @(posedge clk)
	if(!rst)
	   begin
		csr0 <= #1 0;
		csr1 <= #1 0;
		ots_stop <= #1 0;
	   end
	else
	if(we0)
	   begin
		csr0 <= #1 din[12:0];
		ots_stop <= #1 din[13];
		csr1 <= #1 din[27:15];
	   end
	else
	if(ots_stop & out_to_small)
		csr1[8:7] <= #1 2'b01;	

// Endpoint Interrupt Register
always @(posedge clk)
	if(!rst)
	   begin
		ienb <= #1 0;
		iena <= #1 0;
	   end
	else
	if(we1)
	   begin
		ienb <= #1 din[21:16];
		iena <= #1 din[29:24];
	   end

// Endpoint Buffer Registers
always @(posedge clk)
	if(!rst)			buf0 <= #1 32'hffff_ffff;
	else
	if(we2)				buf0 <= #1 din;
	else
	if(ep_match_r & buf0_rl)	buf0 <= #1 buf0_orig;
	else
	if(ep_match_r & buf0_set)	buf0 <= #1 idin;

always @(posedge clk)
	if(!rst)			buf1 <= #1 32'hffff_ffff;
	else
	if(we3)				buf1 <= #1 din;
	else
	if(ep_match_r &
	(buf1_set | out_to_small))	buf1 <= #1 idin;

always @(posedge clk)
	if(!rst)			buf0_orig <= #1 32'hffff_ffff;
	else
	if(we2)				buf0_orig <= #1 din;

///////////////////////////////////////////////////////////////////
//
// Internal Access
//

// Indicates that this register file matches the current
// endpoint from token
assign ep_match = (ep_sel == csr[21:18]);

always @(posedge clk)
	ep_match_r <= #1 ep_match;

// Interrupt Sources
always @(posedge clk)
	if(!rst)			is <= #1 0;
	else
	if(re & (adr == 1) )		is <= #1 0;
	else
	if(ep_match_r)
	   begin
		if(out_to_small)	is[6] <= #1 1;
		if(int_seqerr_set)	is[5] <= #1 1;
		if(int_buf1_set)	is[4] <= #1 1;
		if(int_buf0_set)	is[3] <= #1 1;
		if(int_upid_set)	is[2] <= #1 1;
		if(int_crc16_set)	is[1] <= #1 1;
		if(int_to_set)		is[0] <= #1 1;
	   end

// PID toggle track bits
always @(posedge clk)
	if(!rst)			uc_dpd <= #1 0;
	else
	if(ep_match_r & uc_dpd_set)	uc_dpd <= #1 idin[3:2];

// Buffer toggle track bits
always @(posedge clk)
	if(!rst)			uc_bsel <= #1 0;
	else
	if(ep_match_r & uc_bsel_set)	uc_bsel <= #1 idin[1:0];

///////////////////////////////////////////////////////////////////
//
// Endpoint Interrupt Generation
//

always @(posedge wclk)
	inta <= #1	(is[0] & iena[0]) |
			(is[1] & iena[1]) |
			(is[2] & iena[2]) |
			(is[3] & iena[3]) |
			(is[4] & iena[3]) |
			(is[5] & iena[4]) |
			(is[6] & iena[5]);

always @(posedge wclk)
	intb <= #1	(is[0] & ienb[0]) |
			(is[1] & ienb[1]) |
			(is[2] & ienb[2]) |
			(is[3] & ienb[3]) |
			(is[4] & ienb[3]) |
			(is[5] & ienb[4]) |
			(is[6] & ienb[5]);

///////////////////////////////////////////////////////////////////
//
// Endpoint DMA Request Logic
//

// DMA OUT endpoint counter
always @(posedge clk)
	if(!dma_en)			dma_out_cnt <= #1 0;
	else
	if(dma_ack_i)			dma_out_cnt <= #1 dma_out_cnt - 1;
	else
	if(set_r | buf0_set | buf0_rl)	dma_out_cnt <= #1 dma_out_cnt + max_pl_sz[10:2];

// If buf0_set or buf0_rl was asserted at the same time as dma_ack_i
// remember it and perform the add next cycle ...
always @(posedge clk)
	set_r <= #1 dma_ack_i & (buf0_set | buf0_rl);

// This signal is used to keep dma_req asserted when we know there is
// plenty of data in the buffer.
// When the buffer is "low", we do one dma_req and wait to see if there
// is more data and repeat until the buffer is empty.
// This is because of the sync logic - it has to propagate first
// before we can determine that the buffer is really empty.
always @(posedge wclk)
	dma_req_out_hold <= #1 |dma_out_cnt[11:2] & ep_out;

assign dma_out_cnt_is_zero = dma_out_cnt == 0;

// DMA IN endpoint counter
always @(posedge clk)
	if(!dma_en)			dma_in_cnt <= #1 0;
	else
	if(dma_ack_i)			dma_in_cnt <= #1 dma_in_cnt + 1;
	else
	if(set_r | buf0_set | buf0_rl)	dma_in_cnt <= #1 dma_in_cnt - max_pl_sz[10:2];

// Indicates to Protocol Engine when we have gotten at least one packet in to buffer
// This is for IN transfers only
always @(posedge clk)
	dma_in_buf_sz1 <= #1	(dma_in_cnt >= {3'h0,max_pl_sz[10:2]}) &
				(max_pl_sz[10:0] !=0);

// Indicates to Protocol Engine that there is space for at least one MAX_PL_SZ
// packet in buffer. OUT transfers only.
always @(posedge clk)
	dma_out_left <= #1 (buf0_orig[30:19] - dma_out_cnt);

always @(posedge clk)
	dma_out_buf_avail <= #1 (dma_out_left >= max_pl_sz[10:2]);

// DMA Request Generation
assign dma_req_d = dma_en & (dma_req_in_d | dma_req_out_d);

// For OUT
assign dma_req_out_d = ep_out & !dma_out_cnt_is_zero;

// FOR IN
assign	dma_req_in_d = ep_in & (dma_in_cnt < buf0_orig[30:19]);


always @(posedge wclk)
	buf0_orig_m3 <= #1 buf0_orig[30:19] - 3;

always @(posedge wclk)
	dma_req_in_hold <= #1 ep_in & |buf0_orig[30:21] & (dma_in_cnt < buf0_orig_m3);

assign dma_req_hold = ep_out ? dma_req_out_hold : dma_req_in_hold;

// Generate a Sync. Request
assign dma_req = dma_req_r;

always @(posedge wclk)
	if(!rst)			dma_req_r <= #1 0;
	else
	if(r1 & !r2)			dma_req_r <= #1 1;
	else
	if(dma_ack & !dma_req_hold)	dma_req_r <= #1 0;

always @(posedge wclk)
	r1 <= #1 dma_req_d & !r2 & !r4 & !r5;

always @(posedge wclk)
	if(!rst)	r2 <= #1 0;
	else
	if(r1)		r2 <= #1 1;
	else
	if(r4)		r2 <= #1 0;

// Synchronize ACK
assign r3 = (!rst) ? 0 : dma_ack ? 1 : r4 ? 0 : r3;

always @(posedge clk)
	r4 <= #1 r3;

always @(posedge clk)
	r5 <= #1 r4;

assign dma_ack_i = r5;

endmodule

