/*
Module  : Data Cache 
Author  : Isuru Nawinne, Kisaru Liyanage
Date    : 25/05/2020

Description	:

This file presents a skeleton implementation of the cache controller using a Finite State Machine model. Note that this code is not complete.
*/

`timescale 1ns/100ps

module dcache (clock,reset,cache_read,cache_write,cache_writedata,cache_address,mem_readdata,mem_busywait,cache_busywait,mem_read,mem_write,cache_readdata,mem_writedata,mem_address);
    input cache_read,cache_write,clock,reset,mem_busywait;
    input [7:0] cache_writedata,cache_address;
    input  [31:0] mem_readdata;
    output reg mem_read,mem_write ;
    output reg cache_busywait=1'b0;
    output reg [7:0] cache_readdata;
    output reg [31:0] mem_writedata;
    output reg [5:0] mem_address;
    reg [2:0] tag,index,cache_slot_tag;
    reg [1:0] offset;
    reg validbit,dirtybit,hit;
    reg [36:0] cache_slot [7:0]; //here a single cache_slot consists of a valid bit indexed at 36,a dirty bit indexed at 35,tag indexed from [34:32] and four data words indexed from [31:0]. 
    reg [36:0] current_cache;
    reg [31:0] data_block;
    reg mem_operation=1'b1;
    reg trigger=1'b1;
    reg write_operation;

    parameter IDLE = 3'b000, MEM_READ = 3'b001,MEM_WRITE = 3'b010,CACHE_READ = 3'b011;
    reg [2:0] state, next_state;

    /*
    Combinational part for indexing, tag comparison for hit deciding, etc.
    */
    

    always @(cache_read,cache_write) //set the cache_busywait to 1 if the cache read or write signals are high
    begin
      if(cache_read==1'b1 || cache_write==1'b1)
      begin
        cache_busywait=1'b1;
      end
    end


    always @(cache_address,mem_operation)
    begin

      offset=cache_address[1:0];
      index=cache_address[4:2];
      tag=cache_address[7:5];
      
      #1
      case (index)
        3'b000:
        begin
          current_cache=cache_slot[0];        
        end    
        3'b001:
        begin
            current_cache=cache_slot[1];
        end    
        3'b010:
        begin
            current_cache=cache_slot[2];
        end
        3'b011:
        begin
            current_cache=cache_slot[3];
        end
        3'b100:
        begin
            current_cache=cache_slot[4];
        end
        3'b101:
        begin
            current_cache=cache_slot[5];
        end
        3'b110:
        begin
            current_cache=cache_slot[6];
        end
        3'b111:
        begin
            current_cache=cache_slot[7];
        end     
      endcase

      validbit=current_cache[36];
      dirtybit=current_cache[35];
      cache_slot_tag=current_cache[34:32];
      data_block=current_cache[31:0];
      
      if(cache_read==1'b1 || cache_write==1'b1)
      begin
        trigger=~trigger;
      end
      
    end


    always @(trigger)
    begin
      #0.9
      if((cache_slot_tag==tag)&&(validbit==1'b1))
      begin
        hit=1'b1;
      end
      else
      begin
        hit=1'b0;
      end

      if((cache_read==1'b1) && (hit==1'b1))
      begin
        cache_busywait=1'b0;
        state = IDLE;
      end

      if((cache_write==1'b1) && (hit==1'b1))
      begin
        cache_busywait=1'b0;
        write_operation=1'b1;
        state = IDLE;
      end     

      if ((cache_read || cache_write) && !dirtybit && !hit)  
      begin
        state = MEM_READ;
      end
      if ((cache_read || cache_write) && dirtybit && !hit)  
      begin
        state = MEM_WRITE;
      end      

  

    end

    always @(data_block,offset)
    begin
      #1
      case(offset)
        2'b00:
        begin
          cache_readdata=data_block[7:0];
        end
        2'b01:
        begin
          cache_readdata=data_block[15:8];
        end
        2'b10:
        begin
          cache_readdata=data_block[23:16];
        end
        2'b11:
        begin
          cache_readdata=data_block[31:24];
        end
      endcase                          
    end

    always @(posedge clock)
    #1
    begin
      if(hit==1'b1 && write_operation==1'b1)
      begin
        case(offset)
          2'b00:
          begin
            cache_slot[index][7:0]=cache_writedata;
          end
          2'b01:
          begin
            cache_slot[index][15:8]=cache_writedata;
          end
          2'b10:
          begin
            cache_slot[index][23:16]=cache_writedata;
          end
          2'b11:
          begin
            cache_slot[index][31:24]=cache_writedata;
          end
        endcase  
        cache_slot[index][35]=1'b1;
        write_operation=1'b0;                              
      end
    end
    

    /* Cache Controller FSM Start */



    // combinational next state logic
    always @(*)
    begin
        case (state)
            IDLE:
                if ((cache_read || cache_write) && !dirtybit && !hit)  
                    next_state = MEM_READ;
                else if ((cache_read || cache_write) && dirtybit && !hit)
                    next_state = MEM_WRITE;
                else
                    next_state = IDLE;
            
            MEM_READ:
                if (!mem_busywait)
                    next_state = CACHE_READ;
                else    
                    next_state = MEM_READ;

            MEM_WRITE:
                if (!mem_busywait)
                    next_state = MEM_READ;
                else    
                    next_state = MEM_WRITE;
            CACHE_READ:
                next_state=IDLE;   
            
            
        endcase
    end

    // combinational output logic
    always @(*)
    begin
        case(state)
            IDLE:
            begin
                mem_read = 1'b0;
                mem_write = 1'b0;
                mem_address = 6'dx;
                mem_writedata = 32'dx;
                
            end
         
            MEM_READ: 
            begin
                mem_read = 1'b1;
                mem_write = 1'b0;
                mem_address = {tag, index};
                mem_writedata = 32'dx;
                cache_busywait = 1'b1;
            end

           MEM_WRITE: 
            begin
                mem_read = 1'b0;
                mem_write = 1'b1;
                mem_address = {cache_slot_tag, index};
                mem_writedata = data_block;
                cache_busywait = 1'b1;
            end

           CACHE_READ: 
            begin
              #1
              mem_read=1'b0;
              cache_slot[index]={2'b10,tag,mem_readdata};
              mem_operation=~mem_operation; //to trigger the always block to get the hit 
              
     
            end            
                        
            
        endcase
    end
integer i;
    // sequential logic for state transitioning 
    always @(posedge clock,reset)
    begin
        if(reset)
        begin        
          state = IDLE;
          for (i=0;i<8; i=i+1)
             cache_slot[i] = 0;
        end
        else
            state = next_state;
    end

 


endmodule