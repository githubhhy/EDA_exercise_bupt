module top (
    input clk,
    input rst_n,

    input signed  [1:0]IFin,

    output flag,
    output decode_D
);
    wire [1:0]cos_wave;
    wire [1:0]sin_wave;
    local_carry_wave u_1_local_carry_wave(
        .clk(clk),
        .rst_n(rst_n),
        .cos_wave(cos_wave),
        .sin_wave(sin_wave)
    );

    wire [1:0] conv_I;
    wire [1:0] conv_Q;
    down_converter u_1_down_converter(
        .IFin(IFin),
        .cos_in(cos_wave),
        .sin_in(sin_wave),
        .I_out(conv_I),
        .Q_out(conv_Q)
    );
    wire m_code;
    m_code_31_generate u_m_code_31_generate (
       .clk(clk),
       .rst_n(rst_n),
       .shift_parse(shift_parse),
       .m_code(m_code)
    );

    wire [1:0] corr_I;
    wire [1:0] corr_Q;
    correlator u_correlator (
       .I_in(conv_I), 
       .Q_in(conv_Q), 
       .local_code(m_code), 
       .I_out(corr_I), 
       .Q_out(corr_Q)
    );

    wire [9:0] sum_I;
    wire [9:0] sum_Q;
    wire [19:0] energy;
    wire result_ok;
    integrator u_integrator (
       .clk(clk),
       .rst_n(rst_n),
       .shift_parse(shift_parse),
       .I_in(corr_I),
       .Q_in(corr_Q),
       .I_out(sum_I),
       .Q_out(sum_Q),
       .energy(energy),
       .result_ok(result_ok)
    );

    detect u_detect(
        .clk(clk),
        .rst_n(rst_n),
        .result_ok(result_ok),
        .energy(energy),
        .flag(flag),
        .delay_en(delay_en)
    );
    
    //wire shift_parse;
    control u_control(
        .clk(clk),
        .rst_n(rst_n),
        .delay_en(delay_en),
        .shift_parse(shift_parse)
    );
    
    //译码模块
    wire decode_D;
    decode u_decode(
        .flag(flag),  
        .sum_I(sum_I),
        .sum_Q(sum_Q),
        .result_ok(result_ok),
        .decode_D(decode_D)
    );
endmodule