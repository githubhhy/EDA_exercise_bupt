#`include "defines.v"
module id1 (
    input clk,
    input rst_n,
//来自if_id
    input [31:0] inst_i,
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
    wire[6:0] opcode = inst_i[6:0];
    wire[3:0] funct3 = inst_i[14:12];
    wire[6:0] funct7 = inst_i[31:25];
    wire[4:0] rs1 = inst_i[19:15]; 
    wire[4:0] rs2 = inst_i[24:20];
    wire[4:0] rd = inst_i[11:7];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin

        end else begin
            case (opcode)
                LUI:begin                                   //Lui
                    reg_write <= 1'b1;  
                    rd_addr<=rd;
                    imm<={inst_i[31:12],12;b0};                   
                end
                AUIPC:begin
                    rd_addr<=rd;
                    imm<={inst_i[31:12],12;b0};
                end
                JAL:begin
                    rd_addr<=rd;
                    imm<={{12{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
                    jump<=1'b1;
                    alu_sel<=1'b0;
                end
                JALR:begin
                    case (funct3)
                        3'b000:begin
                            rd_addr<=rd;
                            imm<={{20{inst_i[31]}}, inst_i[31:20]};
                            jump<=1'b1;
                            alu_sel<=1'b1;
                        end 
                        default:begin
                            
                        end 
                    endcase
                end
                BRANCH:begin
                    case (funct3)
                        3'b000,3'b001,3'b100,3'b101,3'b110,3'b111:begin
                            rs1_addr<=rs1;
                            rs2_addr<=rs2;
                            imm<={{20{inst_i[31]}},inst_i[7],inst_i[30:25],inst_i[11:8],1'b0};
                        end
                        default: begin
                            
                        end
                    endcase 
                end
                LOAD:begin
                    case (funct3)
                        3'b000,3'b001,3'b010,3'b100,3'b101: begin
                            rs1_addr<=rs1;
                            rd_addr<=rd;
                            imm<={{20{inst_i[31]}},inst_i[31:20]};
                        end
                        default: begin
                            
                        end
                    endcase
                end
                STORE:begin
                    case (funct3)
                        3'b000,3'b001,3'b010:begin
                            rs1_addr<= rs1;
                            rs2_addr<= rs2;
                            imm<={{20{inst_i[31]}},inst_i[31:25],inst_i[11:7]};
                        end 
                        default: begin
                            
                        end
                    endcase
                end
                ALUI:begin
                    case (funct3)
                        3'b000,3'b010,3'b011,3'b100,3'b110,3'b111: begin
                            rd_addr<=rd;
                            rs1_addr<=rs1;
                            imm<={{20{inst_i[31]}},inst_i[31:20]};
                        end
                        default:begin
                            
                        end 
                    endcase
                end
                ALUR:begin
                    
                end

            endcase
        end

    end


endmodule