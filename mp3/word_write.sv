import lc3b_types::*;

module word_write
(
	input logic [3:1] word_sel,
	input logic [1:0] byte_sel,
	input lc3b_8word data_in,
	input lc3b_word word_in,
	
	output lc3b_8word data_out
);

always_comb
begin
	data_out = data_in;
	if (byte_sel[0])
	begin
		case (word_sel)
		3'd0:
			data_out[7:0] = word_in[7:0];
		3'd1:
			data_out[23:16] = word_in[7:0];
		3'd2:
			data_out[39:32] = word_in[7:0];
		3'd3:
			data_out[55:48] = word_in[7:0];
		3'd4:
			data_out[71:64] = word_in[7:0];
		3'd5:
			data_out[87:80] = word_in[7:0];
		3'd6:
			data_out[103:96] = word_in[7:0];
		3'd7:
			data_out[119:112] = word_in[7:0];
		default:
			data_out[7:0] = word_in[7:0];
		endcase
	end
	if (byte_sel[1])
	begin
		case (word_sel)
		3'd0:
			data_out[15:8] = word_in[15:8];
		3'd1:
			data_out[31:24] = word_in[15:8];
		3'd2:
			data_out[47:40] = word_in[15:8];
		3'd3:
			data_out[63:56] = word_in[15:8];
		3'd4:
			data_out[79:72] = word_in[15:8];
		3'd5:
			data_out[95:88] = word_in[15:8];
		3'd6:
			data_out[111:104] = word_in[15:8];
		3'd7:
			data_out[127:120] = word_in[15:8];
		default:
			data_out[15:8] = word_in[15:8];
		endcase
	end
end

endmodule : word_write