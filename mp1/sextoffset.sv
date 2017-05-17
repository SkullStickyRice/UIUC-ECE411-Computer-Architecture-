import lc3b_types::*;
module sextoffset #(parameter width = 6)
								(
							input [width-1:0] in,
							output lc3b_word out
								);
							
			assign out = $signed (in);			
endmodule