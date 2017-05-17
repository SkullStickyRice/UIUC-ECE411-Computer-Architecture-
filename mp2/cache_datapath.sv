import lc3b_types::*;

module cache_datapath
(
	input clk,
	input lc3b_word mem_address,
	input lc3b_index index,
	input lc3b_offset3 offset,
	input lc3b_tag tag,
	input lc3b_word mem_wdata,
	input logic mem_write,
	input lc3b_mem_wmask mem_byte_enable,

	output lc3b_word mem_rdata,
	input lc3b_line pmem_rdata,
	output lc3b_word pmem_address,
	output lc3b_line pmem_wdata,

	input logic datainmux_sel,
	input logic [1:0] addressmux_sel,
	
	input logic load_dataarr0,
	input logic load_dataarr1,
	input logic load_valid0,
	input logic load_valid1,
	input logic load_tag0,
	input logic load_tag1,
	input logic load_lru,
	
	input logic load_dirty0,
	input logic load_dirty1,

	output logic hit0,
	output logic hit1,
	output logic dirty0_out,
	output logic dirty1_out,
	output logic lru_out

);

/* internal signals */
lc3b_word membytemux_out;
lc3b_tag tag0_out;
lc3b_tag tag1_out;
lc3b_line data0_out;
lc3b_line data1_out;
lc3b_line datawaymux_out;
lc3b_line  datablock_out;
logic valid0_out;
logic valid1_out;
lc3b_line datasel_out;

lc3b_tag tag_comp0_out;
lc3b_tag tag_comp1_out;

// left way
array #(.width(1))valid_arr0
(
	.clk,
	.write(load_valid0),
	.index(index),
	.datain(1'b1),
	.dataout(valid0_out)
);
array #(.width(9))tag_arr0
(
	.clk,
	.write(load_tag0),
	.index(index),
	.datain(tag),
	.dataout(tag0_out)
);
array #(.width(128))data_arr0
(
	.clk,
	.write(load_dataarr0),
	.index(index),
	.datain(datablock_out),
	.dataout(data0_out)
);

array #(.width(1)) dirty_arr0
(
   .clk,
	.write(load_dirty0),
	.index(index),
	.datain(mem_write),
	.dataout(dirty0_out)
);

// right way
array #(.width(1))valid_arr1
(
	.clk,
	.write(load_valid1),
	.index(index),
	.datain(1'b1),
	.dataout(valid1_out)
);
array #(.width(9))tag_arr1
(
	.clk,
	.write(load_tag1),
	.index(index),
	.datain(tag),
	.dataout(tag1_out)
);
array #(.width(128))data_arr1
(
	.clk,
	.write(load_dataarr1),
	.index(index),
	.datain(datablock_out),
	.dataout(data1_out)
);

array #(.width(1)) dirty_arr1
(
    .clk,
	.write(load_dirty1),
	.index(index),
	.datain(mem_write),
	.dataout(dirty1_out)
);

// LRU
array #(.width(1)) lru
(
	.clk,
	.write(load_lru),
	.index(index),
	.datain(~hit1),
	.dataout(lru_out)
);

// determins which way to get data from 
mux2 #(.width(128)) datawaymux
(
	.sel(hit1),
	.a(data0_out),
	.b(data1_out),
	.f(datawaymux_out)
);

// select a word
mux8 #(.width(16)) datawordmux
(
	.sel(offset),
	.a(datawaymux_out[15:0]),
	.b(datawaymux_out[31:16]),
	.c(datawaymux_out[47:32]),
	.d(datawaymux_out[63:48]),
	.e(datawaymux_out[79:64]),
	.f(datawaymux_out[95:80]),
	.g(datawaymux_out[111:96]),
	.h(datawaymux_out[127:112]),
	.out(mem_rdata)
);

mux4 #(.width(16)) addressmux
(
	.sel(addressmux_sel),
	.a(mem_address),
	.b({tag0_out, index, 4'b0}),
	.c({tag1_out, index, 4'b0}),
	.d(),
	.f(pmem_address)
);

hit_comparator hit_left
(
	.tag(tag),
	.curTag(tag0_out),
	.isValid(valid0_out),
	.result(hit0)
);

hit_comparator hit_right
(
	.tag(tag),
	.curTag(tag1_out),
	.isValid(valid1_out),
	.result(hit1)
);

data_selector data_selector
(
   .sel(offset),
	.mem_byte_enable(mem_byte_enable),
	.data(datawaymux_out),
	.word_in(mem_wdata),
	.out(datasel_out)
);

mux2 #(.width(128)) pmemwritemux
(
	.sel(lru_out), 
	.a(data0_out),
	.b(data1_out),
	.f(pmem_wdata)
);

mux2 #(.width(128)) datamux
(
	.sel(datainmux_sel),
	.a(pmem_rdata),
	.b(datasel_out),
	.f(datablock_out)
);

endmodule : cache_datapath
