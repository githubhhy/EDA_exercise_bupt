module m_code_31_generate (
    input clk,
    input rst_n,
    input delay_en,

    output wire m_code
);
    reg [4:0] Q;//5级寄存器

    reg delay_en_reg;

    wire C0;
    assign C0 = Q[3]^Q[0];//反馈

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            Q <= 5'b00001;
        end 
        else begin
            delay_en_reg <= delay_en;
            if (delay_en_reg)
                Q <= Q;
            else
                Q <= {C0,Q[4:1]};
        end
    end

    assign m_code = Q[0];

endmodule