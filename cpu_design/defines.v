`define LUI     7'b0110111
`define AUIPC   7'b0010111
`define JAL     7'b1101111
`define JALR    7'b1100111
`define BRANCH  7'b1100011
`define LOAD    7'b0000011
`define STORE   7'b0100011
`define ALUI    7'b0010011
`define ALUR    7'b0110011
`define FENCE   7'b0001111
`define SYSTEM  7'b1110011

`define FUNCT3_ADD  3'b000  
`define FUNCT3_SUB  3'b000
`define FUNCT3_XOR  3'b100
`define FUNCT3_OR   3'b110
`define FUNCT3_AND  3'b111
`define FUNCT3_SLL  3'b001
`define FUNCT3_SRL  3'b101
`define FUNCT3_SRA  3'b101
`define FUNCT3_SLT  3'b010
`define FUNCT3_SLTU 3'b011

`define FUNCT3_ADDI 3'b000
`define FUNCT3_XORI 3'b100
`define FUNCT3_ORI  3'b110
`define FUNCT3_ANDI 3'b111
`define FUNCT3_SLLI 3'b001
`define FUNCT3_SRLI 3'b101
`define FUNCT3_SRAI 3'b101
`define FUNCT3_SLTI 3'b010
`define FUNCT3_SLTIU 3'b011

`define FUNCT3_LB   3'b000
`define FUNCT3_LH   3'b001
`define FUNCT3_LW   3'b010
`define FUNCT3_LBU  3'b100
`define FUNCT3_LHU  3'b101

`define FUNCT3_SB   3'b000
`define FUNCT3_SH   3'b001
`define FUNCT3_SW   3'b010

`define FUNCT3_BEQ  3'b000
`define FUNCT3_BNE  3'b001
`define FUNCT3_BLT  3'b100
`define FUNCT3_BGE  3'b101
`define FUNCT3_BLTU 3'b110
`define FUNCT3_BGEU 3'b111

`define FUNCT3_JALR 3'b000

`define FUNCT3_ECALL 3'b000
`define FUNCT3_EBREAK 3'b000

`define FUNCT3_FENCE 3'b000

`define ALU_OP_ADD      4'b0000             //加
`define ALU_OP_SUB      4'b1000             //减
`define ALU_OP_SLL      4'b0001             //逻辑左移
`define ALU_OP_SLT      4'b0010             //小于
`define ALU_OP_SLTU     4'b0011             //小于（无符号）
`define ALU_OP_XOR      4'b0100             //异或
`define ALU_OP_SRL      4'b0101             //逻辑右移
`define ALU_OP_SRA      4'b1101             //算数右移（msb填充）
`define ALU_OP_OR       4'b0110             //或
`define ALU_OP_AND      4'b0111             //与

`define ALU_OP_EQ       4'b1001             //相等
`define ALU_OP_NEQ      4'b1010             //不相等
`define ALU_OP_GE       4'b1100             //大于等于（有符号）
`define ALU_OP_GEU      4'b1011             //大于等于（无符号）

`define ALU_OP_XXX      4'b1111

