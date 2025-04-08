/*
    flag变成1后，delay_en就永远失效
*/
module detect (
    input clk,
    input rst_n,
    input result_ok,
    input [19:0] energy,

    output reg flag,
    output reg delay_en
);

    reg flag_set;       //用于实现：当flag变成1后，delay_en就永远失效。完成同步后，就不需要进行码片延迟了

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            flag <= 1'b0;
            delay_en<=1'b0;
            flag_set <= 1'b0;
        end
        else if (result_ok) begin
            if (energy >= 19'd10000) begin
                flag <=1'b1;
                delay_en<=1'b0;
                flag_set <= 1'b1;
            end
            else if (!flag_set) begin       
                delay_en <= 1'b1;
            end
            else begin
                delay_en<=1'b0;
            end
        end
        else begin
            //flag <= 1'b0;
            delay_en<=1'b0;
        end
    end

endmodule  