#`include "defines.v"
module id1 (
    input clk,
    input rst_n,
//来自if_id
    input [31:0] instruction_i,
//通用的控制信号
    output reg reg_write,
    output reg mem_read,
    output reg mem_write,
//特殊的控制码和使能信号
    output reg alu_op,
    output reg[4:0] rs1_addr,
    output reg[4:0] rs2_addr,
    output reg[4:0] rd_addr,
    output reg alu_sel,
    output reg[31:0] imm,
    output reg branch,
    output reg jump
);
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            AlU_en = 1'b0;
            MUL_en = 1'b0;
            LDST_en = 1'b0;
            BR_en = 1'b0;
        end else begin
            case (instruction_i[6:0])
                LUI:begin
                    rd_addr<=instruction_i[11:7];
                    imm<={instruction_i[31:12],12;b0};                   
                end
                AUIPC:begin
                    rd_addr<=instruction_i[11:7];
                    imm<={instruction_i[31:12],12;b0};
                end
                JAL:begin
                    rd_addr<=instruction_i[11:7];
                    imm<={{12{instruction_i[31]}}, instruction_i[19:12], instruction_i[20], instruction_i[30:21], 1'b0};
                    jump<=1'b1;
                    alu_sel<=1'b0;
                end
                JALR:begin
                    rd_addr<=instruction_i[11:7];
                    imm<={{20{inst_i[31]}}, inst_i[31:20]};
                    jump<=1'b1;
                    alu_sel<=1'b1;
                end
            endcase
        end

    end


endmodule