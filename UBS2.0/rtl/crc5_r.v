/*
注意点：
    SYNC同步字段，固定值,已经被物理层解析，信号为rx_lp_valid，与该信号握手来识别包开始
    PID需要进行取反校验
    self_add 是设备自身的地址


*/

module crc5_r (
//from system
    input           clk,
    input           rst_n,
//register
    input   [6:0]   self_addr,
    output          crc5_err,
//interface with phy
    input           rx_lp_sop,          //标志包的开始
    input           rx_lp_eop,          //标志包的结束
    input           rx_lp_valid,        //握手有效，开始取数据         
    output          rx_lp_ready,            
    input   [7:0]   rx_lp_data,         //接收到的8bit数据
//  不确定，但是可以确定的是，与上方的信号一模一样，应该是输出
    output          rx_sop,     //with crc16_ru
    output          rx_eop,     //with crc16_ru
    output          rx_valid,   //with crc16_ru
    input           rx_ready,   //with crc16_ru //不确定是什么，但是在case0中为高阻z                       
    output  [7:0]   rx_data,    //with crc16_ru
//with link_control
    output          rx_handshake_on;
    output  reg [3:0]   rx_pid;
    output          rx_pid_en;
    
);
    
    wire    [10:0]  d;
    wire    [4:0]   c_out;
    wire            crc5_right;
    wire    [3:0]   rx_endp;
    wire            addr_match;
    wire            pid_h_l_ok;
    wire            pid_is_not_data;
    reg             pid_ok;             //表示可以接收PID了
    reg             addr_ok;            //表示可以接收ADDR

assign rx_sop = rx_lp_sop;
assign rx_eop = rx_lp_eop;
assign rx_valid = rx_valid;
assign rx_data = rx_lp_data;
assign rx_lp_ready = rx_ready;

crc5 u0(
    .c      (     5'h1f     ),
    .d      (      d        ),
    .c_out  (     c_out     )
);

assign  pid_h_l_ok = rx_lp_sop;

    //
    always @(posedge clk) begin
        if (!rst_n) begin
            pid_ok <= 1'b0;
        end
        else if (rx_lp_valid & rx_lp_sop) begin
            pid_ok <= 1'b1;
        end
        else if (rx_lp_valid & rx_lp_eop) begin
            pid_ok <= 1'b0;
        end
        else begin
            pid_ok <= pid_ok;
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            rx_pid <= 4'b0;
        end
        else if (pid_ok) begin
            rx_pid <= 
        end
    end


    always @(posedge clk) begin
        if (!rst_n) begin
            d = 11'd8;
        end
        else if (rx_lp_valid) begin
            if (addr_match)
                d = {3'b000,rx_lp_data};
            else
                d = {rx_lp_data[2:0],d[7:0]};
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            addr_ok <= 1'b0;
        end
        else begin
            addr_ok <= addr_match;
        end
    end

endmodule
