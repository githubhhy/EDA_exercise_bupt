module decode_beidou (
    input flag,
    
    input signed [49:0] energy,
    input result_ok,

    output reg decode_D
);
    always @(posedge result_ok) begin
        if (flag) begin
            if (energy < 50'd15000000000) begin
                decode_D <= 1'b0;
            end
            else begin
                decode_D <= 1'b1;
            end
        end
        else begin
            decode_D <= 1'bx;
        end
    end

endmodule