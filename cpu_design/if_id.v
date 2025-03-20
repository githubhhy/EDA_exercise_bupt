module if_id (
    input clk,
    input rst_n,

    input[31:0] instruction_i,
    input[31:0] instruction_addr_i,

    output reg[31:0] instruction_o,
    output reg[31:0] instruction_addr_o
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            instruction_o <= 32'h00000013;
            instruction_addr_o <= 32'b0;
        end else begin
            instruction_o <= instruction_i;
            instruction_addr_o <= instruction_addr_i;
        end
    end

endmodule