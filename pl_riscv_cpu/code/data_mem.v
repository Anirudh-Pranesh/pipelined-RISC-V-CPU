/*
# Team ID:          2604
# Theme:            Logic Quest
# Author List:      Anirudh, Advait, Aman
# Filename:         data_mem.v
# File Description: stores and loads byte, halfword and word data for the CPU
# Global variables: DATA_WIDTH, ADDR_WIDTH, MEM_SIZE, clk, wr_en, funct3, wr_addr, wr_data, rd_data_mem, data_ram, word_addr
*/

// data_mem.v - data memory

module data_mem #(parameter DATA_WIDTH = 32, ADDR_WIDTH = 32, MEM_SIZE = 64) (
    // clk: memory write clock
    // wr_en: enables a store operation
    input       clk, wr_en,
    // funct3: identifies the load or store size and signedness
    input [2:0] funct3,
    // wr_addr: byte address used for load and store operations
    // wr_data: data supplied for store operations
    input       [ADDR_WIDTH-1:0] wr_addr, wr_data,
    // rd_data_mem: data read from memory and formatted for the load instruction
    output reg  [DATA_WIDTH-1:0] rd_data_mem
);

// data_ram: array containing the 32-bit words stored by the processor
reg [DATA_WIDTH-1:0] data_ram [0:MEM_SIZE-1];

// word_addr: word index selected by the byte address
wire [ADDR_WIDTH-1:0] word_addr = wr_addr[DATA_WIDTH-1:2] % 64;

// synchronous write logic
always @(posedge clk) begin
    /*
    Purpose:
    ---
    writes a byte, halfword or word into the addressed memory word when a store operation is enabled
    */

    if (wr_en) begin
        case (funct3)
            3'b000: begin // sb
                case (wr_addr[1:0])
                    2'b00: data_ram[word_addr][ 7: 0] = wr_data[7:0];
                    2'b01: data_ram[word_addr][15: 8] = wr_data[7:0];
                    2'b10: data_ram[word_addr][23:16] = wr_data[7:0];
                    2'b11: data_ram[word_addr][31:24] = wr_data[7:0];
                endcase
            end
            3'b001: begin // sh
                if (wr_addr[1]) data_ram[word_addr][31:16] <= wr_data[15:0];
                else            data_ram[word_addr][15:0]  <= wr_data[15:0];
            end
            3'b010: data_ram[word_addr] <= wr_data; // sw
        endcase
    end
end

always @(*) begin
    /*
    Purpose:
    ---
    selects the requested byte, halfword or word from memory and applies signed or unsigned extension
    */

    case (funct3)
        3'b000: begin // lb
            case (wr_addr[1:0])
                2'b00: rd_data_mem = {{24{data_ram[word_addr][ 7]}}, data_ram[word_addr][ 7: 0]};
                2'b01: rd_data_mem = {{24{data_ram[word_addr][15]}}, data_ram[word_addr][15: 8]};
                2'b10: rd_data_mem = {{24{data_ram[word_addr][23]}}, data_ram[word_addr][23:16]};
                2'b11: rd_data_mem = {{24{data_ram[word_addr][31]}}, data_ram[word_addr][31:24]};
            endcase
        end
        3'b100: begin // lbu
            case (wr_addr[1:0])
                2'b00: rd_data_mem = {24'b0, data_ram[word_addr][ 7: 0]};
                2'b01: rd_data_mem = {24'b0, data_ram[word_addr][15: 8]};
                2'b10: rd_data_mem = {24'b0, data_ram[word_addr][23:16]};
                2'b11: rd_data_mem = {24'b0, data_ram[word_addr][31:24]};
            endcase
        end
        3'b001: begin // lh
            if (wr_addr[1]) rd_data_mem = {{16{data_ram[word_addr][31]}}, data_ram[word_addr][31:16]};
            else            rd_data_mem = {{16{data_ram[word_addr][15]}}, data_ram[word_addr][15:0]};
        end
        3'b010: rd_data_mem = data_ram[word_addr]; // lw
        3'b101: begin // lhu
            if (wr_addr[1]) rd_data_mem = {16'b0, data_ram[word_addr][31:16]};
            else            rd_data_mem = {16'b0, data_ram[word_addr][15:0]};
        end
        default: rd_data_mem = 32'bx;
    endcase
end

endmodule

