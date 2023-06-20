module testbench;

 reg [2:0] AA;

 wire [2:0] EE;
 reg  [4:0] BB;
 reg [4:0] CC;
 reg [4:0]  DD;


 initial
 begin

 $dumpfile("test.vcd");
 $dumpvars(0, testbench);

  #1
    CC=5'b01010;
  #1
    AA=3'b001;


  

  #5
    CC=5'b00010; 
  #1
    AA=3'b111;
   
  #5
  $finish;


 end

 assign EE=AA;
 

 always @(CC)
 begin
 #1
   BB[4:0]={{2{EE[2]}},EE[2:0]};
 #1  
   DD=BB+CC;
 end
endmodule
