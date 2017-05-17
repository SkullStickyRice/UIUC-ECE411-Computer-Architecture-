import lc3b_types::*;

module br_add #(parameter width = 16)
(
    input [width-1:0] in,
	 input [width-1:0] adj,
    output logic [width-1:0] out
);

assign out = in + adj
;

endmodule : br_add