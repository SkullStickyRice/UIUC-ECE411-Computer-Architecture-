import lc3b_types::*;

module L2cache_data_write_select
(
	input write_enable,
	input [1:0] write_sel,
	
	output logic write1,
	output logic write2,
	output logic write3,
	output logic write4
);

always_comb
begin
	write1 = 1'b0;
	write2 = 1'b0;
	write3 = 1'b0;
	write4 = 1'b0;
	if (write_enable)
	begin
		case(write_sel)
			2'b00: write1 = 1;
			2'b01: write2 = 1;
			2'b10: write3 = 1;
			2'b11: write4 = 1;
			default: ;
		endcase
	end
end

endmodule : L2cache_data_write_select