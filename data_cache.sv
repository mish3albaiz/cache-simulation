// data_cache.sv - ECE585 Final Project - Data Cache
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
// Data cache module that handles all data cache functions including MESI and LRU

module data_cache(d_cache_hit, d_cache_miss, d_cache_read, d_cache_write, d_cache_ratio, tag_line, hit_miss,
index, tag, instruction, byte_offset, MESI_line, LRU_line, MESI_MRU, iteration);

output real d_cache_hit, d_cache_miss, d_cache_read, d_cache_write, d_cache_ratio; // statistics outputs
output logic [95:0] tag_line; // tag line output (12 bit x 8 ways)
output logic hit_miss; // hit or miss output
output logic [23:0] LRU_line; // LRU line output
output logic [15:0] MESI_line; // MESI line output
output logic [1:0] MESI_MRU; // MESI state of MRU
input logic [13:0] index; // index input
input logic [11:0] tag; // tag input
input logic [3:0] instruction; // instruction input
input logic [5:0] byte_offset; // byte offset input
input logic [31:0] iteration; // iteration input

logic [95:0] d_cache [0:16383]; // data cache array (16k lines of 96 bit tag lines for each index)
logic [11:0] tag_way1, tag_way2, tag_way3, tag_way4, tag_way5, tag_way6, tag_way7, tag_way8; // tag in each way


logic [2:0] MRU_way; // most recently used way
logic [23:0] LRU_cache [0:16383]; // data cache LRU array (16k lines of 24 bit LRU lines)
logic [2:0] array_LRU [0:7]; // LRU array for one index
logic [2:0] smallest_LRU; // smallest LRU value for finding LRU
logic [2:0] current_LRU_way; // current LRU way for finding LRU
logic [2:0] current_MRU; // current MRU value for finding LRU
logic [2:0] LRU_way1, LRU_way2, LRU_way3, LRU_way4, LRU_way5, LRU_way6, LRU_way7, LRU_way8; // value of LRU in each way

logic [15:0] MESI_cache [0:16383]; // data cache MESI array (16k lines of 16 bit lines)
logic [1:0] array_MESI [0:7]; // MESI array for one index
logic [1:0] MESI_way1, MESI_way2, MESI_way3, MESI_way4, MESI_way5, MESI_way6, MESI_way7, MESI_way8; // MESI state in each way
logic [1:0] current_MESI; // current MESI state
logic [2:0] smallest_MESI_LRU; // used to find the LRU of invalid ways
logic invalid = 1'b0; // invalid flag

integer i, j;

parameter read = 4'b0000; // parameter for read instruction
parameter write = 4'b0001; // parameter for write instruction
parameter data_request_L2 = 4'b0100; // parameter for snooping instruction

parameter I = 2'b00; // Invalid state
parameter S = 2'b01; // Shared state
parameter E = 2'b10; // Exclusive state
parameter M = 2'b11; // Modified state

// initialization function to fill arrays with correct initial information
initial begin

  array_LRU[0] = 3'b000; // setting LRU bits to give priority to first way
  array_LRU[1] = 3'b001;
  array_LRU[2] = 3'b010;
  array_LRU[3] = 3'b011;
  array_LRU[4] = 3'b100;
  array_LRU[5] = 3'b101;
  array_LRU[6] = 3'b110;
  array_LRU[7] = 3'b111;

  // create LRU line by concatenating array
  LRU_line = {array_LRU[0], array_LRU[1], array_LRU[2], array_LRU[3], array_LRU[4], array_LRU[5], array_LRU[6], array_LRU[7]};

  for(i = 0; i < 16384; i = i + 1) begin
    LRU_cache[i] = LRU_line; // fill LRU cache array with line at every index
  end

  array_MESI[0] = I; // setting all ways to Invalid
  array_MESI[1] = I;
  array_MESI[2] = I;
  array_MESI[3] = I;
  array_MESI[4] = I;
  array_MESI[5] = I;
  array_MESI[6] = I;
  array_MESI[7] = I;

  // create MESI line by concatenating array
  MESI_line = {array_MESI[0], array_MESI[1], array_MESI[2], array_MESI[3], array_MESI[4], array_MESI[5], array_MESI[6], array_MESI[7]};

  for(j = 0; j < 16384; j = j + 1) begin
    MESI_cache[j] = MESI_line; // fill MESI cache array with line at every index
  end

  d_cache_hit = 0; // reset all statistics
  d_cache_miss = 0;
  d_cache_read = 0;
  d_cache_write = 0;
  d_cache_ratio = 0;
