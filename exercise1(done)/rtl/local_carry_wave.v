module local_carry_wave (
    input clk,
    input rst_n,


    output reg [1:0]cos_wave,
    output reg [1:0]sin_wave
);
    
    reg [1:0] count;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 2'b0;
        end
        else begin
            count <= count+1'b1;
        end
    end
    
    //使用查表法生成
    always @(posedge clk) begin
        if (!rst_n) begin
            cos_wave <= 2'b01;
            sin_wave <= 2'b00;
        end
        else begin
            case (count)
                2'b00: {cos_wave, sin_wave} <= {2'b01, 2'b00};
                2'b01: {cos_wave, sin_wave} <= {2'b00, 2'b01};
                2'b10: {cos_wave, sin_wave} <= {2'b11, 2'b00}; 
                2'b11: {cos_wave, sin_wave} <= {2'b00, 2'b11}; 
            endcase
        end
    end



endmodule