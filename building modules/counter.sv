//------------------------------------------------------------------------------
// Project: Verifying the VeriRISC CPU
// File:    counter.sv
// Author:  Esteban Rodríguez Quintana
// Date:    <>
//
// Description: <>
//
// Revision History:
// - <Date>: <Version / Modification Description>
//
//------------------------------------------------------------------------------

module counter(
    input logic [0:4] data,
    input logic load,
    input logic enable,
    input logic clk,
    input logic rst_,
    output logic [0:4] count
);
    
always_ff @(posedge clk or negedge rst_) begin
    if(!rst_) begin
        count <= 0;
    end else if (load) begin
        count <= data;
    end else if (enable) begin
        count <= count+1;
    end else begin
        count <= count;
    end
end
endmodule