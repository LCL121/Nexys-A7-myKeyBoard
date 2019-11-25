`timescale 1ns / 1ps

module debouncer(
    input clk,//clk
    input I0,//kclk
    input I1,//kdata
    output reg O0,//kclkf
    output reg O1//kdataf
    );

    reg [4:0]cnt0, cnt1;
    //计数相同的数据CLK50MHZ时钟数
    reg Iv0=0,Iv1=0;

    //检测一次之前数据的与现在的数据是否一样
    //若输入相同，则输出
    always@(posedge clk)begin
        //判断PS2_CLK
        if (I0==Iv0)begin
            if (cnt0==19)
                O0<=I0;
            else 
                cnt0<=cnt0+1;
        end
        else begin
            cnt0<=5'b00000;
            Iv0<=I0;
        end
        //判断PS2_DATA
        if (I1==Iv1)begin
                if (cnt1==19)
                    O1<=I1;
                else 
                    cnt1<=cnt1+1;
            end
            else begin
                cnt1<=5'b00000;
                Iv1<=I1;
            end
        end
    
endmodule
