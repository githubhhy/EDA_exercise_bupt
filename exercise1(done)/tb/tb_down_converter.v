`timescale 1ns / 1ps

module tb_down_converter;
    reg clk;
    reg rst_n;
    reg signed [1:0] IFin;
    reg signed [1:0] carrywave;
    wire signed [3:0] result;

    integer i, j;
    
    down_converter uut(
        .clk(clk),
        .rst_n(rst_n),
        .IFin(IFin),
        .carrywave(carrywave),
        .result(result)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns 周期的时钟
    end


    initial begin
        // 初始化信号
        rst_n = 0;
        #20; // 复位一段时间
        rst_n = 1;

        // 遍历所有 2 位有符号数的组合

        for (i = -2; i <= 1; i = i + 1) begin
            for (j = -2; j <= 1; j = j + 1) begin
                IFin = i;
                carrywave = j;
                #10; // 等待几个时钟周期让结果稳定
                $display("IFin = %d, carrywave = %d, result = %d", IFin, carrywave, result);
            end
        end

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