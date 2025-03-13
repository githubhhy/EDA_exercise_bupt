`timescale 1ns / 1ps

module tb_m_code_31_generate;

    // 信号定义
    reg clk;
    reg rst_n;
    reg delay_en;
    wire m_code;

    // 实例化待测模块
    m_code_31_generate uut (
       .clk(clk),
       .rst_n(rst_n),
       .delay_en(delay_en),
       .m_code(m_code)
    );

    // 时钟生成
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns 周期的时钟
    end

    // 测试序列
    initial begin
        // 初始化信号
        rst_n = 0;
        delay_en <=0;
        #25;
        rst_n = 1;

        #50
        delay_en <=1;
        #8
        delay_en <=0;

        // 运行一段时间
        #2000;
        $finish;
    end

    // 监控输出
//    initial begin
//        $monitor("Time: %0t, m_code: %b", $time, m_code);
//    end

    //产生fsdb文件
    initial begin
        $fsdbDumpfile("tb.fsdb");
        $fsdbDumpvars("+all");
    end

endmodule