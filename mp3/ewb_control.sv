import lc3b_types::*; 


module ewb_control
(
   input clk,
	input buf_read,	//pmem_read
	input buf_write,
	input hit_signal, //datapath
	input pmem_resp,
	
	output logic data_write,
	output logic writing_to_mem,
	output logic buf_resp,
	output logic pmem_write,
	output logic pmem_read,
	output logic data_read_sel
);

enum int unsigned {
    idle,		
    stall,			
	 read_from_mem,
	 empty
} state, next_state;


always_comb
begin
	next_state = state;
	case(state)
	idle: begin
		if (buf_write)
			next_state = empty;
		else if (buf_read && hit_signal)
			next_state = empty;
		else if (buf_read && !hit_signal)
			next_state = read_from_mem;
	end

	stall: begin
		if (pmem_resp)
			next_state = idle;
	end

	read_from_mem: begin
		if (pmem_resp)
			next_state = empty;
	end

	empty: begin
		if (buf_write || buf_read && hit_signal)
			next_state = stall;
		else 
			next_state = idle;
	end
	
	default: next_state = idle;

	endcase
end

always_comb
begin
	data_write = 0;
	buf_resp = 0;
	pmem_write = 0;
	pmem_read = 0;
	data_read_sel = 1;
	writing_to_mem = 0;

	case(state)
	idle: begin
		if (buf_write)
		begin
			data_write = 1;
			buf_resp = 1;
		end
		else if (buf_read && hit_signal)
		begin
			buf_resp = 1;
			data_read_sel = 0;
		end
	end

	stall: begin
		pmem_write = 1;
		writing_to_mem = 1;
	end

	read_from_mem: begin
		pmem_read = 1;
		if (pmem_resp)
			buf_resp = 1;
	end
	
	empty: begin 
		if (buf_read && hit_signal)
			data_read_sel = 0;
	end
	default: ;
	endcase
end


always_ff @(posedge clk)
begin: next_state_assignment
	/* Assignment of next state on clock edge */
	state <= next_state;
end

endmodule : ewb_control