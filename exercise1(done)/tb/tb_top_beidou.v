`timescale 1ns / 1ns

module tb_top_beidou;

    // 参数定义
    parameter DURATION_PER_D = 12488784;  // 每个D持续的时钟周期数
    parameter M_CHIP_DURATION = 3052;  // 每个M码片持续的时钟周期数
    parameter NUM_D_SEQUENCES = 30;   // 定义D序列的数量

    // 信号声明
    reg clk;
    reg rst_n;
    wire flag;
    // wire decode_D;
    reg signed [1:0] IFin;

    // 实例化被测试模块
    top_beidou uut (
       .clk(clk),
       .rst_n(rst_n),
       .IFin(IFin),
       .flag(flag)
    //    .decode_D(decode_D)
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

    // 生成G1 M序列（RTL实现）
    reg [10:0] m_g1_lfsr;
    reg [11:0] m_g1_chip_counter;
    wire [10:0] g1_feedback = {
        m_g1_lfsr[9:0],
        m_g1_lfsr[10] ^ m_g1_lfsr[9] ^ m_g1_lfsr[8] ^
        m_g1_lfsr[7] ^ m_g1_lfsr[6] ^ m_g1_lfsr[0]
    };

    always @(posedge clk) begin
        if (!rst_n) begin
            m_g1_lfsr <= 11'b11010110101;  // G1初始值
            m_g1_chip_counter <= 0;
        end else begin
            if (m_g1_chip_counter == M_CHIP_DURATION - 1) begin
                m_g1_lfsr <= g1_feedback;
                m_g1_chip_counter <= 0;
            end else begin
                m_g1_chip_counter <= m_g1_chip_counter + 1;
            end
        end
    end
    assign m_g1_bit = m_g1_lfsr[10];

    // 生成G2 M序列（RTL实现）
    reg [10:0] m_g2_lfsr;
    reg [11:0] m_g2_chip_counter;
    wire [10:0] g2_feedback = {
        m_g2_lfsr[9:0],
        m_g2_lfsr[10] ^ m_g2_lfsr[9] ^ m_g2_lfsr[8] ^
        m_g2_lfsr[7] ^ m_g2_lfsr[4] ^ m_g2_lfsr[3] ^
        m_g2_lfsr[2] ^ m_g2_lfsr[1] ^ m_g2_lfsr[0]
    };

    always @(posedge clk) begin
        if (!rst_n) begin
            m_g2_lfsr <= 11'b00001000101;  // G2初始值     b01010101010    
            m_g2_chip_counter <= 0;
        end else begin
            if (m_g2_chip_counter == M_CHIP_DURATION - 1) begin
                m_g2_lfsr <= g2_feedback;
                m_g2_chip_counter <= 0;
            end else begin
                m_g2_chip_counter <= m_g2_chip_counter + 1;
            end
        end
    end
    assign m_g2_bit = m_g2_lfsr[0] ^ m_g2_lfsr[2];
    // 生成测距码
    wire ranging_code = m_g1_bit ^ m_g2_bit;


    // 生成D序列（0/1交替，每个持续12488784个时钟周期）
    reg D;
    reg [23:0] d_counter;   // 24位计数器，用于12488784个时钟周期计数
    integer d_sequence_count; // 记录D序列的数量
    initial begin
        D = 1'b0;
        d_counter = 24'd0;
        d_sequence_count = 0;
        forever begin
            #(DURATION_PER_D * 10); // 等待12488784个时钟周期
            D = $random % 2;
            $display("D sequence value at count %0d: %b", d_sequence_count, D);
            d_sequence_count = d_sequence_count + 1;
            if (d_sequence_count == NUM_D_SEQUENCES * 2) begin
                $finish; // 当生成指定数量的D序列后结束仿真
            end
        end
    end

    // 计算IFin信号（D*C之后和载波相乘）
    wire b = D & ranging_code;
    always @(*) begin
        case (cos_value)
            2'b01: IFin = (b) ? 2'b01 : 2'b11; // cos=1时，b=1→1，b=0→-1
            2'b11: IFin = (b) ? 2'b11 : 2'b01; // cos=-1时，b=1→-1，b=0→1
            default: IFin = 2'b00; //
        endcase
    end

    // 产生 fsdb 文件
    initial begin
        $fsdbDumpfile("tb_beidou.fsdb");
        $fsdbDumpvars("+all");
    end

endmodule    