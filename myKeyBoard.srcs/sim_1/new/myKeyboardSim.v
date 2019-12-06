`timescale 1ns / 1ps

module myKeyboardSim;

reg CLK100MHZ;
reg PS2_CLK;
reg PS2_DATA;
reg reset;
reg UART_RXD;
wire [6:0]SEG;
wire [7:0]AN;
wire DP;
wire [3:0]led;
wire infinite;
wire UART_TXD;

main one(CLK100MHZ, PS2_CLK, PS2_DATA, reset, UART_RXD, SEG, AN, DP, led, infinite, UART_TXD);

initial
    forever
        begin
            CLK100MHZ = 0;
            #1;
            CLK100MHZ = 1;
            #1;
        end

initial
    forever
        begin
            PS2_CLK = 0;
            #2;
            PS2_CLK = 1;
            #2;
        end

initial
    forever
        begin
            PS2_DATA = 0;
            #2;
            PS2_DATA = 1;
            #2;
        end

initial
    begin
        reset = 0;
    end

endmodule
