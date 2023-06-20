
/* // this is the test bench.commented out. 
module testbench;
 reg [2:0] READREG1,READREG2,WRITEREG;
 reg [7:0] WRITEDATA;
 wire [7:0] REGOUT1,REGOUT2;
 reg RESET,WRITEENABLE;
 reg CLOCK;


 reg_file model2(WRITEDATA,REGOUT1,REGOUT2,WRITEREG,READREG1,READREG2,WRITEENABLE,CLOCK,RESET);

 initial
 begin
  CLOCK = 1;
  forever 
   #5 CLOCK=~CLOCK;  
 end

 initial
 begin
  $dumpfile("wavedata2.vcd");
  $dumpvars(0,model2);
  #100 $finish;
 end

 initial
  begin

   WRITEENABLE=1'b0;
   RESET=1'b0;
   

   #5
   RESET=1'b1;
   READREG1=3'd0;
   READREG2=3'd4;


   #7
   RESET=1'b0;


   #3
   WRITEREG=3'd2;
   WRITEDATA=8'd95;
   WRITEENABLE=1'b1;

   #9
   WRITEENABLE=1'b0;

   #1
   READREG1=3'd2;

   #9
   WRITEREG=3'd1;
   WRITEDATA=8'd28;
   WRITEENABLE=1'b1;
   READREG1=3'd1;

   #10
   WRITEENABLE=1'b0;

   #10
   WRITEREG=3'd4;
   WRITEDATA=8'd6;
   WRITEENABLE=1'b1;

   #10
   WRITEDATA=8'd15;

   #10
   WRITEENABLE=1'b0;




  end
endmodule

*/



`timescale 1ns/100ps


//8*8 register file
module reg_file(IN,OUT1,OUT2,INADDRESS,OUT1ADDRESS,OUT2ADDRESS,WRITE,CLK,RESET);
 input [7:0] IN;        //input data to be wriiten
 input [2:0] OUT1ADDRESS,OUT2ADDRESS,INADDRESS;  //Read or write to the corresponding addresses of these registers
 input CLK,WRITE,RESET;              
 output reg [7:0] OUT1,OUT2;       //output of the registers

 reg [7:0] register [0:7];   //register1,register2,register3,register4,register5,register6,register7;



//this block will read the register value requested in OUT1ADDRESS,OUT2ADDRESS and send it through OUT1,OUT2
//2 unit artificial time delay is added
always @(OUT1ADDRESS,OUT2ADDRESS,register[OUT1ADDRESS],register[OUT2ADDRESS])
begin
 #2OUT1=register[OUT1ADDRESS]; 
 OUT2=register[OUT2ADDRESS];
end


//At the positive edge of the clock if the write signal is high then the value IN should be wriiten to the register at the address INADDRESS
//1 UNIT artificial time delay is added
always @(posedge CLK)
begin
 if(WRITE==1'b1 && RESET==1'b0)
 begin
  #1register[INADDRESS]=IN;
 end
end


//At the rising edge of the CLK if RESET is high, all the registers should be written to zero
//1 unit time delay is added

always @(posedge CLK)
begin
 if (RESET==1'b1)
 begin
   #1register[0]=8'b00000000;
   register[1]=8'b00000000;
   register[2]=8'b00000000;
   register[3]=8'b00000000;
   register[4]=8'b00000000;
   register[5]=8'b00000000;
   register[6]=8'b00000000;
   register[7]=8'b00000000;
 end
end





endmodule  
