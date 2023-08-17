//------------------------------------------------------------------------------
// Project: Verifying the VeriRISC CPU
// File:    control.sv
// Author:  Esteban Rodríguez Quintana
// Date:    <>
//
// Description: <>
//
// Revision History:
// - <Date>: <Version / Modification Description>
//
//------------------------------------------------------------------------------
typedef enum logic [0:2] {
  HLT,
  SKZ,
  ADD,
  AND,
  XOR,
  LDA,
  STO,
  JMP
} opcode_t;
typedef enum logic [0:2] {
  INST_ADDR,
  INST_FETCH,
  INST_LOAD,
  IDLE,
  OP_ADDR,
  OP_FETCH,
  ALU_OP,
  STORE
} state_t;
module control (
    input opcode_t opcode,
    input logic zero,
    input logic clk,
    input logic rst_,
    output logic mem_rd,
    output logic load_ir,
    output logic halt,
    output logic inc_pc,
    output logic load_ac,
    output logic load_pc,
    output logic mem_wr
);

  state_t state;
  state_t next_state;
  logic   ALUOP;

  always_comb begin
    // ALUOP assignation:
    ALUOP = (opcode == ADD || opcode == AND || opcode == XOR || opcode == LDA) ? 1 : 0;
  end

  always @(posedge clk) begin
    unique case (state)
      INST_ADDR: begin
        // next state assignation:
        state = state.next();
      end
      INST_FETCH: begin
        // output assignations:
        mem_rd <= 1;
        load_ir <= 0;
        halt <= 0;
        inc_pc <= 0;
        load_ac <= 0;
        load_pc <= 0;
        mem_wr <= 0;
        // next state assignation:
        state = state.next();
      end
      INST_LOAD: begin
        // output assignations:
        mem_rd <= 1;
        load_ir <= 1;
        halt <= 0;
        inc_pc <= 0;
        load_ac <= 0;
        load_pc <= 0;
        mem_wr <= 0;
        // next state assignation:
        state = state.next();
      end
      IDLE: begin
        // output assignations:
        mem_rd <= 1;
        load_ir <= 1;
        halt <= 0;
        inc_pc <= 0;
        load_ac <= 0;
        load_pc <= 0;
        mem_wr <= 0;
        // next state assignation:
        state = state.next();
      end
      OP_ADDR: begin
        // output assignations:
        mem_rd <= 0;
        load_ir <= 0;
        halt <= 3'b000;
        inc_pc <= 1;
        load_ac <= 0;
        load_pc <= 0;
        mem_wr <= 0;
        // next state assignation:
        state = state.next();
      end
      OP_FETCH: begin
        // output assignations:
        mem_rd <= ALUOP;
        load_ir <= 0;
        halt <= 0;
        inc_pc <= 0;
        load_ac <= 0;
        load_pc <= 0;
        mem_wr <= 0;
        // next state assignation:
        state = state.next();
      end
      ALU_OP: begin
        // output assignations:
        mem_rd <= ALUOP;
        load_ir <= 0;
        halt <= 0;
        inc_pc <= (3'b001 && zero);
        load_ac <= ALUOP;
        load_pc <= 3'b111;
        mem_wr <= 0;
        // next state assignation:
        state = state.next();
      end
      STORE: begin
        // output assignations:
        mem_rd <= ALUOP;
        load_ir <= 0;
        halt <= 0;
        inc_pc <= 3'b111;
        load_ac <= ALUOP;
        load_pc <= 3'b111;
        mem_wr <= 3'b110;
        // next state assignation:
        state = state.next();
      end
      default: state = 'x;
    endcase
  end
endmodule
