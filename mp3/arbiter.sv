import lc3b_types::*;
module arbiter (
	input clk,
	input logic icache_read, dcache_read, dcache_write,
	input logic pmem_resp,
	input lc3b_word icache_address, dcache_address,
	input lc3b_8word dcache_wdata, 
	input lc3b_8word pmem_rdata,
	
	output logic icache_mem_resp, dcache_mem_resp, //send to L1 
	output logic pmem_read, pmem_write, //send to L2
	output lc3b_word pmem_address, //send to L2
	output lc3b_8word dcache_rdata, icache_rdata, //send to L1
	output lc3b_8word pmem_wdata //send to L2
);

logic cache_addr_mux_sel;
lc3b_word cache_addr_out;
logic addr_reg_load;

enum int unsigned {
    /* List of states */
	 start,
	 iread,
	 dread,
	 dwrite
} state, next_state;

assign icache_rdata = pmem_rdata;
assign dcache_rdata = pmem_rdata;
assign pmem_wdata = dcache_wdata;
//assign pmem_address = cache_addr_out;

mux2 #(.width(16)) cache_addr_mux
(
	.sel(cache_addr_mux_sel),
	.a(icache_address), 
	.b(dcache_address),
	.f(cache_addr_out)
);
		
				

always_comb
begin: state_actions
	cache_addr_mux_sel = dcache_read || dcache_write;
	icache_mem_resp = 1'b0;
	dcache_mem_resp = 1'b0;
	pmem_read = 1'b0;
	pmem_write = 1'b0;
	addr_reg_load = 1'b0;
	pmem_address = cache_addr_out;
	
	case(state)
		start:begin
			//if (icache_read || dcache_read || dcache_write)
			//	pmem_address = cache_addr_out;
			;
			
		end
		
		iread:begin
			icache_mem_resp = pmem_resp;
			pmem_read = 1;
		end
		
		dread:begin
			dcache_mem_resp = pmem_resp;
			pmem_read = 1;
		end
		
		dwrite:begin
			dcache_mem_resp = pmem_resp;
			pmem_write = 1;
		end
		
	endcase
end

always_comb
begin : next_state_logic
	next_state = state;
	
	case(state)
		start:begin
			if (icache_read)
				next_state = iread;
			else if (dcache_read)
				next_state = dread;
			else if (icache_read && dcache_read)
				next_state = dread;
			else if (dcache_write)
				next_state = dwrite;
			else if (icache_read && dcache_write)
				next_state = dwrite;
			else
				next_state = start;
		end
	
		iread: begin
			if (pmem_resp)
				next_state = start;
		end
	
		dread: begin
			if (pmem_resp)
				next_state = start;
		end
	
		dwrite: begin
			if (pmem_resp)
				next_state = start;
		end
	endcase
end


always_ff @(posedge clk)
begin: next_state_assignment
    /* Assignment of next state on clock edge */
	 state <= next_state;
end

endmodule: arbiter