//Wrong

module testbench;
 reg [2:0] READREG1,READREG2,WRITEREG;
 reg [7:0] WRITEDATA;
 wire [7:0] REGOUT1,REGOUT2;
 reg RESET,WRITEENABLE;
 reg CLOCK;


 reg_file model2(WRITEDATA,REGOUT1,REGOUT2,WRITEREG,READREG1,READREG2,WRITEENABLE,CLOCK,RESET);

 initial
 begin
  CLOCK = 0;
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
   READREG1=3'b000;
   READREG2=3'b001;
   WRITEENABLE=1'b0;
   RESET=1'b0;
   

   #5
   WRITEREG=3'b001;
   WRITEDATA=8'b00001111;
   WRITEENABLE=1'b1;

  end
endmodule









//8*8 register file
module reg_file(IN,OUT1,OUT2,INADDRESS,OUT1ADDRESS,OUT2ADDRESS,WRITE,CLK,RESET);
 input [7:0] IN;
 input [2:0] OUT1ADDRESS,OUT2ADDRESS,INADDRESS;
 input CLK,WRITE,RESET;
 output reg [7:0] OUT1,OUT2;

 reg [7:0] register [0:7];   //register1,register2,register3,register4,register5,register6,register7;



//this block will read the register value requested in OUT1ADDRESS and send it through OUT1


/*
 always @(OUT1ADDRESS)
 begin
  if(OUT1ADDRESS==3'b000)
  begin
   OUT1=register0;
  end

  else if(OUT1ADDRESS==3'b001)
  begin
   OUT1=register1;
  end

  else if(OUT1ADDRESS==3'b010)
  begin
   OUT1=register2;
  end

  else if(OUT1ADDRESS==3'b011)
  begin
   OUT1=register3;
  end

  else if(OUT1ADDRESS==3'b100)
  begin
   OUT1=register4;
  end

  else if(OUT1ADDRESS==3'b101)
  begin
   OUT1=register5;
  end

  else if(OUT1ADDRESS==3'b110)
  begin
   OUT1=register6;
  end 

  else 
  begin
   OUT1=register7;
  end
 end 

*/



//this block will read the register value requested in OUT2ADDRESS and send it through OUT2
 always @(OUT2ADDRESS)
 begin
  if(OUT2ADDRESS==3'b000)
  begin
   OUT2=register0;
  end

  else if(OUT2ADDRESS==3'b001)
  begin
   OUT2=register1;
  end

  else if(OUT2ADDRESS==3'b010)
  begin
   OUT2=register2;
  end

  else if(OUT2ADDRESS==3'b011)
  begin
   OUT2=register3;
  end

  else if(OUT2ADDRESS==3'b100)
  begin
   OUT2=register4;
  end

  else if(OUT2ADDRESS==3'b101)
  begin
   OUT2=register5;
  end

  else if(OUT2ADDRESS==3'b110)
  begin
   OUT2=register6;
  end 

  else 
  begin
   OUT2=register7;
  end
 end 

//At the positive edge of the clock if the write signal is high then the value IN should be wriiten to the register at the address INADDRESS

always @(posedge CLK)
begin
 if(WRITE==1'b1)
 begin
  if(INADDRESS==3'b000)
   begin
    register0=IN;
   end

  else if(INADDRESS==3'b001)
   begin
    register1=IN;
   end

  else if(INADDRESS==3'b010)
   begin
    register2=IN;
   end

  else if(INADDRESS==3'b011)
   begin
    register3=IN;
   end

  else if(INADDRESS==3'b100)
   begin
    register4=IN;
   end

  else if(INADDRESS==3'b101)
   begin
    register5=IN;
   end

  else if(INADDRESS==3'b110)
   begin
    register6=IN;
   end 

  else 
   begin
    register7=IN;
   end
 end



end


//At the rising edge of the CLK if RESET is high, all the registers should be written to zero

always @(posedge CLK)
begin
 if (RESET==1'b1)
 begin
   register0=8'b00000000;
   register1=8'b00000000;
   register2=8'b00000000;
   register3=8'b00000000;
   register4=8'b00000000;
   register5=8'b00000000;
   register6=8'b00000000;
   register7=8'b00000000;
 end
end





endmodule  

