import lc3b_types::*;

module L2cache_control
(
	input clk,
	input hit_signal,
	input pmem_resp,
	input mem_read,
	input mem_write,
	input dirty_out,
	
	output logic select_sig_mux_sel,
	output logic data_write_mux_sel,
	output logic dirty_bit_mux_sel,
	output logic pmem_address_mux_sel,
	output logic dirty_update,
	output logic pmem_write,
	output logic mem_resp,
	output logic data_write,
	output logic tag_update,
	output logic pmem_read,
	output logic LRU_write
);


enum int unsigned {
    /* List of states */
	 idle,
	 load_memory,
	 save_memory,
	 empty
} state, next_state;

always_comb
begin : state_actions
    /* Default output assignments */
	 mem_resp = 1'b0;
	 tag_update = 1'b0;
	 data_write = 1'b0;
	 pmem_read = 1'b0;
	 LRU_write = 1'b0;
	 
	 // TODO: newly added signals
	 select_sig_mux_sel = 1'b0;
	 data_write_mux_sel = 1'b0;
	 dirty_bit_mux_sel = 1'b0;
	 dirty_update = 1'b0;
	 pmem_write = 1'b0;
	 pmem_address_mux_sel = 1'b0;
	 
    /* Actions for each state */
	 case(state)
		idle: begin
			if (mem_read && hit_signal)
			begin
				mem_resp = 1'b1;
				LRU_write = 1'b1;
			end
			else if (mem_write && hit_signal)
			begin
				mem_resp = 1'b1;
				data_write = 1'b1;
				LRU_write = 1'b1;
				select_sig_mux_sel = 1'b1;
				data_write_mux_sel = 1'b1;
				dirty_bit_mux_sel = 1'b1;
				dirty_update = 1'b1;
			end
		end
		
		load_memory: begin
			tag_update = 1'b1;
			data_write = 1'b1;
			pmem_read = 1'b1;
			dirty_update = 1'b1;
			if (mem_write)
				dirty_bit_mux_sel = 1'b1;
		end
		
		save_memory: begin
			pmem_write = 1'b1;
			dirty_update = 1'b1;
			pmem_address_mux_sel = 1'b1;
		end
		
		empty: begin
			
		end
		
	endcase
end

always_comb
begin : next_state_logic
    /* Next state information and conditions (if any)
     * for transitioning between states */
	 next_state = state;
	 
	 case(state)
		idle: begin
			if (mem_read && hit_signal)
			begin
				next_state = empty;
			end
			else if (mem_write && hit_signal)
			begin
				next_state = empty;
			end
			else if ((mem_read || mem_write) && !hit_signal && !dirty_out)
				next_state = load_memory;
			else if ((mem_read || mem_write) && !hit_signal && dirty_out)
				next_state = save_memory;
		end
		
		load_memory: begin
			if (pmem_resp)
				next_state = idle;
		end
		
		save_memory: begin
			if (pmem_resp)
				next_state = load_memory;
		end
		
		empty: begin
			next_state = idle;
		end
	 endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
    /* Assignment of next state on clock edge */
	 state <= next_state;
end


endmodule : L2cache_control