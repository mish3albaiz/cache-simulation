module instruction_cache(i_cache_hit, i_cache_miss, i_cache_read, i_cache_ratio, tag_line, LRU_line, hit_miss, index, tag, instruction, byte_offset, iteration);

output real i_cache_hit, i_cache_miss, i_cache_read, i_cache_ratio;
output logic [47:0] tag_line;
output logic hit_miss;
output logic [7:0] LRU_line;
input logic [13:0] index;
input logic [11:0] tag;
input logic [3:0] instruction;
input logic [5:0] byte_offset;
input logic [31:0] iteration;

logic [1:0] MRU_way;
logic [47:0] i_cache [0:16383];
logic [11:0] tag_way1, tag_way2, tag_way3, tag_way4;
logic [7:0] LRU_cache [0:16383];
logic [1:0] array_LRU [0:3];
logic [1:0] smallest_LRU;
logic [1:0] current_LRU_way;
logic [1:0] current_MRU;

logic [1:0] LRU_way1, LRU_way2, LRU_way3, LRU_way4;

integer i;

initial begin

  array_LRU[0] = 2'b00;
  array_LRU[1] = 2'b01;
  array_LRU[2] = 2'b10;
  array_LRU[3] = 2'b11;


  LRU_line = {array_LRU[0], array_LRU[1], array_LRU[2], array_LRU[3]};

  for(i = 0; i < 16384; i = i + 1) begin
    LRU_cache[i] = LRU_line;
  end

  i_cache_hit = 0;
  i_cache_miss = 0;
  i_cache_read = 0;
  i_cache_ratio = 0;
end

always @(index, tag, instruction, byte_offset, iteration) begin
if(instruction == 8) begin
  array_LRU[0] = 2'b00;
  array_LRU[1] = 2'b01;
  array_LRU[2] = 2'b10;
  array_LRU[3] = 2'b11;


  LRU_line = {array_LRU[0], array_LRU[1], array_LRU[2], array_LRU[3]};

  for(i = 0; i < 16384; i = i + 1) begin
    LRU_cache[i] = LRU_line;
  end

  i_cache_hit = 0;
  i_cache_miss = 0;
  i_cache_read = 0;
  i_cache_ratio = 0;

  tag_line = 48'bx;
  for(i = 0; i < 16384; i = i + 1) begin
    i_cache[i] = tag_line;
  end
end
else if(instruction == 2) begin // the instruction cache is only used when the instruction is 2

  i_cache_read = i_cache_read + 1;

// finding current LRU way function

  array_LRU[0] = LRU_cache[index][7:6];
  array_LRU[1] = LRU_cache[index][5:4];
  array_LRU[2] = LRU_cache[index][3:2];
  array_LRU[3] = LRU_cache[index][1:0];

  smallest_LRU = array_LRU[0];
  current_LRU_way = 2'b0;
  for(i = 1; i < 4; i = i + 1) begin
    if(array_LRU[i] < smallest_LRU) begin
      smallest_LRU = array_LRU[i];
      current_LRU_way = i;
    end
end

// D-Cache functions
  tag_line = i_cache[index];
  tag_way1 = tag_line[47:36];
  tag_way2 = tag_line[35:24];
  tag_way3 = tag_line[23:12];
  tag_way4 = tag_line[11:0];

  case(tag)
    tag_way1: begin
          MRU_way = 2'b00;
          hit_miss = 1;
          i_cache_hit = i_cache_hit + 1;
          end
    tag_way2: begin
          MRU_way = 2'b01;
          hit_miss = 1;
          i_cache_hit = i_cache_hit + 1;
          end
    tag_way3: begin
          MRU_way = 2'b10;
          hit_miss = 1;
          i_cache_hit = i_cache_hit + 1;
          end
    tag_way4: begin
          MRU_way = 2'b11;
          hit_miss = 1;
          i_cache_hit = i_cache_hit + 1;
          end
    default: begin
          MRU_way = current_LRU_way;
          hit_miss = 0;
          i_cache_miss = i_cache_miss + 1;
          case(current_LRU_way)
            2'b00: tag_way1 = tag;
            2'b01: tag_way2 = tag;
            2'b10: tag_way3 = tag;
            2'b11: tag_way4 = tag;
            default;
          endcase
          end
  endcase
  tag_line = {tag_way1, tag_way2, tag_way3, tag_way4};
  i_cache[index] = tag_line;

  i_cache_ratio = i_cache_hit/(i_cache_hit + i_cache_miss);

  // LRU function

    current_MRU = array_LRU[MRU_way];
    for(i = 0; i < 4; i = i + 1) begin
      if (array_LRU[i] > current_MRU) begin
        array_LRU[i] = array_LRU[i] - 1;
      end
      else begin
        array_LRU[i] = array_LRU[i];
      end
    end

    array_LRU[MRU_way] = 2'b11;
    LRU_way1 = array_LRU[0];
    LRU_way2 = array_LRU[1];
    LRU_way3 = array_LRU[2];
    LRU_way4 = array_LRU[3];
    LRU_line = {LRU_way1, LRU_way2, LRU_way3, LRU_way4};
    LRU_cache[index] = LRU_line;


end
end

endmodule
