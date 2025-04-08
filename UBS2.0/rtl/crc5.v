/*
crc5模块
输入：
    c   初始状态寄存器的值
    d   11bit的数据
输出:
    c_out   crc5的校验码
*/
module usbf_crc5(
    input	[10:0]	d;
    output	[4:0]	c_out;
);
    wire [4:0] c;
    assign c = 5'b11111;

    assign c_out[0] =	d[10] ^ d[9] ^ d[6] ^ d[5] ^ d[3] ^
                d[0] ^ c[0] ^ c[3] ^ c[4];

    assign c_out[1] =	d[10] ^ d[7] ^ d[6] ^ d[4] ^ d[1] ^
                c[0] ^ c[1] ^ c[4];

    assign c_out[2] =	d[10] ^ d[9] ^ d[8] ^ d[7] ^ d[6] ^
                d[3] ^ d[2] ^ d[0] ^ c[0] ^ c[1] ^
                c[2] ^ c[3] ^ c[4];

    assign c_out[3] =	d[10] ^ d[9] ^ d[8] ^ d[7] ^ d[4] ^ d[3] ^
                d[1] ^ c[1] ^ c[2] ^ c[3] ^ c[4];

    assign c_out[4] =	d[10] ^ d[9] ^ d[8] ^ d[5] ^ d[4] ^ d[2] ^
                c[2] ^ c[3] ^ c[4];

endmodule