/////////////////////////////////////////////////////////////////////
////                                                             ////
////  UTMI Line Status & Speed Negotiation block                 ////
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
//  $Id: usbf_utmi_ls.v,v 1.2 2001/08/10 08:48:33 rudi Exp $
//
//  $Date: 2001/08/10 08:48:33 $
//  $Revision: 1.2 $
//  $Author: rudi $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: usbf_utmi_ls.v,v $
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
//               Revision 1.2  2001/03/31 13:00:52  rudi
//
//               - Added Core configuration
//               - Added handling of OUT packets less than MAX_PL_SZ in DMA mode
//               - Modified WISHBONE interface and sync logic
//               - Moved SSRAM outside the core (added interface)
//               - Many small bug fixes ...
//
//               Revision 1.1  2001/03/07 09:08:13  rudi
//
//               Added USB control signaling (Line Status) block. Fixed some minor
//               typos, added resume bit and signal.
//
//
//


`include "usbf_defines.v"

module usbf_utmi_ls( clk, rst,

		resume_req,

		// UTMI Interface
		rx_active, tx_ready, drive_k,
		XcvSelect, TermSel, SuspendM, LineState, OpMode,
		usb_vbus,

		// Misc Interfaces
		mode_hs, usb_reset, usb_suspend, usb_attached
		);

input		clk;
input		rst;

input		resume_req;
input		rx_active, tx_ready;

output		drive_k;
output		XcvSelect;
output		TermSel;
output		SuspendM;
input	[1:0]	LineState;
output	[1:0]	OpMode;
input		usb_vbus;

output		mode_hs;	// High Speed Mode
output		usb_reset;	// USB Reset
output		usb_suspend;	// USB Suspend
output		usb_attached;	// Attached to USB

///////////////////////////////////////////////////////////////////
//
// Parameters
//
parameter	[14:0]	// synopsys enum state
	POR		= 15'b000_0000_0000_0001,
	NORMAL		= 15'b000_0000_0000_0010,
	RES_SUSP	= 15'b000_0000_0000_0100,
	SUSPEND		= 15'b000_0000_0000_1000,
	RESUME		= 15'b000_0000_0001_0000,
	RESUME_REQ	= 15'b000_0000_0010_0000,
	RESUME_WAIT	= 15'b000_0000_0100_0000,
	RESUME_SIG	= 15'b000_0000_1000_0000,
	ATTACH		= 15'b000_0001_0000_0000,
	RESET		= 15'b000_0010_0000_0000,
	SPEED_NEG	= 15'b000_0100_0000_0000,
	SPEED_NEG_K	= 15'b000_1000_0000_0000,
	SPEED_NEG_J	= 15'b001_0000_0000_0000,
	SPEED_NEG_HS	= 15'b010_0000_0000_0000,
	SPEED_NEG_FS	= 15'b100_0000_0000_0000;

///////////////////////////////////////////////////////////////////
//
// Local Wires and Registers
//

reg	[14:0]	/* synopsys enum state */ state, next_state;
// synopsys state_vector state

reg	[1:0]	line_state_r;

reg		mode_hs, mode_set_hs, mode_set_fs;
reg		usb_suspend, suspend_set, suspend_clr;
reg		usb_attached, attached_set, attached_clr;
reg		TermSel, fs_term_on, fs_term_off;
reg		XcvSelect, xcv_set_hs, xcv_set_fs;
reg	[1:0]	OpMode;
reg		bit_stuff_on, bit_stuff_off;
reg		usb_reset, usb_reset_d;

wire		ls_se0, ls_j, ls_k, ls_se1;
reg		ls_k_r, ls_j_r, ls_se0_r;
reg		ls_idle_r, ls_idle_r1;
wire		ls_idle;
reg		idle_long;
wire		idle_long_set, idle_long_clr;
wire		k_long, j_long, se0_long;

reg		drive_k, drive_k_d;

reg	[3:0]	ps_cnt;
reg		ps_cnt_clr;
reg		idle_cnt_clr;
reg		idle_cnt1_clr;
reg	[7:0]	idle_cnt1, idle_cnt1_next;
reg	[5:0]	idle_cnt2;
reg		T1_gt_2_5_uS, T1_gt_100_uS, T1_st_3_0_mS, T1_gt_3_0_mS;
reg		T1_gt_3_125_mS, T1_gt_5_0_mS;
reg	[7:0]	me_ps;
reg		me_cnt_clr;
reg		me_ps_2_5_us;
reg	[7:0]	me_ps2;
reg		me_ps2_0_5_ms;
reg	[7:0]	me_cnt;
reg		me_cnt_100_ms;
reg		T2_gt_100_uS, T2_wakeup, T2_gt_1_0_mS, T2_gt_1_2_mS;

reg	[2:0]	chirp_cnt;
reg		chirp_cnt_clr, chirp_cnt_inc;
reg		chirp_cnt_is_6;

wire		resume_req_sr;

///////////////////////////////////////////////////////////////////
//
// Misc Logic
//

always @(posedge clk)
	drive_k <= #1 drive_k_d;

assign SuspendM = (usb_suspend & !resume_req_sr) | (LineState == 2'b10);

assign resume_req_sr = (!rst | usb_suspend) ? 0 : resume_req ? 1 : resume_req_sr;

// ---------------------------------------------------------
// USB State/Operation Mode JK Flops
always @(posedge clk)
	if(mode_set_fs)		mode_hs <= #1 0;
	else
	if(mode_set_hs)		mode_hs <= #1 1;

always @(posedge clk)
	if(suspend_clr)		usb_suspend <= #1 0;
	else
	if(suspend_set)		usb_suspend <= #1 1;

always @(posedge clk)
	if(attached_clr)	usb_attached <= #1 0;
	else
	if(attached_set)	usb_attached <= #1 1;

always @(posedge clk)
	if(fs_term_off)		TermSel <= #1 0;
	else
	if(fs_term_on)		TermSel <= #1 1;

always @(posedge clk)
	if(xcv_set_fs)		XcvSelect <= #1 1;
	else
	if(xcv_set_hs)		XcvSelect <= #1 0;

always @(posedge clk)
	if(bit_stuff_off)	OpMode <= #1 2'b10;
	else
	if(bit_stuff_on)	OpMode <= #1 2'b00;

always @(posedge clk)
	usb_reset <= #1 usb_reset_d;

// ---------------------------------------------------------
// Line State Detector

always @(posedge clk)
	line_state_r <= #1 LineState;

assign ls_se0 = (line_state_r == 2'b00);
assign ls_j   = (line_state_r == 2'b01);
assign ls_k   = (line_state_r == 2'b10);
assign ls_se1 = (line_state_r == 2'b11);

assign ls_idle = mode_hs ? ls_se0 : ls_j;

// Idle Detection
// Idle Has to persist for at least two cycles in a roe in the
// same state to recognized
always @(posedge clk)
	ls_idle_r <= #1 ls_idle;

assign idle_long_set = ls_idle & ls_idle_r;
assign idle_long_clr = !ls_idle & !ls_idle_r;

always @(posedge clk)
	if(!rst)		idle_long <= #1 0;
	else
	if(idle_long_clr)	idle_long <= #1 0;
	else
	if(idle_long_set)	idle_long <= #1 1;

// Detect Signals for two cycles ina row before making a transaction ...
always @(posedge clk)
	ls_k_r <= #1 ls_k;

always @(posedge clk)
	ls_j_r <= #1 ls_j;

always @(posedge clk)
	ls_se0_r <= #1 ls_se0;

assign k_long = ls_k & ls_k_r;
assign j_long = ls_j & ls_j_r;
assign se0_long = ls_se0 & ls_se0_r;

///////////////////////////////////////////////////////////////////
//
// Counters
//

// ---------------------------------------------------------
// idle Counter

// Pre-Scaler
// Generates a 0.25 uS Count Enable (ps_cnt_clr)
always @(posedge clk)
	if(!idle_long | idle_cnt_clr | ps_cnt_clr)	ps_cnt <= #1 0;
	else						ps_cnt <= #1 ps_cnt + 1;

always @(posedge clk)		// Clear the pre-scaler in 250 nS intervals
	ps_cnt_clr <= #1 (ps_cnt == `USBF_T1_PS_250_NS);

