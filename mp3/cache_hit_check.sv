import lc3b_types::*;

module cache_hit_check
(
	input lc3b_tag tag1_data,
	input lc3b_tag tag2_data,
	input valid1_data,
	input valid2_data,
	input lc3b_word mem_addr,
	output logic out,
	output logic way_cache_hit
);

always_comb
begin
	if (tag1_data == mem_addr[15:7] && valid1_data)
	begin
		way_cache_hit = 1'b0;
		out = 1'b1;
	end
	else if (tag2_data == mem_addr[15:7] && valid2_data)
	begin
		way_cache_hit = 1'b1;
		out = 1'b1;
	end
	else
	begin
		way_cache_hit = 1'b0;
		out = 1'b0;
	end
end

endmodule : cache_hit_check
