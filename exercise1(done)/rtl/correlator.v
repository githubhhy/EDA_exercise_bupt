module correlator (
    input wire signed [1:0] I_in,  // 2 位有符号 I 路输入信号
    input wire signed [1:0] Q_in,  // 2 位有符号 Q 路输入信号
    input wire local_code,         // 1 位本地码
    output reg signed [1:0] I_out, // 2 位有符号 I 路输出信号
    output reg signed [1:0] Q_out  // 2 位有符号 Q 路输出信号
);
    always @(*) begin
        if (local_code) begin
            I_out = I_in;
        end else begin
            I_out = -I_in;
        end
    end

    always @(*) begin
        if (local_code) begin
            Q_out = Q_in;
        end else begin
            Q_out = -Q_in;
        end
    end
    
endmodule