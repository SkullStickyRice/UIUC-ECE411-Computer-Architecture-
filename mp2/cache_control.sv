module cache_control
(
	input clk,

	input logic hit0,
	input logic hit1,
	input logic lru_out,
	input logic dirty0_out,
	input logic dirty1_out,

	output logic datainmux_sel,
	output logic [1:0] addressmux_sel,

	output logic load_dataarr0,
	output logic load_dataarr1,
	output logic load_valid0,
	output logic load_valid1,
	output logic load_tag0,
	output logic load_tag1,
	output logic load_lru,
	output logic load_dirty0,
	output logic load_dirty1,

	output logic pmem_write,
	output logic pmem_read,
	
	input logic pmem_resp,
	
	output logic mem_resp,
	
	input logic mem_read,
	input logic mem_write 
);


enum int unsigned {
    idle_hit,
    replace,
	 evict
} state, next_state;

always_comb
begin : state_actions
	datainmux_sel = 1'b0;
	load_dataarr1 = 0;
	load_dataarr0 = 0;
	load_valid0 = 0;
	load_valid1 = 0;
	load_tag0 = 0;
	load_tag1 = 0;
	load_lru = 0;
	pmem_write = 0;
	addressmux_sel = 2'b00;
	mem_resp = 0;
	pmem_read = 0;
	load_dirty0 = 0;
	load_dirty1 = 0;

	case(state)
		idle_hit:begin
				//read hit
			if(mem_read && (hit0 || hit1) )
			begin
				mem_resp = 1; // signal data is ready
				load_lru = 1; // update LRU
			end
			//write hit
			else if(mem_write && (hit0 || hit1))
			begin
				//write
				datainmux_sel = 1; //signal our mux to take the superconstructor word 
				load_lru= 1; // update LRU
				mem_resp = 1; 
				if(hit0)
				begin
					//load way 0
					load_dataarr0 = 1;
					load_dirty0 = 1;
					load_tag0 = 1;
					load_valid0 = 1;
				end
			
			else
				begin
					//load way 1					
					load_dataarr1 = 1;
					load_dirty1 = 1;
					load_tag1 = 1;
					load_valid1 = 1;
				end
			end		
		end
		
		

		replace:begin
		pmem_read = 1; // signal a read
		addressmux_sel = 0;
			// if way 1 is least recently used, replace 
			if(lru_out==1)
			begin
			   load_dirty1 = 1;
				load_tag1 = 1;
				load_valid1 = 1;
				if(pmem_resp==1)
					load_dataarr1= 1;
			end
			else
			begin
			   load_dirty0 = 1;
				load_tag0 = 1;
				load_valid0 = 1;
				if(pmem_resp==1)
					load_dataarr0 = 1;
			end
		end
		
		evict:begin
		pmem_write = 1;
			if (lru_out == 0)
			  addressmux_sel = 1;
			else
			  addressmux_sel = 2;
			
		end
	   default: /* Do nothing */;
	endcase
end

always_comb
begin : next_state_logic
	next_state = state;

	case(state)
		idle_hit:begin
		    // if it's hit or idle
			 /*
			if((hit0 || hit1) || (!mem_write && !mem_read)) 
				next_state = idle_hit;
			else if ((lru_out && dirty1_out) || (!lru_out && dirty0_out))
		      next_state = evict;	
			else
				next_state = replace;
*/
		
	if (hit0 == 0 && hit1 ==0)begin
		if ((lru_out && dirty1_out) || (!lru_out && dirty0_out))
		      next_state = evict;
		else
			   next_state = replace;
	end
	else
		    next_state = idle_hit;
		end
		

		
			
		replace:begin
			if(pmem_resp == 1)
				next_state = idle_hit;
			else
				next_state = replace;
		end
		
		evict:begin
			if(pmem_resp == 1)
				next_state = replace;
			else
				next_state = evict;
		end


	endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
    /* Assignment of next state on clock edge */
    state <= next_state;
end

endmodule : cache_control