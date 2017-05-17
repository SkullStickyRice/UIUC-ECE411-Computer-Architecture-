import lc3b_types::*;

module IF_REG 
(
    input clk,
    input load_ir,
	 input IF_FLUSH,
	 
	 input lc3b_word pc,
    input lc3b_word in,
	 
	 output lc3b_reg sr1,
	 output lc3b_reg sr2,
	 output lc3b_reg dest,
    output lc3b_word pc_out,
	 output lc3b_offset4 offset4,
	 output lc3b_offset5 offset5,
	 output lc3b_offset6 offset6,
	 output lc3b_offset8 offset8,
	 output lc3b_offset9 offset9,
	 output lc3b_offset11 offset11,
	 output lc3b_word instr,
	 output lc3b_opcode opcode
);

lc3b_word ir_data;
lc3b_word reg_ir_in;
lc3b_word reg_pc_in;

register #(.width(16)) reg_ir 
(
    .clk(clk),
    .load(load_ir),
    .in(reg_ir_in),
    .out(ir_data)
);

register #(.width(16)) reg_pc 
(
    .clk(clk),
    .load(load_ir),
    .in(reg_pc_in),
    .out(pc_out)
);


always_comb
begin
	dest = ir_data[11:9];
	sr1 = ir_data[8:6];
	sr2 = ir_data[2:0];
	offset4 = ir_data[3:0];
	offset5 = ir_data[4:0];
	offset6 = ir_data[5:0];
	offset8 = ir_data[7:0];
	offset9 = ir_data[8:0];
	offset11 = ir_data[10:0];
	instr = ir_data;
	opcode = lc3b_opcode'(ir_data[15:12]);
	
	if (IF_FLUSH)
	begin
		reg_ir_in = 16'b0;
		reg_pc_in = 16'b0;
	end
	else
	begin
		reg_ir_in = in;
		reg_pc_in = pc;
	end
end

endmodule : IF_REG
