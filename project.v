// Baraa Khafar , S1, 1210640


// ALU Module
module alu (
  input [5:0] opcode,
  input [31:0] a,
  input [31:0] b,
  output reg [31:0] result
);

  always @*
    case (opcode)
      6'b001000: result = a + b;          // a + b
      6'b001001: result = a - b;          // a - b
      6'b000010: result = (a < 0) ? -a : a; // |a|
      6'b001010: result = -a;             // -a
      6'b001100: result = (a > b) ? a : b; // max(a, b)
      6'b000001: result = (a < b) ? a : b; // min(a, b)
      6'b001101: result = (a + b) >> 1;    // avg(a, b)
      6'b000101: result = ~a;             // not a
      6'b000100: result = a | b;          // a or b
      6'b001011: result = a & b;          // a and b
      6'b001111: result = a ^ b;          // a xor b
      default: result = 32'b0;            // default case (do nothing)
    endcase

endmodule


// Register File Module
module reg_file (
  input clk,
  input enable,
  input [4:0] addr1,
  input [4:0] addr2,
  input [4:0] addr3,
  input [31:0] in,
  output reg [31:0] out1,
  output reg [31:0] out2
);
  // declare memory
  reg [31:0] mem [0:31];
  reg clk_edge_condition;

  initial begin
    clk_edge_condition = 1'b0;
  end

  always @(posedge clk or negedge clk) begin
    clk_edge_condition =~clk_edge_condition;
  end

  always @*
    if (enable && clk_edge_condition)
    begin
      out1 <= mem[addr1];
      out2 <= mem[addr2];
      mem[addr3] <= in;
    end

  // Initialize memory based on the second-from-last digit of ID
  initial begin
    mem[0] <= 1'b0;
    mem[1] <= 13'b1000001100110;
    mem[2] <= 13'b1010111011100;
    mem[3] <= 14'b11100001011010;
    mem[4] <= 13'b1110110111100;
    mem[5] <= 13'b1100111101110;
    mem[6] <= 14'b10011100111000;
    mem[7] <= 12'b111101011010;
    mem[8] <= 13'b1000000110110;
    mem[9] <= 13'b1100100000110;
    mem[10] <= 13'b1010100011000;
    mem[11] <= 14'b10000101111100;
    mem[12] <= 14'b11111111000100;
    mem[13] <= 14'b10001010001000;
    mem[14] <= 14'b10000001000010;
    mem[15] <= 14'b10101111011100;
    mem[16] <= 14'b10000100001110;
    mem[17] <= 14'b11001111100100;
    mem[18] <= 13'b1001001000100;
    mem[19] <= 12'b111110001100;
    mem[20] <= 13'b1011000000010;
    mem[21] <= 13'b1110111010000;
    mem[22] <= 14'b10011001110110;
    mem[23] <= 13'b1010101000010;
    mem[24] <= 14'b11000011001000;
    mem[25] <= 13'b1101000000000;
    mem[26] <= 10'b1101000000;
    mem[27] <= 13'b1001000111000;
    mem[28] <= 13'b1101010001110;
    mem[29] <= 14'b11011101010110;
    mem[30] <= 12'b110010101110;
    mem[31] <= 1'b0;
  end

endmodule

// Microprocessor Top Module
module mp_top (
  input clk,
  input [31:0] instruction,
  output reg [31:0] result
);

  reg [5:0] opcode;
  reg [4:0] addr1, addr2, addr3;

  // buffer for opcode with one clock cycle delay
  reg [5:0] opcode_buffer;

  // enable signal
  reg enable;

  // output registers from Register File
  reg [31:0] reg_out1, reg_out2;

  // initialize ALU and Register File
  alu my_alu (.opcode(opcode), .a(reg_out1), .b(reg_out2), .result(result));
  reg_file my_reg_file (.clk(clk), .enable(enable), .addr1(addr1), .addr2(addr2), .addr3(addr3), .in(result), .out1(reg_out1), .out2(reg_out2));

  always @(posedge clk) begin
    // extract fields from the instruction
    enable = 1'b0;
     opcode_buffer <= instruction[5:0];  
    addr1 <= instruction[10:6];          
    addr2 <= instruction[15:11];        
    addr3 <= instruction[20:16];        
    opcode = opcode_buffer;
    // use only the rising edge of the clock for synchronization
    enable = 1'b1;
  end

