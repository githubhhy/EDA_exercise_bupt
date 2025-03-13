module correlator (
    input   clk,
    input   rst_n,
    input   [3:0] I,
    input   m,
    output  reg [5:0] result
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            result <= 6'b0;
        end else begin
            if (m) begin
                result <= { {2{I[1]}}, I } * 2'b01;
            end else begin
                result <= { {2{I[1]}}, I } * 2'b11;
            end
        end
    end
    
endmodule