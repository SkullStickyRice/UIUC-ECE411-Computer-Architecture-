import lc3b_types::*;

module MEM_REG
(
    input clk,
    input load_mem,
	 input MEM_FLUSH,
	 input lc3b_word pc,
	 input lc3b_word sr1,
	 input lc3b_control_word ctrl,
	 input lc3b_offset8 offset8,
	 input lc3b_offset9 offset9,
	 input lc3b_offset11 offset11,
	 input lc3b_word alu,
	 input lc3b_word rdata,
	 input lc3b_reg dest,
	 
	 output lc3b_word pc_out,
	 output lc3b_word sr1_out,
	 output lc3b_control_word ctrl_out,
	 output lc3b_offset8 offset8_out,
	 output lc3b_offset9 offset9_out,
	 output lc3b_offset11 offset11_out,
	 output lc3b_word alu_out,
	 output lc3b_word rdata_out,
	 output lc3b_reg dest_out
);


lc3b_word pc_in;
lc3b_word sr1_in;
lc3b_control_word ctrl_in;
lc3b_offset8 offset8_in;
lc3b_offset9 offset9_in;
lc3b_offset11 offset11_in;
lc3b_word alu_in;
lc3b_word rdata_in;
lc3b_reg dest_in;

always_comb
begin
	pc_in = pc;
	sr1_in = sr1;
	ctrl_in = ctrl;
	offset8_in = offset8;
	offset9_in = offset9;
	offset11_in = offset11;
	alu_in = alu;
	rdata_in = rdata;
	dest_in = dest;
	
	if (MEM_FLUSH)
	begin
		pc_in = 0;
		sr1_in = 0;
		ctrl_in = 1;
		offset8_in = 0;
		offset9_in = 0;
		offset11_in = 0;
		alu_in = 0;
		rdata_in = 0;
		dest_in = 0;
	end
end

register #(.width(16)) reg_pc 
(
    .clk(clk),
    .load(load_mem),
    .in(pc_in),
    .out(pc_out)
);

register #(.width(16)) reg_sr1 
(
    .clk(clk),
    .load(load_mem),
    .in(sr1_in),
    .out(sr1_out)
);

register #(.width(36)) reg_ctrl 
(
    .clk(clk),
    .load(load_mem),
    .in(ctrl_in),
    .out(ctrl_out)
);

register #(.width(8)) reg_offset8 
(
    .clk(clk),
    .load(load_mem),
    .in(offset8_in),
    .out(offset8_out)
);

register #(.width(9)) reg_offset9 
(
    .clk(clk),
    .load(load_mem),
    .in(offset9_in),
    .out(offset9_out)
);

register #(.width(11)) reg_offset11 
(
    .clk(clk),
    .load(load_mem),
    .in(offset11_in),
    .out(offset11_out)
);

register #(.width(16)) reg_alu
(
    .clk(clk),
    .load(load_mem),
    .in(alu_in),
    .out(alu_out)
);

register #(.width(16)) reg_rdata 
(
    .clk(clk),
    .load(load_mem),
    .in(rdata_in),
    .out(rdata_out)
);

register #(.width(3)) reg_dest
(
    .clk(clk),
    .load(load_mem),
    .in(dest_in),
    .out(dest_out)
);

endmodule : MEM_REG
