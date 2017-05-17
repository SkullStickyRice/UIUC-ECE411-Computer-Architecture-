module mux4 #(parameter width = 16)(
			input logic [width-1:0] a,
			input logic [width-1:0] b,
			input logic [width-1:0] c,
			input logic [width-1:0] d,
			input logic [1:0] sel,
			
			output logic [width-1:0] f
);
always_comb
begin
	case(sel)
	2'b00:f = a;
	2'b01:f = b;
	2'b10:f = c;
	2'b11:f = d;
	endcase
end

endmodule : mux4