
//add two bits, get sum and carry- gate implementation
module gate_adder(A,B,CIN,SUM,COUT);
 input A,B,CIN;
 output SUM,COUT;
 wire S1,C1,S2;

 xor xo1(S1,A,B);
 and a1(C1,A,B);
 and a2(S2,S1,CIN);
 xor xo2(SUM,S1,CIN);
 xor xo3(COUT,S2,C1);

endmodule 

//ripple adder of two 8 bit numbers-gate level implementation
module ripple_adder(NUM1,NUM2,ADDITION,CARRY);
 input [7:0] NUM1,NUM2;
 output [7:0] ADDITION;
 output CARRY;

 wire CIN=1'b0;
 wire COUT[7:0];
 gate_adder g1(NUM1[0],NUM2[0],CIN,ADDITION[0],COUT[0]);
 gate_adder g2(NUM1[1],NUM2[1],COUT[0],ADDITION[1],COUT[1]);
 gate_adder g3(NUM1[2],NUM2[2],COUT[1],ADDITION[2],COUT[2]);
 gate_adder g4(NUM1[3],NUM2[3],COUT[2],ADDITION[3],COUT[3]);
 gate_adder g5(NUM1[4],NUM2[4],COUT[3],ADDITION[4],COUT[4]);
 gate_adder g6(NUM1[5],NUM2[5],COUT[4],ADDITION[5],COUT[5]);
 gate_adder g7(NUM1[6],NUM2[6],COUT[5],ADDITION[6],COUT[6]);
 gate_adder g8(NUM1[7],NUM2[7],COUT[6],ADDITION[7],CARRY);
endmodule

//depending on a switch add two 8 bit numbers
module add_result(NUM1,NUM2,RESULTADD,RESULTCARRY,SWITCH);
 input [7:0] NUM1,NUM2;
 input SWITCH;
 output reg [7:0] RESULTADD;
 output reg RESULTCARRY;
 reg [7:0] OPE1=8'b00000000;
 wire [7:0] ADDITION1,ADDITION2;
 wire CARRY1,CARRY2;

 ripple_adder R1(NUM1,NUM2,ADDITION1,CARRY1);
 ripple_adder R2(OPE1,NUM2,ADDITION2,CARRY2); 

 always @(NUM1,NUM2,SWITCH,ADDITION1,ADDITION2)
 begin
   if(SWITCH==1'b0)
   begin
     RESULTADD=ADDITION2;
     RESULTCARRY=CARRY2;
   end
   else
   begin
     RESULTADD=ADDITION1;
     RESULTCARRY=CARRY1;     
   end
 end

endmodule

//right shift for arithmetic and rotate operations-gate level implementation
module right_shift(INVALUE,LIN,SHIFT,SHIFTVALUE);
 input [7:0] INVALUE;
 input LIN,SHIFT;
 output [7:0] SHIFTVALUE;

 wire SNOT,A,B,C,D,E,F,G,H;
 
 not n1(SNOT,SHIFT);

 and a3(A,INVALUE[0],SNOT);
 and a4(B,INVALUE[1],SHIFT);
 or  o1(SHIFTVALUE[0],A,B);

 and a5(C,INVALUE[1],SNOT);
 and a6(D,INVALUE[2],SHIFT);
 or  o2(SHIFTVALUE[1],C,D);

 and a7(E,INVALUE[2],SNOT);
 and a8(F,INVALUE[3],SHIFT);
 or  o3(SHIFTVALUE[2],E,F);

 and a9(G,INVALUE[3],SNOT);
 and a10(H,INVALUE[4],SHIFT);
 or  o4(SHIFTVALUE[3],G,H);

 and a11(I,INVALUE[4],SNOT);
 and a12(J,INVALUE[5],SHIFT);
 or  o5(SHIFTVALUE[4],I,J);

 and a13(K,INVALUE[5],SNOT);
 and a14(L,INVALUE[6],SHIFT);
 or  o6(SHIFTVALUE[5],K,L);

 and a15(M,INVALUE[6],SNOT);
 and a16(N,INVALUE[7],SHIFT);
 or  o7(SHIFTVALUE[6],M,N);

 and a17(O,INVALUE[7],SNOT);
 and a18(P,LIN,SHIFT);
 or  o8(SHIFTVALUE[7],O,P);


endmodule 


//logic shift both right and left depending on a parameter

module logic_general_shift(INVALUE,SHIFTTYPE,SHIFTVALUE);
 input [7:0] INVALUE;
 input SHIFTTYPE; //0 FOR LEFT SHIFT BY 1 POSITION. 1 FOR RIGHT SHIFT BY 1 POSITION.
 output [7:0] SHIFTVALUE;

 wire SNOT,A,C,D,E,F,G,H,I,J,K,L,N;
 
 not n1(SNOT,SHIFTTYPE);

 and a3(A,INVALUE[7],SHIFTTYPE);
 and a4(SHIFTVALUE[7],INVALUE[6],SNOT);
 and a5(C,INVALUE[6],SHIFTTYPE);
 and a6(D,INVALUE[5],SNOT);
 and a7(E,INVALUE[5],SHIFTTYPE);
 and a8(F,INVALUE[4],SNOT); 
 and a9(G,INVALUE[4],SHIFTTYPE);
 and a10(H,INVALUE[3],SNOT);
 and a11(I,INVALUE[3],SHIFTTYPE);
 and a12(J,INVALUE[2],SNOT);
 and a13(K,INVALUE[2],SHIFTTYPE);
 and a14(L,INVALUE[1],SNOT);
 and a15(SHIFTVALUE[0],INVALUE[1],SHIFTTYPE);
 and a16(N,INVALUE[0],SNOT);



 or  o1(SHIFTVALUE[6],A,D); 
 or  o2(SHIFTVALUE[5],C,F);
 or  o3(SHIFTVALUE[4],E,H);
 or  o4(SHIFTVALUE[3],G,J);
 or  o5(SHIFTVALUE[2],I,L);
 or  o6(SHIFTVALUE[1],K,N);



endmodule 







