// cache_TB.sv - ECE585 Final Project - Cache Test Bench
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
// Cache testbench, used to get user input for Mode and trace file name
// "vsim cache_TB +M=0 +filename=tracefile.txt" for mode 0
// "vsim cache_TB +M=1 +filename=tracefile.txt" for mode 1
// Prints cache statistics at the end of any trace file and the states at the last index

module cache_TB;

logic [35:0] input_in; // input into top module is 36 bits, 4 bits for instructions and 32 for address
logic clk; // clock for the test bench always block
logic mode, m; // mode from input from user
parameter TRUE   = 1'b1; // true / false parameters
parameter FALSE  = 1'b0;

parameter N = 36000; // half the maximum number of instructions in trace file

logic [1000:0] str; // string for file name
logic [31:0] data [N-1:0]; // array of data in trace file
logic [35:0] address [N-1:0]; // array of data concatenated into instruction and address

integer i, j, k; // integers for reading file and running the main loop


initial clk = 1'b1; // clock initially on
always #5 clk = ~clk; // flip with 5 delay

cache dcache(.address(input_in), .mode(mode), .iteration(k)); // instantiation of the cache top level


// user input function
initial begin

$value$plusargs("M=%b", m); // get mode
mode = m; // assign mode


$value$plusargs("filename=%0s", str); // get string of file name
$readmemh(str, data); // read file using file name and fill data array with content


j = 0; // setting integer j to 0 before filling instruction and address array

for(i = 0 ; i < N ; i = i + 1) begin // loop from zero to trace file length N
	if(i % 2 != 0) begin // when i is odd fill address
		// this is done because when reading the trace file a space creates a new item in data array
		address[j] = {data[i-1], data[i]}; // current index in data would hold address and prior index holds instruction
		j = j + 1; // increment j only when i is odd
	end
end
end

always @(posedge clk) begin // at every rising clock edge

	for(k = 0 ; k < N ; k = k + 1) begin // for loop to run entire trace file commands
		#100 // after delay of 100
		if(address[k] !== 36'bx) begin // if address is not X then use as input
			input_in = address[k]; // input in goes into the cache top module
		end
		else if(address[k] === 36'bx || k == N - 1) begin // if address is X (end of trace file) or int k is N - 1 (end of entire data array)
			input_in = {4'b1001, address[k-1][31:0]}; // send the final command as a 9 to print statistics and use the last index for cache state
			#100 // delay 100
			$stop; // stop running simulation
		end
	end

end


endmodule