// Count uS
always @(posedge clk)
	if(!idle_long | idle_cnt1_clr | idle_cnt_clr)	idle_cnt1 <= #1 0;
	else
	if(!T1_gt_3_125_mS & ps_cnt_clr)		idle_cnt1 <= #1 idle_cnt1_next;

always @(posedge clk)
	idle_cnt1_next <= #1 idle_cnt1 + 1;

always @(posedge clk)		// Clear the uS counter every 62.5 uS
	idle_cnt1_clr <= #1 idle_cnt1 == `USBF_T1_C_62_5_US;

// Count mS
always @(posedge clk)
	if(!idle_long | idle_cnt_clr)		idle_cnt2 <= #1 0;
	else
	if(!T1_gt_5_0_mS & idle_cnt1_clr)	idle_cnt2 <= #1 idle_cnt2 + 1;

always @(posedge clk)	// Greater Than 2.5uS (Actual Time will be T0+2.75uS)
	T1_gt_2_5_uS <= #1 !idle_cnt_clr & (idle_cnt1 > `USBF_T1_C_2_5_US);

always @(posedge clk)	// Greater Than 100uS (Actual Time will be T0+187.5uS)
	T1_gt_100_uS <= #1 !idle_cnt_clr & (`USBF_T1_C_100_US < idle_cnt2);

