import lc3b_types::*;

module hazard_detection_unit
(
    input clk,
	 input mem_read,
	 input resp_a,
	 input lc3b_reg MEM_dest,
	 input lc3b_reg ID_dest,
	 input lc3b_reg IF_dest,
	 input lc3b_reg IF_sr1,
	 input lc3b_reg IF_sr2,
	 input stall_reg_out,
	 input lc3b_opcode IF_opcode,
	 input lc3b_opcode opcode,
	 input lc3b_opcode opcode_stall,
	 input lc3b_opcode MEM_opcode,
	 input icache_stall, //////////////new 3-30
	 input dcache_stall,
	 input branch_enable,
	 
	 output logic load_pc,
	 output logic load_IF, load_ID, load_EX, load_MEM,   //previous logic load_reg,
	 output logic ctrl_mux_sel, IF_FLUSH, REG_FLUSH, adj9_zero_mux_sel, load_stall_reg
);

logic ctrl_stall_reg_in, ctrl_stall_reg_out;

register #(.width(1)) ctrl_stall_reg
(
	.clk(clk),
	.load(load_IF),
	.in(ctrl_stall_reg_in),
	.out(ctrl_stall_reg_out)
);

always_comb
begin
	load_pc = 1'b1;
	load_IF = 1'b1;
	load_ID = 1'b1;
	load_EX = 1'b1;
	load_MEM = 1'b1;
	ctrl_mux_sel = 1'b0;
	IF_FLUSH = 1'b0;
	REG_FLUSH = 1'b0;
	load_stall_reg = 1'b1;
	
	adj9_zero_mux_sel = 1'b0;
	if (MEM_opcode == op_br && MEM_dest != 0 && !branch_enable)
		adj9_zero_mux_sel = 1'b1;
	
	/* control hazard (br taken): flush pipeline */
	if (MEM_opcode == op_br && branch_enable)
	begin
		ctrl_mux_sel = 1'b1;
		IF_FLUSH = 1'b1;
		REG_FLUSH = 1'b1;
	end
	
	else if (MEM_opcode == op_jmp || MEM_opcode == op_jsr || MEM_opcode == op_trap)
	begin
		ctrl_mux_sel = 1'b1;
		IF_FLUSH = 1'b1;
		REG_FLUSH = 1'b1;
	end
	
	else if ((opcode_stall == op_ldi || opcode_stall == op_sti) && !stall_reg_out) begin
		load_pc = 1'b0;
		load_IF = 1'b0;
		load_ID = 1'b0;
		load_EX = 1'b0;
		load_MEM = 1'b0;
		ctrl_mux_sel = 1'b1;
	end
	else if ((opcode_stall == op_ldi || opcode_stall == op_sti) && stall_reg_out && !resp_a) begin
		load_pc = 1'b0;
		load_IF = 1'b0;
		load_ID = 1'b0;
		load_EX = 1'b0;
		load_MEM = 1'b0;
		ctrl_mux_sel = 1'b1;
	end
	else if (icache_stall)
	begin
		load_pc = 1'b0;
		load_IF = 1'b0;
		load_ID = 1'b0;
		load_EX = 1'b0;
		load_MEM = 1'b0;
		load_stall_reg = 1'b0;
		ctrl_mux_sel = 1'b1;
	end
	else if (dcache_stall)
	begin
		load_pc = 1'b0;
		load_IF = 1'b0;
		load_ID = 1'b0;
		load_EX = 1'b0;
		load_MEM = 1'b0;
		ctrl_mux_sel = 1'b1;
	end
	
	
	
	/* control hazard: insert nop instruction */
	/*else if (ctrl_stall_reg_out && (MEM_opcode == op_jmp || MEM_opcode == op_jsr || MEM_opcode == op_trap || (MEM_opcode == op_br && MEM_dest != 0)))
	begin
		ctrl_mux_sel = 1'b1;
		IF_FLUSH = 1'b1;
	end
	else if (ctrl_stall_reg_out)
	begin
		load_pc = 1'b0;
		ctrl_mux_sel = 1'b1;
	end
	else if (!ctrl_stall_reg_out && (IF_opcode == op_jmp || IF_opcode == op_jsr || IF_opcode == op_trap || (IF_opcode == op_br && IF_dest != 0)))
	begin
		load_pc = 1'b0;
	end
	*/
end
/*
always_comb
begin
	ctrl_stall_reg_in = ctrl_stall_reg_out;
	if (IF_opcode == op_jmp || IF_opcode == op_jsr || IF_opcode == op_trap || (IF_opcode == op_br && IF_dest != 0))
	begin
		ctrl_stall_reg_in = 1'b1;
	end
	if (MEM_opcode == op_jmp || MEM_opcode == op_jsr || MEM_opcode == op_trap || (MEM_opcode == op_br && MEM_dest != 0))
	begin
		ctrl_stall_reg_in = 1'b0;
	end
end
*/
endmodule : hazard_detection_unit