`timescale 1ns / 1ps

module PS2Receiver(
    input reset,//reset
    input clk,//CLK50MHZ
    input kclk,//PS2_CLK
    input kdata,//PS2_DATA
    output [31:0] keycodeout,//keycode[31:0]
    output dp,//judegedp
    output [7:0]judge,//judgean
    output [3:0]led,//led
    output infinite,//infinite
    output reg TXD
    );
    
    
    wire kclkf;//去抖动之后的，ps2的时钟信
    wire kdataf;//去抖动之后的，ps2每一个脉冲时，键盘传入的信号
    reg [7:0]datacur;//当前的数据
    reg [7:0]dataprev;//前一次的数据
    reg [3:0]cnt;//记录ps2的脉冲次据
    reg [31:0]keycode;//存储目前的键盘数据
    reg flag;//标志键盘数据的变化，是不是下一组数据到了
    reg [7:0]firstdata;//存储第一个数据
    reg [7:0]secondedata;//存储第二个数据
    reg [1:0]keydata;//判断目前数据
    reg [1:0]sign;//运算符标志
    //0=>+
    //1=>-
    //2=>*
    //3=>/
    reg keysign;//0时，表示还没保存符号。1时，表示已经保存符号
    reg keyspot;//0时，表示是小数
    reg keynegative;//0时，表示不是负数
    wire [31:0]keepcode;//32位数据
    wire [7:0]keyjudge;//标记阴极是否有效
    reg [7:0]deleteother;//删除其他键的扫描码
    reg [3:0]keyled;//标记现在使用了什么运算
    reg keyinfinite;//标记数据是不是无穷
    
    //数据初始化
    initial begin
        keycode[31:0]<=0'h00000000;
        cnt<=4'b0000;
        flag<=1'b0;
        keydata<=0;
        keysign<=1'b0;
        keyspot<=1;
        keynegative<=1'b0;
        deleteother<=8'b00000000;
        keyled<=4'b0000;
        keyinfinite<=1'b0;
    end
    
    //去抖动电路
    debouncer debounce(
        .clk(clk),
        .I0(kclk),
        .I1(kdata),
        .O0(kclkf),
        .O1(kdataf)
    );
    
    //ps2每次时钟信号来，记录一组键盘数据到当前数据寄存器
    always@(negedge(kclkf))begin
        case(cnt)
        0:begin
            // TXD<=1'b0;
        end//标志键盘数据开始位
        1:begin
            datacur[0]<=kdataf;
            TXD<=kdataf;
        end 
        2:begin
            datacur[1]<=kdataf;
            TXD<=kdataf;
        end 
        3:begin
            datacur[2]<=kdataf;
            TXD<=kdataf;
        end 
        4:begin
            datacur[3]<=kdataf;
            TXD<=kdataf;
        end 
        5:begin
            datacur[4]<=kdataf;
            TXD<=kdataf;
        end 
        6:begin
            datacur[5]<=kdataf;
            TXD<=kdataf;
        end 
        7:begin
            datacur[6]<=kdataf;
            TXD<=kdataf;
        end 
        8:begin
            datacur[7]<=kdataf;
            TXD<=kdataf;
        end 
        9:flag<=1'b1;
        10:begin
            flag<=1'b0;
            TXD<=kdataf;
        end 
        endcase

        //每11个脉冲一次,即ps2键盘的传数据的脉冲
        if(cnt<=9)
            cnt<=cnt+1;
        else if(cnt==10)
            cnt<=0;     
    end

    //一组数据到来或复位信号到来处理一些数据
    always @(posedge flag, posedge reset) begin
        keyinfinite=0;
        keyled=4'b0000;
        keyspot=1;
        keynegative=0;
        deleteother=8'h00;

        //当下一组数据到来时，各个数据的变化
        //最前面的数据给keycode[31:24]
        //上上组的数据给keycode[23:16]
        //上一组的数据给keycode[15:8]
        //当前组的数据给keycode[7:0]
        //构成4字节的数据，即一个按键传入的数据
        if (dataprev!=datacur) begin
            keycode[31:24]=keycode[23:16];
            keycode[23:16]=keycode[15:8];
            keycode[15:8]=dataprev;
            keycode[7:0]=datacur;
            dataprev<=datacur;
        end

        //采集数据
        if ({dataprev, datacur} == 16'hf069) begin//小键盘的1
            if (keydata==0) begin
                firstdata=1;
                keydata=1;
            end else if(keydata==3&&keysign==1) begin
                secondedata=secondedata*10+1;
            end else if (keysign==1) begin
                secondedata=1;
                keydata=3;
            end else if (keydata==1) begin
                firstdata=firstdata*10+1;
                keydata=2;
            end
        end else if ({dataprev, datacur} == 16'hf072) begin//小键盘的2
            if (keydata==0) begin
                firstdata=2;
                keydata=1;
            end else if(keydata==3&&keysign==1) begin
                secondedata=secondedata*10+2;
            end else if (keysign==1) begin
                secondedata=2;
                keydata=3;
            end else if (keydata==1) begin
                firstdata=firstdata*10+2;
                keydata=2;
            end
        end else if ({dataprev, datacur} == 16'hf07A) begin//小键盘的3
            if (keydata==0) begin
                firstdata=3;
                keydata=1;
            end else if(keydata==3&&keysign==1) begin
                secondedata=secondedata*10+3;
            end else if (keysign==1) begin
                secondedata=3;
                keydata=3;
            end else if (keydata==1) begin
                firstdata=firstdata*10+3;
                keydata=2;
            end
        end else if ({dataprev, datacur} == 16'hf06B) begin//小键盘的4
            if (keydata==0) begin
                firstdata=4;
                keydata=1;
            end else if(keydata==3&&keysign==1) begin
                secondedata=secondedata*10+4;
            end else if (keysign==1) begin
                secondedata=4;
                keydata=3;
            end else if (keydata==1) begin
                firstdata=firstdata*10+4;
                keydata=2;
            end
        end else if ({dataprev, datacur} == 16'hf073) begin//小键盘的5
            if (keydata==0) begin
                firstdata=5;
                keydata=1;
            end else if(keydata==3&&keysign==1) begin
                secondedata=secondedata*10+5;
            end else if (keysign==1) begin
                secondedata=5;
                keydata=3;
            end else if (keydata==1) begin
                firstdata=firstdata*10+5;
                keydata=2;
            end
        end else if ({dataprev, datacur} == 16'hf074) begin//小键盘的6
            if (keydata==0) begin
                firstdata=6;
                keydata=1;
            end else if(keydata==3&&keysign==1) begin
                secondedata=secondedata*10+6;
            end else if (keysign==1) begin
                secondedata=6;
                keydata=3;
            end else if (keydata==1) begin
                firstdata=firstdata*10+6;
                keydata=2;
            end
        end else if ({dataprev, datacur} == 16'hf06C) begin//小键盘的7
            if (keydata==0) begin
                firstdata=7;
                keydata=1;
            end else if(keydata==3&&keysign==1) begin
                secondedata=secondedata*10+7;
            end else if (keysign==1) begin
                secondedata=7;
                keydata=3;
            end else if (keydata==1) begin
                firstdata=firstdata*10+7;
                keydata=2;
            end
        end else if ({dataprev, datacur} == 16'hf075) begin//小键盘的8
            if (keydata==0) begin
                firstdata=8;
                keydata=1;
            end else if(keydata==3&&keysign==1) begin
                secondedata=secondedata*10+8;
            end else if (keysign==1) begin
                secondedata=8;
                keydata=3;
            end else if (keydata==1) begin
                firstdata=firstdata*10+8;
                keydata=2;
            end
        end else if ({dataprev, datacur} == 16'hf07D) begin//小键盘的9
            if (keydata==0) begin
                firstdata=9;
                keydata=1;
            end else if(keydata==3&&keysign==1) begin
                secondedata=secondedata*10+9;
            end else if (keysign==1) begin
                secondedata=9;
                keydata=3;
            end else if (keydata==1) begin
                firstdata=firstdata*10+9;
                keydata=2;
            end
        end else if ({dataprev, datacur} == 16'hf070) begin//小键盘的0
            if (keydata==0) begin
                firstdata=0;
                keydata=1;
            end else if(keydata==3&&keysign==1) begin
                secondedata=secondedata*10+0;
            end else if (keysign==1) begin
                secondedata=0;
                keydata=3;
            end else if (keydata==1) begin
                firstdata=firstdata*10+0;
                keydata=2;
            end
        end

        //采集运算符
        if ({dataprev, datacur} == 16'hf079) begin//小键盘的+
            deleteother=8'hff;
            keyled=4'b0001;
            if (!keysign) begin
                sign=0;
                keysign=1'b1;
            end
        end else if ({dataprev, datacur} == 16'hf07B) begin//小键盘的-
            deleteother=8'hff;
            keyled=4'b0010;
            if (!keysign) begin
                sign=1;
                keysign=1'b1;
            end
        end else if ({dataprev, datacur} == 16'hf07C) begin//小键盘的*
            deleteother=8'hff;
            keyled=4'b0100;
            if (!keysign) begin
                sign=2;
                keysign=1'b1;
            end 
        end else if ({dataprev, datacur} == 16'hf04A) begin//小键盘的/
            deleteother=8'hff;
            keyled=4'b1000;
            if (!keysign) begin
                sign=3;
                keysign=1'b1;
            end
        end

        //运算符的按下去时的码
        if ({dataprev, datacur} == 16'he04A) begin
            deleteother=8'hff;
            keyled=4'b1000;
        end
        if ({dataprev, datacur} == 16'he05a) begin
            deleteother=8'hff;
            keyled=4'b1111;
        end

        //在输入数据时，七段数码管的显示
        if (({dataprev, datacur} == 16'hf069) || 
        ({dataprev, datacur} == 16'hf072) ||
        ({dataprev, datacur} == 16'hf07A) ||
        ({dataprev, datacur} == 16'hf06B) ||
        ({dataprev, datacur} == 16'hf073) ||
        ({dataprev, datacur} == 16'hf074) ||
        ({dataprev, datacur} == 16'hf06C) ||
        ({dataprev, datacur} == 16'hf075) ||
        ({dataprev, datacur} == 16'hf07D) ||
        ({dataprev, datacur} == 16'hf070)) begin
            keycode=firstdata;
            if (keydata>1&&keysign==1) begin
                keycode=secondedata;
            end
        end

        //计算
        if ({dataprev, datacur} == 16'hf05a && keysign == 1'b1&&keydata==3) begin//小键盘的enter
            keyled=4'b1111;
            if (sign == 0) begin
                keycode=firstdata+secondedata;
                keyspot=1;
            end else if (sign == 1) begin
                keycode=firstdata-secondedata;
                keyspot=1;
                if (firstdata < secondedata) begin
                    keycode=secondedata-firstdata;
                    keynegative=1;
                end
            end else if (sign == 2) begin
                keycode=firstdata*secondedata;
                keyspot=1;
            end else if (sign == 3) begin
                keycode=firstdata/secondedata;
                keyspot=1;
                if (secondedata == 0) begin
                    keycode=0;
                    keyinfinite=1;
                end else if (firstdata != keycode*secondedata) begin
                    keyspot=0;
                    keycode=firstdata*10/secondedata;
                end
            end
            keysign=1'b0;
            firstdata=0;
            secondedata=0;
            keydata=0;
            deleteother=8'h00;
        end

        //复位，清除所有数据，标志数据
        if (reset) begin
            keycode=32'b0;
            keysign=1'b0;
            firstdata=0;
            secondedata=0;
            keydata=0;
            keyspot=1;
            deleteother=8'h00;
            keyled=4'b0000;
            keyinfinite=1'b0;
        end
    end

    //将十六进制的数据转换十进制显示
    //并且判断阴极的状态
    HexToDecAndOther one(keycode,keynegative,keyspot,keepcode,keyjudge);


    //输出数据
    assign keycodeout=keepcode;
    assign dp=keyspot;
    assign judge= (deleteother != 0) ? deleteother : keyjudge;
    assign led = keyled;
    assign infinite = keyinfinite;
  
endmodule
