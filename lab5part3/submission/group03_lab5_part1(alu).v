
/* //used as the test bench.commented out 
module testbench;

 reg [7:0] OPERAND1,OPERAND2;
 reg [2:0] ALUOP;
 wire [7:0] ALURESULT;


 alu model1(OPERAND1,OPERAND2, ALURESULT, ALUOP); 

 initial
 begin
 //$monitor($time,"OPERAND1:%b, OPERAND2:%b, ALUOP:%b ALURESULT:%b",OPERAND1,OPERAND2,ALUOP,ALURESULT);
 $dumpfile("wavedata.vcd");
 $dumpvars(0,model1);
 #100 $finish;
 end

 initial
 begin
 OPERAND1=8'd5;
 OPERAND2=8'd1;
 ALUOP=3'b000;


 #10
 OPERAND1=8'd54;
 ALUOP=3'b001;
 #1
 OPERAND2=8'd45;
 ALUOP=3'b001;
 #10ALUOP=3'b010; 
 #10ALUOP=3'b011;
 
 end
endmodule

*/






module alu(DATA1, DATA2, RESULT, SELECT);
 input [7:0] DATA1,DATA2; // INPUT DATA TO THE ALU
 input [2:0] SELECT;       // THIS WILL DECIDE THE CORRESPONDING OUTPUT RESULT FROM THE OUTPUTS OF FUNCTIONAL UNITS
 output [7:0] RESULT;
 wire [7:0] FORWARD_OUT, ADD_OUT, AND_OUT, OR_OUT; // these will be the outputs of the functional units

 FORWARD forward_result(DATA2, FORWARD_OUT); //FORWARD FUNCTION  
 ADD add_result(DATA1,DATA2, ADD_OUT);      //ADD FUNCTION
 AND and_result(DATA1, DATA2, AND_OUT);     //AND  FUNCTION
 OR or_result(DATA1, DATA2, OR_OUT);        //OR FUNCTION
 MUX mux_result(SELECT,FORWARD_OUT, ADD_OUT, AND_OUT, OR_OUT,RESULT);  // RESULT OUTPUT WILL BE DECIDED FROM THE OUTPUTS OF THE FUNCTIONAL UNITS
 
endmodule





module FORWARD(DATA2, FORWARD_OUT);   //JUST FORWARD THE OUTPUT (loadi,mov)
 input [7:0] DATA2;
 output [7:0] FORWARD_OUT;

 assign  #1FORWARD_OUT=DATA2;  //DELAY 1 UNIT

endmodule


module ADD(DATA1,DATA2, ADD_OUT); //Addition and substraction operations
input [7:0] DATA1,DATA2;
output [7:0]ADD_OUT;

assign  #2ADD_OUT=DATA1+DATA2;  //DELAY 2 UNITS

endmodule

module AND(DATA1, DATA2, AND_OUT); //AND OPERATION
 input [7:0] DATA1,DATA2;
 output [7:0] AND_OUT;

 assign  #1AND_OUT=DATA1&DATA2;  //DELAY 1 UNIT

endmodule

module OR(DATA1, DATA2, OR_OUT); //OR OPERATION
 input [7:0] DATA1,DATA2;
 output [7:0] OR_OUT;

 assign  #1OR_OUT=DATA1|DATA2;  //DELAY 1 UNIT

endmodule


module MUX(SELECT,FORWARD_OUT, ADD_OUT, AND_OUT, OR_OUT,RESULT); //THE MUX IS USED TO GET THE RESULT OF THE DESIRED FUNCTION

input [7:0] FORWARD_OUT, ADD_OUT, AND_OUT, OR_OUT;
input [2:0] SELECT;
output reg [7:0] RESULT;



always @ (SELECT,FORWARD_OUT, ADD_OUT, AND_OUT, OR_OUT)
begin
  if(SELECT == 3'b000)
  begin
    RESULT = FORWARD_OUT;
  end

  else if(SELECT == 3'b001)
  begin
    RESULT = ADD_OUT;
  end  

  else if(SELECT == 3'b010)
  begin
    RESULT = AND_OUT;
  end

  else if(SELECT == 3'b011)
  begin
    RESULT = OR_OUT;
  end  

  else
  begin
    RESULT = OR_OUT;
  end  
end
endmodule