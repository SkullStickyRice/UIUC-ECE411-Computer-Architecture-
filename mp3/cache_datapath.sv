import lc3b_types::*;

module cache_datapath
(
	input clk,
	input lc3b_8word pmem_rdata,
	input lc3b_word mem_address,
	input data_write,
	input tag_update,
	input LRU_write,
	
	// newly added signals
	input logic [1:0] mem_byte_enable,
	input select_sig_mux_sel,
	input data_write_mux_sel,
	input dirty_bit_mux_sel,
	input dirty_update,
	input pmem_address_mux_sel,
	input lc3b_word mem_wdata,
	output logic dirty_out,
	output lc3b_8word pmem_wdata,
	
	output logic hit_signal,
	output lc3b_word mem_rdata,
	output lc3b_word pmem_address
);

logic [2:0] array_index;
lc3b_tag tag_in;
logic way_cache_hit;
lc3b_8word data_in;
logic valid1_write, valid2_write;

lc3b_8word data1_out, data2_out;
lc3b_tag tag1_out, tag2_out;
logic valid1_out, valid2_out;
lc3b_8word data_out;

lc3b_8word data_write_mux_out;
lc3b_8word word_write_out;
logic select_sig_mux_out;
logic LRU_out;
logic dirty_bit_mux_out;
logic dirty1_write, dirty2_write;
logic dirty1_out, dirty2_out;
logic data1_write, data2_write;
logic [8:0] LRU_tag;

assign array_index = mem_address[6:4];
assign tag_in = mem_address[15:7];
assign data_in = data_write_mux_out;
assign valid1_write = data1_write;
assign valid2_write = data2_write;

always_comb
begin
	if (way_cache_hit)
		data_out = data2_out;
	else
		data_out = data1_out;
end

mux2 #(.width(128)) pmem_wdata_mux
(
	.sel(LRU_out),
	.a(data1_out), .b(data2_out),
	.f(pmem_wdata)
);

/* data array used to store data */
array #(.width(128)) data1
(
	.clk(clk),
	.write(data1_write),
	.index(array_index),
	.datain(data_in),
	.dataout(data1_out)
);

array #(.width(128)) data2
(
	.clk(clk),
	.write(data2_write),
	.index(array_index),
	.datain(data_in),
	.dataout(data2_out)
);

/* tag array used to store tag bits */
array #(.width(9)) tag1
(
	.clk(clk),
	.write(tag1_write),
	.index(array_index),
	.datain(tag_in),
	.dataout(tag1_out)
);

array #(.width(9)) tag2
(
	.clk(clk),
	.write(tag2_write),
	.index(array_index),
	.datain(tag_in),
	.dataout(tag2_out)
);

/* determine cache hit */
cache_hit_check cache_hit_check_inst
(
	.tag1_data(tag1_out),
	.tag2_data(tag2_out),
	.valid1_data(valid1_out),
	.valid2_data(valid2_out),
	.mem_addr(mem_address),
	.out(hit_signal),
	.way_cache_hit(way_cache_hit)
);

/* mux to select which data to write: pmem_rdata or mem_wdata */
mux2 #(.width(128)) data_write_mux
(
	.sel(data_write_mux_sel),
	.a(pmem_rdata), .b(word_write_out),
	.f(data_write_mux_out)
);

/* mux to select the LRU tag bit */
mux2 #(.width(9)) lru_tag_mux
(
	.sel(LRU_out),
	.a(tag1_out), .b(tag2_out),
	.f(LRU_tag)
);

/* mux to select pmem_address from mem_address or tag value */

mux2 #(.width(16)) pmem_address_mux
(
	.sel(pmem_address_mux_sel),
	.a({mem_address[15:4],4'b0}), .b({LRU_tag, array_index, 4'b0}),
	.f(pmem_address)
);

/* write one byte to the 8 word data */
word_write word_write_inst
(
	.word_sel(mem_address[3:1]),
	.byte_sel(mem_byte_enable),
	.data_in(data_out),
	.word_in(mem_wdata),
	.data_out(word_write_out)
);


/* select appropriate write signal for data array */
data_write_select data_write_select_inst
(
	.write_enable(data_write),
	.write_sel(select_sig_mux_out),
	.write1(data1_write),
	.write2(data2_write)
);

data_write_select tag_write_select_inst
(
	.write_enable(tag_update),
	.write_sel(select_sig_mux_out),
	.write1(tag1_write),
	.write2(tag2_write)
);

data_write_select dirty_write_select_inst
(
	.write_enable(dirty_update),
	.write_sel(select_sig_mux_out),
	.write1(dirty1_write),
	.write2(dirty2_write)
);


/* mux to select from LRU_out and way_cache_hit */
mux2 #(.width(1)) select_sig_mux
(
	.sel(select_sig_mux_sel),
	.a(LRU_out), .b(way_cache_hit),
	.f(select_sig_mux_out)
);

mux2 #(.width(1)) dirty_out_mux
(
	.sel(select_sig_mux_out),
	.a(dirty1_out), .b(dirty2_out),
	.f(dirty_out)
);


/* valid array used to store valid bit */
array #(.width(1)) valid1
(
	.clk(clk),
	.write(valid1_write),
	.index(array_index),
	.datain(1'b1),
	.dataout(valid1_out)
);

array #(.width(1)) valid2
(
	.clk(clk),
	.write(valid2_write),
	.index(array_index),
	.datain(1'b1),
	.dataout(valid2_out)
);


/* dirty array used to store dirty bit */
array #(.width(1)) dirty1
(
	.clk(clk),
	.write(dirty1_write),
	.index(array_index),
	.datain(dirty_bit_mux_out),
	.dataout(dirty1_out)
);

array #(.width(1)) dirty2
(
	.clk(clk),
	.write(dirty2_write),
	.index(array_index),
	.datain(dirty_bit_mux_out),
	.dataout(dirty2_out)
);


/* mux to select value of dirty bit to write */
mux2 #(.width(1)) dirty_bit_mux
(
	.sel(dirty_bit_mux_sel),
	.a(1'b0), .b(1'b1),
	.f(dirty_bit_mux_out)
);


/* LRU array used to store LRU bit */
array #(.width(1)) LRU
(
	.clk(clk),
	.write(LRU_write),
	.index(array_index),
	.datain(LRU_in),
	.dataout(LRU_out)
);

next_LRU next_LRU_inst
(
	.hit_signal(hit_signal),
	.way_cache_hit(way_cache_hit),
	.LRU_out(LRU_out),
	.LRU_in(LRU_in)
);

/* select one word from the 8 word data */
word_select word_select_inst
(
	.word_sel(mem_address[3:1]),
	.data_in(data_out),
	.data_out(mem_rdata)
);

endmodule: cache_datapath
