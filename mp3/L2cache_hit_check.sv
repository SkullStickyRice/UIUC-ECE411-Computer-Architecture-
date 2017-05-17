import lc3b_types::*;

module L2cache_hit_check
(
	input lc3b_tag tag1_data,
	input lc3b_tag tag2_data,
	input lc3b_tag tag3_data,
	input lc3b_tag tag4_data,
	input valid1_data,
	input valid2_data,
	input valid3_data,
	input valid4_data,
	input lc3b_word mem_addr,
	
	output logic out,
	output logic [0:1] way_cache_hit
);

always_comb
begin
	if (tag1_data == mem_addr[15:7] && valid1_data)
	begin
		way_cache_hit = 2'b00;
		out = 1'b1;
	end
	else if (tag2_data == mem_addr[15:7] && valid2_data)
	begin
		way_cache_hit = 2'b01;
		out = 1'b1;
	end
	else if (tag3_data == mem_addr[15:7] && valid3_data)
	begin
		way_cache_hit = 2'b10;
		out = 1'b1;
	end
	else if (tag4_data == mem_addr[15:7] && valid4_data)
	begin
		way_cache_hit = 2'b11;
		out = 1'b1;
	end
	else
	begin
		way_cache_hit = 2'b00;
		out = 1'b0;
	end
end





endmodule : L2cache_hit_check