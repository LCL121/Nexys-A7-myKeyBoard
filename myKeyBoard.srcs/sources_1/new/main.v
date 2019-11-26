`timescale 1ns / 1ps

module top(
    input CLK100MHZ,//100MHZ的时钟信号
    input PS2_CLK,//ps2的时钟信号
    input PS2_DATA,//ps2每一个脉冲时，键盘传入的信号
    input reset,//复位信号
    input UART_RXD,
    output [6:0]SEG,//7段数码管的7个阳极
    output [7:0]AN,//7段数码管的8个阴极
    output DP,//7段数码管的小数点
    output [3:0]led,//标记现在使用了什么运算
    output infinite,//标记数据是不是无穷
    output UART_TXD//TXD和RXD分别是串行收发信号
    );
    
    reg CLK50MHZ=0;//50MHZ的时钟信号
    wire [31:0]keycode;//32位数据
    wire judgedp;//标志小数点的显示
    wire [7:0]judgean;//标志阴极是否有效

    //将100MHZ的时钟信号转换成50MHZ的时钟信号
    always @(posedge(CLK100MHZ))begin
        CLK50MHZ<=~CLK50MHZ;
    end

    //ps2数据的接收
    PS2Receiver keyboard (
    .reset(reset),
    .clk(CLK50MHZ),
    .kclk(PS2_CLK),
    .kdata(PS2_DATA),
    .keycodeout(keycode[31:0]),
    .dp(judgedp),
    .judge(judgean),
    .led(led),
    .infinite(infinite),
    .TXD(UART_TXD)
    );

    //七段数码管的显示
    seg7display sevenSeg (
    .dpjudge(judgedp),
    .reset(reset),
    .x(keycode[31:0]),
    .clk(CLK100MHZ),
    .judgean(judgean),
    .seg(SEG[6:0]),
    .an(AN[7:0]),
    .dp(DP) 
    );

endmodule
