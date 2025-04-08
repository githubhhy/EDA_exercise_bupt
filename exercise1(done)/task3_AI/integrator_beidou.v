module integrator_beidou (
    input wire clk,         
    input wire rst_n,
    input wire shift_parse,  
    input wire signed [1:0] I_in, // 2 位有符号 I 路输入信号
    input wire signed [1:0] Q_in, // 2 位有符号 Q 路输入信号
    output reg signed [24:0] I_out, // 10 位有符号 I 路积分输出信号
    output reg signed [24:0] Q_out, // 10 位有符号 Q 路积分输出信号
    output  [49:0] energy,
    output result_ok
);

    reg [23:0] counter; // 24 位计数器，用于计数 12488784 个值

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            I_out <= 25'b0;
            Q_out <= 25'b0;
            counter <= 24'b0;
        end
        else if (shift_parse) begin
            I_out <= 25'b0;
            Q_out <= 25'b0;
            counter <= 24'b0;
        end
        else if (counter == 24'd12488784) begin
            I_out <= 25'b0;
            Q_out <= 25'b0;
            counter <= 24'b0;
        end
        else begin
            I_out <= I_out + I_in;
            Q_out <= Q_out + Q_in;
            counter <= counter + 1;
        end
    end

assign energy = I_out * I_out + Q_out * Q_out;
assign result_ok = (counter == 24'd12488784)? 1'b1 : 1'b0;    

endmodule