endmodule

// testbench for Microprocessor Top
module tb_mp_top;

  // declare signals
  reg clk;
  reg [31:0] instruction;
  wire [31:0] result;
  integer i;
  reg [31:0] expected_result;
  reg [31:0] instructions [0:10];

  // initialize the microprocessor top module
  mp_top uut (
    .clk(clk),
    .instruction(instruction),
    .result(result)
  );

  // clock generation and instruction initialization
  initial begin
    clk <= 0;
    // Instructions using the defined opcodes
    instructions[0] <= 32'b00000000000_00011_00010_00001_001000; // add
    instructions[1] <= 32'b00000000000_00011_00001_00010_001001; // subtract
    instructions[2] <= 32'b00000000000_00011_00000_00001_000010; // absolute value
    instructions[3] <= 32'b00000000000_00011_00000_00001_001010; // -a
    instructions[4] <= 32'b00000000000_00011_00010_00001_001100; // maximum
    instructions[5] <= 32'b00000000000_00011_00010_00001_000001; // minimum
    instructions[6] <= 32'b00000000000_00011_00010_00001_001101; // average
    instructions[7] <= 32'b00000000000_00011_00000_00001_000101; // bitwise NOT
    instructions[8] <= 32'b00000000000_00011_00010_00001_000100; // bitwise OR
    instructions[9] <= 32'b00000000000_00011_00010_00001_001011; // bitwise AND
	instructions[10] <= 32'b00000000000_00011_00010_00001_001111; // bitwise XOR


    i <= 0;
    forever #5 clk = ~clk;

  end

  // test procedure
  always @(posedge clk) begin

    if (i == 11) begin
      // end simulation
      $stop;
    end
    // execute instructions
    instruction = instructions[i];
    #25;
    // print input instruction and result
    expected_result = calculate_expected_result(instruction);
    $display("Instruction: %b, Result: %b, Expected Result: %b", instruction, result, expected_result);
    // compare expected result with output result
    if (result !== expected_result) begin
      $display("Test failed for instruction %b\n\n", instruction);
    end
    else begin
      $display("Test Passed for instruction %b\n\n", instruction);
    end

    i = i + 1;
  end

  function [31:0] calculate_expected_result(input [31:0] instr);
    reg [5:0] opcode;
    reg [4:0] addr1, addr2;

    // extract fields from the instruction
    opcode = instr[5:0];
    addr1 = instr[10:6];
    addr2 = instr[15:11];
    // decode opcode and perform the corresponding operation
    case (opcode)
      6'b001000: expected_result = uut.my_reg_file.mem[addr1] + uut.my_reg_file.mem[addr2]; // add
      6'b001001: expected_result = uut.my_reg_file.mem[addr1] - uut.my_reg_file.mem[addr2]; // subtract
      6'b000010: expected_result = (uut.my_reg_file.mem[addr1] < 0) ? -uut.my_reg_file.mem[addr1] : uut.my_reg_file.mem[addr1]; // absolute value
      6'b001010: expected_result = -uut.my_reg_file.mem[addr1]; // -a
      6'b001100: expected_result = (uut.my_reg_file.mem[addr1] > uut.my_reg_file.mem[addr2]) ? uut.my_reg_file.mem[addr1] : uut.my_reg_file.mem[addr2]; // max(a, b)
      6'b000001: expected_result = (uut.my_reg_file.mem[addr1] < uut.my_reg_file.mem[addr2]) ? uut.my_reg_file.mem[addr1] : uut.my_reg_file.mem[addr2]; // min(a, b)
      6'b001101: expected_result = (uut.my_reg_file.mem[addr1] + uut.my_reg_file.mem[addr2]) >> 1; // avg(a, b)
      6'b000101: expected_result = ~uut.my_reg_file.mem[addr1]; // not a
      6'b000100: expected_result = uut.my_reg_file.mem[addr1] | uut.my_reg_file.mem[addr2]; // a or b
      6'b001011: expected_result = uut.my_reg_file.mem[addr1] & uut.my_reg_file.mem[addr2]; // a and b
      6'b001111: expected_result = uut.my_reg_file.mem[addr1] ^ uut.my_reg_file.mem[addr2]; // a xor b
      default: expected_result = 32'b0; // default case (do nothing)
    endcase

    return expected_result;
  endfunction

endmodule
