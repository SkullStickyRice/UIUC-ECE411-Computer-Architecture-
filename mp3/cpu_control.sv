import lc3b_types::*;

module cpu_control
(
	 input clk,
	 input lc3b_word instr,

	 output lc3b_control_word ctrl
	 
);

lc3b_opcode opcode;
logic sr_imm, shf_d, shd_a, offset1;

assign opcode = lc3b_opcode'(instr[15:12]);
assign sr_imm = instr[11];
assign shf_d = instr[4];
assign shf_a = instr[5];
assign offset1 = instr[0];

always_comb
begin
	ctrl = 0;
	ctrl.opcode = opcode;
	//ctrl.nop_pc = 0; ///////////////

	case(opcode)
	op_add: begin
		ctrl.aluop = alu_add;
		ctrl.load_regfile = 1;
		ctrl.regfilemux_sel = 0;
		ctrl.load_cc = 1;
		if (shf_a)
			ctrl.sr2mux_sel = 1;
	end
	op_and: begin
		ctrl.aluop = alu_and;
		ctrl.load_regfile = 1;
		ctrl.load_cc = 1;
		if (shf_a)
			ctrl.sr2mux_sel = 1;
	end
	op_not: begin
		ctrl.aluop = alu_not;
		ctrl.load_regfile = 1;
		ctrl.load_cc = 1;
	end
   op_br: begin
		//ctrl.nop_pc = 1; /////////////////////
   end
	op_jmp: begin
		ctrl.pcmux_sel = 1;
		ctrl.jmpmux_sel = 1;
		
		//ctrl.nop_pc = 1; /////////////////////
	end 
	op_jsr: begin
		ctrl.jsrmux_sel = 1;
		ctrl.r7mux_sel = 1;
		ctrl.load_regfile = 1;
		
		ctrl.pcmux_sel = 1;
		if (!sr_imm)
			ctrl.jmpmux_sel = 1;
		else
			ctrl.offsetmux_sel = 1;
			
		//ctrl.nop_pc = 1; /////////////////////
	end
	
	op_ldb: begin
		ctrl.aluop = alu_add;
		ctrl.alumux_sel = 1;
		ctrl.mem_read = 1;
		ctrl.regfilemux_sel = 1;
		ctrl.load_regfile = 1;
		ctrl.load_cc = 1;
		ctrl.bytemux_sel = 1;
		ctrl.offset6mux_sel = 1;
	end
	op_ldi: begin
		ctrl.aluop = alu_add;
		ctrl.alumux_sel = 1;
		ctrl.mem_read = 1;
		ctrl.regfilemux_sel = 1;
		ctrl.load_regfile = 1;
		ctrl.load_cc = 1;
		
		//ctrl.nop_pc = 1; /////////////////////
	end
	
	op_ldr: begin
		ctrl.aluop = alu_add;
		ctrl.alumux_sel = 1;
		ctrl.mem_read = 1;
		ctrl.regfilemux_sel = 1;
		ctrl.load_regfile = 1;
		ctrl.load_cc = 1;
	end
	
	
	op_str: begin
		ctrl.storemux_sel = 1;
		ctrl.alumux_sel = 1;
		ctrl.aluop = alu_add;
		ctrl.mem_write = 1;
	end
	
	op_stb: begin
		ctrl.storemux_sel = 1;
		ctrl.alumux_sel = 1;
		ctrl.aluop = alu_add;
		ctrl.bytemux2_sel = 1;
		ctrl.mem_write = 1;
		ctrl.offset6mux_sel = 1;
	end
	
	op_sti: begin
		ctrl.storemux_sel = 1;
		ctrl.alumux_sel = 1;
		ctrl.aluop = alu_add;
		ctrl.mem_write = 1;
		
		//ctrl.nop_pc = 1; /////////////////////
	end
	
	op_lea: begin
		ctrl.leamux_sel = 1;
		ctrl.load_regfile = 1;
		ctrl.load_cc = 1;
	end
	
	op_shf: begin
		ctrl.sr2mux_sel = 1;
		ctrl.offset4mux_sel = 1;
		if(shf_d == 0)
			ctrl.aluop = alu_sll;
		else begin
			if(shf_a == 0)
				ctrl.aluop = alu_srl;
			else
				ctrl.aluop = alu_sra;
		end
		ctrl.load_regfile = 1;
		ctrl.load_cc = 1;
	end

	op_trap: begin
		ctrl.r7mux_sel = 1;
		ctrl.jsrmux_sel = 1;
		ctrl.mem_read = 1;
		ctrl.adj8mux_sel = 1;
		ctrl.trapmux_sel = 1;
		ctrl.load_regfile = 1;
	end
	default: begin
		/* unknown opcode */
		ctrl = 0; 
		//ctrl.nop_pc = 1; /////////////////////
	end
	endcase
end

endmodule : cpu_control

