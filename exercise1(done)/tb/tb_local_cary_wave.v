`timescale 1ns / 1ps

module tb_local_carry_wave;
    reg clk;
    reg rst_n;

    wire [1:0]cos_wave;
    wire [1:0]sin_wave;
    
    local_carry_wave uut(
        .clk(clk),
        .rst_n(rst_n),
        .cos_wave(cos_wave),
        .sin_wave(sin_wave)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns 周期的时钟
    end

    initial begin
        // 初始化信号
        rst_n = 0;
        #25;
        rst_n = 1;

        // 运行一段时间
        #2000;
        $finish;
    end

    //产生fsdb文件
    initial begin
        $fsdbDumpfile("tb.fsdb");
        $fsdbDumpvars("+all");
    end

endmodule