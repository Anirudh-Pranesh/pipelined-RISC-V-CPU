/*
# Team ID:          2604
# Theme:            Logic Quest
# Author List:      Anirudh, Advait, Aman
# Filename:         store_unit.v
# File Description: prepares write data for byte, halfword and word store instructions
# Global variables: StoreData
*/

// store_unit.v - prepare store data for byte, halfword, and word stores

module store_unit (
    input      [31:0] ReadData,     // current word at the address
    input      [31:0] WriteData,    // rs2
    input      [1:0]  addr,         // ALUResult[1:0]
    input      [2:0]  funct3,       // Instr[14:12]
    output reg [31:0] StoreData
);

always @(*) begin
    /*
    Purpose:
    ---
    selects the write data format required by sb, sh and sw store instructions
    */

    case (funct3)
        3'b000:  StoreData = {24'b0, WriteData[7:0]};                  // sb
        3'b001:  StoreData = {{16{WriteData[15]}}, WriteData[15:0]};   // sh
        3'b010:  StoreData = WriteData;                                // sw
        default: StoreData = WriteData;
    endcase
end

endmodule