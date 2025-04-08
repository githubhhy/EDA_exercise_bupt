module ranging_code_generate (
    input clk,
    input rst_n,
    input shift_parse,  // 延迟一个码片
    output reg ranging_code
);

    wire g1,g2;
    
    m_g1_generate u_m_g1_generate(
       .clk(clk),
       .rst_n(rst_n),
       .shift_parse(shift_parse),
       .m_code(g1)
    );

    m_g2_generate u_m_g2_generate(
       .clk(clk),
       .rst_n(rst_n),
       .shift_parse(shift_parse),
       .m_code(g2)
    );

    always @(posedge clk) begin
        if (!rst_n) begin
            ranging_code <= 1'b0;
        end
        else begin
            ranging_code <= g1 ^ g2;
        end
    end

endmodule