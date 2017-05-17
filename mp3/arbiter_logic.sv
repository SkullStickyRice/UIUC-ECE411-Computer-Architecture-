import lc3b_types::*;
module arbiter_logic (
	input clk,
	input icache_read, dcache_read, dcache_write,
	input pmem_resp,
	input lc3b_word icache_address, dcache_address,
	input lc3b_8word dcache_wdata, 
	input lc3b_8word pmem_rdata,
	
	output logic icache_mem_resp, dcache_mem_resp, 	//send to L1 
	output logic pmem_read, pmem_write, 				//send to L2
	output lc3b_word pmem_address, 						//send to L2
	output lc3b_8word dcache_rdata, icache_rdata, 	//send to L1
	output lc3b_8word pmem_wdata 							//send to L2
);

logic cache_addr_mux_sel;

lc3b_word cache_addr_out; /*LIHAO29*/

assign icache_rdata = pmem_rdata;
assign dcache_rdata = pmem_rdata;
assign pmem_wdata = dcache_wdata;
assign cache_addr_mux_sel = (dcache_read || dcache_write);

mux2 #(.width(16)) cache_addr_mux
(
	.sel(cache_addr_mux_sel),
	.a(icache_address), 
	.b(dcache_address),
	.f(cache_addr_out)     
);



always_comb
begin
	//cache_addr_mux_sel = dcache_read || dcache_write;
	pmem_address = cache_addr_out;
	icache_mem_resp = 1'b0;
	dcache_mem_resp = 1'b0;
	pmem_read = 1'b0;
	pmem_write = 1'b0;
	
	//dcache_read
	if (dcache_read || (icache_read && dcache_read))
	begin
		dcache_mem_resp = pmem_resp;
		pmem_read = 1'b1;
	end
	
	//dcache_write
	else if (dcache_write || (icache_read && dcache_write))
	begin
		dcache_mem_resp = pmem_resp;
		pmem_write = 1'b1;
	end
	
	//icache_read
	else if (icache_read)
	begin
		icache_mem_resp = pmem_resp;
		pmem_read = 1'b1;
	end
	
end




endmodule: arbiter_logic 
