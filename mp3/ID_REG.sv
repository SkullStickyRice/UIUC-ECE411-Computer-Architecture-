import lc3b_types::*;

module ID_REG
(
    input clk,
    input load_id,
	 input lc3b_reg dest,
	 input lc3b_reg sr1,
	 input lc3b_reg sr2,
	 input lc3b_word sr1_data,
	 input lc3b_word sr2_data,
	 input lc3b_control_word ctrl,  
	 input lc3b_word pc,
	 input lc3b_offset4 offset4,
	 input lc3b_offset5 offset5,
	 input lc3b_offset6 offset6,
	 input lc3b_offset8 offset8,
	 input lc3b_offset9 offset9,
	 input lc3b_offset11 offset11,
	 
	 output lc3b_reg dest_out,
	 output lc3b_reg sr1_out,
	 output lc3b_reg sr2_out,
	 output lc3b_word sr1_data_out,
	 output lc3b_word sr2_data_out,
	 output lc3b_control_word ctrl_out,
	 output lc3b_word pc_out,
	 output lc3b_offset4 offset4_out,
	 output lc3b_offset5 offset5_out,
	 output lc3b_offset6 offset6_out,
	 output lc3b_offset8 offset8_out,
	 output lc3b_offset9 offset9_out,
	 output lc3b_offset11 offset11_out
);

register #(.width(3)) reg_dest 
(
    .clk(clk),
    .load(load_id),
    .in(dest),
    .out(dest_out)
);

register #(.width(3)) reg_sr1
(
    .clk(clk),
    .load(load_id),
    .in(sr1),
    .out(sr1_out)
);

register #(.width(3)) reg_sr2 
(
    .clk(clk),
    .load(load_id),
    .in(sr2),
    .out(sr2_out)
);

register #(.width(16)) reg_sr1_data 
(
    .clk(clk),
    .load(load_id),
    .in(sr1_data),
    .out(sr1_data_out)
);

register #(.width(16)) reg_sr2_data 
(
    .clk(clk),
    .load(load_id),
    .in(sr2_data),
    .out(sr2_data_out)
);

register #(.width(36)) reg_ctrl 
(
    .clk(clk),
    .load(load_id),
    .in(ctrl),
    .out(ctrl_out)
);

register #(.width(16)) reg_pc 
(
    .clk(clk),
    .load(load_id),
    .in(pc),
    .out(pc_out)
);

register #(.width(4)) reg_offset4 
(
    .clk(clk),
    .load(load_id),
    .in(offset4),
    .out(offset4_out)
);

register #(.width(5)) reg_offset5 
(
    .clk(clk),
    .load(load_id),
    .in(offset5),
    .out(offset5_out)
);


register #(.width(6)) reg_offset6 
(
    .clk(clk),
    .load(load_id),
    .in(offset6),
    .out(offset6_out)
);


register #(.width(8)) reg_offset8 
(
    .clk(clk),
    .load(load_id),
    .in(offset8),
    .out(offset8_out)
);


register #(.width(9)) reg_offset9 
(
    .clk(clk),
    .load(load_id),
    .in(offset9),
    .out(offset9_out)
);

register #(.width(11)) reg_offset11 
(
    .clk(clk),
    .load(load_id),
    .in(offset11),
    .out(offset11_out)
);

endmodule : ID_REG
