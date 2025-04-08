module m_g2_generate (
    input clk,
    input rst_n,
    input shift_parse,  // 延迟一个码片
    output reg m_code
);


    // 计数，一个M码，3052个clk
    // 延迟时，计数器清零
    reg [11:0] count;  // 因为要计数到3052，至少需要12位
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 12'b0;
        end
        else if (shift_parse) begin
            count <= 12'b0;
        end
        else begin
            count <= count + 1;
        end
    end

    reg [10:0] Q; // 11级寄存器
    wire feedback;

    // 合适的反馈抽头，对于2046长度的M序列需要根据理论确定
    assign feedback = Q[10] ^ Q[9] ^ Q[8] ^ Q[7] ^ Q[4] ^ Q[3] ^ Q[2] ^ Q[1] ^ Q[0]; 

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            Q <= 11'b01010101010;
        end
        else if (count == 12'd3051) begin
            Q <= {Q[9:0],feedback};
            m_code <= Q[0] ^ Q[2];   //抽头1和3
            count <= 12'b0; // 计数到3052后，计数器清零
        end
    end

endmodule