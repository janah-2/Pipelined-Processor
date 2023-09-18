//***********************************************************
// ECE 3058 Architecture Concurrency and Energy in Computation
//
// RISCV Processor System Verilog Behavioral Model
//
// School of Electrical & Computer Engineering
// Georgia Institute of Technology
// Atlanta, GA 30332
//
//  Module:     core_tb
//  Functionality:
//      Forward Controller for a 5 Stage RISCV Processor
//
//***********************************************************

import CORE_PKG::*;

module FWD_Control (
  input logic reset, 

  input [6:0] id_instr_opcode_ip, // ID/EX pipeline buffer opcode

  input write_back_mux_selector EX_MEM_wb_mux_ip,
  input write_back_mux_selector MEM_WB_wb_mux_ip,

  input logic [4:0] EX_MEM_dest_ip, //EX/MEM Dest Register
  input logic [4:0] MEM_WB_dest_ip, //MEM/WB Dest Register
  input logic [4:0] ID_dest_rs1_ip, //Rs1 from decode stage
  input logic [4:0] ID_dest_rs2_ip, //Rs2 from decode stage

  output forward_mux_code fa_mux_op, //select lines for forwarding muxes (Rs)
  output forward_mux_code fb_mux_op  //select lines for forwarding muxes (Rt)
);

  logic EX_MEM_RegWrite_en;
  logic MEM_WB_RegWrite_en;

  assign EX_MEM_RegWrite_en = (EX_MEM_wb_mux_ip == NO_WRITEBACK) ? 1'b0 : 1'b1;
  assign MEM_WB_RegWrite_en = (MEM_WB_wb_mux_ip == NO_WRITEBACK) ? 1'b0 : 1'b1;

  always @(*) begin
    fa_mux_op = ORIGINAL_SELECT;
    fb_mux_op = ORIGINAL_SELECT;

    case (id_instr_opcode_ip)

      OPCODE_OP: begin // Register-Register ALU operation

        /**
        * Task 2
        * 
        * Here you will need to check for hazards and decide if and what you will forward 
        * For Register Register instructions, what registers are relevant for you to check 
        */
        // if EX Hazard exists, forward data in EX, else if MEM data exists, forward MEM data
        if ((EX_MEM_RegWrite_en && (EX_MEM_dest_ip !== 0)) && (EX_MEM_dest_ip === ID_dest_rs1_ip)) begin
          fa_mux_op = EX_RESULT_SELECT;
        end
        else if ((MEM_WB_RegWrite_en && (MEM_WB_dest_ip !== 0)) && (MEM_WB_dest_ip === ID_dest_rs1_ip)) begin
          fa_mux_op = WB_RESULT_SELECT;
        end

        // repeat for ForwardB
        if ((EX_MEM_RegWrite_en && (EX_MEM_dest_ip !== 0)) && (EX_MEM_dest_ip === ID_dest_rs2_ip)) begin
          fb_mux_op = EX_RESULT_SELECT;
        end
        else if ((MEM_WB_RegWrite_en && (MEM_WB_dest_ip !== 0)) && (MEM_WB_dest_ip === ID_dest_rs2_ip)) begin
          fb_mux_op = WB_RESULT_SELECT;
        end
      end

      OPCODE_OPIMM: begin // Register Immediate 

        /**
        * Task 2
        * 
        * Here you will need to check for hazards and decide if and what you will forward 
        * For Register Immediate instructions, what registers are relevant for you to check
        */
        // if EX Hazard exists, forward data in EX, else if MEM data exists, forward MEM data -> check only for rs1 (ForwardB always 00)
        if ((EX_MEM_RegWrite_en && (EX_MEM_dest_ip !== 0)) && (EX_MEM_dest_ip === ID_dest_rs1_ip)) begin
          fa_mux_op = EX_RESULT_SELECT;
        end
        else if ((MEM_WB_RegWrite_en && (MEM_WB_dest_ip !== 0)) && (MEM_WB_dest_ip === ID_dest_rs1_ip)) begin
          fa_mux_op = WB_RESULT_SELECT;
        end
      end

      OPCODE_LOAD: begin // same as opcodeimm
        if ((EX_MEM_RegWrite_en && (EX_MEM_dest_ip !== 0)) && (EX_MEM_dest_ip === ID_dest_rs1_ip)) begin
          fa_mux_op = EX_RESULT_SELECT;
        end
        else if ((MEM_WB_RegWrite_en && (MEM_WB_dest_ip !== 0)) && (MEM_WB_dest_ip === ID_dest_rs1_ip)) begin
          fa_mux_op = WB_RESULT_SELECT;
        end
      end



    endcase

  end
endmodule