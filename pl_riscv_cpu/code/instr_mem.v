/*
# Team ID:          2604
# Theme:            Logic Quest
# Author List:      Anirudh, Advait, Aman
# Filename:         instr_mem.v
# File Description: stores and supplies instructions to the pipelined CPU
# Global variables: DATA_WIDTH, ADDR_WIDTH, MEM_SIZE, instr_addr, instr, instr_ram
*/

// instr_mem.v - instruction memory

module instr_mem #(parameter DATA_WIDTH = 32, ADDR_WIDTH = 32, MEM_SIZE = 512) (
    // instr_addr: byte address of the instruction requested by the CPU
    input       [ADDR_WIDTH-1:0] instr_addr,
    // instr: instruction word read from instruction memory
    output      [DATA_WIDTH-1:0] instr
);

// instr_ram: array of MEM_SIZE instruction words
reg [DATA_WIDTH-1:0] instr_ram [0:MEM_SIZE-1];

initial begin
    /*
    Purpose:
    ---
    loads the program instruction words from the hexadecimal memory initialization file
    */

    $readmemh("rv32i_test.hex", instr_ram);
end

// word-aligned memory access
// combinational read logic
assign instr = instr_ram[instr_addr[31:2]];

endmodule

