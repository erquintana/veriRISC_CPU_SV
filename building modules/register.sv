//------------------------------------------------------------------------------
// Project: Verifying the VeriRISC CPU
// File:    register.sv
// Author:  Esteban Rodríguez Quintana
// Date:    <>
//
// Description: <>
//
// Revision History:
// - <Date>: <Version / Modification Description>
//
//------------------------------------------------------------------------------

module register(
    input logic [0:7] data,
    input logic enable,
    input logic clk,
    input logic rst_,

    output logic [0:7] out
);
    always_ff @(posedge clk or negedge rst_) begin
        if(!rst_) begin
            out <= 0;
        end else if (enable) begin
            out <= data;
        end else begin
            out <= out;
        end
    end
endmodule
