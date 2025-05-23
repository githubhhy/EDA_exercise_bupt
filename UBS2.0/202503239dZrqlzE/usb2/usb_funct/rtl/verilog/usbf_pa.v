/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Packet Assembler                                           ////
////  Assembles Token and Data USB packets                       ////
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
//  $Id: usbf_pa.v,v 1.2 2001/08/10 08:48:33 rudi Exp $
//
//  $Date: 2001/08/10 08:48:33 $
//  $Revision: 1.2 $
//  $Author: rudi $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: usbf_pa.v,v $
//               Revision 1.2  2001/08/10 08:48:33  rudi
//
//               - Changed IO names to be more clear.
//               - Uniquifyed define names to be core specific.
//
//               Revision 1.1  2001/08/03 05:30:09  rudi
//
//
//               1) Reorganized directory structure
//
//               Revision 1.0  2001/03/07 09:17:12  rudi
//
//
//               Changed all revisions to revision 1.0. This is because OpenCores CVS
//               interface could not handle the original '0.1' revision ....
//
//               Revision 0.1.0.1  2001/02/28 08:10:54  rudi
//               Initial Release
//
//

`include "usbf_defines.v"

module usbf_pa(	clk, rst,

		// UTMI TX I/F
		tx_data, tx_valid, tx_valid_last, tx_ready,
		tx_first,

		// Protocol Engine Interface
		send_token, token_pid_sel,
		send_data, data_pid_sel,

		// IDMA Interface
		tx_data_st, rd_next
		);

input		clk, rst;

// UTMI TX Interface
output	[7:0]	tx_data;
output		tx_valid;
output		tx_valid_last;
input		tx_ready;
output		tx_first;

// Protocol Engine Interface
input		send_token;
input	[1:0]	token_pid_sel;
input		send_data;
input	[1:0]	data_pid_sel;

// IDMA Interface
input	[7:0]	tx_data_st;
output		rd_next;

///////////////////////////////////////////////////////////////////
//
// Local Wires and Registers
//

parameter	[3:0]	// synopsys enum state
		IDLE   = 4'b0001,
		DATA   = 4'b0010,
		CRC1   = 4'b0100,
		CRC2   = 4'b1000;

reg	[3:0]	/* synopsys enum state */ state, next_state;
// synopsys state_vector state

reg		last;
reg		rd_next;

reg	[7:0]	token_pid, data_pid;	// PIDs from selectors
reg	[7:0]	tx_data_d;
reg	[7:0]	tx_data_data;
reg		dsel;
reg		tx_valid_d;
reg		send_token_r;
reg	[7:0]	tx_spec_data;
reg		crc_sel1, crc_sel2;
reg		tx_first_r;
reg		send_data_r;
wire		crc16_clr;
reg	[15:0]	crc16;
wire	[15:0]	crc16_next;
wire	[15:0]	crc16_rev;
wire		crc16_add;
reg		send_data_r2;

///////////////////////////////////////////////////////////////////
//
// Misc Logic
//

always @(posedge clk)
	if(!rst)	send_token_r <= #1 0;
	else
	if(send_token)	send_token_r <= #1 1;
	else
	if(tx_ready)	send_token_r <= #1 0;

// PID Select
always @(token_pid_sel)
	case(token_pid_sel)		// synopsys full_case parallel_case
	   0: token_pid = {  ~`USBF_T_PID_ACK,   `USBF_T_PID_ACK};
	   1: token_pid = { ~`USBF_T_PID_NACK,  `USBF_T_PID_NACK};
	   2: token_pid = {~`USBF_T_PID_STALL, `USBF_T_PID_STALL};
	   3: token_pid = { ~`USBF_T_PID_NYET,  `USBF_T_PID_NYET};
	endcase

always @(data_pid_sel)
	case(data_pid_sel)		// synopsys full_case parallel_case
	   0: data_pid = { ~`USBF_T_PID_DATA0, `USBF_T_PID_DATA0};
	   1: data_pid = { ~`USBF_T_PID_DATA1, `USBF_T_PID_DATA1};
	   2: data_pid = { ~`USBF_T_PID_DATA2, `USBF_T_PID_DATA2};
	   3: data_pid = { ~`USBF_T_PID_MDATA, `USBF_T_PID_MDATA};
	endcase

// Data path Muxes

always @(send_token or send_token_r or token_pid or tx_data_data)
	if(send_token | send_token_r)	tx_data_d = token_pid;
	else				tx_data_d = tx_data_data;

always @(dsel or tx_data_st or tx_spec_data)
	if(dsel)	tx_data_data = tx_spec_data;
	else		tx_data_data = tx_data_st;

always @(crc_sel1 or crc_sel2 or data_pid or crc16_rev)
	if(!crc_sel1 & !crc_sel2)	tx_spec_data = data_pid;
	else
	if(crc_sel1)			tx_spec_data = crc16_rev[15:8];	// CRC 1
	else				tx_spec_data = crc16_rev[7:0];	// CRC 2

assign tx_data = tx_data_d;

// TX Valid assignment
assign tx_valid_last = send_token | last;
assign tx_valid = tx_valid_d;

always @(posedge clk)
	tx_first_r <= #1 send_token | send_data;

assign tx_first = (send_token | send_data) & ! tx_first_r;

// CRC Logic
always @(posedge clk)
	send_data_r <= #1 send_data;

always @(posedge clk)
	send_data_r2 <= #1 send_data_r;

assign crc16_clr = send_data & !send_data_r;
assign crc16_add = (send_data_r & !send_data_r2) | (rd_next & !crc_sel1);

always @(posedge clk)
	if(crc16_clr)		crc16 <= #1 16'hffff;
	else
	if(crc16_add)		crc16 <= #1 crc16_next;


usbf_crc16 u1(
	.crc_in(	crc16		),
	.din(	{tx_data_st[0], tx_data_st[1],
		tx_data_st[2], tx_data_st[3],
		tx_data_st[4], tx_data_st[5],
		tx_data_st[6], tx_data_st[7]}	),
	.crc_out(	crc16_next		) );

assign crc16_rev[15] = ~crc16[8];
assign crc16_rev[14] = ~crc16[9];
assign crc16_rev[13] = ~crc16[10];
assign crc16_rev[12] = ~crc16[11];
assign crc16_rev[11] = ~crc16[12];
assign crc16_rev[10] = ~crc16[13];
assign crc16_rev[9]  = ~crc16[14];
assign crc16_rev[8]  = ~crc16[15];
assign crc16_rev[7]  = ~crc16[0];
assign crc16_rev[6]  = ~crc16[1];
assign crc16_rev[5]  = ~crc16[2];
assign crc16_rev[4]  = ~crc16[3];
assign crc16_rev[3]  = ~crc16[4];
assign crc16_rev[2]  = ~crc16[5];
assign crc16_rev[1]  = ~crc16[6];
assign crc16_rev[0]  = ~crc16[7];

///////////////////////////////////////////////////////////////////
//
// Transmit/Encode state machine
//

always @(posedge clk)
	if(!rst)	state <= #1 IDLE;
	else		state <= #1 next_state;

always @(state or send_data or tx_ready )
   begin
	next_state = state;	// Default don't change current state
	tx_valid_d = 0;
	dsel = 0;
	rd_next = 0;
	last = 0;
	crc_sel1 = 0;
	crc_sel2 = 0;
	case(state)		// synopsys full_case parallel_case
	   IDLE:
		   begin
			if(send_data)	// Send DATA packet
			   begin
				tx_valid_d = 1;
				next_state = DATA;
				dsel = 1;
			   end
		   end
	   DATA:
		   begin
			if(tx_ready)
				rd_next = 1;

			tx_valid_d = 1;
			if(!send_data & tx_ready)
			   begin
				dsel = 1;
				crc_sel1 = 1;
				next_state = CRC1;
			   end
		   end
	   CRC1:
		   begin
			dsel = 1;
			tx_valid_d = 1;
			if(tx_ready)
			   begin
				last = 1;
				crc_sel2 = 1;
				next_state = CRC2;
			   end
			else
			   begin
				tx_valid_d = 1;
				crc_sel1 = 1;
			   end

		   end
	   CRC2:
		   begin
			dsel = 1;
			crc_sel2 = 1;
			if(tx_ready)
			   begin
				next_state = IDLE;
			   end
			else
			   begin
				last =1;
			   end

		   end
	endcase
   end

endmodule

