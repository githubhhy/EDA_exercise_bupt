module clk_div16 (
    input wire clk,      // 输入时钟信号
    input wire rst_n,    // 异步复位信号，低电平有效
    output reg clk_out   // 输出分频后的时钟信号
);

    reg [3:0] counter;   // 4 位计数器，因为 2^4 = 16

    // 异步复位和计数器逻辑
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 4'b0000;  // 复位时计数器清零
            clk_out <= 1'b0;     // 复位时输出信号置为 0
        end else begin
            if (counter == 4'b1111) begin
                counter <= 4'b0000;  // 计数器达到 15 时清零
                clk_out <= ~clk_out; // 输出信号取反
            end else begin
                counter <= counter + 1; // 计数器加 1
            end
        end
    end

endmodule