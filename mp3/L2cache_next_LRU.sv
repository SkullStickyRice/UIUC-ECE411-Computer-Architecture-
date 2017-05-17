import lc3b_types::*;

module L2cache_next_LRU
(
	input hit_signal,
	input [1:0] way_cache_hit,
	input [2:0] LRU_out,
	
	output logic [2:0] LRU_in
);

always_comb
begin
	LRU_in = LRU_out;
	if (hit_signal) begin
		case (way_cache_hit)
		2'b00: begin
			LRU_in[1] = 0;
			LRU_in[0] = 0;
		end
		2'b01: begin
			LRU_in[1] = 1;
			LRU_in[0] = 0;
		end
		2'b10: begin
			LRU_in[2] = 0;
			LRU_in[0] = 1;
		end
		2'b11: begin
			LRU_in[2] = 1;
			LRU_in[0] = 1;
		end
		default: ;
		endcase
	end
end

endmodule : L2cache_next_LRU