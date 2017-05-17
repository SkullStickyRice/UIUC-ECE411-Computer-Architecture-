import lc3b_types::*;

module counter_array
(
	input clk,
	input inc, 
	input write,
	input [2:0] index,
	
	output logic [1:0] ctr_value
);

logic [1:0] dataout, datain;

array #(.width(2))
(
    .clk(clk),
    .write(write),
    .index(index),
    .datain(datain),
    .dataout(dataout),
);

always_comb
begin
	datain = dataout;
	if (dataout > 0 && inc == 0)
		datain = dataout - 1;
	else if (dataout < 3 && inc == 1)
		datain = dataout + 1;
end

endmodule : counter_array
