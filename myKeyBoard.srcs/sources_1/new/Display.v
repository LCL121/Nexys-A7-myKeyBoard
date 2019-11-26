`timescale 1ns / 1ps

module seg7diplay(
    input dpjudge,//judgedp
    input reset,//reset
	input [31:0] x,//keycode[31:0]
    input clk,//CLK100MHZ
    input [7:0]judgean,
    output reg [6:0] seg,//SEG[6:0]
    output reg [7:0] an,//AN[7:0]
    output reg dp//DP
	 );
	
    wire [2:0] s;//记录第几位的7段数码管应该被显示
    reg [3:0] digit;
    //用于存储一个字节的数据
    //即当前七段数码管应该显示的数据
    wire [7:0] aen;//用于记录七段数码管的亮暗，阴极
    reg [19:0] clkdiv;
    //记录clk的脉冲次数，进行分频，刷新七段数码管
    //将近2的17次的100MHZ时钟脉冲，刷新一次七段数码管的阴极
    reg judgeanuse;
    //用于动态控制阴极的状态
    //即当前七段数码管阴极的状态
    
    assign s = clkdiv[19:17];
    //记录这次应该刷新那个阴极
    //每2的17次方的CLK100MHZ的脉冲，即1ms
    assign aen = 8'b11111111;//七段数码管最初全部不亮，阴极
    
    //4选1数据选择器
    //用于动态知道，目前位置的七段数码管的具体状态
    always @(posedge clk)
        case(s)
            0:begin
                digit = x[3:0];
                judgeanuse = judgean[0];
            end
            1:begin
                digit = x[7:4];
                judgeanuse = judgean[1];
            end
            2:begin
                digit = x[11:8];
                judgeanuse = judgean[2];
            end
            3:begin
                digit = x[15:12];
                judgeanuse = judgean[3];
            end
            4:begin
                digit = x[19:16];
                judgeanuse = judgean[4];
            end
            5:begin
                digit = x[23:20];
                judgeanuse = judgean[5];
            end
            6:begin
                digit = x[27:24];
                judgeanuse = judgean[6];
            end
            7:begin
                digit = x[31:28];
                judgeanuse = judgean[7];
            end
            default:begin
                digit = x[3:0];
                judgeanuse = judgean[0];
            end
        endcase
    
    //将十六进制到七段数码管
    //之前是为了确定键盘的扫描码
    //但是目前只用了十进制
    always @(*) begin
        if(!reset)
            case(digit)
                //高位——低位
                0:seg = 7'b1000000;	
                1:seg = 7'b1111001;
                2:seg = 7'b0100100;                                         
                3:seg = 7'b0110000;
                4:seg = 7'b0011001;
                5:seg = 7'b0010010;
                6:seg = 7'b0000010;
                7:seg = 7'b1111000;
                8:seg = 7'b0000000;
                9:seg = 7'b0010000;
                'hA:seg = 7'b0001000; 
                'hB:seg = 7'b0000011; 
                'hC:seg = 7'b1000110;
                'hD:seg = 7'b0100001;
                'hE:seg = 7'b0000110;
                'hF:seg = 7'b0001110;
                default: seg = 7'b01111111;
            endcase
        else
            seg = 7'b1000000;
    end

    //将有数据的7段数码管的阴极置0，即显示7段数码管
    always @(*) begin
        an=8'b11111111;//先将所有阴极都赋值1，不亮
        //判断当前的数码管亮不亮
        if(aen[s] == 1 && !judgeanuse)
            an[s] = 0;
        if (s == 1) begin
            dp=dpjudge;
        end else begin
            dp=1;
        end
    end

    //计数CLK100MHZ的脉冲
    always @(posedge clk) begin
        clkdiv <= clkdiv+1;
    end

endmodule