end


// main function triggered by change in address or iteration
always @(instruction, index, tag, byte_offset, iteration)
begin
if (instruction == 8) begin // if instruction is 8 then reset cache and statistics as done in initialization
  array_LRU[0] = 3'b000;
  array_LRU[1] = 3'b001;
  array_LRU[2] = 3'b010;
  array_LRU[3] = 3'b011;
  array_LRU[4] = 3'b100;
  array_LRU[5] = 3'b101;
  array_LRU[6] = 3'b110;
  array_LRU[7] = 3'b111;

  LRU_line = {array_LRU[0], array_LRU[1], array_LRU[2], array_LRU[3], array_LRU[4], array_LRU[5], array_LRU[6], array_LRU[7]};

  for(i = 0; i < 16384; i = i + 1) begin
    LRU_cache[i] = LRU_line;
  end

  array_MESI[0] = I;
  array_MESI[1] = I;
  array_MESI[2] = I;
  array_MESI[3] = I;
  array_MESI[4] = I;
  array_MESI[5] = I;
  array_MESI[6] = I;
  array_MESI[7] = I;
  MESI_line = {array_MESI[0], array_MESI[1], array_MESI[2], array_MESI[3], array_MESI[4], array_MESI[5], array_MESI[6], array_MESI[7]};

  for(j = 0; j < 16384; j = j + 1) begin
    MESI_cache[j] = MESI_line;
  end

  d_cache_hit = 0;
  d_cache_miss = 0;
  d_cache_read = 0;
  d_cache_write = 0;
  d_cache_ratio = 0;

  tag_line = 96'bx; // make tag line x
  for(j = 0; j < 16384; j = j + 1) begin
    d_cache[j] = tag_line; // fill data cache array with empty tag line at every index to reset cache
  end
end


// if instruction is 0 1 3 4 or 9
else if(instruction == 0 || instruction == 1 || instruction == 3 || instruction == 4 || instruction == 9) begin
array_LRU[0] = LRU_cache[index][23:21]; // LRU array gets LRU values at index for each way
array_LRU[1] = LRU_cache[index][20:18];
array_LRU[2] = LRU_cache[index][17:15];
array_LRU[3] = LRU_cache[index][14:12];
array_LRU[4] = LRU_cache[index][11:9];
array_LRU[5] = LRU_cache[index][8:6];
array_LRU[6] = LRU_cache[index][5:3];
array_LRU[7] = LRU_cache[index][2:0];

MESI_line = MESI_cache[index]; // get MESI line from MESI cache array at index
array_MESI[0] = MESI_line[15:14]; // MESI array gets each way's state
array_MESI[1] = MESI_line[13:12];
array_MESI[2] = MESI_line[11:10];
array_MESI[3] = MESI_line[9:8];
array_MESI[4] = MESI_line[7:6];
array_MESI[5] = MESI_line[5:4];
array_MESI[6] = MESI_line[3:2];
array_MESI[7] = MESI_line[1:0];


// finding current LRU way function

invalid = 1'b0; // invalid is set to 0 since it is not known yet if there are invalid states
current_LRU_way = 3'b0; // current LRU way is set to 0 initially
smallest_MESI_LRU = 3'b111; // smallest MESI LRU value is set to max in order to find min

