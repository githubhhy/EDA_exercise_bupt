/*
接收来自物理层的令牌包和握手包，以保证传输的控制内容无误；
*/
module crc5_r (
    input clk,
    input rst_n,

    input           rx_lp_sop,
    input           rx_lp_eop,
    input           rx_lp_valid,
    input [7:0]     rx_lp_data,
    output          rx_lp_ready,



);
//状态机 状态参数
    parameter [3:0] IDLE = 4'b0001;
    parameter [3:0] ACTIVE = 4'b0010;
    parameter [3:0] TOKEN = 4'b0100;
    parameter [3:0] DATA = 4'b1000;
    
    reg [3:0] state, next_state;

//PID of a Packet
    reg[7:0] pid;
    reg pid_l_en_sm;    //PID Load enable from State Machine


//PID Type
    wire    pid_OUT, pid_IN, pid_SOF, pid_SETUP,
            pid_DATA0, pid_DATA1, pid_DATA2, pid_MDATA,
            pid_ACK, pid_NACK, pid_STALL, pid_NYET,
            pid_PRE, pid_ERR, pid_SPLIT, pid_PING,
            pid_cks_err;
    wire    pid_TOKEN;
    wire    pid_DATA;
    wire    pid_HANDSHAKE;

assign	pid_OUT   = pid[3:0] == `USBF_T_PID_OUT;
assign	pid_IN    = pid[3:0] == `USBF_T_PID_IN;
assign	pid_SOF   = pid[3:0] == `USBF_T_PID_SOF;
assign	pid_SETUP = pid[3:0] == `USBF_T_PID_SETUP;
assign	pid_DATA0 = pid[3:0] == `USBF_T_PID_DATA0;
assign	pid_DATA1 = pid[3:0] == `USBF_T_PID_DATA1;
assign	pid_DATA2 = pid[3:0] == `USBF_T_PID_DATA2;
assign	pid_MDATA = pid[3:0] == `USBF_T_PID_MDATA;
assign	pid_ACK   = pid[3:0] == `USBF_T_PID_ACK;
assign	pid_NACK  = pid[3:0] == `USBF_T_PID_NACK;
assign	pid_STALL = pid[3:0] == `USBF_T_PID_STALL;
assign	pid_NYET  = pid[3:0] == `USBF_T_PID_NYET;
assign	pid_PRE   = pid[3:0] == `USBF_T_PID_PRE;
assign	pid_ERR   = pid[3:0] == `USBF_T_PID_ERR;
assign	pid_SPLIT = pid[3:0] == `USBF_T_PID_SPLIT;
assign	pid_PING  = pid[3:0] == `USBF_T_PID_PING;
assign	pid_RES   = pid[3:0] == `USBF_T_PID_RES;

assign	pid_TOKEN = pid_OUT | pid_IN | pid_SOF | pid_SETUP | pid_PING | pid_PRE | pid_SPLIT;
assign	pid_DATA = pid_DATA0 | pid_DATA1 | pid_DATA2 | pid_MDATA;
assign  pid_HANDSHAKE = pid_ACK | pid_NACK | pid_STALL | pid_NYET | pid_ERR;

    always @(posedge clk) begin
        if (!rst_n) begin
            pid <= 8'hf0;
        end
        else begin
            pid <= rx_lp_data;
        end
    end


    always @(posedge clk) begin
        if (!rst_n) begin
            state <= #1 IDLE;
        end
        else begin
            state <= #1 next_state;
        end
    end

    always @(state) begin
        next_state = state;
        pid_l_en_sm = 0;
        case (state)
            IDLE:begin
                pid_l_en_sm = 1;
                if (rx_lp_valid) 
                    next_state = state;
            end 
            default: 
        endcase
    end

endmodule