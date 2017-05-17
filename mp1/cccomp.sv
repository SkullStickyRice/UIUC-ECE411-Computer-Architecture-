import lc3b_types::*;

module cccomp (input lc3b_nzp cc_in,
					input lc3b_nzp NZP_in,
					output branch_enable);
					
logic BEA;

always_comb
begin
BEA = (cc_in[0] && NZP_in[0]) || (cc_in[1] && NZP_in[1]) || (cc_in[2]&&NZP_in[2]);
end
assign branch_enable = BEA;
endmodule: cccomp