`timescale 1ns / 1ps

module tb_correlator;

    // 定义信号
    reg clk;
    reg rst_n;
    reg [3:0] I;
    reg m;
    wire [4:0] result;

    // 实例化待测模块
    correlator uut (
       .clk(clk),
       .rst_n(rst_n),
       .I(I),
       .m(m),
       .result(result)
    );

    // 时钟生成
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns 周期的时钟
    end

    integer i;
    // 测试序列
    initial begin
        // 初始化信号
        rst_n = 0;
        I = 4'b0000;
        m = 1'b0;
        #20; // 复位一段时间

        // 释放复位信号
        rst_n = 1;

        // 遍历所有 I 的值
        for (i = 0; i < 16; i = i + 1) begin
            I = i;

            // 测试 m = 0 的情况
            m = 1'b0;
            #20;

            // 测试 m = 1 的情况
            m = 1'b1;
            #20;
        end

        // 结束仿真
        #2000;
        $finish;
    end

    // 监控信号
    initial begin
        $monitor("Time: %0t, clk: %b, rst_n: %b, I: %b, m: %b, result: %b",
                 $time, clk, rst_n, I, m, result);
    end

    //产生fsdb文件
    initial begin
        $fsdbDumpfile("tb.fsdb");
        $fsdbDumpvars("+all");
    end

endmodule    