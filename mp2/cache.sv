import lc3b_types::*;

module cache
(
	input clk,

	input mem_read,
	input mem_write,
	input lc3b_mem_wmask mem_byte_enable,
	input lc3b_word mem_address,
	input lc3b_word mem_wdata,

	output lc3b_word mem_rdata,
	output mem_resp,

	input pmem_resp,
	input lc3b_line pmem_rdata,

	output pmem_read,
	output pmem_write,
	output lc3b_word pmem_address,
	output lc3b_line pmem_wdata

);

//internal signals
lc3b_index datawordmux_sel;
lc3b_index datawritemux_sel;
logic [1:0] membytemux_sel;
logic [1:0] datawaymux_sel;
logic datainmux_sel;
logic [1:0] addressmux_sel;
 
logic load_dataarr0;
logic load_dataarr1;
logic load_valid0;
logic load_valid1;
logic load_tag0;
logic load_tag1;
logic load_lru;

logic load_dirty0;
logic load_dirty1;

logic lru_out;

logic hit0;
logic hit1;

logic dirty0_out;
logic dirty1_out;

cache_control cache_control
(
	.clk(clk),
	.datainmux_sel(datainmux_sel),
	.addressmux_sel(addressmux_sel),
 
	.load_valid0(load_valid0),
	.load_valid1(load_valid1),
	.load_tag0(load_tag0),
	.load_tag1(load_tag1),
	.load_dataarr0(load_dataarr0),
	.load_dataarr1(load_dataarr1),
	.load_lru(load_lru),

	.lru_out(lru_out),
	.hit0(hit0),
	.hit1(hit1),
	
	.load_dirty0(load_dirty0),
	.load_dirty1(load_dirty1),
	.dirty0_out(dirty0_out),
   .dirty1_out(dirty1_out),

	.pmem_write(pmem_write),
	.pmem_read(pmem_read),
	.pmem_resp(pmem_resp),
	.mem_resp(mem_resp),
	.mem_write(mem_write),
	.mem_read(mem_read)
);

cache_datapath cache_datapath
(
	.clk(clk),
	.datainmux_sel(datainmux_sel),
	.addressmux_sel(addressmux_sel),
	
	.load_valid0(load_valid0),
	.load_valid1(load_valid1),
	.load_tag0(load_tag0),
	.load_tag1(load_tag1),
	.load_dataarr0(load_dataarr0),
	.load_dataarr1(load_dataarr1),
	.load_lru(load_lru),	 
	 
	.lru_out(lru_out),
	.hit0(hit0),
	.hit1(hit1),
	
	.load_dirty0(load_dirty0),
	.load_dirty1(load_dirty1),
	.dirty0_out(dirty0_out),
   .dirty1_out(dirty1_out),

	.pmem_rdata(pmem_rdata),
	.pmem_address(pmem_address), 
	.pmem_wdata(pmem_wdata),
	
	.mem_address(mem_address),
	.offset(mem_address[3:1]),
	.index(mem_address[6:4]),
	.tag(mem_address[15:7]),
	.mem_wdata(mem_wdata),
	.mem_write(mem_write),
	.mem_byte_enable(mem_byte_enable),
	.mem_rdata(mem_rdata)
);

endmodule : cache