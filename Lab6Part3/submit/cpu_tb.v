// Computer Architecture (CO224) - Lab 05
// Design: Testbench of Integrated CPU of Simple Processor
// Author: Isuru Nawinne
`include "cpu.v"
`include "data_memory.v"
`include "dcacheFSM_skeleton.v"
`include "cache_instruction.v"
`include "instruction_memory.v"
`timescale 1ns/100ps

module cpu_tb;

    reg CLK, RESET;
    wire [31:0] PC;
    wire [31:0] INSTRUCTION,mem_readdata,mem_writedata;
    wire READ,WRITE,CACHE_BUSYWAIT,mem_busywait,mem_read,mem_write,cache_instruction_busywait,instruction_memory_busywait,instruction_memory_read;
    wire [9:0] word_address;
    wire [127:0] readinst;
    wire [7:0] CACHE_READDATA,ALURESULT,REGOUT1;
    wire [5:0] mem_address,memory_address;
    
    /* 
    ------------------------
     SIMPLE INSTRUCTION MEM
    ------------------------
    */
    
    // TODO: Initialize an array of registers (8x1024) named 'instr_mem' to be used as instruction memory
   // reg [7:0] instr_mem [0:1023];
    
    // TODO: Create combinational logic to support CPU instruction fetching, given the Program Counter(PC) value 
    //       (make sure you include the delay for instruction fetching here)

   
    assign  word_address=PC[9:0];
    


    
    initial
    begin
        // Initialize instruction memory with the set of instructions you need execute on CPU
        
        // METHOD 1: manually loading instructions to instr_mem
        //{instr_mem[10'd3], instr_mem[10'd2], instr_mem[10'd1], instr_mem[10'd0]} = 32'b00000000000001000000000000000101;
        //{instr_mem[10'd7], instr_mem[10'd6], instr_mem[10'd5], instr_mem[10'd4]} = 32'b00000000000000100000000000001001;
        //{instr_mem[10'd11], instr_mem[10'd10], instr_mem[10'd9], instr_mem[10'd8]} = 32'b00000010000001100000010000000010;
        
        // METHOD 2: loading instr_mem content from instr_mem.mem file
        //$readmemb("instr_mem.mem", instr_mem);

    end
    
    /* 
    -----
     CPU
    -----
    */
    cpu mycpu(PC,INSTRUCTION,CLK,RESET,READ,WRITE,CACHE_BUSYWAIT,CACHE_READDATA,ALURESULT,REGOUT1,cache_instruction_busywait);
    dcache my_cache(CLK,RESET,READ,WRITE,REGOUT1,ALURESULT,mem_readdata,mem_busywait,CACHE_BUSYWAIT,mem_read,mem_write,CACHE_READDATA,mem_writedata,mem_address);
    data_memory my_data(CLK,RESET,mem_read,mem_write,mem_address,mem_writedata,mem_readdata,mem_busywait);
    cache_instructions my_cache_instructions_memory(CLK,RESET,cache_instruction_busywait,instruction_memory_busywait,word_address,memory_address,INSTRUCTION,instruction_memory_read,readinst);
    instruction_memory my_instruct_memory(CLK,instruction_memory_read,memory_address,readinst,instruction_memory_busywait);
    
    
    initial
    begin
    
        // generate files needed to plot the waveform using GTKWave
        $dumpfile("cpu_wavedata.vcd");
		$dumpvars(0, cpu_tb);
        
        CLK = 1'b0;
        RESET=1'b0;
        #1
        RESET=1'b1;
        #1
        RESET=1'b0;




        
        // TODO: Reset the CPU (by giving a pulse to RESET signal) to start the program execution
     //   RESET=1'b1;
     //   #5
     //   RESET=1'b0;
      //  #120
     //   RESET=1'b1;

        
        // finish simulation after some time
        #2000
        $finish;
        
    end
    
    // clock signal generation
    always
        #4 CLK = ~CLK;
        

endmodule