`timescale 1ns / 1ps

module HexToDecAndOther(
    input [31:0]hex,//keycode
    input keynegative,//keynegative
    input keyspot,//keyspot
    output reg [31:0]dec,//keepcode
    output reg [7:0]judge//keyjudge
    );

    always @(*) begin
        judge=8'b11111111;//先将阴极全部关闭
        //用垃圾方法将十六进制的数据转换十进制
        dec=0;
        dec[3:0]=hex-hex/10*10;
        dec[7:4]=(hex-hex/100*100-dec[3:0])/10;
        dec[11:8]=(hex-hex/1000*1000-dec[7:4]*10-dec[3:0])/100;
        dec[15:12]=(hex-hex/10000*10000-dec[11:8]*100-dec[7:4]*10-dec[3:0])/1000;
        //判断阴极的状态
        if (keynegative) begin//负数时，阴极的状态变换
            if (dec[15:12] == 0 && dec[11:8] != 0) begin
                dec[19:16]=4'bx;
                judge=8'b11110000;
            end else if (dec[11:8] == 0 && dec[7:4] != 0) begin
                dec[15:12]=4'bx;
                judge=8'b11111000;
            end else if (dec[7:4] == 0 && dec[3:0] != 0) begin
                dec[11:8]=4'bx;
                judge=8'b11111100;
            end else if (dec[3:0] == 0) begin
                judge=8'b11111110;
            end
        end else if (!keyspot) begin//小数时，阴极的状态变换
            if (dec[15:12] == 0 && dec[11:8] != 0) begin
                judge=8'b11111000;
            end else if (dec[11:8] == 0 && dec[7:4] != 0) begin
                judge=8'b11111100;
            end else if (dec[7:4] == 0) begin
                judge=8'b11111100;
            end
        end else begin//其余的时候，阴极的变换
            if (dec[15:12] != 0) begin
                judge=8'b11110000;
            end else if (dec[15:12] == 0 && dec[11:8] != 0) begin
                judge=8'b11111000;
            end else if (dec[11:8] == 0 && dec[7:4] != 0) begin
                judge=8'b11111100;
            end else if (dec[7:4] == 0) begin
                judge=8'b11111110;
            end
        end
    end
    
endmodule
