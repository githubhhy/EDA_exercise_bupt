module link_control (
    input   clk,
    input   rst_n,
    input [3:0] rx_pid,
    input   rx_pid_en,
    input   rx_sop_en,
    input [5:0] delay_threshole,
    input   ms,
    input [15:0] time_threshold,
    input [3:0]  tx_con_pid,
    input   tx_con_pid_en,
    input   tx_lp_eop_en

    output reg rx_handshake_on,
    output reg rx_data_on,
    output reg  d_oe,
    output reg time_out,
    output reg tx_data_on

);
    reg rx_sop_en_redg;
    reg [5:0] delay_ent;
    wire deley_done;
    reg delay_on;
    reg master_d_oe;
    reg master_finish_sending_rt;
    reg [1:0] master_finish_sending_wr;
    wire master_send_rt;
    wire master_send_wt;
    wire ms_receive_hs;
    reg slave_d_oe;
    reg slave_has_received_rt;
    wire slave_receive_rt;
    wire slave_receive_wt;
    reg [15:0] timer;







    
endmodule