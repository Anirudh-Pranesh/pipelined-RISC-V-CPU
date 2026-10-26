/*
# Team ID:          2604
# Theme:            Logic Quest
# Author List:      Anirudh, Advait, Aman
# Filename:         datapath.v
# File Description: connects the program counter, register file, ALU, pipeline registers and result path for the pipelined CPU
# Global variables: clk, reset, Instr, ReadData, PC, Mem_WrAddr, Mem_WrData, Result, Funct3M, MemWriteM, MemWriteW, PCW, ALUResultW, WriteDataW, PCF, PCNextF, PCPlus4F, InstrD, PCD, PCPlus4D, Rs1D, Rs2D, RdD, Funct3D, RD1D, RD2D, ImmExtD, UImmD, RegWriteD, MemWriteD, BranchD, JumpD, JalrD, ResultSrcD, ImmSrcD, ALUSrcD, ALUControlD, RD1E, RD2E, ImmExtE, UImmE, PCE, PCPlus4E, Rs1E, Rs2E, RdE, Funct3E, UTypeSelE, RegWriteE, MemWriteE, BranchE, JumpE, JalrE, ALUSrcE, ResultSrcE, ALUControlE, ALUResultE, WriteDataE, UTypeResultE, ALUResultForM, PCTargetE, BranchTakenE, PCSrcE, ALUZeroE, ForwardAE, ForwardBE, StallF, StallD, FlushD, FlushE, ALUResultM, WriteDataM, PCM, RdM, Funct3M_r, RegWriteM_r, MemWriteM_r, ResultSrcM, ALUResultW_r, ReadDataW, PCW_r, WriteDataW_r, RdW, RegWriteW, ResultSrcW, ResultW, SrcAE, SrcBE
*/

// datapath.v - five-stage pipelined RISC-V datapath

module datapath (
    // clk: processor clock
    // reset: reset signal for program counter and pipeline registers
    input         clk, reset,
    // Instr: instruction supplied by instruction memory
    input  [31:0] Instr,
    // ReadData: data returned by data memory
    input  [31:0] ReadData,
    // PC: current fetch stage program counter
    output [31:0] PC,
    // Mem_WrAddr: memory stage address sent to data memory
    // Mem_WrData: memory stage store data sent to data memory
    output [31:0] Mem_WrAddr, Mem_WrData,
    // Result: final result written back to the register file
    output [31:0] Result,
    // Funct3M: memory stage load or store operation type
    output [2:0]  Funct3M,
    // MemWriteM: memory stage store enable
    // MemWriteW: writeback stage store indicator used by the testbench
    output        MemWriteM, MemWriteW,
    // PCW: program counter of the instruction in writeback
    // ALUResultW: ALU or address result in writeback
    // WriteDataW: store data in writeback
    output [31:0] PCW, ALUResultW, WriteDataW
);

// PCF: current program counter used by fetch stage
// PCNextF: next program counter selected for the following cycle
// PCPlus4F: sequential next program counter
wire [31:0] PCF, PCNextF, PCPlus4F;
// InstrD: instruction held in decode stage
// PCD: program counter associated with decode stage instruction
// PCPlus4D: PC plus four associated with decode stage instruction
wire [31:0] InstrD, PCD, PCPlus4D;
// Rs1D: first source register extracted in decode stage
// Rs2D: second source register extracted in decode stage
// RdD: destination register extracted in decode stage
wire [4:0]  Rs1D, Rs2D, RdD;
// Funct3D: instruction function field used by the controller
wire [2:0]  Funct3D;
// RD1D: first register file operand read in decode stage
// RD2D: second register file operand read in decode stage
// ImmExtD: sign extended immediate generated in decode stage
// UImmD: upper immediate used by LUI and AUIPC
wire [31:0] RD1D, RD2D, ImmExtD, UImmD;
// RegWriteD: decode stage register write control
// MemWriteD: decode stage memory write control
// BranchD: decode stage conditional branch control
// JumpD: decode stage JAL control
// JalrD: decode stage JALR control
wire        RegWriteD, MemWriteD, BranchD, JumpD, JalrD;
// ResultSrcD: decode stage selection for writeback result
// ImmSrcD: decode stage immediate format selection
wire [1:0]  ResultSrcD, ImmSrcD;
// ALUSrcD: selects the second ALU operand source in decode stage
wire        ALUSrcD;
// ALUControlD: decoded ALU operation control
wire [3:0]  ALUControlD;

