import lc3b_types::*;

module L2cache
(
	input clk,
	input lc3b_8word pmem_rdata,
	input pmem_resp,
	input lc3b_8word mem_wdata,
	input lc3b_word mem_address,
	input mem_read,
	input mem_write,
	//input lc3b_mem_wmask mem_byte_enable,
	
	output lc3b_8word mem_rdata,
	output logic mem_resp,
	output logic pmem_read,
	output logic pmem_write,
	output lc3b_8word pmem_wdata,
	output lc3b_word pmem_address
);

logic data_write, tag_update, hit_signal, LRU_write;
logic select_sig_mux_sel, data_write_mux_sel, dirty_bit_mux_sel, dirty_update, dirty_out;
logic pmem_resp_tmp, pmem_address_mux_sel;

always_ff @ (posedge clk)
begin
	pmem_resp_tmp <= pmem_resp;
end

L2cache_datapath L2cache_datapath_inst
(
	.clk(clk),
	.pmem_rdata(pmem_rdata),
	.mem_address(mem_address),
	.data_write(data_write),
	.tag_update(tag_update),
	.hit_signal(hit_signal),
	.LRU_write(LRU_write),
	
	// newly added signals
	//.mem_byte_enable(mem_byte_enable),
	.select_sig_mux_sel(select_sig_mux_sel),
	.data_write_mux_sel(data_write_mux_sel),
	.dirty_bit_mux_sel(dirty_bit_mux_sel),
	.dirty_update(dirty_update),
	.pmem_address_mux_sel(pmem_address_mux_sel),
	.dirty_out(dirty_out),
	.pmem_wdata(pmem_wdata),
	.mem_wdata(mem_wdata),
	
	.mem_rdata(mem_rdata),
	.pmem_address(pmem_address)
);

L2cache_control L2cache_control_inst
(
	.clk(clk),
	.hit_signal(hit_signal),
	.pmem_resp(pmem_resp_tmp),
	.mem_read(mem_read),
	
	// newly added signals
	.dirty_out(dirty_out),
	.mem_write(mem_write),
	.select_sig_mux_sel(select_sig_mux_sel),
	.data_write_mux_sel(data_write_mux_sel),
	.dirty_bit_mux_sel(dirty_bit_mux_sel),
	.pmem_address_mux_sel(pmem_address_mux_sel),
	.dirty_update(dirty_update),
	.pmem_write(pmem_write),
	
	.mem_resp(mem_resp),
	.data_write(data_write),
	.tag_update(tag_update),
	.pmem_read(pmem_read),
	.LRU_write(LRU_write)
);

endmodule : L2cache