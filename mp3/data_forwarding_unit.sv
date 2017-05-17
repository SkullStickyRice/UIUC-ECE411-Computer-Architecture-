import lc3b_types::*;

module data_forwarding_unit
(
	input logic EX_ctrl_out_load_regfile, MEM_ctrl_out_load_regfile, jsr_imm,
	input lc3b_reg EX_dest_out, MEM_dest_out, ID_sr1_out, ID_sr2_out, IF_sr1_out, IF_sr2_out,
	input lc3b_opcode ID_opcode_out, EX_opcode_out,
	input logic ID_imm_bit,
	output logic [1:0] forward_a, forward_b,
	output logic forward_sr1, forward_sr2
);

always_comb
begin

forward_a = 2'b00;
forward_b = 2'b00;
forward_sr1 = 1'b0;
forward_sr2 = 1'b0;

/* NOTE: handle control hazard by considering r7mux */

/* WB hazard for IF stage */
if (MEM_ctrl_out_load_regfile && (MEM_dest_out == IF_sr1_out))
	forward_sr1 = 1'b1;
if (MEM_ctrl_out_load_regfile && (MEM_dest_out == IF_sr2_out))
	forward_sr2 = 1'b1;

/* EX and MEM hazard for SR1 */
if (!(ID_opcode_out == op_br || (ID_opcode_out == op_jsr && jsr_imm) || ID_opcode_out == op_lea || ID_opcode_out == op_rti || ID_opcode_out == op_trap))
begin
	if (EX_ctrl_out_load_regfile && (EX_dest_out == ID_sr1_out))
	begin
		if (EX_opcode_out == op_ldr || EX_opcode_out == op_ldb || EX_opcode_out == op_ldi)
			forward_a = 2'b11;
		else
			forward_a = 2'b10;
	end
	else if (MEM_ctrl_out_load_regfile && (MEM_dest_out == ID_sr1_out))
		forward_a = 2'b01;
end
	
/* EX and MEM hazard for SR2 */
if (((ID_opcode_out == op_add || ID_opcode_out == op_and) && (ID_imm_bit == 0)) || (ID_opcode_out == op_stb || ID_opcode_out == op_sti || ID_opcode_out == op_str))
begin
	if (EX_ctrl_out_load_regfile && (EX_dest_out == ID_sr2_out))
		if (EX_opcode_out == op_ldr || EX_opcode_out == op_ldb || EX_opcode_out == op_ldi)
			forward_b = 2'b11;
		else
			forward_b = 2'b10;
	else if (MEM_ctrl_out_load_regfile && (MEM_dest_out == ID_sr2_out))
		forward_b = 2'b01;

	end
end

endmodule : data_forwarding_unit