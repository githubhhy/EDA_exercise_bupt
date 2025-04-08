module m_code_31_generate (
    input clk,
    input rst_n,
    input shift_parse,  //延迟一个码片,
    output reg m_code
);    
    //计数，一个M码，16个clk
    //延迟时，计数器清零
    reg [3:0] count;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count<=4'b0;
        end
        else if (shift_parse) begin
            count<=4'b0;
        end
        else begin
            count<=count +1;
        end 
    end

    reg [4:0] Q;//5级寄存器

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            Q <= 5'b11111;
        end
        else if (count == 4'b1111) begin
            Q <= {Q[3]^Q[0],Q[4:1]};
            m_code = Q[0];
        end
    end


endmodule