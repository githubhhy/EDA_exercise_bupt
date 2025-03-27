module decode (
    input flag,
    
    input signed [8:0] sum_I,
    input signed [8:0] sum_Q,
    input result_ok,

    output reg decode_D
);
    always @(posedge result_ok) begin
        if (flag) begin
            if (sum_I > sum_Q) begin
                decode_D <= 1'b1;
            end
            else begin
                decode_D <= 1'b0;
            end
        end
        else begin
            decode_D <= 1'bx;
        end
    end

endmodule