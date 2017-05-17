
module btb_counter
(
	input clk,
	input inc, 
	
	output logic [1:0] ctr_value 

);

logic [1:0] counter, counter_in;
assign ctr_value = counter;

initial
begin
	counter = 2'b00;
end


always_comb
begin
	if (inc)
		counter_in = counter + 1;
	else
		counter_in = counter;
end

always_ff @(posedge clk)
begin
	counter <= counter_in;
end

endmodule : btb_counter