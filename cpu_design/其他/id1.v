#`include "defines.v"
module id1 (
    input clk,
    input rst_n,
//来自if_id
    input [31:0] instruction_i,

//各类型指令的使能信号
    output AlU_en,      //ALU使能    
    output MUL_en,      //乘法使能
    output LDST_en,     //Load_Store使能
    output BR_en,       //跳转使能
//各类指令所需的控制码信号
    output reg[4:0] rs1_addr,
    output reg[4:0] rs2_addr,
    output reg[4:0] rd_addr,
    output reg[2:0] funct3,
    output reg[6:0] funct7,
    output reg[31:0] imm
);
    rs1_addr = instruction_i[19:15];
    rs2_addr = instruction_i[24:20];
    rd_addr = instruction_i[11:7];
    funct3 = instruction_i[14:12];
    funct7 = instruction_i[31:25];

    ALU_en <= 1'b
    MUL_en <= 1'b
    LDST_en <= 1'b
    BR_en <= 1'b
    rs1_addr <= instruction_i[:];
    rs2_addr <= instruction_i[:];
    rd_addr <= instruction_i[:];
    funct3 <= instruction_i[:];
    funct7 <= instruction_i[:];
    imm <= instruction_i[:];
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            AlU_en = 1'b0;
            MUL_en = 1'b0;
            LDST_en = 1'b0;
            BR_en = 1'b0;
        end else begin
            case (instruction_i[6:0])
                LUI:begin
                    ALU_en <= 1'b
                    rd_addr <= instruction_i[:];
                    imm <= instruction_i[:];                    
                end
                AUIPC:begin
                    ALU_en <= 1'b
                    MUL_en <= 1'b
                    LDST_en <= 1'b
                    BR_en <= 1'b
                    rs1_addr <= instruction_i[:];
                    rs2_addr <= instruction_i[:];
                    rd_addr <= instruction_i[:];
                    funct3 <= instruction_i[:];
                    funct7 <= instruction_i[:];
                    imm <= instruction_i[:];                    
                end
                JAL:begin
                    ALU_en <= 1'b
                    MUL_en <= 1'b
                    LDST_en <= 1'b
                    BR_en <= 1'b
                    rs1_addr <= instruction_i[:];
                    rs2_addr <= instruction_i[:];
                    rd_addr <= instruction_i[:];
                    funct3 <= instruction_i[:];
                    funct7 <= instruction_i[:];
                    imm <= instruction_i[:];                    
                end
                JALR:begin
                    ALU_en <= 1'b
                    MUL_en <= 1'b
                    LDST_en <= 1'b
                    BR_en <= 1'b
                    rs1_addr <= instruction_i[:];
                    rs2_addr <= instruction_i[:];
                    rd_addr <= instruction_i[:];
                    funct3 <= instruction_i[:];
                    funct7 <= instruction_i[:];
                    imm <= instruction_i[:];                    
                end
                BRANCH:begin
                    ALU_en <= 1'b
                    MUL_en <= 1'b
                    LDST_en <= 1'b
                    BR_en <= 1'b
                    rs1_addr <= instruction_i[:];
                    rs2_addr <= instruction_i[:];
                    rd_addr <= instruction_i[:];
                    funct3 <= instruction_i[:];
                    funct7 <= instruction_i[:];
                    imm <= instruction_i[:];                    
                end
                LOAD:begin
                    ALU_en <= 1'b
                    MUL_en <= 1'b
                    LDST_en <= 1'b
                    BR_en <= 1'b
                    rs1_addr <= instruction_i[:];
                    rs2_addr <= instruction_i[:];
                    rd_addr <= instruction_i[:];
                    funct3 <= instruction_i[:];
                    funct7 <= instruction_i[:];
                    imm <= instruction_i[:];                    
                end
                STORE:begin
                    ALU_en <= 1'b
                    MUL_en <= 1'b
                    LDST_en <= 1'b
                    BR_en <= 1'b
                    rs1_addr <= instruction_i[:];
                    rs2_addr <= instruction_i[:];
                    rd_addr <= instruction_i[:];
                    funct3 <= instruction_i[:];
                    funct7 <= instruction_i[:];
                    imm <= instruction_i[:];                    
                end
                ALUI:begin
                    ALU_en <= 1'b1;
                    MUL_en <= 1'b0;
                    LDST_en <= 1'b0;
                    BR_en <= 1'b0;
                    rs1_addr <= instruction_i[:];
                    rs2_addr <= instruction_i[:];
                    rd_addr <= instruction_i[:];
                    funct3 <= instruction_i[:];
                    funct7 <= instruction_i[:];
                    imm <= instruction_i[:];                    
                end
                ALUR:begin
                    ALU_en <= 1'b1;
                    MUL_en <= 1'b0;
                    LDST_en <= 1'b0;
                    BR_en <= 1'b0;
                    rs1_addr <= instruction_i[19:15];
                    rs2_addr <= instruction_i[24:20];
                    rd_addr <= instruction_i[11:7];
                    funct3 <= instruction_i[14:12];
                    funct7 <= instruction_i[31:25];
                    imm <= 32'b0;
                end
                FENCE:begin
                    ALU_en <= 1'b
                    MUL_en <= 1'b
                    LDST_en <= 1'b
                    BR_en <= 1'b
                    rs1_addr <= instruction_i[:];
                    rs2_addr <= instruction_i[:];
                    rd_addr <= instruction_i[:];
                    funct3 <= instruction_i[:];
                    funct7 <= instruction_i[:];
                    imm <= instruction_i[:];                    
                end
                SYSTEM:begin
                    ALU_en <= 1'b
                    MUL_en <= 1'b
                    LDST_en <= 1'b
                    BR_en <= 1'b
                    rs1_addr <= instruction_i[:];
                    rs2_addr <= instruction_i[:];
                    rd_addr <= instruction_i[:];
                    funct3 <= instruction_i[:];
                    funct7 <= instruction_i[:];
                    imm <= instruction_i[:];                    
                end
                default:begin
                    
                end
            endcase
        end

    end


endmodule