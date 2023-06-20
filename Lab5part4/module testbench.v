module testbench;

 wire [2:0] AA;
 reg  [4:0] BB;
 wire [4:0] CC;
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
  AA=3'b011;
   
  #5
  $finish;


 end

 
 BB={{2{AA[2]}},AA};

 always @(CC)
 begin
 #1
   DD=BB+CC;
 end
endmodule
