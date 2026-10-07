/*
# Team ID:          2604
# Theme:            Logic Quest
# Author List:      Anirudh, Advait, Aman
# Filename:         load_unit.v
# File Description: selects byte, halfword or word data from memory and extends it for load instructions
# Global variables: LoadResult
*/

// load_unit.v - select and extend loaded data
module load_unit (
    input      [31:0] ReadData,     // word from data memory
    input      [1:0]  addr,         // ALUResult[1:0] (byte offset)
    input      [2:0]  funct3,       // Instr[14:12]
    output reg [31:0] LoadResult
);

// ByteData: selected byte from the addressed word for lb and lbu instructions
wire [7:0]  ByteData = (addr == 2'b00) ? ReadData[7:0]   :
                       (addr == 2'b01) ? ReadData[15:8]  :
                       (addr == 2'b10) ? ReadData[23:16] :
                                         ReadData[31:24];

// HalfData: selected halfword from the addressed word for lh and lhu instructions
wire [15:0] HalfData = addr[1] ? ReadData[31:16] : ReadData[15:0];

always @(*) begin
    /*
    Purpose:
    ---
    produces the final load result by sign extending or zero extending the selected memory data
    */

    case (funct3)
        3'b000:  LoadResult = {{24{ByteData[7]}},  ByteData};   // lb
        3'b001:  LoadResult = {{16{HalfData[15]}}, HalfData};   // lh
        3'b100:  LoadResult = {24'b0, ByteData};                // lbu
        3'b101:  LoadResult = {16'b0, HalfData};                // lhu
        default: LoadResult = ReadData;                         // lw
    endcase
end

endmodule