// RD1E: first operand transferred from decode to execute
// RD2E: second operand transferred from decode to execute
// ImmExtE: sign extended immediate transferred to execute
// UImmE: upper immediate transferred to execute
// PCE: program counter of execute stage instruction
// PCPlus4E: PC plus four of execute stage instruction
wire [31:0] RD1E, RD2E, ImmExtE, UImmE, PCE, PCPlus4E;
// Rs1E: first source register number in execute stage
// Rs2E: second source register number in execute stage
// RdE: destination register number in execute stage
wire [4:0]  Rs1E, Rs2E, RdE;
// Funct3E: instruction function field in execute stage
wire [2:0]  Funct3E;
// UTypeSelE: selects LUI or AUIPC behavior for U-type instructions
wire        UTypeSelE;
// RegWriteE: execute stage register write control
// MemWriteE: execute stage memory write control
// BranchE: execute stage branch control
// JumpE: execute stage JAL control
// JalrE: execute stage JALR control
// ALUSrcE: selects the second ALU operand in execute stage
wire        RegWriteE, MemWriteE, BranchE, JumpE, JalrE, ALUSrcE;
// ResultSrcE: execute stage result source control
wire [1:0]  ResultSrcE;
// ALUControlE: execute stage ALU operation control
wire [3:0]  ALUControlE;

// ALUResultE: raw result generated by execute stage ALU
// WriteDataE: forwarded second register operand used by ALU and stores
// UTypeResultE: LUI or AUIPC result generated in execute stage
wire [31:0] ALUResultE, WriteDataE, UTypeResultE;
// ALUResultForM: final result passed from execute to memory
wire [31:0] ALUResultForM;
// PCTargetE: branch or jump target calculated in execute stage
wire [31:0] PCTargetE;
// BranchTakenE: result of execute stage branch comparison
// PCSrcE: indicates that the next PC must use a branch or jump target
wire        BranchTakenE, PCSrcE;
// ALUZeroE: zero indication generated by execute stage ALU
wire        ALUZeroE;
// ForwardAE: forwarding selection for first execute stage operand
// ForwardBE: forwarding selection for second execute stage operand
wire [1:0]  ForwardAE, ForwardBE;
// StallF: holds fetch stage program counter during a hazard
// StallD: holds decode stage instruction during a hazard
// FlushD: clears decode stage after a branch or jump
// FlushE: clears execute stage after a hazard or control transfer
wire        StallF, StallD, FlushD, FlushE;

// ALUResultM: final ALU, U-type, or PC+4 result in memory stage
// WriteDataM: store data in memory stage
// PCM: program counter associated with memory stage instruction
wire [31:0] ALUResultM, WriteDataM, PCM;
// RdM: destination register number in memory stage
wire [4:0]  RdM;
// Funct3M_r: memory stage load or store function field
wire [2:0]  Funct3M_r;
// RegWriteM_r: memory stage register write control
// MemWriteM_r: memory stage store control
wire        RegWriteM_r, MemWriteM_r;
// ResultSrcM: memory stage result source control
wire [1:0]  ResultSrcM;

// ALUResultW_r: final ALU, U-type, or PC+4 result transferred into writeback
// ReadDataW: data memory result transferred into writeback
// PCW_r: program counter of instruction in writeback
wire [31:0] ALUResultW_r, ReadDataW, PCW_r;
// WriteDataW_r: store data transferred into writeback for observation
wire [31:0] WriteDataW_r;
// RdW: destination register number in writeback
wire [4:0]  RdW;
// RegWriteW: enables writing the final result into the register file
wire        RegWriteW;
// ResultSrcW: selects the final writeback value
wire [1:0]  ResultSrcW;
// ResultW: final value written into the register file
wire [31:0] ResultW;
// SrcAE: final forwarded first operand supplied to the ALU
// SrcBE: final second operand supplied to the ALU
wire [31:0] SrcAE, SrcBE;

// current fetch stage PC
assign PC = PCF;
// sequential next PC
assign PCPlus4F = PCF + 32'd4;
// select branch or jump target, otherwise continue to next instruction
assign PCNextF = PCSrcE ? PCTargetE : PCPlus4F;

// program counter register, stalls when load use hazard is detected
reset_ff #(32) pc_reg(clk, reset, StallF, PCNextF, PCF);

