module crc5_r (

    input           clk,
    input           rst_n,
    input   [6:0]   self_addr,          //from top, with register
    input           rx_lp_sop,          //from top, with phy, 包的开始
    input           rx_lp_eop,          //from top, with phy, 包的结束
    input           rx_lp_valid,        //from top, with phy, 握手有效，开始取数据         
    input   [7:0]   rx_lp_data,         //from top, with phy, 接收到的8bit数据
    input           rx_ready,           //from crc16_r,case中恒为z
    input           rx_handshake_on,    //from link_control,

    output          rx_sop,             //with crc16_ru
    output          rx_eop,             //with crc16_ru
    output          rx_valid,           //with crc16_ru
    output  [7:0]   rx_data,            //with crc16_ru
    output  reg        crc5_err,           //to top, with register
    output          rx_lp_ready,        //to top, with phy,在case中恒为1
    output  reg [3:0]   rx_pid,         //with link_control
    output  reg [3:0]   rx_endp,        //to top, with link layer
    output  reg         rx_pid_en,          //with link_control
    
);
    
    wire    [10:0]  d;                  //crc5
    wire    [4:0]   c_out;              //crc5
    wire            crc5_right;         //crc5
    wire            addr_match;         //addr is self_addr
    wire            pid_h_l_ok;         //pid high == ~low 
    wire            pid_is_not_data;
    reg             pid_ok;             //for token, means the pid is ok, should receive addr
    reg             addr_ok;            //

    
//rx_lp_ready在case中恒为1
//保持接收状态
    assign rx_lp_ready = 1'b1;

//pid相关
    //接收pid
    always @(posedge clk) begin
        if (!rst_n) begin
            rx_pid <= 4'b0;
        end
        if (rx_lp_valid && rx_lp_ready && rx_lp_sop) begin
            rx_pid <= rx_lp_data[3:0];
        end
    end

    //PID取反校验
    assign pid_h_l_ok = rx_lp_valid && rx_lp_ready && rx_lp_sop && (rx_lp_data[3:0] == ~rx_lp_data[7:4]);
    always @(posedge clk) begin
        if (!rst_n) begin
            pid_ok<=1'b0;
        end
        else if (pid_h_l_ok) begin
            //if (rx_lp_data[3:0] == 4'b0001 || rx_lp_data[3:0] == 4'b1001 || rx_lp_data[3:0] == 4'b0101 || rx_lp_data[3:0] == 4'b1101) begin
            if (rx_lp_data[1:0] == 2'b01) begin  //is token
                pid_ok <= 1'b1;
            end
        end
    end
    //PID判断是不是数据包
    assign pid_is_not_data = (rx_lp_data[3:0] != 4'b0011)
                           &&(rx_lp_data[3:0] != 4'b1011)
                           &&(rx_lp_data[3:0] != 4'b0111)
                           &&(rx_lp_data[3:0] != 4'b1111);

//地址相关
    //addr match
    assign addr_match = rx_lp_valid && rx_lp_ready && (rx_lp_data[6:0]==self_addr);
    always @(posedge clk) begin
        if (!rst_n) begin
            addr_ok<=1'b0;
        end
        else begin
            addr_ok<=addr_match;
        end
    end

//crc5 data
    assign d = (addr_match)? 1'b0 : {rx_lp_data[2:0],d[7:0]};
    crc5 u0(
        .d(d),
        .c_out(c_out)
    );
    assign crc5_right = (c_out == rx_lp_data[3:7]);


//
    always @(posedge clk) begin
        if (!rst_n) begin
            rx_pid <= 4'b0;
        end
        else begin
            
        end
    end

    assign rx_valid = rx_lp_valid;
    assign rx_sop = rx_lp_sop;
    assign rx_eop = rx_lp_eop;
    assign rx_data = rx_lp_data;

endmodule
