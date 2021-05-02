// display.sv - ECE585 Final Project - Display Module for ECE585 Project
//
// Meshal Albaiz
// Tapasya Bhatnagar
// Tristan Cunderla
// Aakanksha Mathuria
//
// Fall 2018
// 11/26/2018
//
// Description:
// ------------
// This module serves as the display module for the ECE585 cache project.
// The most important aspect of this module is that it will operate
// differently based on the mode input determined at run time.  Meaning that
// depending on what the mode is the display module will display different info.
// This module displays information also based on the input instruction given in
// the input trace file.  Depending on the instruction and mode the display function
// will display cache contents (tag, LRU, MESI) as well as cache usage
// statistics (hits, misses, hit ratio, reads, writes)

module display(mode, index, address, instruction, tag, byte_offset, tag_line_data, hit_miss_data, LRU_line_data, MESI_line, d_cache_hit, d_cache_miss,
d_cache_read, d_cache_write, d_cache_ratio, i_cache_hit, i_cache_miss, i_cache_read, i_cache_ratio, tag_line_instrc, LRU_line_instrc, MESI_MRU, iteration);

// parameters
parameter read = 4'b0000;
parameter write = 4'b0001;
parameter read_L2 = 4'b0010;
parameter invalidate_from_L2 = 4'b0011;
parameter snoop = 4'b0100;
parameter print_info = 4'b1001;
parameter clear_cache = 4'b1000;
parameter miss = 1'b0;
parameter hit = 1'b1;

// general info to display
input logic [13:0] index;
input logic mode;
input logic [35:0] address;
input logic [3:0] instruction;
input logic [11:0] tag;
input logic [5:0] byte_offset;
input logic [31:0] iteration;

// data cache info
input logic [95:0] tag_line_data;
input logic hit_miss_data;
input logic [23:0] LRU_line_data;
input logic [15:0] MESI_line;
input real d_cache_hit, d_cache_miss, d_cache_read, d_cache_write, d_cache_ratio;
input logic [1:0] MESI_MRU;
logic [11:0] tag_way_data1, tag_way_data2, tag_way_data3, tag_way_data4, tag_way_data5, tag_way_data6, tag_way_data7, tag_way_data8;
logic [2:0] LRU_way_data1, LRU_way_data2, LRU_way_data3, LRU_way_data4, LRU_way_data5, LRU_way_data6, LRU_way_data7, LRU_way_data8;
logic [1:0] MESI_way1, MESI_way2, MESI_way3, MESI_way4, MESI_way5, MESI_way6, MESI_way7, MESI_way8;

// instruction cache
input real i_cache_hit, i_cache_miss, i_cache_read, i_cache_ratio;
input logic [47:0] tag_line_instrc;
input logic [7:0] LRU_line_instrc;
logic [11:0] tag_wayinst1, tag_wayinst2, tag_wayinst3, tag_wayinst4;
logic [1:0] LRU_way_inst1, LRU_way_inst2, LRU_way_inst3, LRU_way_inst4;

always @(instruction, index, tag, byte_offset, iteration) begin

// data cache tag line
tag_way_data1 = tag_line_data[95:84];
tag_way_data2 = tag_line_data[83:72];
tag_way_data3 = tag_line_data[71:60];
tag_way_data4 = tag_line_data[59:48];
tag_way_data5 = tag_line_data[47:36];
tag_way_data6 = tag_line_data[35:24];
tag_way_data7 = tag_line_data[23:12];
tag_way_data8 = tag_line_data[11:0];

// instruction cache tag line
tag_wayinst1 = tag_line_instrc[47:36];
tag_wayinst2 = tag_line_instrc[35:24];
tag_wayinst3 = tag_line_instrc[23:12];
tag_wayinst4 = tag_line_instrc[11:0];

// data cache LRU line
LRU_way_data1 = LRU_line_data[23:21];
LRU_way_data2 = LRU_line_data[20:18];
LRU_way_data3 = LRU_line_data[17:15];
LRU_way_data4 = LRU_line_data[14:12];
LRU_way_data5 = LRU_line_data[11:9];
LRU_way_data6 = LRU_line_data[8:6];
LRU_way_data7 = LRU_line_data[5:3];
LRU_way_data8 = LRU_line_data[2:0];

// instruction cache LRU line
LRU_way_inst1 = LRU_line_instrc[7:6];
LRU_way_inst2 = LRU_line_instrc[5:4];
LRU_way_inst3 = LRU_line_instrc[3:2];
LRU_way_inst4 = LRU_line_instrc[1:0];

// data cache MESI line
MESI_way1 = MESI_line[15:14];
MESI_way2 = MESI_line[13:12];
MESI_way3 = MESI_line[11:10];
MESI_way4 = MESI_line[9:8];
MESI_way5 = MESI_line[7:6];
MESI_way6 = MESI_line[5:4];
MESI_way7 = MESI_line[3:2];
MESI_way8 = MESI_line[1:0];

// mode 0 is activated, only displays critical info and when the instruction is a 9
  if(mode == 0) begin
