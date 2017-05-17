module nzp_comparator #(parameter width = 3)
(
	input [width-1:0] a, b,
	output logic f
);

always_comb
begin
	if ((a & b) == 0)
		f = 1'b0;
	else
		f = 1'b1;
end

endmodule : nzp_comparator
