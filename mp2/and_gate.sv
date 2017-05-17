import lc3b_types::*;
module and_gate 
(
	input a,
	input b,
	output logic f
);

always_comb
begin
   f = a & b;
end

endmodule : and_gate