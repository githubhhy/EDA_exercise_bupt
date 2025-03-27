#`include "defines.v"
module id1 (
//from if_id
    input [31:0] inst_i,
//from regs
    input [31:0]    reg1_rdata_i,   //reg1读取到的值
    input [31:0]    reg2_rdata_i,   //reg2读取到的值
    
//to ALU
    output [3:0]    alu_op,         //ALU的运算
    output [31:0]   reg1_data_o,    //reg1读取到的值，直接输出
    output [31:0]   reg2_data_o,    //reg2读取到的值，直接输出
    output [31:0]   imm_o,
//
    output          branch,         //分支
    output          jump,           //跳转
//to regs
    output          reg_wen,            //写寄存器使能
    output [4:0]    reg_waddr,          //目标寄存器的地址
    output [4:0]    reg1_raddr,         //源寄存器1的地址
    output [4:0]    reg2_raddr,         //源寄存器2的地址
//to memory
    output          mem_read,           //读memory    
    output          mem_write,          //写memory
//to imm_gen
    output [2:0]    imm_gen_op,         //立即数生成操作的控制
    output [1:0]    alu_src_sel     //rs2 or imm

);
    wire[6:0] opcode = inst_i[ 6: 0];
    wire[3:0] funct3 = inst_i[14:12];
    wire[6:0] funct7 = inst_i[31:25];
    wire[4:0] rs1    = inst_i[19:15]; 
    wire[4:0] rs2    = inst_i[24:20];
    wire[4:0] rd     = inst_i[11: 7];

    assign reg1_data_o  =   reg1_rdata_i;
    assign reg2_data_o  =   reg2_rdata_i;

    always @(*) begin
        branch          =1'b0;
        jump            =1'b0;
        reg_wen         =1'b0;
        reg_waddr       =5'b0;
        reg1_raddr      =5'b0;
        reg2_raddr      =5'b0;
        imm_gen_op      =3'b0;
        imm_o           =31'b0;
        alu_op          =`ALU_OP_ADD;
        alu_src_sel     =2'b00;
        mem_read        =1'b0;
        mem_write       =1'b0; 
        case (opcode)
            `ALUR:begin
                reg_wen     = 1'b1;    
                reg_waddr   = rd;
                reg1_raddr  = rs1;
                reg2_raddr  = rs2;
                case (funct3)
                    `FUNCT3_ADD,`FUNCT3_SUB:      //ADD,SUB
                        alu_op = (funct7==7'b0000000) ? `ALU_OP_ADD : `ALU_OP_SUB;
                    `FUNCT3_XOR:
                        alu_op = `ALU_OP_XOR;
                    `FUNCT3_OR:
                        alu_op = `ALU_OP_OR;
                    `FUNCT3_AND:
                        alu_op = `ALU_OP_AND
                    `FUNCT3_SLL:
                        alu_op = `ALU_OP_SLL
                    `FUNCT3_SRL,`FUNCT3_SRA:
                        alu_op = (funct7==7'b0000000) ? `ALU_OP_SRL : `ALU_OP_SRA;
                    `FUNCT3_SLT:
                        alu_op = `ALU_OP_SLT;
                    `FUNCT3_SLTU:
                        alu_op = `ALU_OP_SLTU;
                    default:
                        alu_op = `ALU_OP_ADD;  
                endcase  
            end
            `ALUI:begin
                reg_wen     = 1'b1;
                alu_src_sel = 2'b01;     
                reg_waddr   = rd;
                reg1_raddr  = rs1;
                case (funct3)
                    `FUNCT3_ADDI:
                        alu_op = `ALU_OP_ADD;
                    `FUNCT3_XORI:
                        alu_op = `ALU_OP_XOR;
                    `FUNCT3_ORI:
                        alu_op = `ALU_OP_OR;
                    `FUNCT3_ANDI:
                        alu_op = `ALU_OP_AND;
                    `FUNCT3_SLLI:
                        alu_op = `ALU_OP_SLL;
                    `FUNCT3_SRLI:
                        alu_op = `ALU_OP_SRL;
                    `FUNCT3_SRAI:
                        alu_op = `ALU_OP_SRA;
                    `FUNCT3_SLTI:
                        alu_op = `ALU_OP_SLT;
                    `FUNCT3_SLTIU:
                        alu_op = `ALU_OP_SLTU;
                    default: alu_op = `ALU_OP_ADD;  
                endcase
            end
            `LOAD:begin
                reg_wen     = 1'b1;
                alu_src_sel = 2'b01;     
                reg_waddr   = rd;
                reg1_raddr  = rs1;
                mem_read    = 1'b1;
                case (funct3)
                    `FUNCT3_LB,`FUNCT3_LH,`FUNCT3_LW,`FUNCT3_LBU,`FUNCT3_LHU: 
                        alu_op      = `ALU_OP_ADD;
                    default: alu_op = `ALU_OP_ADD;  
                endcase
            end
            `STORE:begin
                alu_src_sel = 2'b01; 
                reg1_raddr  = rs1;
                reg2_raddr  = rs2;
                imm_gen_op  =3'b001;
                mem_write   = 1'b1;
                case (funct3)
                    `FUNCT3_SB,`FUNCT3_SH,`FUNCT3_SW: 
                        alu_op      = `ALU_OP_ADD;
                    default: alu_op      = `ALU_OP_ADD;
                endcase
            end
            `BRANCH:begin
                branch          =1'b1;
                reg1_raddr      = rs1;
                reg2_raddr      = rs2;
                imm_gen_op      =3'b010;
                case (funct3)
                    `FUNCT3_BEQ:begin
                        alu_op  = `ALU_OP_EQ;
                    end
                    `FUNCT3_BNE:begin
                        alu_op  = `ALU_OP_NEQ;
                    end
                    `FUNCT3_BLT:begin
                        
                    end
                    default: 
                endcase
            end
            default: 
        endcase
    end


endmodule