always @(posedge clk)	// Smaller Than 3 mS (Actual Time will be 0-2.9375mS)
	T1_st_3_0_mS <= #1 !idle_cnt_clr & (idle_cnt1 < `USBF_T1_C_3_0_MS);

always @(posedge clk)	// Greater Than 3 mS (Actual Time will be T0+3.0625mS)
	T1_gt_3_0_mS <= #1 !idle_cnt_clr & (idle_cnt1 > `USBF_T1_C_3_0_MS);

always @(posedge clk)	// Greater Than 3.125 mS (Actual Time will be T0+3.1875uS)
	T1_gt_3_125_mS <= #1 !idle_cnt_clr & (idle_cnt1 > `USBF_T1_C_3_125_MS);

always @(posedge clk)	// Greater Than 3.125 mS (Actual Time will be T0+3.1875uS)
	T1_gt_5_0_mS <= #1 !idle_cnt_clr & (idle_cnt1 > `USBF_T1_C_5_MS);

// ---------------------------------------------------------
// Misc Events Counter

// Pre-scaler - 2.5uS
always @(posedge clk)
	if(me_cnt_clr | me_ps_2_5_us)		me_ps <= #1 0;
	else					me_ps <= #1 me_ps + 1;

always @(posedge clk)	// Generate a pulse every 2.5 uS
	me_ps_2_5_us <= #1 (me_ps == `USBF_T2_C_2_5_US);

// Second Pre-scaler - 0.5mS
always @(posedge clk)
	if(me_cnt_clr | me_ps2_0_5_ms )	me_ps2 <= #1 0;
	else
	if(me_ps_2_5_us)			me_ps2 <= #1 me_ps2 + 1;

always @(posedge clk)	// Generate a pulse every 0.5 mS
	me_ps2_0_5_ms <= #1 (me_ps2 == `USBF_T2_C_0_5_MS) & !me_ps2_0_5_ms;

// final misc Counter
always @(posedge clk)
	if(me_cnt_clr)				me_cnt <= #1 0;
	else
	if(!me_cnt_100_ms & me_ps2_0_5_ms)	me_cnt <= #1 me_cnt + 1;

always @(posedge clk)	// Indicate when 100uS have passed
	T2_gt_100_uS <= #1 !me_cnt_clr & (me_ps2 > `USBF_T2_C_100_US);	// Actual Time: 102.5 uS

