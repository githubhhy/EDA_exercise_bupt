module down_converter (
    input wire signed [1:0] IFin,
    input wire signed [1:0] cos_in,
    input wire signed [1:0] sin_in,
    output wire signed [1:0] I_out,
    output wire signed [1:0] Q_out
);
    wire signed [2:0] temp_I;
    wire signed [2:0] temp_Q;

    assign temp_I = IFin * cos_in;
    assign temp_Q = IFin * sin_in;

    assign I_out = temp_I[1:0];
    assign Q_out = temp_Q[1:0];

endmodule