`include "defines.v"
module id (
//from if_id
    input [31:0] inst_i,
//from regs
    input [31:0]    reg1_rdata_i,   //reg1读取到的值
    input [31:0]    reg2_rdata_i,   //reg2读取到的值
    
//to ALU
    output reg [3:0]    alu_op,         //ALU的运算
    output reg [31:0]   reg1_data_o,    //reg1读取到的值，直接输出
    output reg [31:0]   reg2_data_o,    //reg2读取到的值，直接输出
    output reg [31:0]   imm_o,
//
    output reg          branch,         //分支
    output reg          jump,           //跳转
//to regs
    output reg          reg_wen,            //写寄存器使能
    output reg [4:0]    reg_waddr,          //目标寄存器的地址
    output reg [4:0]    reg1_raddr,         //源寄存器1的地址
    output reg [4:0]    reg2_raddr,         //源寄存器2的地址
//to memory
    output reg          mem_read,           //读memory    
    output reg          mem_write,          //写memory
//to system
    output reg          ecall,
    output reg          ebreak,
    output reg          fence,

    output reg [1:0]    alu_src_sel,     //rs2 or imm
    output reg [1:0]    PC_add_sel      //PC的加法器数据选择

);
    
    //to imm_gen
    reg [5:0]    imm_gen_op;         //立即数生成操作的控制

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
        imm_gen_op      =6'b100000;
        alu_op          =`ALU_OP_ADD;
        alu_src_sel     =2'b00;
        mem_read        =1'b0;
        mem_write       =1'b0;
        PC_add_sel      =2'b00;     //PC += 4
        ecall           =1'b0;
        ebreak          =1'b0;
        fence           =1'b0;
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
                        alu_op = `ALU_OP_AND;
                    `FUNCT3_SLL:
                        alu_op = `ALU_OP_SLL;
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
                reg_waddr   = rd;
                reg1_raddr  = rs1;
                alu_src_sel = 2'b01;
                imm_gen_op  = 6'b000001;
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
                reg_waddr   = rd;
                reg1_raddr  = rs1;
                alu_src_sel = 2'b01;
                mem_read    = 1'b1;
                imm_gen_op  = 6'b000001;
                case (funct3)
                    `FUNCT3_LB,`FUNCT3_LH,`FUNCT3_LW,`FUNCT3_LBU,`FUNCT3_LHU: 
                        alu_op      = `ALU_OP_ADD;
                    default: alu_op = `ALU_OP_ADD;  
                endcase
            end
            `STORE:begin
                reg1_raddr  = rs1;
                reg2_raddr  = rs2;
                alu_src_sel = 2'b01; 
                imm_gen_op  =3'b001;
                mem_write   = 1'b1;
                imm_gen_op  = 6'b000010;
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
                alu_src_sel     =2'b11;
                imm_gen_op      = 6'b000100;
                PC_add_sel      =2'b01;         //PC += imm
                case (funct3)
                    `FUNCT3_BEQ:begin
                        alu_op  = `ALU_OP_EQ;
                    end
                    `FUNCT3_BNE:begin
                        alu_op  = `ALU_OP_NEQ;
                    end
                    `FUNCT3_BLT:begin
                        alu_op  = `ALU_OP_SLT;
                    end
                    `FUNCT3_BGE:begin
                        alu_op  = `ALU_OP_GE;
                    end
                    `FUNCT3_BLTU:begin
                        alu_op  = `ALU_OP_SLTU;
                    end
                    `FUNCT3_BGEU:begin
                        alu_op  = `ALU_OP_GEU;
                    end
                    default: alu_op  =  `ALU_OP_EQ;
                endcase
            end
            `JAL:begin
                jump            =1'b1;      //这个信号就可以判定，使得rd = PC+4
                reg_wen         =1'b1;      
                reg_waddr       =rd;
                imm_gen_op      =6'b010000;
                PC_add_sel      =2'b01;         //PC += imm
                //alu_op          =`ALU_OP_ADD;
                //alu_src_sel     =2'b11;
            end
            `JALR:begin
                case (funct3)
                    `FUNCT3_JALR:begin
                        jump            =1'b1; 
                        reg_wen         =1'b1; 
                        reg_waddr       =rd;
                        imm_gen_op      =6'b000001;
                        PC_add_sel      =2'b10;         //PC = rs1 + imm
                    end
                endcase
            end
            `LUI:begin
                reg_wen         =1'b1; 
                reg_waddr       =rd;
                imm_gen_op      =6'b001000;
            end
            `AUIPC:begin
                reg_wen         =1'b1; 
                reg_waddr       =rd;
                imm_gen_op      =6'b001000;
            end
            `SYSTEM:begin
                case (funct3)
                    `FUNCT3_ECALL, `FUNCT3_EBREAK: begin
                        ecall = (funct7==7'b0000000) ? 1'b1 : 1'b0;
                        ebreak = (funct7==7'b0000001) ? 1'b1 : 1'b0;
                    end
                    default: begin
                        ecall = 1'b0;
                        ebreak = 1'b0;
                    end
                endcase
            end
            `FENCE:begin
                case (funct3)
                    `FUNCT3_FENCE: fence = 1'b1;
                    default: fence = 1'b0;
                endcase
            end
            default:begin
                end
        endcase
    end

wire [31:0] Iimm = {{21{inst_i[31]}}, inst_i[30:20]};
wire [31:0] Simm = {{21{inst_i[31]}}, inst_i[30:25], inst_i[11:7]};
wire [31:0] Bimm = {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
wire [31:0] Uimm = {inst_i[31:12], 12'b0};
wire [31:0] Jimm = {{12{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};

assign imm_o = {32{imm_gen_op[0]}} & Iimm
             | {32{imm_gen_op[1]}} & Simm
             | {32{imm_gen_op[2]}} & Bimm
             | {32{imm_gen_op[3]}} & Uimm
             | {32{imm_gen_op[4]}} & Jimm;

endmodule