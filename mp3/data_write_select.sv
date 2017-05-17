import lc3b_types::*;

module data_write_select
(
	input write_enable,
	input write_sel,
	output logic write1,
	output logic write2
);

always_comb
begin
	if (write_enable)
	begin
		write1 = ~write_sel;
		write2 = write_sel;
	end
	else
	begin
		write1 = 1'b0;
		write2 = 1'b0;
	end
end

endmodule : data_write_select