/////////////////////////////////////////////////////////////////////
////                                                             ////
////  UTMI Interface                                             ////
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
//  $Id: usbf_utmi_if.v,v 1.1 2001/08/03 05:30:09 rudi Exp $
//
//  $Date: 2001/08/03 05:30:09 $
//  $Revision: 1.1 $
//  $Author: rudi $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: usbf_utmi_if.v,v $
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
//               Revision 1.0  2001/03/07 09:17:12  rudi
//
//
//               Changed all revisions to revision 1.0. This is because OpenCores CVS
//               interface could not handle the original '0.1' revision ....
//
//               Revision 0.2  2001/03/07 09:08:13  rudi
//
//               Added USB control signaling (Line Status) block. Fixed some minor
//               typos, added resume bit and signal.
//
//               Revision 0.1.0.1  2001/02/28 08:11:45  rudi
//               Initial Release
//
//

`include "usbf_defines.v"

module usbf_utmi_if( // UTMI Interface (EXTERNAL)
		phy_clk, rst,
		DataOut, TxValid, TxReady,
		RxValid, RxActive, RxError, DataIn,
		XcvSelect, TermSel, SuspendM, LineState,
		OpMode, usb_vbus,

		// Internal Interface
		rx_data, rx_valid, rx_active, rx_err,
		tx_data, tx_valid, tx_valid_last, tx_ready,
		tx_first,

		// Misc Interfaces
		mode_hs, usb_reset, usb_suspend, usb_attached,
		resume_req
		);

input		phy_clk;
input		rst;

output	[7:0]	DataOut;
output		TxValid;
input		TxReady;

input	[7:0]	DataIn;
input		RxValid;
input		RxActive;
input		RxError;

output		XcvSelect;
output		TermSel;
output		SuspendM;
input	[1:0]	LineState;
output	[1:0]	OpMode;
input		usb_vbus;

output	[7:0]	rx_data;
output		rx_valid, rx_active, rx_err;
input	[7:0]	tx_data;
input		tx_valid;
input		tx_valid_last;
output		tx_ready;
input		tx_first;

output		mode_hs;	// High Speed Mode
output		usb_reset;	// USB Reset
output		usb_suspend;	// USB Suspend
output		usb_attached;	// Attached to USB
input		resume_req;

///////////////////////////////////////////////////////////////////
//
// Local Wires and Registers
//
reg	[7:0]	rx_data;
reg		rx_valid, rx_active, rx_err;
reg	[7:0]	DataOut;
reg		tx_ready;
reg		TxValid;
wire		drive_k;

///////////////////////////////////////////////////////////////////
//
// Misc Logic
//


///////////////////////////////////////////////////////////////////
//
// RX Interface Input registers
//

always @(posedge phy_clk)
	if(!rst)	rx_valid <= #1 0;
	else		rx_valid <= #1 RxValid;

always @(posedge phy_clk)
	if(!rst)	rx_active <= #1 0;
	else		rx_active <= #1 RxActive;

always @(posedge phy_clk)
	if(!rst)	rx_err <= #1 0;
	else		rx_err <= #1 RxError;

always @(posedge phy_clk)
		rx_data <= #1 DataIn;

///////////////////////////////////////////////////////////////////
//
// TX Interface Output/Input registers
//
wire	tx_valid_sr;

assign	tx_valid_sr = (!rst) ? 0 : tx_valid_last ? 1 : TxReady ? 0 : tx_valid_sr;

always @(posedge phy_clk)
	if(TxReady | tx_first)	DataOut <= #1 tx_data;
	else
	if(drive_k)		DataOut <= #1 8'hff;

always @(posedge phy_clk)
	tx_ready <= #1 TxReady;

always @(posedge phy_clk)
	TxValid <= #1 tx_valid | tx_valid_sr | drive_k;

///////////////////////////////////////////////////////////////////
//
// Line Status Signaling & Speed Negotiation Block
//

usbf_utmi_ls	u0(.clk(	phy_clk		),
		.rst(		rst		),
		.resume_req(	resume_req	),
		.rx_active(	rx_active	),
		.tx_ready(	tx_ready	),
		.drive_k(	drive_k		),
		.XcvSelect(	XcvSelect	),
		.TermSel(	TermSel		),
		.SuspendM(	SuspendM	),
		.LineState(	LineState	),
		.OpMode(	OpMode		),
		.usb_vbus(	usb_vbus	),
		.mode_hs(	mode_hs		),
		.usb_reset(	usb_reset	),
		.usb_suspend(	usb_suspend	),
		.usb_attached(	usb_attached	)
		);

endmodule

