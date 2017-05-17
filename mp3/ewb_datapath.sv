import lc3b_types::*;

module ewb_datapath
(
	input clk,
	input data_write,
	input data_read_sel,
	input writing_to_mem,
	input lc3b_8word buf_wdata,
	input lc3b_word buf_address,
	input lc3b_8word pmem_rdata,
	
	output logic hit_signal,
	output lc3b_8word buf_rdata,
	output lc3b_8word pmem_wdata,
	output lc3b_word pmem_address
	//output lc3b_word buf_address_out
);

lc3b_8word buf_data;
lc3b_word buf_address_out;

//assign pmem_wdata = buf_data;

always_comb
begin
	if (writing_to_mem)
		pmem_address = buf_address_out;
	else
		pmem_address = buf_address;
end

logic buf_valid_out;

always_comb
begin
	pmem_wdata = buf_data;
	if (buf_address == buf_address_out && buf_valid_out)
		hit_signal = 1;
	else
		hit_signal = 0;
end

register #(.width(128)) data_arr
(
	.clk,
   .load(data_write),
   .in(buf_wdata),
   .out(buf_data)
);

register #(.width(16)) address_arr
(
	.clk,
   .load(data_write),
   .in(buf_address),
   .out(buf_address_out)
);

register #(.width(1)) valid_arr
(
	.clk,
	.load(data_write),
	.in(1'b1),
	.out(buf_valid_out)
);

mux2 #(.width(128)) data_read_mux
(
	.sel(data_read_sel),
	.a(buf_data),
	.b(pmem_rdata),
	.f(buf_rdata)
);

endmodule : ewb_datapath