always @(posedge clk)	// Indicate when wakeup period has passed
	T2_wakeup <= #1 !me_cnt_clr & (me_cnt > `USBF_T2_C_WAKEUP);

always @(posedge clk)	// Indicate when 1 mS has passed
	T2_gt_1_0_mS <= #1 !me_cnt_clr & (me_cnt > `USBF_T2_C_1_0_MS);	// Actual Time: 1.5 mS

always @(posedge clk)	// Indicate when 1.2 mS has passed
	T2_gt_1_2_mS <= #1 !me_cnt_clr & (me_cnt > `USBF_T2_C_1_2_MS);	// Actual Time: 1.5 mS

always @(posedge clk)	// Generate a pulse after 100 mS
	me_cnt_100_ms <= #1 !me_cnt_clr & (me_cnt == `USBF_T2_C_100_MS);	// Actual Time: 100 mS

// ---------------------------------------------------------
// Chirp Counter

always @(posedge clk)
	if(chirp_cnt_clr)	chirp_cnt <= #1 0;
	else
	if(chirp_cnt_inc)	chirp_cnt <= #1 chirp_cnt + 1;

always @(posedge clk)
	chirp_cnt_is_6 <= #1 (chirp_cnt == 6);

///////////////////////////////////////////////////////////////////
//
// Main State Machine
//

always @(posedge clk)
	if(!rst | !usb_vbus)	state <= #1 POR;
	else			state <= #1 next_state;

