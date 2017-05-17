import lc3b_types::*;

module EX_REG 
(
    input clk,
    input load_ex,
	 input EX_FLUSH,
	 input lc3b_word mar,
	 input lc3b_word mdr,
	 input lc3b_word sr1,
	 input lc3b_word pc,
	 input lc3b_word alu,
	 input lc3b_control_word ctrl,  /*LIHAO*/
	 input lc3b_offset8 offset8,	 /*LIHAO*/
	 input lc3b_offset9 offset9,
	 input lc3b_offset11 offset11,
	 input lc3b_reg dest,
	 input lc3b_mem_wmask mem_wmask,
	 
	 output lc3b_word mar_out,
	 output lc3b_word mdr_out,
	 output lc3b_word sr1_out,
	 output lc3b_word pc_out,
	 output lc3b_word alu_out,
	 output lc3b_control_word ctrl_out,  /*LIHAO*/
	 output lc3b_offset8 offset8_out,	/*LIHAO*/
	 output lc3b_offset9 offset9_out,
	 output lc3b_offset11 offset11_out,
	 output lc3b_reg dest_out,
	 output lc3b_mem_wmask mem_wmask_out
);

lc3b_word ir_data;

lc3b_word mar_in;
lc3b_word mdr_in;
lc3b_word sr1_in;
lc3b_word pc_in;
lc3b_word alu_in;
lc3b_control_word ctrl_in;  /*LIHAO*/
lc3b_offset8 offset8_in;	 /*LIHAO*/
lc3b_offset9 offset9_in;
lc3b_offset11 offset11_in;
lc3b_reg dest_in;
lc3b_mem_wmask mem_wmask_in;

always_comb
begin
	mar_in = mar;
	mdr_in = mdr;
	sr1_in = sr1;
	pc_in = pc;
	alu_in = alu;
	ctrl_in = ctrl;
	offset8_in = offset8;
	offset9_in = offset9;
	offset11_in = offset11;
	dest_in = dest;
	mem_wmask_in = mem_wmask;
	
	if (EX_FLUSH)
	begin
		mar_in = 0;
		mdr_in = 0;
		sr1_in = 0;
		pc_in = 0;
		alu_in = 0;
		ctrl_in = 1;
		offset8_in = 0;
		offset9_in = 0;
		offset11_in = 0;
		dest_in = 0;
		mem_wmask_in = 0;
	end
end

register #(.width(16)) reg_mar 
(
    .clk(clk),
    .load(load_ex),
    .in(mar_in),
    .out(mar_out)
);

register #(.width(16)) reg_mdr 
(
    .clk(clk),
    .load(load_ex),
    .in(mdr_in),
    .out(mdr_out)
);


register #(.width(16)) reg_sr1 
(
    .clk(clk),
    .load(load_ex),
    .in(sr1_in),
    .out(sr1_out)
);

register #(.width(16)) reg_pc 
(
    .clk(clk),
    .load(load_ex),
    .in(pc_in),
    .out(pc_out)
);

register #(.width(16)) reg_alu 
(
    .clk(clk),
    .load(load_ex),
    .in(alu_in),
    .out(alu_out)
);

register #(.width(36)) reg_ctrl 
( 
    .clk(clk),
    .load(load_ex),
    .in(ctrl_in),
    .out(ctrl_out)
);

register #(.width(8)) reg_offset8 
(
    .clk(clk),
    .load(load_ex),
    .in(offset8_in),
    .out(offset8_out)
);

register #(.width(9)) reg_offset9 
(
    .clk(clk),
    .load(load_ex),
    .in(offset9_in),
    .out(offset9_out)
);

register #(.width(11)) reg_offset11 
(
    .clk(clk),
    .load(load_ex),
    .in(offset11_in),
    .out(offset11_out)
);

register #(.width(3)) reg_dest 
(
    .clk(clk),
    .load(load_ex),
    .in(dest_in),
    .out(dest_out)
);

register #(.width(2)) reg_mem_wmask
(
    .clk(clk),
    .load(load_ex),
    .in(mem_wmask_in),
    .out(mem_wmask_out)
);

endmodule : EX_REG
