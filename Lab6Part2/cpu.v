//cpu for lab 6 part 1
//GROUP 3
//CO224
`include "alu.v"
`include "reg_file.v"
`timescale 1ns/100ps

module cpu(PC,INSTRUCTION,CLK,RESET,READ,WRITE,BUSYWAIT,READDATA,ALURESULT,REGOUT1);

 input [31:0] INSTRUCTION;   //Current instruction to be executed-32 bits long
 input [7:0] READDATA; // Data input from the data memory
 input CLK,RESET,BUSYWAIT;            //clock, reset And Busy Wait(To freeze cpu while data memory operations are going) signals
 output reg [31:0] PC=-32'd4;       //PC contains the address of the intruction to be read
 output  READ,WRITE;   // Read and Write control signals to Data Memory
 output  [7:0] ALURESULT,REGOUT1; //Result of the alu operation AND value of the Register at READREG1
 
 wire [31:0] PCOUT,PCBRANCH,PCNEXT;
 wire [7:0] OPCODE,IMMEDIATE,REGOUT2,OPERAND2,REGOUT2COMPLIMENT,VALUE2,OFFSET,WRITERESULT;
 wire [2:0] READREG1,READREG2,WRITEREG,ALUOP;
 wire MUXREGOUT2,MUXIMMEDIATE,WRITEENABLE,MUXJUMP,MUXBEQ,ZERO,PICKWRITE;

 assign OPCODE=INSTRUCTION[31:24];
 assign READREG1=INSTRUCTION[10:8];  //INSTRUCTION[15:8] PROVIDES THE ADDRESS OF THE FIRST REGISTER.HOWEVER THE ADDRESS CAN BE INTERPRETED BY USING ONLY THE FIRST 3 BITS
 assign READREG2=INSTRUCTION[2:0];   //INSTRUCTION[7:0] PROVIDES THE ADDRESS OF THE SECOND REGISTER.HOWEVER THE ADDRESS CAN BE INTERPRETED BY USING ONLY THE FIRST 3 BITS
 assign IMMEDIATE=INSTRUCTION[7:0];   //THE IMMEDIATE VALUE OF loadi INSTRUCTION
 assign WRITEREG=INSTRUCTION[18:16]; //INSTRUCTION[23:16] PROVIDES THE ADDRESS OF THE WRITE REGISTER.HOWEVER THE ADDRESS CAN BE INTERPRETED BY USING ONLY THE FIRST 3 BITS
 assign OFFSET=INSTRUCTION[23:16];  // JUMP OR BRANCH OFFSET TARGET

 control_unit control_signals(OPCODE,MUXREGOUT2,MUXIMMEDIATE,MUXJUMP,MUXBEQ,WRITEENABLE,ALUOP,READ,WRITE,PICKWRITE,BUSYWAIT); //generate control unit signals
 reg_file register_operation(WRITERESULT,REGOUT1,REGOUT2,WRITEREG,READREG1,READREG2,WRITEENABLE,CLK,RESET); //8*8 REGISTER OPERATIONS
 compliment compliment_operation(REGOUT2,REGOUT2COMPLIMENT); //compliement of the REGOUT2 value
 compliment_mux sub_or_not(VALUE2,REGOUT2,REGOUT2COMPLIMENT,MUXREGOUT2); //check whether it is an sub operation and get the appropriate result
 immediate_mux ValueOPERAND2(OPERAND2,VALUE2,IMMEDIATE,MUXIMMEDIATE); //check whether the value of operand2 is immediate or the register value and get the output
 alu alu_result(REGOUT1, OPERAND2, ALURESULT, ALUOP,ZERO);  //ALU operation
 adder pc_adder(PC,PCOUT);// Increment the pc by 4 and keep it in PCOUT
 jump_branch pc_jump_branch(ALUOP,PCOUT,OFFSET,PCBRANCH);//calculate the pc address for a jump or branch instruction
 pc_mux pc_final(MUXJUMP,MUXBEQ,PCOUT,PCBRANCH,ZERO,PCNEXT); //decide the next pc value depending on the instruction. whether it is just an increment of 4 or a different address in a beq or jump instruction
 choosewrite_mux write_alu_or_mem(READDATA,ALURESULT,PICKWRITE,WRITERESULT); // to decide whether to write to register from alu or memory

 //pc update operation

 always @(posedge CLK)
 begin
  if(RESET==1'b0 && BUSYWAIT==1'b0) //if reset and busy wait are not enabled next instruction
  begin
   #1 PC=PCNEXT;
  end

  else if(BUSYWAIT==1'b1&& RESET==1'b0) // if busy wait is enabled. don't change pc
  begin
     PC=PC;
  end

  else
  begin
    #1 PC=32'd0; //if reset is enabled set PC to 0
  end  

 end


endmodule


//control unit operations
module control_unit(OPCODE,MUXREGOUT2,MUXIMMEDIATE,MUXJUMP,MUXBEQ,WRITEENABLE,ALUOP,READ,WRITE,PICKWRITE,BUSYWAIT);
 input [7:0] OPCODE;
 input BUSYWAIT;
 output reg MUXREGOUT2,MUXIMMEDIATE,WRITEENABLE,MUXJUMP,MUXBEQ,READ,WRITE,PICKWRITE;
 output reg [2:0] ALUOP;

 reg MEMREAD,MEMWRITE;//to indicate that a value is being read from the memory OR WRITTEN TO MEMORY

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
    MUXBEQ=1'b0;  // Not a branch if equal instruction
    MUXJUMP=1'b0; // Not a jump instruction
    READ=1'b0; // Not a READ INSTRUCTION FROM THE DATA MEMORY
    WRITE=1'b0; // Not a WRITE INSTRUCTION TO THE DATA MEMORY
    PICKWRITE=1'b0; // Value to be written to the register is not from the data memory
  end

  8'b00000001: //OPCODE for mov instructions.both carried out by ADD function in ALU
  begin
    ALUOP=3'b000;
    MUXIMMEDIATE=1'b0;  //value in register2 is taken in mov
    MUXREGOUT2=1'b1;    //2's comliment is not considered in mov
    WRITEENABLE=1'b1;     //a value is written to a register  
    MUXBEQ=1'b0;  // Not a branch if equal instruction
    MUXJUMP=1'b0; // Not a jump instruction
    READ=1'b0; // Not a READ INSTRUCTION FROM THE DATA MEMORY
    WRITE=1'b0; // Not a WRITE INSTRUCTION TO THE DATA MEMORY
    PICKWRITE=1'b0; // Value to be written to the register is not from the data memory    
  end

  8'b00000010: //OPCODE for add instructions.carried out by ADD function in ALU.
  begin
    ALUOP=3'b001;
    MUXIMMEDIATE=1'b0;  //value in register2 is taken in add
    MUXREGOUT2=1'b1;    //2's comliment is not considered in add
    WRITEENABLE=1'b1;     //a value is written to a register
    MUXBEQ=1'b0;  // Not a branch if equal instruction
    MUXJUMP=1'b0; // Not a jump instruction      
    READ=1'b0; // Not a READ INSTRUCTION FROM THE DATA MEMORY
    WRITE=1'b0; // Not a WRITE INSTRUCTION TO THE DATA MEMORY
    PICKWRITE=1'b0; // Value to be written to the register is not from the data memory    
  end

  8'b00000011: //OPCODE for sub instructions.both carried out by ADD function in ALU.
  begin
    ALUOP=3'b001;
    MUXIMMEDIATE=1'b0;  //value in register2 is taken in sub
    MUXREGOUT2=1'b0;    //2's compliment is considered in sub
    WRITEENABLE=1'b1;     //a value is written to a register
    MUXBEQ=1'b0;  // Not a branch if equal instruction
    MUXJUMP=1'b0; // Not a jump instruction       
    READ=1'b0; // Not a READ INSTRUCTION FROM THE DATA MEMORY
    WRITE=1'b0; // Not a WRITE INSTRUCTION TO THE DATA MEMORY
    PICKWRITE=1'b0; // Value to be written to the register is not from the data memory     
  end

  8'b00000100:             //OPCODE for and instructions.carried out by AND function in ALU
  begin
    ALUOP=3'b010;
    MUXIMMEDIATE=1'b0;  //value in register2 is taken in and
    MUXREGOUT2=1'b1;    //2's compliment is not considered in and
    WRITEENABLE=1'b1;     //a value is written to a register
    MUXBEQ=1'b0;  // Not a branch if equal instruction
    MUXJUMP=1'b0; // Not a jump instruction   
    READ=1'b0; // Not a READ INSTRUCTION FROM THE DATA MEMORY
    WRITE=1'b0; // Not a WRITE INSTRUCTION TO THE DATA MEMORY
    PICKWRITE=1'b0; // Value to be written to the register is not from the data memory         
  end

  8'b00000101:           //OPCODE for or instructions.carried out by OR function in ALU
  begin
    ALUOP=3'b011;
    MUXIMMEDIATE=1'b0;  //value in register2 is taken in or
    MUXREGOUT2=1'b1;    //2's compliment is not considered in or
    WRITEENABLE=1'b1;     //a value is written to a register
    MUXBEQ=1'b0;  // Not a branch if equal instruction
    MUXJUMP=1'b0; // Not a jump instruction        
    READ=1'b0; // Not a READ INSTRUCTION FROM THE DATA MEMORY
    WRITE=1'b0; // Not a WRITE INSTRUCTION TO THE DATA MEMORY
    PICKWRITE=1'b0; // Value to be written to the register is not from the data memory       
  end

  8'b00000110:           //OPCODE for jump instructions.ALU not used
  begin
    ALUOP=3'b011;  //ALU NOT NEEDED SO THIS COULD BE ANYTHING
    MUXIMMEDIATE=1'b0;  //doesn't matter whether the value in register 2 or immediate is taken
    MUXREGOUT2=1'b1;    //2's compliment DOSEN'T matter
    WRITEENABLE=1'b0;     //a value is NOT written to a register
    MUXBEQ=1'b0;  // Not a branch if equal instruction
    MUXJUMP=1'b1; // this is a jump instruction       
    READ=1'b0; // Not a READ INSTRUCTION FROM THE DATA MEMORY
    WRITE=1'b0; // Not a WRITE INSTRUCTION TO THE DATA MEMORY
    PICKWRITE=1'b0; // this signal doesn't matter      
  end

  8'b00000111:           //OPCODE for beq instructions.carried out by ADD function in ALU.
  begin
    ALUOP=3'b001;  //ALU performs add function
    MUXIMMEDIATE=1'b0;  //value in register2 is taken after compliment
    MUXREGOUT2=1'b0;    //2's compliment is taken
    WRITEENABLE=1'b0;     //a value is NOT written to a register
    MUXBEQ=1'b1;  // branch if equal instruction is taken
    MUXJUMP=1'b0; //  Not a jump instruction      
    READ=1'b0; // Not a READ INSTRUCTION FROM THE DATA MEMORY
    WRITE=1'b0; // Not a WRITE INSTRUCTION TO THE DATA MEMORY
    PICKWRITE=1'b0; // this signal doesn't matter 

  end     


  8'b00001000:           //OPCODE for lwd instructions.carried out by FORWARD function in ALU.
  begin
    ALUOP=3'b000;  //ALU performs forward function
    MUXIMMEDIATE=1'b0;  //value in register2 
    MUXREGOUT2=1'b1;    //2's compliment is NOT taken
    WRITEENABLE=1'b1;     //a value is  written to a register
    MUXBEQ=1'b0;  // NOT a branch if equal instruction 
    MUXJUMP=1'b0; //  Not a jump instruction      
    READ=1'b1; // READ INSTRUCTION FROM THE DATA MEMORY
    WRITE=1'b0; // Not a WRITE INSTRUCTION TO THE DATA MEMORY
    PICKWRITE=1'b1; // Value to be written to the register is from the data memory  

  end      

  8'b00001001:           //OPCODE for lwi instructions.carried out by FORWARD function in ALU.
  begin
    ALUOP=3'b000;  //ALU performs FORWARD function
    MUXIMMEDIATE=1'b1;  //Immediate value is taken
    MUXREGOUT2=1'b1;    //2's compliment is NOT taken.
    WRITEENABLE=1'b1;     //a value is written to a register
    MUXBEQ=1'b0;  // NOT A branch if equal instruction
    MUXJUMP=1'b0; //  Not a jump instruction      
    READ=1'b1; // READ INSTRUCTION FROM THE DATA MEMORY
    WRITE=1'b0; // Not a WRITE INSTRUCTION TO THE DATA MEMORY
    PICKWRITE=1'b1; // Value to be written to the register is from the data memory   

  end    

  8'b00001010:           //OPCODE for swd instructions.carried out by FORAWARD function in ALU.
  begin
    ALUOP=3'b000;  //ALU performs FORWARD function
    MUXIMMEDIATE=1'b0;  //value in register2 is taken 
    MUXREGOUT2=1'b1;    //2's compliment is NOT taken
    WRITEENABLE=1'b0;     //a value is NOT written to a register
    MUXBEQ=1'b0;  // NOT A branch if equal instruction 
    MUXJUMP=1'b0; //  Not a jump instruction      
    READ=1'b0; // Not a READ INSTRUCTION FROM THE DATA MEMORY
    WRITE=1'b1; // WRITE INSTRUCTION TO THE DATA MEMORY
    PICKWRITE=1'b0; // this signal doesn't matter 

  end    

  8'b00001011:           //OPCODE for swi instructions.carried out by FORAWARD function in ALU.
  begin
    ALUOP=3'b000;  //ALU performs FORWARD function
    MUXIMMEDIATE=1'b1;  //value in Immediate is taken 
    MUXREGOUT2=1'b1;    //2's compliment is NOT taken
    WRITEENABLE=1'b0;     //a value is NOT written to a register
    MUXBEQ=1'b0;  // NOT A branch if equal instruction 
    MUXJUMP=1'b0; //  Not a jump instruction      
    READ=1'b0; // Not a READ INSTRUCTION FROM THE DATA MEMORY
    WRITE=1'b1; // WRITE INSTRUCTION TO THE DATA MEMORY
    PICKWRITE=1'b0; // this signal doesn't matter 

  end   



  default: 
  begin
    ALUOP=3'b011;           //other instructions are not yet used.assigned to OR function.this doesn't mean anything.
    MUXIMMEDIATE=1'b0;  //doesn't matter either way.can be either 1 or 0
    MUXREGOUT2=1'b1;    //doesn't matter either way.can be either 1 or 0
    WRITEENABLE=1'b0;     //write is not enabled to make sure the values in registeres are not replaced by garbage values
    MUXBEQ=1'b0;  // Not a branch if equal instruction
    MUXJUMP=1'b0; // Not a jump instruction 
    WRITE=1'b0; // WRITE INSTRUCTION TO THE DATA MEMORY is off   
    READ=1'b0; // Not a READ INSTRUCTION FROM THE DATA MEMORY      
  end
 endcase

 

 end

always @(BUSYWAIT) //hault the cpu when data is read or being written to the memory
begin
 
 if(BUSYWAIT==1'b1 && WRITEENABLE==1'b1)
 begin
   WRITEENABLE=1'b0; //set to zero while the memory read opeartion is completed
   MEMREAD=1'b1; //to indicate that a value is being read from the data memory
 end

 else if(BUSYWAIT==1'b0 && WRITEENABLE==1'b0 && MEMREAD==1'b1)
 begin
   WRITEENABLE=1'b1; //set to highw after the memory read opeartion is completed
   MEMREAD=1'b0; //to indicate that memory read operation is over
   READ=1'b0; //clear the read control signal
 end 

 else if(BUSYWAIT==1'b1 && WRITEENABLE==1'b0)
 begin
   MEMWRITE=1'b1; //to indicate that a value is being WRITTEN TO the data memory
 end  

 else if(BUSYWAIT==1'b0 && MEMWRITE==1'b1)
 begin

   MEMWRITE=1'b0; //to indicate that memory WRITE operation is over
   WRITE=1'b0; //clear the WRITE control signal
 end 

 else
 begin
   MEMREAD=1'b0;
 end


  
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

  if(MUXIMMEDIATE==1'b1)     //IMMEDIATE VALUE IS CONSIDERED
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
module jump_branch(ALUOP,PCOUT,OFFSET,PCBRANCH);
 input [31:0] PCOUT;
 input [2:0] ALUOP;
 input [7:0] OFFSET;
 output reg [31:0] PCBRANCH;

 reg [31:0] OFFSET_EXTENDED ;


 always @(OFFSET,ALUOP)
 begin
  OFFSET_EXTENDED={{24{OFFSET[7]}},OFFSET};
  OFFSET_EXTENDED=OFFSET_EXTENDED *4;  
  #2 PCBRANCH=PCOUT+OFFSET_EXTENDED; //FOR JUMP AND BEQ INSTRUCTION. THE NEXT ADDRESS OF PC IS IN PCBRANCH
 end


endmodule

module pc_mux(MUXJUMP,MUXBEQ,PCOUT,PCBRANCH,ZERO,PCNEXT);
 input MUXJUMP,MUXBEQ,ZERO;
 input [31:0] PCOUT,PCBRANCH;
 output reg [31:0] PCNEXT;

 always @(MUXJUMP,MUXBEQ,PCOUT,PCBRANCH,ZERO)
 begin
   if(MUXJUMP==1'b1)
   begin
    PCNEXT=PCBRANCH;
   end

   else if((MUXBEQ&&ZERO)==1'b1)
   begin
    PCNEXT=PCBRANCH;
   end

   else
   begin
     PCNEXT=PCOUT;
   end 

 end
endmodule


module choosewrite_mux(READDATA,ALURESULT,PICKWRITE,WRITERESULT);

 input [7:0] READDATA,ALURESULT;
 input  PICKWRITE;
 output reg [7:0] WRITERESULT;

 always @(READDATA,ALURESULT,PICKWRITE)
 begin
   if(PICKWRITE==1'b0)
   begin
    WRITERESULT=ALURESULT;
   end

   else
   begin
     WRITERESULT=READDATA;
   end 

 end
endmodule