// if instruction is a 9 then print cache statistics and cache contents
    if(instruction == print_info)begin
      $display("_______________________________________________________________________");
      $display("");
      $display("DATA CACHE USAGE STATISTICS");
      $display("Cache Reads: %d", d_cache_read);
      $display("Cache Writes: %d", d_cache_write);
      $display("Cache Hits: %d", d_cache_hit);
      $display("Cache Misses: %d", d_cache_miss);
      $display("Cache Hit Ratio: %1.2f", d_cache_ratio);
      $display("");
      $display("INSTRUCTION CACHE USAGE STATISTICS");
      $display("Cache Reads: %d", i_cache_read);
      $display("Cache Hits: %d", i_cache_hit);
      $display("Cache Misses: %d", i_cache_miss);
      $display("Cache Hit Ratio: %1.2f", i_cache_ratio);
      $display("");
      $display("Index: %b (%h)",index, index);
      $display("");
      $display("DATA CACHE CONTENTS");
      $display("TAGS: %h | %h | %h | %h | %h | %h | %h | %h", tag_way_data1, tag_way_data2, tag_way_data3, tag_way_data4, tag_way_data5, tag_way_data6, tag_way_data7, tag_way_data8);
      $display("MESI:  %h  |  %h  |  %h  |  %h  |  %h  |  %h  |  %h  |  %h", MESI_way1, MESI_way2, MESI_way3, MESI_way4, MESI_way5, MESI_way6, MESI_way7, MESI_way8);
      $display("LRU:  %b | %b | %b | %b | %b | %b | %b | %b", LRU_way_data1, LRU_way_data2, LRU_way_data3, LRU_way_data4, LRU_way_data5, LRU_way_data6, LRU_way_data7, LRU_way_data8);
      $display("");
      $display("INSTRUCTION CACHE CONTENTS");
      $display("TAGS: %h | %h | %h | %h", tag_wayinst1, tag_wayinst2, tag_wayinst3, tag_wayinst4);
      $display("LRU:  %b  | %b  | %b  | %b", LRU_way_inst1, LRU_way_inst2, LRU_way_inst3, LRU_way_inst4);
      $display("_______________________________________________________________________");
      $display("");
    end
  end
// mode 1 is activated, displays critical info as well as the instructions between L1 and L2 cache
  else if(mode == 1) begin
// if instruction is a 9 then print cache statistics and cache contents
    if(instruction == print_info)begin
      $display("_______________________________________________________________________");
      $display("");
      $display("DATA CACHE USAGE STATISTICS");
      $display("Data Cache Reads: %d", d_cache_read);
      $display("Data Cache Writes: %d", d_cache_write);
      $display("Data Cache Hits: %d", d_cache_hit);
      $display("Data Cache Misses: %d", d_cache_miss);
      $display("Data Cache Hit Ratio: %1.2f", d_cache_ratio);
      $display("");
      $display("INSTRUCTION CACHE USAGE STATISTICS");
      $display("Instruction Cache Reads: %d", i_cache_read);
      $display("Instruction Cache Hits: %d", i_cache_hit);
      $display("Instruction Cache Misses: %d", i_cache_miss);
      $display("Instruction Cache Hit Ratio: %1.2f", i_cache_ratio);
      $display("");
      $display("Index: %b (%h)",index, index);
      $display("");
      $display("DATA CACHE CONTENTS");
      $display("TAGS: %h | %h | %h | %h | %h | %h | %h | %h", tag_way_data1, tag_way_data2, tag_way_data3, tag_way_data4, tag_way_data5, tag_way_data6, tag_way_data7, tag_way_data8);
      $display("MESI:  %h  |  %h  |  %h  |  %h  |  %h  |  %h  |  %h  |  %h", MESI_way1, MESI_way2, MESI_way3, MESI_way4, MESI_way5, MESI_way6, MESI_way7, MESI_way8);
      $display("LRU:  %b | %b | %b | %b | %b | %b | %b | %b", LRU_way_data1, LRU_way_data2, LRU_way_data3, LRU_way_data4, LRU_way_data5, LRU_way_data6, LRU_way_data7, LRU_way_data8);
      $display("");
      $display("INSTRUCTION CACHE CONTENTS");
      $display("TAGS: %h | %h | %h | %h", tag_wayinst1, tag_wayinst2, tag_wayinst3, tag_wayinst4);
      $display("LRU:  %b  | %b  | %b  | %b", LRU_way_inst1, LRU_way_inst2, LRU_way_inst3, LRU_way_inst4);
      $display("_______________________________________________________________________");
      $display("");
    end
// display message if instruction is a write (1) and the MESI bit is an M or I
    else if((instruction == write && MESI_MRU == 2'b11) | (instruction == write && MESI_MRU == 2'b00) )begin
      $display("SYSTEM MESSAGE: Write Data to L2 Cache Address %h", address);
      $display("");
    end
// display message if instruction is a read to L2 cache (2)
    else if(instruction == read_L2)begin
      $display("SYSTEM MESSAGE: Read Data from L2 Cache Address %h", address);
      $display("");
    end
    else if(instruction == snoop) begin
      $display("SYSTEM MESSAGE: Return Data to L2 Cache Address %h", address);
      $display("");
    end
// display message if instruction is a write and there is a miss within the data cache
    else if(instruction == write && hit_miss_data == miss) begin
      $display("SYSTEM MESSAGE: Read for Ownership From L2 Cache Address %h", address);
      $display("");
    end
// display message if instruction is an invalidate command from the L2 cache (3)
    else if(instruction == invalidate_from_L2) begin
      $display("SYSTEM MESSAGE: Invalidate Command From L2 Cache");
      $display("");
    end
// display message if instruction is reset (8)
    else if(instruction == clear_cache) begin
      $display("SYSTEM MESSAGE: Cache Contents Have Been Cleared and Cache States Have Been Reset");
      $display("");
    end
  end
end

endmodule
