import lc3b_types::*;

module word_select
(
	input logic [2:0] word_sel,
	input lc3b_8word data_in,
	output lc3b_word data_out
);

always_comb
begin

	case (word_sel)
		3'd0:
			data_out = data_in[15:0];
		3'd1:
			data_out = data_in[31:16];
		3'd2:
			data_out = data_in[47:32];
		3'd3:
			data_out = data_in[63:48];
		3'd4:
			data_out = data_in[79:64];
		3'd5:
			data_out = data_in[95:80];
		3'd6:
			data_out = data_in[111:96];
		3'd7:
			data_out = data_in[127:112];
		default:
			data_out = data_in[15:0];
		
	endcase

end

endmodule : word_select
