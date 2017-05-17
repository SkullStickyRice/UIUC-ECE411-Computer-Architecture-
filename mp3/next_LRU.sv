import lc3b_types::*;

module next_LRU
(
	input hit_signal,
	input way_cache_hit,
	input LRU_out,
	output logic LRU_in
);

always_comb
begin
	if (hit_signal)
		LRU_in = ~way_cache_hit;
	else
		LRU_in = ~LRU_out;
end

endmodule : next_LRU