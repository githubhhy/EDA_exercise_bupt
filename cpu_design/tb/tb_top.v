`timescale 1ns / 1ps
module tb_top;
    // 时钟和复位信号
    reg clk;
    reg rst_n;

    // 输入信号
    reg [31:0] inst_i;
    reg [31:0] reg1_rdata_i;
    reg [31:0] reg2_rdata_i;

    // 输出信号
    wire [3:0] alu_op;
    wire [31:0] reg1_data_o;
    wire [31:0] reg2_data_o;
    wire [31:0] imm_o;
    wire branch;
    wire jump;
    wire reg_wen;
    wire [4:0] reg_waddr;
    wire [4:0] reg1_raddr;
    wire [4:0] reg2_raddr;
    wire mem_read;
    wire mem_write;
    wire ecall;
    wire ebreak;
    wire fence;
    wire [1:0] alu_src_sel;
    wire [1:0] PC_add_sel;

    // 实例化被测模块
    id uut (
        .inst_i (inst_i),
        .reg1_rdata_i (reg1_rdata_i),
        .reg2_rdata_i (reg2_rdata_i),
        .alu_op (alu_op),
        .reg1_data_o (reg1_data_o),
        .reg2_data_o (reg2_data_o),
        .imm_o (imm_o),
        .branch (branch),
        .jump (jump),
        .reg_wen (reg_wen),
        .reg_waddr (reg_waddr),
        .reg1_raddr (reg1_raddr),
        .reg2_raddr (reg2_raddr),
        .mem_read (mem_read),
        .mem_write (mem_write),
        .ecall (ecall),
        .ebreak (ebreak),
        .fence (fence),
        .alu_src_sel (alu_src_sel),
        .PC_add_sel (PC_add_sel)
    );    

// 时钟生成
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        inst_i = 32'b0;
        reg1_rdata_i = 32'b0;
        reg2_rdata_i = 32'b0;
        #20;
        inst_i = 32'Hf0650513;      //addi	a0,a0,-250
        
        #20
        inst_i = 32'H00052f03;      //lw	t5,0(a0)

        #100    $finish;
    end


    // 产生 fsdb 文件
    initial begin
        $fsdbDumpfile("tb.fsdb");
        $fsdbDumpvars("+all");
    end

    
endmodule