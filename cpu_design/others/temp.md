RISC-V 的 ALU 可以处理多种不同的运算
算术运算：加法（add）、减法（sub）。
逻辑运算：左移（sll）、异或（xor）、或（or）、算术右移（sra）。
比较运算：有符号小于（slt）、无符号小于（sltu）
在 RISC-V 架构中，通常使用 4bit 的操作码来控制 ALU 的运算。
    ALU_OP_ADD	4'b0000	加法
    ALU_OP_SUB	4'b1000	减法
    ALU_OP_SLL	4'b0001	逻辑左移
    ALU_OP_SLT	4'b0010	有符号数小于比较
    ALU_OP_SLTU	4'b0011	无符号数小于比较
    ALU_OP_XOR	4'b0100	异或
    ALU_OP_SRL	4'b0101	逻辑右移
    ALU_OP_SRA	4'b1101	算术右移（有符号右移）
    ALU_OP_OR	4'b0110	或
    ALU_OP_AND	4'b0111	与
    ALU_OP_EQ	4'b1001	相等比较（结果为 1 或 0）
    ALU_OP_NEQ	4'b1010	不相等比较（结果为 1 或 0）
    ALU_OP_GE	4'b1100	有符号数大于等于比较
    ALU_OP_GEU	4'b1011	无符号数大于等于比较


ALU（算术逻辑单元）操作数来源的信号,通常2 bit就可以表示
00：reg1 reg2
01：reg1 imm
10：reg1 pc
11: imm  pc

立即数生成操作的控制
000001:I型立即数
000010:S型立即数
000100:B型立即数
001000:U型立即数
010000:J型立即数
100000:立即数为0