`timescale 1ns/100ps


module cache_instructions(clock,reset,cache_instruction_busywait,instruction_memory_busywait,word_address,memory_address,instruction,instruction_memory_read,readinst);

input clock,reset;
input [9:0] word_address;
input [127:0] readinst;
input instruction_memory_busywait;
output reg [5:0] memory_address;
output reg [31:0] instruction; //the instruction sent to the cpu
output reg cache_instruction_busywait,instruction_memory_read;
reg [131:0] cache_slot [7:0]; //in a single cache_slot, 131th bit denotes the validbit,[130-128] bits represent the tag and [127:0] represnts the four words each [31:0] bits long
reg [131:0] current_cache;


reg [1:0] offset;
reg [2:0] index,tag,cache_slot_tag;
reg validbit,hit;
reg [127:0] instruction_block;
reg trigger1=1'b0; //used to trigger always blocks
reg trigger2=1'b0; //used to trigger always blocks
reg mem_operation=1'b0;
reg cpu_working=1'b0; //This is initialized at the first positive clock edge in the code

//Extract the data and determine the hit status
always @(word_address,trigger2)
begin
if(cpu_working==1'b1)
begin
      cache_instruction_busywait=1'b1;
      offset=word_address[3:2];
      index=word_address[6:4];
      tag=word_address[9:7];

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

      validbit=current_cache[131];
      cache_slot_tag=current_cache[130:128];
      instruction_block=current_cache[127:0];
      trigger1=~trigger1;

      #0.9

      if((cache_slot_tag==tag)&&(validbit==1'b1))
      begin
        hit=1'b1;
        cache_instruction_busywait=1'b0;
      end

      else 
      begin
        hit=1'b0;
        instruction_memory_read=1'b1;
        memory_address={tag,index};  
        mem_operation=1'b1;      
      end
    

end         
end

//fetching the instruction from the instruction block
always @(trigger1)
begin
  #1
  case (offset)
    2'b00:
    begin
      instruction=instruction_block[31:0];
    end

    2'b01:
    begin
      instruction=instruction_block[63:32];
    end    

    2'b10:
    begin
      instruction=instruction_block[95:64];
    end    

    2'b11:
    begin
      instruction=instruction_block[127:96];
    end  
  endcase   
end

always @(instruction_memory_busywait)
begin
  if(instruction_memory_busywait==1'b0 && mem_operation==1'b1)
  begin
    instruction_memory_read=1'b0;
    #1
    cache_slot[index]={1'b1,tag,readinst};
    mem_operation=1'b0;
    trigger2=~trigger2;
  end
end

//reset the cache memory
integer i;

always @ (posedge reset)
begin
  if(reset)
  begin
    for (i=0;i<8; i=i+1)
        cache_slot[i] = 0;
  end
  
end

always @(posedge clock)
begin
  cpu_working=1'b1;
end

endmodule