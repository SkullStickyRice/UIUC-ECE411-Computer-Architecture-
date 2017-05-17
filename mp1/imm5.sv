import lc3b_types::*;

module imm5 (input lc3b_imm5 in,
				 output lc3b_word out);
				 assign out = $signed(in);
endmodule