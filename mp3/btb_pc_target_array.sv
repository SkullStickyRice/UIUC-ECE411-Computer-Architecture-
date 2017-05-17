module btb_pc_target_array #(parameter width = 16)
(
	input clk, 
	input logic write,
	input logic [1:0] index, 
	input [width-1:0] datain, 
	input logic cmp1, 
	input logic cmp2, 
	input logic cmp3, 
	input logic cmp4, 
	input cmp1_cur, 
	input cmp2_cur, 
	input cmp3_cur, 
	input cmp4_cur, 
	
	output logic [width-1:0] dataout,
	output logic hit 
);

logic [width-1:0] data [3:0]; 

/* Initialize array */
initial
begin
	for (int i = 0; i < $size(data); i++)
		data[i] = 0;
end

always_ff @(posedge clk)
begin
	if (write == 1)
	begin
		if (!cmp1 && !cmp2 && !cmp3 && !cmp4) //update the pc target only when no entry is hit
			data[index] = datain; 
	end
end

always_comb
begin
	// choose which entry to output, and set hit to 1
	if (cmp1_cur)
	begin
		dataout = data[2'b00];
		hit = 1; 
	end
	else if (cmp2_cur)
	begin
		dataout = data[2'b01];
		hit = 1; 
	end
	else if (cmp3_cur)
	begin
		dataout = data[2'b10];
		hit = 1; 
	end
	else if (cmp4_cur)
	begin
		dataout = data[2'b11];
		hit = 1 ; 
	end
	else 
	begin
		dataout = data[2'b00];
		hit = 0; 
	end
end

endmodule : btb_pc_target_array