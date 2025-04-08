module crc16_r (
    input   clk,
    input   rst_n,
    input   rx_sop,
    input   rx_eop,
    input   rx_valid
    input [7:0] rx_data,
    input   rx_data_on,
    input   rx_lt_ready,

    output  rx_ready,
    output  rx_sop_en,
    output [7:0] rx_lt_data,
    output  rx_lt_eop,
    output  rx_lt_sop,
    output  rx_lt_eop_en,
    output  rx_lt_valid
);
    reg [7:0] data_reg;
    reg sop_reg;
    reg eop_reg;
    reg valid_reg;
    wire packet_is_data;
    wire tran_buf;
    reg tran_en;


endmodule