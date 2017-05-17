import lc3b_types::*;

module performance_counter
(
	input clk,
	input logic icache_read, icache_write, icache_mem_resp,
	input logic dcache_read, dcache_write, dcache_mem_resp,
	input logic L2_read, L2_write, L2_mem_resp,
	input lc3b_opcode MEM_opcode_out, 
	input lc3b_nzp nzp_val,
	input logic branch_enable,
	input logic is_nop, 
	input logic counter_write, counter_read,
	input lc3b_word dcache_address,
	//br_miss,
	
	output integer icache_miss_out,
	output integer icache_hit_out,
	output integer dcache_miss_out,
	output integer dcache_hit_out,
	output integer L2_miss_out,
	output integer L2_hit_out,
	output integer br_misprediction_out,
	output integer br_out,
	output integer stall_out,
	output lc3b_word counter_data
	//output integer br_miss_out
);

integer icache_hit_count;
integer dcache_hit_count;
integer L2_hit_count;

integer icache_miss_count;
integer dcache_miss_count;
integer L2_miss_count;

integer br_misprediction_count;
integer br_count;
integer stall_count;


integer icache_hit_count_in;
integer dcache_hit_count_in;
integer L2_hit_count_in;

integer icache_miss_count_in;
integer dcache_miss_count_in;
integer L2_miss_count_in;

integer br_misprediction_count_in;
integer br_count_in;
integer stall_count_in;

//integer br_miss_count;
lc3b_word icache_previous_addr;
lc3b_word dcache_previous_addr;
lc3b_word L2_previous_addr;

initial
begin
	icache_hit_count = 0;
	dcache_hit_count = 0;
	L2_hit_count = 0;
	icache_miss_count = 0;
	dcache_miss_count = 0;
	L2_miss_count = 0;
	br_misprediction_count = 0;
	br_count = 0;
	stall_count = 0;
	
	//br_miss_count = 0;
	/*icache_previous_addr = 16'b0;
	dcache_previous_addr = 16'b0;
	L2_previous_addr = 16'b0;*/
end

enum int unsigned {
    /* List of states */
	 cache_hit,
	 cache_miss
} icache_state, icache_next_state, dcache_state, dcache_next_state, L2_state, L2_next_state;

always_ff @(posedge clk)
begin
	icache_state <= icache_next_state;
	dcache_state <= dcache_next_state;
	L2_state <= L2_next_state;
end

always_ff @(posedge clk)
begin
	icache_hit_count <= icache_hit_count_in;
	icache_miss_count <= icache_miss_count_in;
	dcache_hit_count <= dcache_hit_count_in;
	dcache_miss_count <= dcache_miss_count_in;
	L2_hit_count <= L2_hit_count_in;
	L2_miss_count <= L2_miss_count_in;
	br_misprediction_count <= br_misprediction_count_in;
	br_count <= br_count_in;
	stall_count <= stall_count_in;
end

always_comb
begin
	icache_miss_out = icache_miss_count;
	icache_hit_out = icache_hit_count;
	dcache_miss_out = dcache_miss_count;
	dcache_hit_out = dcache_hit_count;
	L2_miss_out = L2_miss_count;
	L2_hit_out = L2_hit_count;
	br_misprediction_out = br_misprediction_count;
	br_out = br_count;
	stall_out = stall_count;
end

always_comb
begin
	counter_data = 0;
	if (counter_read)
	begin
		case (dcache_address)
		16'hffee: begin
			counter_data = icache_miss_out[15:0];
		end
		16'hfff0: begin
			counter_data = icache_hit_out[15:0];
		end
		16'hfff2: begin
			counter_data = dcache_miss_out[15:0];
		end
		16'hfff4: begin
			counter_data = dcache_hit_out[15:0];
		end
		16'hfff6: begin
			counter_data = L2_miss_out[15:0];
		end
		16'hfff8: begin
			counter_data = L2_hit_out[15:0];
		end
		16'hfffa: begin
			counter_data = br_misprediction_out[15:0];
		end
		16'hfffc: begin
			counter_data = br_out[15:0];
		end
		16'hfffe: begin
			counter_data = stall_out[15:0];
		end
		default:
			counter_data = 0;
		endcase
	end
end

always_comb
begin
	icache_next_state = icache_state;
	dcache_next_state = dcache_state;
	L2_next_state = L2_state;

	case (icache_state)
	cache_hit:
		if ((icache_read || icache_write) && !icache_mem_resp)
			icache_next_state = cache_miss;
	cache_miss:
		if (icache_mem_resp)
			icache_next_state = cache_hit;
	endcase
	
	case (dcache_state)
	cache_hit:
		if ((dcache_read || dcache_write) && !dcache_mem_resp)
			dcache_next_state = cache_miss;
	cache_miss:
		if (dcache_mem_resp)
			dcache_next_state = cache_hit;
	endcase
	
	case (L2_state)
	cache_hit:
		if ((L2_read || L2_write) && !L2_mem_resp)
			L2_next_state = cache_miss;
	cache_miss:
		if (L2_mem_resp)
			L2_next_state = cache_hit;
	endcase
end


always_comb
begin	
	icache_hit_count_in = icache_hit_count;
	icache_miss_count_in = icache_miss_count;
	dcache_hit_count_in = dcache_hit_count;
	dcache_miss_count_in = dcache_miss_count;
	L2_hit_count_in = L2_hit_count;
	L2_miss_count_in = L2_miss_count;
	br_misprediction_count_in = br_misprediction_count;
	br_count_in = br_count;
	stall_count_in = stall_count;
	
	if (icache_mem_resp && icache_state == cache_hit)
		icache_hit_count_in = icache_hit_count + 1;
	else if (icache_mem_resp && icache_state == cache_miss)
		icache_miss_count_in = icache_miss_count + 1;
		
	if (dcache_mem_resp && dcache_state == cache_hit)
		dcache_hit_count_in = dcache_hit_count + 1;
	else if (dcache_mem_resp && dcache_state == cache_miss)
		dcache_miss_count_in = dcache_miss_count + 1;	
	
	if (L2_mem_resp && L2_state == cache_hit)
		L2_hit_count_in = L2_hit_count + 1;
	else if (L2_mem_resp && L2_state == cache_miss)
		L2_miss_count_in = L2_miss_count + 1;
	
	if (is_nop || ((dcache_read || dcache_write) && !dcache_mem_resp))
		stall_count_in = stall_count + 1;
	if ((MEM_opcode_out == op_br && nzp_val != 0) && branch_enable)
		br_misprediction_count_in = br_misprediction_count + 1;
	if ((MEM_opcode_out == op_br && nzp_val != 0) && !branch_enable)
		br_count_in = br_count + 1;
		
	if (counter_write)
	begin
		case (dcache_address)
		16'hffee: begin
			icache_miss_count_in = 0;
		end
		16'hfff0: begin
			icache_hit_count_in = 0;
		end
		16'hfff2: begin
			dcache_miss_count_in = 0;
		end
		16'hfff4: begin
			dcache_hit_count_in = 0;
		end
		16'hfff6: begin
			L2_miss_count_in = 0;
		end
		16'hfff8: begin
			L2_hit_count_in = 0;
		end
		16'hfffa: begin
			br_misprediction_count_in = 0;
		end
		16'hfffc: begin
			br_count_in = 0;
		end
		16'hfffe: begin
			stall_count_in = 0;
		end
		default: ;
			
		endcase
	end
end


//assign br_miss_out = br_miss_count;

endmodule: performance_counter
