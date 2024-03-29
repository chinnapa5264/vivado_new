`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.02.2024 09:46:44
// Design Name: 
// Module Name: D_flipflop_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module tb_dff;
    reg RST_n, CLK,D;
    wire Q;
    
    d_ff DFF (.clk(CLK) ,.rst_n(RST_n) ,.q(Q),.d(D));
    
    initial begin
        RST_n = 1'b0;
        CLK =1'b0;
        D =1'b0;
        #5 RST_n = 1'b1;
        #13 RST_n = 1'b0;
        #7 RST_n = 1'b1;
        #45 $finish;
    end
    
    always #3 CLK = ~CLK;
    always #6 D = ~D;
    
    always @(posedge CLK ,negedge RST_n)
    $strobe("time =%0t \t INPUD VALUES \t D =%b RST_n =%b \t OUDPUD VALUES Q =%d",$time,D,RST_n,Q);
    //$strobe will execute as a last statement in current simulation.

endmodule
