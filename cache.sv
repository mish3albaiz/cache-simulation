// cache.sv - ECE585 Final Project - Cache Top Module
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
// Cache top module to integrate all other modules
// Parses the input into instruction, index, tag, and, byte offset

module cache(address, mode, iteration);

input logic [35:0] address; // input of 36 bits named address (4 MSB are instruction, 32 LSB are address)
input logic mode; // mode input to go into display module
input logic [31:0] iteration; // iteration input coming from k in test bench for sensitivity lists

logic [11:0] tag; // 12 bit tag register
logic [5:0] byte_offset; // 6 bit byte offset register
logic [13:0] index; // 14 bit index register
logic [3:0] instruction; // 4 bit instruction register

logic [95:0] tag_line_data; // 96 bit tag line for data cache (8 ways x 12 bits) at index
logic [15:0] MESI_line; // states of MESI (2 bits per MESI state x 8 ways) at index
logic [1:0] MESI_MRU; // MRU MESI state
logic [23:0] LRU_line_data; // LRU line at index for data cache (3 bits x 8 ways)
logic hit_miss_data; // hit or miss in data cache for current instruction

logic hit_miss_instr; // hit or miss in instruction for current instruction
logic [7:0] LRU_line_instrc; // LRU line at index for instruction cache (3 bits x 4 ways)
logic [47:0] tag_line_instrc; // tag line for instruction cache (12 bits x 4 ways)


real d_cache_hit, d_cache_miss, d_cache_read, d_cache_write, d_cache_ratio; // floating point numbers for data read write hit miss and ratio
real i_cache_hit, i_cache_miss, i_cache_read, i_cache_ratio; // floating point numbers for instruction read hit miss and ratio

assign byte_offset = address[5:0]; // parsing input for byte offset
assign index = address[19:6]; // parsing input for index
assign tag = address[31:20]; // parsing input for tag
assign instruction = address[35:32]; // parsing input for instruction



// data cache instantiation

data_cache D_cache(
  .d_cache_hit(d_cache_hit), // data cache hits count output
  .d_cache_miss(d_cache_miss), // data cache miss count output
  .d_cache_read(d_cache_read), // data cache read count output
  .d_cache_write(d_cache_write), // data cache write count output
  .d_cache_ratio(d_cache_ratio), // data cache hit ratio output
  .tag_line(tag_line_data), // data cache tag line output
  .hit_miss(hit_miss_data), // data cache hit or miss output
  .index(index), // data cache index input
  .tag(tag), // data cache tag input
  .instruction(instruction), // data cache instruction input
  .byte_offset(byte_offset), // data cache byte offset input
  .MESI_line(MESI_line), // data cache MESI line output
  .LRU_line(LRU_line_data), // data cache LRU line output
  .MESI_MRU(MESI_MRU), // data cache MRU MESI state output
  .iteration(iteration) // data cache iteration input
);



// instruction cache instantiation

instruction_cache i_cache(
  .i_cache_hit(i_cache_hit), // instruction cache hits count output
  .i_cache_miss(i_cache_miss), // instruction cache miss count output
  .i_cache_read(i_cache_read), // instruction cache read count output
  .i_cache_ratio(i_cache_ratio), // instruction cache hit ratio output
  .tag_line(tag_line_instrc), // instruction cache tag line output
  .LRU_line(LRU_line_instrc), // instruction cache LRU line output
  .hit_miss(hit_miss_instr), // instruction cache hit or miss output
  .index(index), // instruction cache index input
  .tag(tag), // instruction cache tag input
  .instruction(instruction), // instruction cache instruction input
  .byte_offset(byte_offset), // instruction cache byte offset input
  .iteration(iteration) // instruction cache iteration input
);



// display module instantiation

display d1(
  .mode(mode), // mode input
  .index(index), // index input
  .address(address), // 32 bit address input
  .instruction(instruction),  // instruction input
  .tag(tag), // tag input
  .byte_offset(byte_offset), // byte offset input
  .tag_line_data(tag_line_data), // data cache tag line input
  .tag_line_instrc(tag_line_instrc), // instruction cache tag line input
  .hit_miss_data(hit_miss_data), // data cache hit or miss input
  .LRU_line_data(LRU_line_data), // data cache LRU line input
  .LRU_line_instrc(LRU_line_instrc), // instruction cache LRU line input
  .MESI_line(MESI_line), // data cache MESI line input
  .d_cache_hit(d_cache_hit), // data cache hits count input
  .d_cache_miss(d_cache_miss), // data cache miss count input
  .d_cache_read(d_cache_read),  // data cache read count input
  .d_cache_write(d_cache_write), // data cache write count input
  .d_cache_ratio(d_cache_ratio),  // data cache hit ratio input
  .i_cache_hit(i_cache_hit), // instruction cache hits count input
  .i_cache_miss(i_cache_miss), // instruction cache miss count input
  .i_cache_read(i_cache_read), // instruction cache read count input
  .i_cache_ratio(i_cache_ratio), // instruction cache hit ratio input
  .MESI_MRU(MESI_MRU),  // data cache MRU MESI state input
  .iteration(iteration) // iteration input
);

endmodule