// fetch/decode pipeline register, stalls or flushes on hazards
pl_reg_fd if_id_reg(
    .clk(clk), .reset(reset), .en(~StallD), .clr(FlushD),
    .InstrF(Instr), .PCF(PCF), .PCPlus4F(PCPlus4F),
    .InstrD(InstrD), .PCD(PCD), .PCPlus4D(PCPlus4D)
);

// extract source and destination registers from decode stage instruction
assign Rs1D = InstrD[19:15];
assign Rs2D = InstrD[24:20];
assign RdD  = InstrD[11:7];
assign Funct3D = InstrD[14:12];
// extract upper immediate for LUI and AUIPC instructions
assign UImmD = {InstrD[31:12], 12'b0};

// decode instruction and generate control signals
controller controller_d(
    .op(InstrD[6:0]),
    .funct3(InstrD[14:12]),
    .funct7b5(InstrD[30]),
    .ResultSrc(ResultSrcD),
    .MemWrite(MemWriteD),
    .ALUSrc(ALUSrcD),
    .RegWrite(RegWriteD),
    .Branch(BranchD),
    .Jump(JumpD),
    .Jalr(JalrD),
    .ImmSrc(ImmSrcD),
    .ALUControl(ALUControlD)
);

// register file read and write logic
reg_file register_file(
    .clk(clk),
    .wr_en(RegWriteW),
    .rd_addr1(Rs1D),
    .rd_addr2(Rs2D),
    .wr_addr(RdW),
    .wr_data(ResultW),
    .rd_data1(RD1D),
    .rd_data2(RD2D)
);

// generate sign extended immediate for decode stage instruction
imm_extend immediate_ext(InstrD[31:7], ImmSrcD, ImmExtD);

// decode/execute pipeline registers
pipeline_reg #(32) id_ex_rd1(clk, reset, 1'b1, FlushE, RD1D, RD1E);
pipeline_reg #(32) id_ex_rd2(clk, reset, 1'b1, FlushE, RD2D, RD2E);
pipeline_reg #(32) id_ex_imm(clk, reset, 1'b1, FlushE, ImmExtD, ImmExtE);
pipeline_reg #(32) id_ex_uimm(clk, reset, 1'b1, FlushE, UImmD, UImmE);
pipeline_reg #(32) id_ex_pc(clk, reset, 1'b1, FlushE, PCD, PCE);
pipeline_reg #(32) id_ex_pc4(clk, reset, 1'b1, FlushE, PCPlus4D, PCPlus4E);
pipeline_reg #(5)  id_ex_rs1(clk, reset, 1'b1, FlushE, Rs1D, Rs1E);
pipeline_reg #(5)  id_ex_rs2(clk, reset, 1'b1, FlushE, Rs2D, Rs2E);
pipeline_reg #(5)  id_ex_rd(clk, reset, 1'b1, FlushE, RdD, RdE);
pipeline_reg #(3)  id_ex_funct3(clk, reset, 1'b1, FlushE, Funct3D, Funct3E);
pipeline_reg #(1)  id_ex_utype(clk, reset, 1'b1, FlushE, InstrD[5], UTypeSelE);
pipeline_reg #(1)  id_ex_regwrite(clk, reset, 1'b1, FlushE, RegWriteD, RegWriteE);
pipeline_reg #(2)  id_ex_resultsrc(clk, reset, 1'b1, FlushE, ResultSrcD, ResultSrcE);
pipeline_reg #(1)  id_ex_memwrite(clk, reset, 1'b1, FlushE, MemWriteD, MemWriteE);
pipeline_reg #(1)  id_ex_branch(clk, reset, 1'b1, FlushE, BranchD, BranchE);
pipeline_reg #(1)  id_ex_jump(clk, reset, 1'b1, FlushE, JumpD, JumpE);
pipeline_reg #(1)  id_ex_jalr(clk, reset, 1'b1, FlushE, JalrD, JalrE);
pipeline_reg #(4)  id_ex_alucontrol(clk, reset, 1'b1, FlushE, ALUControlD, ALUControlE);
pipeline_reg #(1)  id_ex_alusrc(clk, reset, 1'b1, FlushE, ALUSrcD, ALUSrcE);

// forward the newest available values to execute stage operands
mux3 #(32) forward_a(RD1E, ResultW, ALUResultM, ForwardAE, SrcAE);
mux3 #(32) forward_b(RD2E, ResultW, ALUResultM, ForwardBE, WriteDataE);
// select register or immediate value for second ALU input
mux2 #(32) alu_src_b(WriteDataE, ImmExtE, ALUSrcE, SrcBE);

// execute ALU and branch comparison logic
alu execute_alu(SrcAE, SrcBE, ALUControlE, ALUResultE, ALUZeroE);
branching_unit execute_branch(Funct3E, SrcAE, WriteDataE, BranchTakenE);

// calculate branch and jump targets and select the next PC
assign PCTargetE = JalrE ? {ALUResultE[31:1], 1'b0} : (PCE + ImmExtE);
assign PCSrcE = (BranchE & BranchTakenE) | JumpE | JalrE;
// select LUI or AUIPC result and pass the selected execute result forward
assign UTypeResultE = UTypeSelE ? UImmE : (PCE + UImmE);
assign ALUResultForM = (ResultSrcE == 2'b11) ? UTypeResultE :
                       (ResultSrcE == 2'b10) ? PCPlus4E : ALUResultE;

// execute/memory pipeline registers
pipeline_reg #(32) ex_mem_alu(clk, reset, 1'b1, 1'b0, ALUResultForM, ALUResultM);
pipeline_reg #(32) ex_mem_data(clk, reset, 1'b1, 1'b0, WriteDataE, WriteDataM);
pipeline_reg #(32) ex_mem_pc(clk, reset, 1'b1, 1'b0, PCE, PCM);
pipeline_reg #(5)  ex_mem_rd(clk, reset, 1'b1, 1'b0, RdE, RdM);
pipeline_reg #(3)  ex_mem_funct3(clk, reset, 1'b1, 1'b0, Funct3E, Funct3M_r);
pipeline_reg #(1)  ex_mem_regwrite(clk, reset, 1'b1, 1'b0, RegWriteE, RegWriteM_r);
pipeline_reg #(2)  ex_mem_resultsrc(clk, reset, 1'b1, 1'b0, ResultSrcE, ResultSrcM);
pipeline_reg #(1)  ex_mem_memwrite(clk, reset, 1'b1, 1'b0, MemWriteE, MemWriteM_r);

// memory stage interface
assign Mem_WrAddr = ALUResultM;
assign Mem_WrData = WriteDataM;
assign Funct3M = Funct3M_r;
assign MemWriteM = MemWriteM_r;

// memory/writeback pipeline registers
pipeline_reg #(32) mem_wb_alu(clk, reset, 1'b1, 1'b0, ALUResultM, ALUResultW_r);
pipeline_reg #(32) mem_wb_data(clk, reset, 1'b1, 1'b0, ReadData, ReadDataW);
pipeline_reg #(32) mem_wb_pc(clk, reset, 1'b1, 1'b0, PCM, PCW_r);
pipeline_reg #(32) mem_wb_store_data(clk, reset, 1'b1, 1'b0, WriteDataM, WriteDataW_r);
pipeline_reg #(5)  mem_wb_rd(clk, reset, 1'b1, 1'b0, RdM, RdW);
pipeline_reg #(1)  mem_wb_regwrite(clk, reset, 1'b1, 1'b0, RegWriteM_r, RegWriteW);
pipeline_reg #(1)  mem_wb_memwrite(clk, reset, 1'b1, 1'b0, MemWriteM_r, MemWriteW);
pipeline_reg #(2)  mem_wb_resultsrc(clk, reset, 1'b1, 1'b0, ResultSrcM, ResultSrcW);

// select ALU/load result or the already-selected link/U-type result for writeback
mux4 #(32) writeback_mux(
    ALUResultW_r, ReadDataW, ALUResultW_r, ALUResultW_r,
    ResultSrcW, ResultW
);

// expose writeback and debug values
assign Result = ResultW;
assign PCW = PCW_r;
assign ALUResultW = ALUResultW_r;
assign WriteDataW = WriteDataW_r;

// generate forwarding, stall, and flush controls
hazard_unit hazards(
    .Rs1D(Rs1D), .Rs2D(Rs2D),
    .Rs1E(Rs1E), .Rs2E(Rs2E), .RdE(RdE),
    .RdM(RdM), .RdW(RdW),
    .RegWriteM(RegWriteM_r), .RegWriteW(RegWriteW),
    .ResultSrcE(ResultSrcE), .PCSrcE(PCSrcE),
    .ForwardAE(ForwardAE), .ForwardBE(ForwardBE),
    .StallF(StallF), .StallD(StallD),
    .FlushD(FlushD), .FlushE(FlushE)
);

endmodule
