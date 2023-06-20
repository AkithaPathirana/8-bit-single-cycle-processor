`include "alu_extend.v"
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






module alu(DATA1, DATA2, RESULT, SELECT,ZERO);
 input [7:0] DATA1,DATA2; // INPUT DATA TO THE ALU
 input [2:0] SELECT;       // THIS WILL DECIDE THE CORRESPONDING OUTPUT RESULT FROM THE OUTPUTS OF FUNCTIONAL UNITS
 output [7:0] RESULT;
 output ZERO;
 wire [7:0] FORWARD_OUT, ADD_OUT, AND_OUT, OR_OUT,SHIFT_OUT,ARISHIFT_OUT,CRISHIFT_OUT,MULTI_OUT; // these will be the outputs of the functional units

 FORWARD forward_result(DATA2, FORWARD_OUT); //FORWARD FUNCTION  
 ADD add_result(DATA1,DATA2, ADD_OUT);      //ADD FUNCTION
 AND and_result(DATA1, DATA2, AND_OUT);     //AND  FUNCTION
 OR or_result(DATA1, DATA2, OR_OUT);        //OR FUNCTION

 ZERO_MUX ZERO_MUX_result(ADD_OUT,ZERO); //IF THE OUTPUT OF AN ADD/SUB OPEARION IS 0 THEN ZERO SIGNAL WILL BE HIGH  
 SHIFT_LR SHIFT_LR_result(SHIFT_OUT,DATA1,DATA2); //logical shift left or right
 SHIFT_ARI SHIFT_ARI_result(ARISHIFT_OUT,DATA1,DATA2); //arithmatic shift right
 SHIFT_CRI SHIFT_CRI_result(CRISHIFT_OUT,DATA1,DATA2); //rotate right shifts
 MUX mux_result(MULTI_OUT,CRISHIFT_OUT,ARISHIFT_OUT,SHIFT_OUT,SELECT,FORWARD_OUT, ADD_OUT, AND_OUT, OR_OUT,RESULT);  // RESULT OUTPUT WILL BE DECIDED FROM THE OUTPUTS OF THE FUNCTIONAL UNITS
 MULTIPLY multy_result(DATA1,DATA2,MULTI_OUT); //RESULT OF THE MULTIPLY OPERATION
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


module MUX(MULTI_OUT,CRISHIFT_OUT,ARISHIFT_OUT,SHIFT_OUT,SELECT,FORWARD_OUT, ADD_OUT, AND_OUT, OR_OUT,RESULT); //THE MUX IS USED TO GET THE RESULT OF THE DESIRED FUNCTION

input [7:0] FORWARD_OUT, ADD_OUT, AND_OUT, OR_OUT,CRISHIFT_OUT,ARISHIFT_OUT,SHIFT_OUT,MULTI_OUT;
input [2:0] SELECT;
output reg [7:0] RESULT;
output reg ZERO;



always @ (MULTI_OUT,CRISHIFT_OUT,ARISHIFT_OUT,SHIFT_OUT,SELECT,FORWARD_OUT, ADD_OUT, AND_OUT, OR_OUT,RESULT)
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

  else if(SELECT == 3'b100)
  begin
    RESULT = SHIFT_OUT;
  end  

  else if(SELECT == 3'b101)
  begin
    RESULT = ARISHIFT_OUT;
  end  

  else if(SELECT == 3'b110)
  begin
    RESULT = CRISHIFT_OUT;
  end        

  else
  begin
    RESULT = MULTI_OUT;
  end  
end
endmodule


module ZERO_MUX(ADD_OUT,ZERO); //IF THE OUTPUT OF AN ADD OPERATION IS 0 THEN ZERO IS HIGH ELSE IT IS LOW.USED IN BEQ OPERATIONS
 input [7:0] ADD_OUT;
 output reg ZERO;

 always @(ADD_OUT)
 begin
   if(ADD_OUT==8'd0)
   begin
     ZERO=1'd1;
   end

   else
   begin
     ZERO=1'd0;
   end 
 end

endmodule



module SHIFT_LR(SHIFT_OUT,DATA1,DATA2); //logical shift left or right
 input [7:0] DATA1,DATA2;
 output reg [7:0] SHIFT_OUT;

 wire SHIFTTYPE;
 reg [7:0] SHIFTVALUE;
 wire [7:0] p1,p2,p3,p4,p5,p6,p7,p8;

 assign SHIFTTYPE=DATA2[7];
 always @(DATA2)
 begin
   SHIFTVALUE=DATA2;
   SHIFTVALUE[7]=1'b0;
 end
 
 logic_general_shift m1(DATA1,SHIFTTYPE,p1);
 logic_general_shift m2(p1,SHIFTTYPE,p2);
 logic_general_shift m3(p2,SHIFTTYPE,p3);
 logic_general_shift m4(p3,SHIFTTYPE,p4);
 logic_general_shift m5(p4,SHIFTTYPE,p5);
 logic_general_shift m6(p5,SHIFTTYPE,p6);
 logic_general_shift m7(p6,SHIFTTYPE,p7);
 logic_general_shift m8(p7,SHIFTTYPE,p8);


 always @(p1,p2,p3,p4,p5,p6,p7,p8)
 begin
   case(SHIFTVALUE)
    8'b00000000: 
    begin
      SHIFT_OUT=DATA1;
    end

    8'b00000001: 
    begin
      SHIFT_OUT=p1;
    end  

    8'b00000010: 
    begin
      SHIFT_OUT=p2;
    end

    8'b00000011: 
    begin
      SHIFT_OUT=p3;
    end

    8'b00000100: 
    begin
      SHIFT_OUT=p4;
    end

    8'b00000101: 
    begin
      SHIFT_OUT=p5;
    end

    8'b00000110: 
    begin
      SHIFT_OUT=p6;
    end

    8'b00000111: 
    begin
      SHIFT_OUT=p7;
    end    

    8'b00001000: 
    begin
      SHIFT_OUT=p8;
    end

    default: 
    begin
      SHIFT_OUT=8'b00000000;
    end
  endcase  

 end




endmodule









module SHIFT_ARI(ARISHIFT_OUT,DATA1,DATA2); //Arithmetic shift right

 input [7:0] DATA1,DATA2;
 output reg [7:0] ARISHIFT_OUT;

 wire SHIFT=1'b1;
 wire LIN;

 wire [7:0] p1,p2,p3,p4,p5,p6,p7,p8;
 assign LIN=DATA1[7];

 
  right_shift m1(DATA1,LIN,SHIFT,p1);
  right_shift m2(p1,LIN,SHIFT,p2);
  right_shift m3(p2,LIN,SHIFT,p3);
  right_shift m4(p3,LIN,SHIFT,p4);
  right_shift m5(p4,LIN,SHIFT,p5);
  right_shift m6(p5,LIN,SHIFT,p6);
  right_shift m7(p6,LIN,SHIFT,p7);
  right_shift m8(p7,LIN,SHIFT,p8);


 always @(p1,p2,p3,p4,p5,p6,p7,p8)
 begin
   case(DATA2)
    8'b00000000: 
    begin
      ARISHIFT_OUT=DATA1;
    end

    8'b00000001: 
    begin
      ARISHIFT_OUT=p1;
    end  

    8'b00000010: 
    begin
      ARISHIFT_OUT=p2;
    end

    8'b00000011: 
    begin
      ARISHIFT_OUT=p3;
    end

    8'b00000100: 
    begin
      ARISHIFT_OUT=p4;
    end

    8'b00000101: 
    begin
      ARISHIFT_OUT=p5;
    end

    8'b00000110: 
    begin
      ARISHIFT_OUT=p6;
    end

    8'b00000111: 
    begin
      ARISHIFT_OUT=p7;
    end    

    8'b00001000: 
    begin
      ARISHIFT_OUT=p8;
    end

    default: 
    begin
      ARISHIFT_OUT=p8;
    end  
   endcase     
 end




endmodule






module SHIFT_CRI(CRISHIFT_OUT,DATA1,DATA2); //rotate right 
 input [7:0] DATA1,DATA2;
 output reg [7:0] CRISHIFT_OUT;

 wire SHIFT=1'b1;


 wire [7:0] p1,p2,p3,p4,p5,p6,p7,p8;


 
  right_shift m1(DATA1,DATA1[0],SHIFT,p1);
  right_shift m2(p1,p1[0],SHIFT,p2);
  right_shift m3(p2,p2[0],SHIFT,p3);
  right_shift m4(p3,p3[0],SHIFT,p4);
  right_shift m5(p4,p4[0],SHIFT,p5);
  right_shift m6(p5,p5[0],SHIFT,p6);
  right_shift m7(p6,p6[0],SHIFT,p7);
  right_shift m8(p7,p7[0],SHIFT,p8);


 always @(p1,p2,p3,p4,p5,p6,p7,p8)
 begin
   case(DATA2)
    8'b00000000: 
    begin
      CRISHIFT_OUT=DATA1;
    end

    8'b00000001: 
    begin
      CRISHIFT_OUT=p1;
    end  

    8'b00000010: 
    begin
      CRISHIFT_OUT=p2;
    end

    8'b00000011: 
    begin
      CRISHIFT_OUT=p3;
    end

    8'b00000100: 
    begin
      CRISHIFT_OUT=p4;
    end

    8'b00000101: 
    begin
      CRISHIFT_OUT=p5;
    end

    8'b00000110: 
    begin
      CRISHIFT_OUT=p6;
    end

    8'b00000111: 
    begin
      CRISHIFT_OUT=p7;
    end    

    8'b00001000: 
    begin
      CRISHIFT_OUT=p8;
    end

    default: 
    begin
      CRISHIFT_OUT=p8;
    end   
   endcase 

 end




endmodule


module MULTIPLY(DATA1,DATA2,MULTI_OUT); //Multiply 2 values
 input [7:0] DATA1,DATA2;
 output  [7:0] MULTI_OUT;
 reg [7:0] Y=8'b00000000;
 wire C1,C2,C3,C4,C5,C6,C7,C8;
 wire [7:0] A,B,C,D,E,F,G,H,I,J,K,L,M,N,O;
 reg [7:0] MUL1;
 wire [7:0] MUL2,MUL3,MUL4,MUL5,MUL6,MUL7,MUL8;
 reg SHIFT=1'b1;

 always @(DATA1,DATA2)
 begin
   MUL1=DATA2;
 end
 
 //1 ST DIGIT 
 add_result a1(DATA1,Y,A,C1,MUL1[0]);
 right_shift s1(MUL1,A[0],SHIFT,MUL2);
 right_shift d1(A,C1,SHIFT,B);

 //2 ND DIGIT 
 add_result a2(DATA1,B,C,C2,MUL2[0]);
 right_shift s2(MUL2,C[0],SHIFT,MUL3);
 right_shift d2(C,C2,SHIFT,D);

 
 //3 RD DIGIT 
 add_result a3(DATA1,D,E,C3,MUL3[0]);
 right_shift s3(MUL3,E[0],SHIFT,MUL4);
 right_shift d3(E,C3,SHIFT,F);

 //4 TH DIGIT 
 add_result a4(DATA1,F,G,C4,MUL4[0]);
 right_shift s4(MUL4,G[0],SHIFT,MUL5);
 right_shift d4(G,C4,SHIFT,H);

 //5 TH DIGIT 
 add_result a5(DATA1,H,I,C5,MUL5[0]);
 right_shift s5(MUL5,I[0],SHIFT,MUL6);
 right_shift d5(I,C5,SHIFT,J);

 //6 TH DIGIT 
 add_result a6(DATA1,J,K,C6,MUL6[0]);
 right_shift s6(MUL6,K[0],SHIFT,MUL7);
 right_shift d6(K,C6,SHIFT,L);

 //7 TH DIGIT 
 add_result a7(DATA1,L,M,C7,MUL7[0]);
 right_shift s7(MUL7,M[0],SHIFT,MUL8);
 right_shift d7(M,C7,SHIFT,N);

 //8 ST DIGIT 
 add_result a8(DATA1,N,O,C8,MUL8[0]);
 right_shift s8(MUL8,O[0],SHIFT,MULTI_OUT);






endmodule