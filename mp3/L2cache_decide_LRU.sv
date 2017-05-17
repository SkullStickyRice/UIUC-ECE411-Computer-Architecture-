import lc3b_types::*;

module L2cache_decide_LRU
(
	input [2:0] LRU_out,
	
	output logic [1:0] LRU_decide_out
);

always_comb
begin
	LRU_decide_out = 2'b00;
	if (LRU_out[1] == 1 && LRU_out[0] == 1) 
		LRU_decide_out = 2'b00;
	else if (LRU_out[1] == 0 && LRU_out[0] == 1) 
		LRU_decide_out = 2'b01;
	else if (LRU_out[2] == 1 && LRU_out[0] == 0) 
		LRU_decide_out = 2'b10;
	else if (LRU_out[2] == 0 && LRU_out[0] == 0) 
		LRU_decide_out = 2'b11;	
end

endmodule : L2cache_decide_LRU