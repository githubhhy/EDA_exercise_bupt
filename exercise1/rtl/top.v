module top (
    input clk,
    input rst_n,

    input   [1:0]IFin,

    output flag
);
    //wire cos_wave;
    //wire sin_wave;
    local_carry_wave u_1_local_carry_wave(
        .clk(clk),
        .rst_n(rst_n),
        .cos_wave(cos_wave),
        .sin_wave(sin_wave)
    );

    wire r1;
    wire r2;
    down_converter u_1_down_converter(
        .clk(clk),
        .rst_n(rst_n),
        .IFin(IFin),
        .carrywave(cos_wave),
        .result(r1)
    );

    down_converter u_2_down_converter(
        .clk(clk),
        .rst_n(rst_n),
        .IFin(IFin),
        .carrywave(sin_wave),
        .result(r2)
    );


    clk_div16 u_clk_div16 (
       .clk(clk),
       .rst_n(rst_n),
       .clk_out(clk_div_16)
    );
    //该模块的时钟频率为f/4/4，即16分配
    wire m_code;
    m_code_31_generate u_m_code_31_generate (
       .clk(clk_div_16),
       .rst_n(rst_n),
       .delay_en(delay_en),
       .m_code(m_code)
    );

    
endmodule