// this function looks through MESI states and sets current LRU way to LRU invalid way
for(i = 0; i < 8; i = i + 1) begin
  if(array_MESI[i] == I && array_LRU[i] <= smallest_MESI_LRU) begin // if the state in invalid and LRU is less than prior smallest LRU
    invalid = 1'b1; // set invalid to 1
    smallest_MESI_LRU = array_LRU[i]; // smallest MESI LRU is updated
    current_LRU_way = i; // current LRU way is selected
  end
end

// if no ways are invalid then invalid is 0 and current LRU way is found just by comparing LRUs
if(invalid == 0) begin
  smallest_LRU = array_LRU[0]; // smallest LRU gets first way's LRU
  current_LRU_way = 3'b0; // current way gets first way initially
  for(i = 1; i < 8; i = i + 1) begin
    if(array_LRU[i] < smallest_LRU) begin // if LRU is smaller than smallest LRU
      smallest_LRU = array_LRU[i]; // replace with smallest LRU value
      current_LRU_way = i; // current LRU way is selected
    end
  end
end



// D-Cache functions
  tag_line = d_cache[index]; // tag line get tag line at index
  tag_way1 = tag_line[95:84]; // tag line is broken into each tag way
  tag_way2 = tag_line[83:72];
  tag_way3 = tag_line[71:60];
  tag_way4 = tag_line[59:48];
  tag_way5 = tag_line[47:36];
  tag_way6 = tag_line[35:24];
  tag_way7 = tag_line[23:12];
  tag_way8 = tag_line[11:0];

  case(tag) // case statement to compare current tag with tags in each way
    tag_way1: begin // if it is a hit
          MRU_way = 3'b000; // specify MRU way
          hit_miss = 1; // hit is asserted
          d_cache_hit = d_cache_hit + 1; // add one to d-cache hit count
          end
    tag_way2: begin
          MRU_way = 3'b001;
          hit_miss = 1;
          d_cache_hit = d_cache_hit + 1;
          end
    tag_way3: begin
          MRU_way = 3'b010;
          hit_miss = 1;
          d_cache_hit = d_cache_hit + 1;
          end
    tag_way4: begin
          MRU_way = 3'b011;
          hit_miss = 1;
          d_cache_hit = d_cache_hit + 1;
          end
    tag_way5: begin
          MRU_way = 3'b100;
          hit_miss = 1;
          d_cache_hit = d_cache_hit + 1;
          end
    tag_way6: begin
          MRU_way = 3'b101;
          hit_miss = 1;
          d_cache_hit = d_cache_hit + 1;
          end
    tag_way7: begin
          MRU_way = 3'b110;
          hit_miss = 1;
          d_cache_hit = d_cache_hit + 1;
          end
    tag_way8: begin
          MRU_way = 3'b111;
          hit_miss = 1;
          d_cache_hit = d_cache_hit + 1;
          end
    default: begin // if it is a miss
          MRU_way = current_LRU_way; // MRU way gets the current LRU way
          hit_miss = 0; // miss so hit_miss is not asserted
          d_cache_miss = d_cache_miss + 1; // add one to d-cache miss count
          case(current_LRU_way) // case statement to update tag at current LRU way
            3'b000: tag_way1 = tag;
            3'b001: tag_way2 = tag;
            3'b010: tag_way3 = tag;
            3'b011: tag_way4 = tag;
            3'b100: tag_way5 = tag;
            3'b101: tag_way6 = tag;
            3'b110: tag_way7 = tag;
            3'b111: tag_way8 = tag;
            default;
          endcase
          end
  endcase

  tag_line = {tag_way1, tag_way2, tag_way3, tag_way4, tag_way5, tag_way6, tag_way7, tag_way8}; // tag line is updated
  d_cache[index] = tag_line; // tag line at index in data cache array is updated

  d_cache_ratio = d_cache_hit/(d_cache_hit + d_cache_miss); // d-cache hit ratio is calculated



