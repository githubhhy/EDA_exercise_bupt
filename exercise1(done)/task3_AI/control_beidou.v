module control_beidou (
    input clk,
    input rst_n,
    input delay_en,

    output reg shift_parse
);
    
    reg [11:0] counter; // 12 位计数器，用于计数 3052 个时钟周期

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // 异步复位，当 rst_n 为低电平时，计数器清零，shift_parse 置为低电平
            counter <= 12'b0;
            shift_parse <= 1'b0;
        end else if (delay_en && counter == 12'b0) begin
            // 当检测到 delay_en 脉冲且计数器为 0 时，开始计数
            counter <= counter + 1;
            shift_parse <= 1'b1;
        end else if (counter > 12'b0 && counter < 12'd3052) begin
            // 计数器大于 0 且小于 3052 时，继续计数，shift_parse 保持高电平
            counter <= counter + 1;
            shift_parse <= 1'b1;
        end else if (counter == 12'd3052) begin
            // 计数器达到 3052 时，计数结束，计数器清零，shift_parse 置为低电平
            counter <= 12'b0;
            shift_parse <= 1'b0;
        end
    end


endmodule