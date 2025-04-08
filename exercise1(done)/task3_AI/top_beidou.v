module top_beidou(
    input clk,
    input rst_n,

    input signed  [1:0]IFin,

    output flag
);
    //本地载波生成
    wire [1:0]cos_wave;
    wire [1:0]sin_wave;
    local_carry_wave u_1_local_carry_wave(
        .clk(clk),
        .rst_n(rst_n),
        .cos_wave(cos_wave),
        .sin_wave(sin_wave)
    );
    //下采样
    wire [1:0] conv_I;
    wire [1:0] conv_Q;
    down_converter u_1_down_converter(
        .IFin(IFin),
        .cos_in(cos_wave),
        .sin_in(sin_wave),
        .I_out(conv_I),
        .Q_out(conv_Q)
    );
    //本地测距码生成
    wire ranging_code;
    ranging_code_generate u_ranging_code_generate(
       .clk(clk),
       .rst_n(rst_n),
       .shift_parse(shift_parse),
       .ranging_code(local_code)
    );
    
    //相关运算
    wire [1:0] corr_I;
    wire [1:0] corr_Q;
    correlator u_correlator (
       .I_in(conv_I), 
       .Q_in(conv_Q), 
       .local_code(local_code), 
       .I_out(corr_I),
       .Q_out(corr_Q)
    );

    //积分与求能量
    wire [24:0] sum_I;
    wire [24:0] sum_Q;
    wire [49:0] energy;
    wire result_ok;
    integrator_beidou u_integrator_beidou (
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

    //判决
    detect_beidou u_detect_beidou(
        .clk(clk),
        .rst_n(rst_n),
        .result_ok(result_ok),
        .energy(energy),
        .flag(flag),
        .delay_en(delay_en)
    );

    //移相
    //wire shift_parse;
    control_beidou u_control_beidou(
        .clk(clk),
        .rst_n(rst_n),
        .delay_en(delay_en),
        .shift_parse(shift_parse)
    );

    //译码
    //wire decode_D;
    decode_beidou u_decode_beidou(
        .flag(flag),  
        .energy(energy),
        .result_ok(result_ok),
        .decode_D(decode_D)
    );

endmodule