always @(state or mode_hs or idle_long or resume_req_sr or me_cnt_100_ms or
	j_long or k_long or se0_long or ls_se0 or
	T1_gt_2_5_uS or T1_gt_100_uS or T1_st_3_0_mS or T1_gt_3_0_mS or T1_gt_5_0_mS or 
	T2_gt_100_uS or T2_wakeup or T2_gt_1_0_mS or T2_gt_1_2_mS or
	chirp_cnt_is_6)
   begin
	next_state = state;	// Default don't change state

	mode_set_hs = 0;
	mode_set_fs = 0;
	suspend_set = 0;
	suspend_clr = 0;
	attached_set = 0;
	attached_clr = 0;
	usb_reset_d = 0;

	fs_term_on = 0;
	fs_term_off = 0;
	xcv_set_hs = 0;
	xcv_set_fs = 0;
	bit_stuff_on  = 0;
	bit_stuff_off = 0;

	idle_cnt_clr = 0;
	me_cnt_clr = 0;
	drive_k_d = 0;
	chirp_cnt_clr = 0;
	chirp_cnt_inc = 0;

	case(state)	// synopsys full_case parallel_case
	   POR:		// Power On/Reset
	     begin
		me_cnt_clr = 1;
		xcv_set_fs = 1;
		fs_term_on = 1;
		mode_set_fs = 1;
		attached_clr = 1;
		bit_stuff_on  = 1;
		suspend_clr = 1;
		next_state = ATTACH;
	     end

	   NORMAL:	// Normal Operation
	     begin
		if(!mode_hs & T1_gt_2_5_uS & T1_st_3_0_mS & !idle_long)
		   begin
			me_cnt_clr = 1;
			next_state = RESET;
		   end
		else
		if(!mode_hs & T1_gt_3_0_mS)			
		   begin
			idle_cnt_clr = 1;
			suspend_set = 1;
			next_state = SUSPEND;
		   end
		else
		if(mode_hs & T1_gt_3_0_mS)
		   begin			// Switch to FS mode, and decide
						// if it's a RESET or SUSPEND
			me_cnt_clr = 1;
			xcv_set_fs = 1;
			fs_term_on = 1;
			next_state = RES_SUSP;
		   end
	     end

	   RES_SUSP:	// Decide if it's a Reset or Suspend Signaling
	     begin	// We are now in FS mode, wait 100uS first
		if(T2_gt_100_uS & se0_long)
		   begin
			me_cnt_clr = 1;
			next_state = RESET;
		   end
		else
		if(T2_gt_100_uS & j_long)
		   begin
			idle_cnt_clr = 1;
			suspend_set = 1;
			next_state = SUSPEND;
		   end
	     end

	   SUSPEND:	// In Suspend
	     begin
		if(T1_gt_2_5_uS & se0_long)
		   begin
			suspend_clr = 1;
			me_cnt_clr = 1;
			next_state = RESET;
		   end
		else
		if(k_long)			// Start Resuming
		   begin
			next_state = RESUME;
		   end
		else
		if(T1_gt_5_0_mS & resume_req_sr)
			next_state = RESUME_REQ;
	     end

	   RESUME:
	     begin
		suspend_clr = 1;
		if(ls_se0)
		   begin
			if(mode_hs)
			   begin	// Switch Back to HS mode
				xcv_set_hs = 1;
				fs_term_off = 1;
			   end
			me_cnt_clr = 1;
			next_state = RESUME_WAIT;
		   end
	     end

	   RESUME_WAIT:
	     begin
		if(T2_gt_100_uS)	next_state = NORMAL;
	     end

	   RESUME_REQ:	// Function Resume Request
	     begin
		suspend_clr = 1;
		// Wait for internal wake up
		if(T2_wakeup)
		   begin
			me_cnt_clr = 1;
			next_state = RESUME_SIG;
		   end
	     end

	   RESUME_SIG:	// Signal resume
	     begin
		// Drive Resume ('K') for 1-15 mS
		drive_k_d = 1;
		// Stop driving after 1.5 mS
		if(T2_gt_1_0_mS)		next_state = RESUME;
	     end

	   ATTACH:	// Attach To USB Detected
	     begin
		idle_cnt_clr = 1;
		if(me_cnt_100_ms & j_long)
		   begin
			attached_set = 1;
			next_state = NORMAL;
		   end
		if(me_cnt_100_ms & se0_long)
		   begin
			attached_set = 1;
			me_cnt_clr = 1;
			next_state = RESET;
		   end
	     end

	   RESET:	// In Reset
	     begin
		usb_reset_d = 1;	// Assert Internal USB Reset
		xcv_set_hs = 1;		// Switch xcvr to HS mode
		fs_term_on = 1;		// Turn FS termination On
		mode_set_fs = 1;	// Change mode to FS
		// Get out of reset after 1.5 mS
		if(T2_gt_1_0_mS)
		   begin
			me_cnt_clr = 1;
			next_state = SPEED_NEG;
		   end
	     end

	   SPEED_NEG:	// Speed Negotiation
	     begin
		drive_k_d = 1;
		chirp_cnt_clr = 1;
		// Start looking for 'K' after 1.5 mS
		if(T2_gt_1_2_mS)	next_state = SPEED_NEG_K;
	     end

	   SPEED_NEG_K:
	     begin
		if(chirp_cnt_is_6)	next_state = SPEED_NEG_HS;
		else
		   begin
			if(k_long)
			   begin
				chirp_cnt_inc = 1;
				next_state = SPEED_NEG_J;
			   end
			if(se0_long)
				next_state = SPEED_NEG_FS;
		   end
	     end

	   SPEED_NEG_J:
	     begin
		if(chirp_cnt_is_6)	next_state = SPEED_NEG_HS;
		else
		   begin
			if(j_long)
			   begin
				chirp_cnt_inc = 1;
				next_state = SPEED_NEG_K;
			   end
			if(se0_long)
				next_state = SPEED_NEG_FS;
		   end
	     end

	   SPEED_NEG_HS:
	     begin
		xcv_set_hs = 1;		// Switch xcvr to HS mode
		fs_term_off = 1;	// Turn FS termination Off
		mode_set_hs = 1;	// Change mode to FS
		if(se0_long)		next_state = NORMAL;
	     end

	   SPEED_NEG_FS:
	     begin
		xcv_set_fs = 1;		// Switch xcvr to FS mode
		fs_term_on = 1;		// Turn FS termination On
		mode_set_fs = 1;	// Change mode to FS
		next_state = NORMAL;
	     end

	endcase
   end

endmodule

