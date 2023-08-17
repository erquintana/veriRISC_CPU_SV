//------------------------------------------------------------------------------
// Project: Verifying the VeriRISC CPU
// File:    scale_mux.sv
// Author:  Esteban Rodríguez Quintana
// Date:    <>
//
// Description: <>
//
// Revision History:
// - <Date>: <Version / Modification Description>
//
//------------------------------------------------------------------------------

module scale_mux #(parameter width = 1) (
    input logic [0:width-1] in_a,
    input logic [0:width-1] in_b,
    input logic sel_a,
    output logic [0:width-1] out
);
    always_comb begin
        unique case (sel_a)
           1'b1 : out = in_a;
           1'b0 : out = in_b; 
            default: out = 'x;
        endcase
    end
endmodule
