/*
# Team ID:          2604
# Theme:            Logic Quest
# Author List:      Anirudh, Advait, Aman
# Filename:         riscv_cpu.v
# File Description: instantiates and connects the pipelined datapath of the riscv cpu
# Global variables: PC, MemWrite, Mem_WrAddr, Mem_WrData, Result, PCW, ALUResultW, WriteDataW
*/

// riscv_cpu.v - five-stage pipelined RISC-V processor

module riscv_cpu (
    // clk: processor clock
    // reset: reset signal for program counter and pipeline registers
    input         clk, reset,
    // PC: current fetch stage program counter
    output [31:0] PC,
    // Instr: instruction supplied by instruction memory
    input  [31:0] Instr,
    // MemWrite: memory stage store enable
    output        MemWrite,
    // Mem_WrAddr: memory stage address sent to data memory
    // Mem_WrData: memory stage store data sent to data memory
    output [31:0] Mem_WrAddr, Mem_WrData,
    // ReadData: data returned by data memory
    input  [31:0] ReadData,
    // Result: final result written back to the register file
    output [31:0] Result,
    // funct3: memory stage load or store operation type
    output [2:0]  funct3,
    // PCW: program counter of instruction in writeback
    // ALUResultW: ALU or address result in writeback
    // WriteDataW: store data in writeback
    output [31:0] PCW, ALUResultW, WriteDataW,
    // MemWriteW: writeback stage store indicator used by the testbench
    output        MemWriteW
);

// instantiate and connect the pipelined datapath
datapath dp(
    .clk(clk),
    .reset(reset),
    .Instr(Instr),
    .ReadData(ReadData),
    .PC(PC),
    .Mem_WrAddr(Mem_WrAddr),
    .Mem_WrData(Mem_WrData),
    .Result(Result),
    .Funct3M(funct3),
    .MemWriteM(MemWrite),
    .MemWriteW(MemWriteW),
    .PCW(PCW),
    .ALUResultW(ALUResultW),
    .WriteDataW(WriteDataW)
);

endmodule
