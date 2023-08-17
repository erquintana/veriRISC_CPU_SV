//------------------------------------------------------------------------------
// Project: Verifying the VeriRISC CPU
// File:    veriRISC_CPU.sv
// Author:  Esteban Rodríguez Quintana
// Date:    <>
//
// Description: <>
//
// Revision History:
// - <Date>: <Version / Modification Description>
//
// ********** This file includes all submodules in the same file for  **********
// ********** easy testing using EDA playground platform.             **********
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
timeunit 1ns;
timeprecision 1ns;
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
timeunit 1ns;
timeprecision 1ns;
    always_comb begin
        unique case (sel_a)
           1'b1 : out = in_a;
           1'b0 : out = in_b; 
            default: out = 'x;
        endcase
    end
endmodule

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
timeunit 1ns;
timeprecision 1ns;
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

//------------------------------------------------------------------------------
// Project: Verifying the VeriRISC CPU
// File:    mem.sv
// Author:  Esteban Rodríguez Quintana
// Date:    <>
//
// Description: <>
//
// Revision History:
// - <Date>: <Version / Modification Description>
//
//------------------------------------------------------------------------------

module mem (
    input        clk,
    input        read,
    input        write,
    input  logic [4:0] addr  ,
    input  logic [7:0] data_in  ,
    output logic [7:0] data_out
   );
// SYSTEMVERILOG: timeunit and timeprecision specification
timeunit 1ns;
timeprecision 1ns;

// SYSTEMVERILOG: logic data type
logic [7:0] memory [0:31] ;

always @(posedge clk)
if (write && !read)
// SYSTEMVERILOG: time literals
  #1 memory[addr] <= data_in;

// SYSTEMVERILOG: always_ff and iff event control
always_ff @(posedge clk iff ((read == '1)&&(write == '0)) )
   data_out <= memory[addr];

endmodule

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
        HLT : out <= accum;
        SKZ : out <= accum;
        ADD : out <= data + accum;
        AND : out <= data & accum;
        XOR : out <= data ^ accum;
        LDA : out <= data;
        STO : out <= accum;
        JMP : out <= accum;
        default : out <= 'x;
    endcase
end
endmodule

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


//------------------------------------------------------------------------------
// Project: Verifying the VeriRISC CPU
// File:    veriRISC_CPU.sv
// Author:  Esteban Rodríguez Quintana
//------------------------------------------------------------------------------

module veriRISC_CPU(
                output logic halt  ,
                output logic load_ir  ,
                input  logic clk   ,
                input  logic cntrl_clk  ,
                input  logic alu_clk  ,
                input  logic fetch ,
                input  logic rst_
);
timeunit 1ns;
timeprecision 100ps;
logic    [7:0]   data_out, alu_out, accum_out, ir_out;
logic    [4:0]   pc_addr, ir_addr, addr;
opcode_t   opcode;
logic load_ac, mem_rd, mem_wr, inc_pc, load_pc, zero;

    register ir(
        .data(data_out),
        .enable(load_ir),
        .clk(clk),
        .rst_(rst_),
        .out(ir_out));

    assign opcode = opcode_t'(ir_out[7:5]);
    assign ir_addr = ir_out[4:0];

    register ac(
        .data(alu_out),
        .enable(load_ir),
        .clk(clk),
        .rst_(rst_),
        .out(accum_out));

    scale_mux #5 smx(
        .in_a(pc_addr),
        .in_b(ir_addr),
        .sel_a(fetch),
        .out(addr));

    counter pc(
        .data(ir_addr),
        .load(load_pc),
        .enable(inc_pc),
        .clk(clk),
        .rst_(rst_),
        .count(pc_addr));

    mem mem1(
        .clk(~cntrl_clk),
        .read(mem_rd),
        .write(mem_wr),
        .addr(addr),
        .data_in(alu_out),
        .data_out(data_out));

    alu alu1(
        .accum(accum_out),
        .data(data_out),
        .opcode(opcode),
        .clk(alu_clk),
        .out(alu_out),
        .zero(zero));

    control cntl(
        .opcode(opcode),
        .zero(zero),
        .clk(cntrl_clk),
        .rst_(rst_),
        .mem_rd(mem_rd),
        .load_ir(load_ir),
        .halt(halt),
        .inc_pc(inc_pc),
        .load_ac(load_ac),
        .load_pc(load_pc),
        .mem_wr(mem_wr));

endmodule
