`timescale 1ns / 1ps

module tb_integrator;

    // 定义信号
    reg clk;
    reg rst_n;
    reg delay_en;
    reg [4:0] corr_result;
    wire [11:0] I_sum;

    // 实例化待测模块
    integrator uut (
       .clk(clk),
       .rst_n(rst_n),
       .delay_en(delay_en),
       .corr_result(corr_result),
       .I_sum(I_sum)
    );

    // 时钟生成
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns 周期的时钟
    end

    // 定义测试数据数组
        reg [4:0] test_data [0:15];
        integer i;

    // 测试序列
    initial begin
        // 初始化信号
        rst_n = 0;
        delay_en = 1'b0;
        corr_result = 5'b00000;
        #20; // 复位一段时间

        // 释放复位信号
        rst_n = 1;



        // 填充测试数据
        for (i = 0; i < 16; i = i + 1) begin
            test_data[i] = i[4:0];
        end

        // 开始测试
        for (i = 0; i < 16; i = i + 1) begin
            // 随机设置 delay_en 信号
            delay_en = $random % 2;

            // 设置 corr_result 信号
            corr_result = test_data[i];

            // 等待一个时钟周期
            #10;

            // 打印当前测试信息
            $display("Test Case %0d: delay_en = %b, corr_result = %b, I_sum = %b", i, delay_en, corr_result, I_sum);
        end

        // 结束仿真
        #20;
        $finish;
    end

    //产生fsdb文件
    initial begin
        $fsdbDumpfile("tb.fsdb");
        $fsdbDumpvars("+all");
    end

endmodule    