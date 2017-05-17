module btb_valid_array 
(
	input clk, 
	input logic write, 
	input logic [1:0] index, 
	input logic datain, 
	
	output logic out1, 
	output logic out2, 
	output logic out3, 
	output logic out4 
);

logic data_out [3:0]; 

initial
begin
	for (int i = 0; i < $size(data_out); i++)
	begin
		data_out[i] = 0; 
	end
end

always_ff @(posedge clk)
begin	 
	if (write) 
	begin
		if (data_out[2'b00] != datain || data_out[2'b01] != datain || data_out[2'b10] != datain || data_out[2'b11] != datain)
			data_out[index] = datain; 
	end
end

assign out1 = data_out[2'b00];
assign out2 = data_out[2'b01];
assign out3 = data_out[2'b10];
assign out4 = data_out[2'b11];

endmodule : btb_valid_array