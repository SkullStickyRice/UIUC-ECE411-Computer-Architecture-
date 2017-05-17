module global_hist_br_pred
(
	input clk,
	input br_taken,
	input load,
	input [2:0] index,
	
	output logic prediction
);

logic [1:0] ctr_value;

counter_array counter_array_inst
(
	.clk(clk),
	.inc(br_taken), 
	.write(load),
	.index(index),
	
	.ctr_value(ctr_value)
);

always_comb
begin
	if (ctr_value < 2)
		prediction = 0;
	else
		prediction = 1;
end

endmodule : global_hist_br_pred
