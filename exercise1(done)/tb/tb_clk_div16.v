`timescale 1ns / 1ps

module tb_clk_div16;

    reg clk;
    reg rst_n;
    wire clk_out;

    // 实例化被测试模块
    clk_div16 uut (
       .clk(clk),
       .rst_n(rst_n),
       .clk_out(clk_out)
    );

    // 生成时钟信号
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns 周期的时钟
    end

    // 测试序列
    initial begin
        // 初始化信号
        rst_n = 0;
        #20; // 复位一段时间
        rst_n = 1; // 释放复位信号

        #2000; // 运行一段时间
        $finish;
    end

endmodule