module crc5_t (
    input   clk,
    input   rst_n,
    input [6:0] tx_addr,
    input [3:0] tx_endp,
    input [3:0] tx_pid,
    input   tx_to_ready,
    input  tx_valid,

    output [3:0] tx_con_pid,
    output  tx_con_pid_en,
    output  tx_ready,
    output [7:0] tx_to_dada,
    output  tx_to_eop,
    output  tx_to_sop,
    output  tx_to_valid,
);
    reg [6:0] adr_reg;
    wire [4:0] c_out;
    wire [4:0] crc_out;
    wire [10:0] d;
    reg [3:0] endp_reg;
    reg [3:0] pid_reg;
    reg [1:0] send_cnt;
    reg valid_reg;

endmodule