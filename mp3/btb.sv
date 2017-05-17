import lc3b_types::*;

module btb
(		
	input clk, 
	input lc3b_word br_pc_in,  		//branch instr pc
	input lc3b_word cur_pc_in,
	input lc3b_word br_target_pc,  	//branch instr target
	input load, 							//if instr is br, load the btb
	
	output logic hit,						//output whether we find a pc target or not
	output lc3b_word outcome			//output the target pc
);

lc3b_word address1; 
lc3b_word address2; 
lc3b_word address3; 
lc3b_word address4; 
logic [1:0] ctr_value;
logic valid1, valid2, valid3, valid4;
logic comp1_out, comp2_out, comp3_out, comp4_out, btb_hit; 
logic comp1_cur, comp2_cur, comp3_cur, comp4_cur; 

always_comb
begin
	// check if one of the 4 br pc address in the btb equal the input pc
	comp1_out = 1'b0; 
	comp2_out = 1'b0; 
	comp3_out = 1'b0; 
	comp4_out = 1'b0; 
	comp1_cur = 1'b0; 
	comp2_cur = 1'b0; 
	comp3_cur = 1'b0; 
	comp4_cur = 1'b0; 
	btb_hit = 1'b0; 
	if (br_pc_in == address1 && valid1)
		comp1_out = 1;
	else if (br_pc_in == address2 && valid2)
		comp2_out = 1;
	else if (br_pc_in == address3 && valid3)
		comp3_out = 1;
	else if (br_pc_in == address4 && valid4)
		comp4_out = 1;
	if (comp1_out || comp2_out || comp3_out || comp4_out)
		btb_hit = 1'b1;	
		
	if (cur_pc_in == address1 && valid1)
		comp1_cur = 1'b1;
	else if (cur_pc_in == address2 && valid2)
		comp2_cur = 1'b1;
	else if (cur_pc_in == address3 && valid3)
		comp3_cur = 1'b1;
	else if (cur_pc_in == address4 && valid4)
		comp4_cur = 1'b1;
end

 
btb_pc_array  pc_arr_inst
(
	.clk, 
	.write(load), 		//always write to the pc_array when the instr is br
	.index(ctr_value), 
	.datain(br_pc_in), 
	
	.out1(address1), 
	.out2(address2), 
	.out3(address3), 
	.out4(address4)  
);

btb_valid_array  valid_arr_inst
(
	.clk, 
	.write(load), 		
	.index(ctr_value), 
	.datain(1'b1), 
	
	.out1(valid1), 
	.out2(valid2), 
	.out3(valid3), 
	.out4(valid4)  
);

btb_pc_target_array  pc_target_arr_inst
(
	.clk, 
	.write(load), 			/*NOT SURE: whether the write come from btb_hit or load*/
	.index(ctr_value), 
	.datain(br_target_pc),  
	.cmp1(comp1_out), 
	.cmp2(comp2_out), 
	.cmp3(comp3_out), 
	.cmp4(comp4_out), 
	.cmp1_cur(comp1_cur), 
	.cmp2_cur(comp2_cur), 
	.cmp3_cur(comp3_out), 
	.cmp4_cur(comp4_out), 
	
	.hit(hit),
	.dataout(outcome)
); 	


btb_counter  btb_counter_inst
(
	.clk,
	//.a(comp1_out),
	//.b(comp2_out),
	//.c(comp3_out),
	//.d(comp4_out),
	.inc(btb_hit), 		//increment counter when pc is not found in table (btb_hit==0)
	
	.ctr_value(ctr_value)
);

/*
comparator #(.width(16)) comp1_inst
(
	.a(br_pc_in),
	.b(address1),
	.f(comp1_out)
);

comparator #(.width(16)) comp2_inst
(
	.a(br_pc_in),
	.b(address2),
	.f(comp2_out)
);

comparator #(.width(16)) comp3_inst
(
	.a(br_pc_in),
	.b(address3),
	.f(comp3_out)
);

comparator #(.width(16)) comp4_inst
(
	.a(br_pc_in),
	.b(address4),
	.f(comp4_out)
);


// determine whether need to replace and load in new target address
checkpc checkpc_unit
(
	.load(load),
	.comp1_out(comp1_out),
	.comp2_out(comp2_out),
	.comp3_out(comp3_out),
	.comp4_out(comp4_out), 
	.btb_hit(btb_hit) // btb_hit = 1 only when all comp_out are 0
);
*/

endmodule: btb