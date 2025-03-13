module down_converter (
    input   clk,
    input   rst_n,
    input   [1:0]IFin,
    input   [1:0]carrywave,
    output  reg [3:0] result
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            result <= 4'b0000;
        end else begin
            result <= { {2{IFin[1]}},IFin } * { {2{carrywave[1]}},carrywave };
        end
    end

endmodule