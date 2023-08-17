//------------------------------------------------------------------------------
// Project: Verifying the VeriRISC CPU
// File:    alu.sv
// Author:  Esteban Rodríguez Quintana
// Date:    <>
//
// Description: <>
//
// Revision History:
// - <Date>: <Version / Modification Description>
//
//------------------------------------------------------------------------------
typedef enum logic [0:2] {HLT, SKZ, ADD, AND, XOR, LDA, STO, JMP } opcode_t;

module alu (
    input logic [0:7] accum,
    input logic [0:7] data,
    input opcode_t opcode,
    input logic  clk,
    output logic  [0:7] out,
    output logic  zero
); 


always_comb begin
    zero = (accum == 0)? 1 : 0;
end

always_ff @(negedge clk) begin
    unique case(opcode)
        HLT : out = accum;
        SKZ : out = accum;
        ADD : out = data + accum;
        AND : out = data & accum;
        XOR : out = data ^ accum;
        LDA : out = data;
        STO : out = accum;
        JMP : out = accum;
        default : out = 'x;
    endcase
end
endmodule