// MESI function

  current_MESI = array_MESI[MRU_way]; // current MESI gets MESI status at MRU way

  case(current_MESI) // case for MESI state in order to determine next transmission

  I: begin // if state is invalid
    if(instruction == write) begin // if instruction is write
      array_MESI[MRU_way] = M; // update MESI state to M
    end
    else if(instruction == read && hit_miss == 1) begin // if instruction is read and hit
      array_MESI[MRU_way] = S; // change state to S
    end
    else if(instruction == read && hit_miss == 0) begin // if instruction read and miss
      array_MESI[MRU_way] = E; // change state to E
    end
  end

  S: begin // if state is shared
    if(instruction == write && hit_miss == 0) begin // if write and miss
      array_MESI[MRU_way] = M; // change state to M
    end
    else if(instruction == read) begin // if read
      array_MESI[MRU_way] = S; // keep state as S
    end
  end

  E: begin // if state is exclusive
    if(instruction == write) begin // if instruction is write
      array_MESI[MRU_way] = M; // change state to M
    end
    else if(instruction == read && hit_miss == 1) begin // if instruction is read and hit
      array_MESI[MRU_way] = S; // change state to S
    end
    else if(instruction == read && hit_miss == 0) begin // if instruction is read and miss
      array_MESI[MRU_way] = E; // keep state as E
    end
    else if(instruction == data_request_L2) begin // if instruction is snoop
      array_MESI[MRU_way] = I; // change state to I
    end
  end

  M: begin // if state is modified
    if(instruction == write || instruction == read) begin // if instruction is write or read
      array_MESI[MRU_way] = M; // keep state as M
    end
    else if(instruction == data_request_L2) begin // if instruction is snoop
      array_MESI[MRU_way] = I; // change state to I
    end
  end
  endcase

  // update MESI line with new MESI states
  MESI_line = {array_MESI[0], array_MESI[1], array_MESI[2], array_MESI[3], array_MESI[4], array_MESI[5], array_MESI[6], array_MESI[7]};
  MESI_way1 = MESI_line[15:14];
  MESI_way2 = MESI_line[13:12];
  MESI_way3 = MESI_line[11:10];
  MESI_way4 = MESI_line[9:8];
  MESI_way5 = MESI_line[7:6];
  MESI_way6 = MESI_line[5:4];
  MESI_way7 = MESI_line[3:2];
  MESI_way8 = MESI_line[1:0];
  MESI_cache[index] = MESI_line; // update MESI cache at index with MESI line
  MESI_MRU = array_MESI[MRU_way]; // get MESI state for MRU way


// LRU function to update LRUs at index

  current_MRU = array_LRU[MRU_way]; // get current LRU value at MRU way
  for(i = 0; i < 8; i = i + 1) begin
    if (array_LRU[i] > current_MRU) begin // if value of LRU is bigger than current MRU
      array_LRU[i] = array_LRU[i] - 1; // decrement LRU by one
    end
    else begin
      array_LRU[i] = array_LRU[i]; // else keep the same
    end
  end

  array_LRU[MRU_way] = 3'b111; // LRU value at MRU way is set to MRU
  LRU_way1 = array_LRU[0]; // LRU ways updated
  LRU_way2 = array_LRU[1];
  LRU_way3 = array_LRU[2];
  LRU_way4 = array_LRU[3];
  LRU_way5 = array_LRU[4];
  LRU_way6 = array_LRU[5];
  LRU_way7 = array_LRU[6];
  LRU_way8 = array_LRU[7];

  // LRU line updated by concatenating LRU ways
  LRU_line = {LRU_way1, LRU_way2, LRU_way3, LRU_way4, LRU_way5, LRU_way6, LRU_way7, LRU_way8};
  LRU_cache[index] = LRU_line; // LRU cache at index is updated with LRU line


// reads and writes count

  case(instruction)
    0: d_cache_read = d_cache_read + 1; // increment reads if instruction is read
    1: d_cache_write = d_cache_write + 1; // increment writes if instruction is write
    default;
  endcase
end
end

endmodule
