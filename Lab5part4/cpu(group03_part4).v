//cpu for lab 5 part 3
//GROUP 3
//CO224
`include "alu.v"
`include "reg_file.v"

module cpu(PC,INSTRUCTION,CLK,RESET);

 input [31:0] INSTRUCTION;   //Current instruction to be executed-32 bits long
 input CLK,RESET;            //clock and reset signals
 output reg [31:0] PC=-32'd4;       //PC contains the address of the intruction to be read
 
 wire [31:0] PCOUT,PCBRANCH,PCNEXT;
 wire [7:0] OPCODE,IMMEDIATE,REGOUT1,REGOUT2,OPERAND2,REGOUT2COMPLIMENT,VALUE2,ALURESULT,OFFSET;
 wire [2:0] READREG1,READREG2,WRITEREG,ALUOP;
 wire MUXREGOUT2,MUXIMMEDIATE,WRITEENABLE,MUXJUMP,MUXBEG,ZERO;

 assign OPCODE=INSTRUCTION[31:24];
 assign READREG1=INSTRUCTION[10:8];  //INSTRUCTION[15:8] PROVIDES THE ADDRESS OF THE FIRST REGISTER.HOWEVER THE ADDRESS CAN BE INTERPRETED BY USING ONLY THE FIRST 3 BITS
 assign READREG2=INSTRUCTION[2:0];   //INSTRUCTION[7:0] PROVIDES THE ADDRESS OF THE SECOND REGISTER.HOWEVER THE ADDRESS CAN BE INTERPRETED BY USING ONLY THE FIRST 3 BITS
 assign IMMEDIATE=INSTRUCTION[7:0];   //THE IMMEDIATE VALUE OF loadi INSTRUCTION
 assign WRITEREG=INSTRUCTION[18:16]; //INSTRUCTION[23:16] PROVIDES THE ADDRESS OF THE WRITE REGISTER.HOWEVER THE ADDRESS CAN BE INTERPRETED BY USING ONLY THE FIRST 3 BITS
 assign OFFSET=INSTRUCTION[23:16];  // JUMP OR BRANCH OFFSET TARGET

 control_unit control_signals(OPCODE,MUXREGOUT2,MUXIMMEDIATE,WRITEENABLE,ALUOP); //generate control unit signals
 reg_file register_operation(ALURESULT,REGOUT1,REGOUT2,WRITEREG,READREG1,READREG2,WRITEENABLE,CLK,RESET); //8*8 REGISTER OPERATIONS
 compliment compliment_operation(REGOUT2,REGOUT2COMPLIMENT); //compliement of the REGOUT2 value
 compliment_mux sub_or_not(VALUE2,REGOUT2,REGOUT2COMPLIMENT,MUXREGOUT2); //check whether it is an sub operation and get the appropriate result
 immediate_mux ValueOPERAND2(OPERAND2,VALUE2,IMMEDIATE,MUXIMMEDIATE); //check whether the value of operand2 is immediate or the register value and get the output
 alu alu_result(REGOUT1, OPERAND2, ALURESULT, ALUOP);  //ALU operation
 adder pc_adder(PC,PCOUT);// Increment the pc by 4 and keep it in PCOUT
 jump_branch pc_jump_brance(PCOUT,OFFSET,PCBRANCH);//calculate the pc address for a jump or branch instruction
 pc_mux pc_final(MUXJUMP,MUXBEG,PCOUT,PCBRANCH,ZERO,PCNEXT); //decide the next pc value depending on the instruction. whether it is just an increment of 4 or a different address in a beq or jump instruction


 //pc update operation

 always @(posedge CLK)
 begin
  if(RESET==1'b0) //if reset is not enabled next instruction
  begin
   #1 PC=PCNEXT;
  end
  else
  begin
    #1 PC=32'd0; //if reset is enabled set PC to 0
  end
 end


endmodule


//control unit operations
module control_unit(OPCODE,MUXREGOUT2,MUXIMMEDIATE,MUXJUMP,MUXBEQ,WRITEENABLE,ALUOP);
 input [7:0] OPCODE;
 output reg MUXREGOUT2,MUXIMMEDIATE,WRITEENABLE,MUXJUMP,MUXBEQ;
 output reg [2:0] ALUOP;

 always @(OPCODE)
 begin

 #1 //one time unit delay for instruction decoding
 case(OPCODE)

  8'b00000000: //OPCODE FOR loadi instructions.carried out by FORWARD function in ALU.
  begin
    ALUOP=3'b000;
    MUXIMMEDIATE=1'b1;   //immediate value is taken in loadi instruction insted of the value in register2
    MUXREGOUT2=1'b1;    //2's comliment is not considered in loadi
    WRITEENABLE=1'b1;   //a value is written to a register 
    MUXBEG=1'b0;  // Not a branch if equal instruction
    MUXJUMP=1'b0; // Not a jump instruction
  end

  8'b00000001: //OPCODE for mov instructions.both carried out by ADD function in ALU
  begin
    ALUOP=3'b000;
    MUXIMMEDIATE=1'b0;  //value in register2 is taken in mov
    MUXREGOUT2=1'b1;    //2's comliment is not considered in mov
    WRITEENABLE=1'b1;     //a value is written to a register  
    MUXBEG=1'b0;  // Not a branch if equal instruction
    MUXJUMP=1'b0; // Not a jump instruction
  end

  8'b00000010: //OPCODE for add instructions.carried out by ADD function in ALU.
  begin
    ALUOP=3'b001;
    MUXIMMEDIATE=1'b0;  //value in register2 is taken in add
    MUXREGOUT2=1'b1;    //2's comliment is not considered in add
    WRITEENABLE=1'b1;     //a value is written to a register
    MUXBEG=1'b0;  // Not a branch if equal instruction
    MUXJUMP=1'b0; // Not a jump instruction      
  end

  8'b00000011: //OPCODE for sub instructions.both carried out by ADD function in ALU.
  begin
    ALUOP=3'b001;
    MUXIMMEDIATE=1'b0;  //value in register2 is taken in sub
    MUXREGOUT2=1'b0;    //2's compliment is considered in sub
    WRITEENABLE=1'b1;     //a value is written to a register
    MUXBEG=1'b0;  // Not a branch if equal instruction
    MUXJUMP=1'b0; // Not a jump instruction        
  end

  8'b00000100:             //OPCODE for and instructions.carried out by AND function in ALU
  begin
    ALUOP=3'b010;
    MUXIMMEDIATE=1'b0;  //value in register2 is taken in and
    MUXREGOUT2=1'b1;    //2's compliment is not considered in and
    WRITEENABLE=1'b1;     //a value is written to a register
    MUXBEG=1'b0;  // Not a branch if equal instruction
    MUXJUMP=1'b0; // Not a jump instruction        
  end

  8'b00000101:           //OPCODE for or instructions.carried out by OR function in ALU
  begin
    ALUOP=3'b011;
    MUXIMMEDIATE=1'b0;  //value in register2 is taken in or
    MUXREGOUT2=1'b1;    //2's compliment is not considered in or
    WRITEENABLE=1'b1;     //a value is written to a register
    MUXBEG=1'b0;  // Not a branch if equal instruction
    MUXJUMP=1'b0; // Not a jump instruction           
  end

  8'b00000110:           //OPCODE for jump instructions.ALU not used
  begin
    ALUOP=3'b011;  //ALU NOT NEEDED SO THIS COULD BE ANYTHING
    MUXIMMEDIATE=1'b0;  //doesn't matter whether the value in register 2 or immediate is taken
    MUXREGOUT2=1'b1;    //2's compliment DOSEN'T matter
    WRITEENABLE=1'b0;     //a value is NOT written to a register
    MUXBEG=1'b0;  // Not a branch if equal instruction
    MUXJUMP=1'b1; // this is a jump instruction           
  end

  8'b00000111:           //OPCODE for beq instructions.carried out by ADD function in ALU.
  begin
    ALUOP=3'b001;  //ALU performs add function
    MUXIMMEDIATE=1'b0;  //value in register2 is taken after compliment
    MUXREGOUT2=1'b0;    //2's compliment is taken
    WRITEENABLE=1'b0;     //a value is NOT written to a register
    MUXBEG=1'b1;  // branch if equal instruction is taken
    MUXJUMP=1'b0; //  Not a jump instruction           
  end     

  default: 
  begin
    ALUOP=3'b011;           //other instructions are not yet used.assigned to OR function.this doesn't mean anything.
    MUXIMMEDIATE=1'b0;  //doesn't matter either way.can be either 1 or 0
    MUXREGOUT2=1'b1;    //doesn't matter either way.can be either 1 or 0
    WRITEENABLE=1'b0;     //write is not enabled to make sure the values in registeres are not replaced by garbage values
    MUXBEG=1'b0;  // Not a branch if equal instruction
    MUXJUMP=1'b0; // Not a jump instruction           
  end
 endcase

 

 end

endmodule

//this module will compute 2's compliment of a given value
module compliment(REGOUT2,REGOUT2COMPLIMENT);
 input [7:0] REGOUT2;
 output reg [7:0] REGOUT2COMPLIMENT;
  
  always @(REGOUT2)
  begin
  #1 REGOUT2COMPLIMENT= ~REGOUT2+8'd1; //taking 2's compliment with unit time delay
  end
endmodule


//this mux will choose between register2 value and it's 2's compliment based on control signal
module compliment_mux(VALUE2,REGOUT2,REGOUT2COMPLIMENT,MUXREGOUT2);
 input [7:0] REGOUT2,REGOUT2COMPLIMENT;
 input MUXREGOUT2;
 output reg [7:0] VALUE2;

 always @(REGOUT2,REGOUT2COMPLIMENT,MUXREGOUT2)
 begin

  if(MUXREGOUT2==1'b0) //2's compliment should be the output
  begin
   VALUE2=REGOUT2COMPLIMENT;
  end

  else        //REGOUT2 value should be the output
  begin
   VALUE2=REGOUT2;
  end


 end
endmodule



//this mux will choose between register value after compliment(VALUE2) and an immediate value based on control signal
module immediate_mux(OPERAND2,VALUE2,IMMEDIATE,MUXIMMEDIATE);
 input [7:0] VALUE2,IMMEDIATE;
 input MUXIMMEDIATE;
 output reg [7:0] OPERAND2;

 always @(VALUE2,IMMEDIATE,MUXIMMEDIATE)
 begin

  if(MUXIMMEDIATE==1'b0) //REGISTER VALUE IS CONSIDERED
  begin
   OPERAND2=VALUE2;
  end

  else        //IMMEDIATE VALUE IS CONSIDERED
  begin
   OPERAND2=IMMEDIATE;
  end


 end
endmodule



//get the pc value
module adder(PC,PCOUT);
 input [31:0] PC;
 output [31:0] PCOUT;

 assign #1 PCOUT=PC+4;    //increment PC by 4
endmodule


//jump or branch instructions
module jump_branch(PCOUT,OFFSET,PCBRANCH);
 input [31:0] PCOUT;
 input [7:0] OFFSET;
 output reg [31:0] PCBRANCH;

 reg OFFSET_EXTENDED [31:0];

 

 always @(PCOUT)
 begin
   #1
   OFFSET_EXTENDED={{24{OFFSET[7]}},OFFSET};
   #2 PCBRANCH=PCOUT+OFFSET_EXTENDED; //FOR JUMP AND BEQ INSTRUCTION. THE NEXT ADDRESS OF PC IS IN PCBRANCH
 end


endmodule

module pc_mux(MUXJUMP,MUXBEG,PCOUT,PCBRANCH,ZERO,PCNEXT);
 input MUXJUMP,MUXBEG,PCOUT,PCBRANCH,ZERO;
 output reg PCNEXT;

 always @(MUXJUMP,MUXBEG,PCOUT,PCBRANCH,ZERO)
 begin
   if(MUXJUMP==1'b1)
   begin
    PCNEXT=PCBRANCH;
   end

   else if((MUXBEG&&ZERO)==1'b1)
   begin
    PCNEXT=PCBRANCH;
   end

   else
   begin
     PCNEXT=PCOUT;
   end 

 end
endmodule