//------------------------------------------------------------------------------
// Project: Verifying the VeriRISC CPU
// File:    typedefs.sv
// Author:  Esteban Rodríguez Quintana
// Date:    <>
//
// Description: <>
//
// Revision History:
// - <Date>: <Version / Modification Description>
//
//------------------------------------------------------------------------------

//  Package: typedefs
package typedefs;
    //  Group: Typedefs
    typedef enum logic [0:2] {HTL, SKZ, ADD, AND, XOR, LDA, STO, JMP } opcode_t;
    typedef enum logic [0:2] {INST_ADDR, INST_FETCH, INST_LOAD, IDLE, OP_ADDR, OP_FETCH, ALU_OP, STORE} state_t;
endpackage: typedefs
