`timescale 1ns / 1ps

module tb_top;

    // 参数定义
    parameter DURATION_PER_D = 496;  // 每个D持续的时钟周期数
    parameter M_CHIP_DURATION = 16;  // 每个M码片持续的时钟周期数
    parameter NUM_D_SEQUENCES = 100;   // 定义D序列的数量

    // 信号声明
    reg clk;
    reg rst_n;
    wire flag;
    wire decode_D;
    reg signed [1:0] IFin;

    // 实例化被测试模块
    top uut (
       .clk(clk),
       .rst_n(rst_n),
       .IFin(IFin),
       .flag(flag),
       .decode_D(decode_D)
    );

    // 时钟生成（10ns周期）
    initial begin
        clk = 1;
        forever #5 clk = ~clk;
    end

    // 复位信号生成
    initial begin
        rst_n = 0;
        #10;
        rst_n = 1;
    end

    // 生成余弦载波信号（1,0,-1,0循环）
    reg [1:0] cos_value;
    reg [1:0] cos_counter;
    initial begin
        cos_counter = 2'b0;
    end
    always @(posedge clk) begin
        cos_counter <= cos_counter + 1;
        case (cos_counter)
            2'b00: cos_value <= 2'b01; // 1
            2'b01: cos_value <= 2'b00; // 0
            2'b10: cos_value <= 2'b11; // -1
            2'b11: cos_value <= 2'b00; // 0
        endcase
    end

    // 生成M序列（31位m码）
    reg [4:0] m_lfsr;
    reg m_bit;
    reg [3:0] m_chip_counter; // 每个码片持续16个时钟周期
    initial begin
        m_lfsr = 5'b00110;
        m_chip_counter = 4'd0;
        m_bit = 1'b0;
        forever begin
            #(M_CHIP_DURATION * 10); // 每个码片持续16个时钟周期
            m_lfsr = {m_lfsr[3] ^ m_lfsr[0], m_lfsr[4:1]};
            m_bit = m_lfsr[0];
        end
    end

    // 生成D序列（0/1交替，每个持续496个时钟周期）
    reg D;
    reg [9:0] d_counter; // 496个时钟周期计数
    integer d_sequence_count; // 记录D序列的数量
    initial begin
        D = 1'b0;
        d_counter = 10'd0;
        d_sequence_count = 0;
        forever begin
            #(DURATION_PER_D * 10); // 等待496个时钟周期
            D = $random % 2;
            d_sequence_count = d_sequence_count + 1;
            if (d_sequence_count == NUM_D_SEQUENCES * 2) begin
                $finish; // 当生成指定数量的D序列后结束仿真
            end
        end
    end

    // 计算IFin信号（D^M后应用极化函数和载波相乘）
    wire b = D ^ m_bit;
    always @(*) begin
        case (cos_value)
            2'b01: IFin = (b) ? 2'b01 : 2'b11; // cos=1时，b=1→1，b=0→-1
            2'b11: IFin = (b) ? 2'b11 : 2'b01; // cos=-1时，b=1→-1，b=0→1
            default: IFin = 2'b00; // cos=0时输出0
        endcase
    end

    // 产生 fsdb 文件
    initial begin
        $fsdbDumpfile("tb.fsdb");
        $fsdbDumpvars("+all");
    end

endmodule    