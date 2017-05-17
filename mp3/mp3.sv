import lc3b_types::*;

module mp3
(
    input clk,
	 /*
	 input resp_a,
	 input lc3b_word rdata_a,
	 input resp_b,
	 input lc3b_word rdata_b,
	 
	 output logic read_a,
	 output logic write_a,
	 output lc3b_mem_wmask wmask_a,
	 output lc3b_word address_a,
	 output lc3b_word wdata_a,
	 output logic read_b,
	 output logic write_b,
	 output lc3b_mem_wmask wmask_b,
	 output lc3b_word address_b,
	 output lc3b_word wdata_b,
	 */
	 input pmem_resp,
	 input lc3b_8word pmem_rdata,
	 output pmem_read,
	 output pmem_write,
	 output lc3b_word pmem_address,
	 output lc3b_8word pmem_wdata
);
/*L1*/
logic icache_read, dcache_read, dcache_write, icache_write;
lc3b_word icache_address, dcache_address;
lc3b_8word dcache_wdata, icache_wdata;
	
logic icache_mem_resp, dcache_mem_resp; //send to L1 
lc3b_8word dcache_rdata, icache_rdata;  //send to L1
/*from PC*/
logic resp_a;
lc3b_word rdata_a;
logic resp_b;
lc3b_word rdata_b;
logic read_a;
logic write_a;
lc3b_mem_wmask wmask_a;
lc3b_word address_a;
lc3b_word wdata_a;
logic read_b;
logic write_b;
lc3b_mem_wmask wmask_b;
lc3b_word address_b;
lc3b_word wdata_b;
/*L2*/
lc3b_8word L2_wdata, L2_rdata; 
lc3b_word L2_address;
logic L2_read, L2_write, L2_resp;
logic L2_write_out, L2_read_out;
lc3b_8word L2_wdata_out;
lc3b_word L2_address_out;
/*EWB*/
logic buf_resp;
lc3b_8word buf_rdata;

//logic REG_FLUSH;
logic icache_miss, dcache_miss, L2_miss, is_nop, br_miss;
integer icache_miss_out, dcache_miss_out, L2_miss_out, icache_hit_out, dcache_hit_out, L2_hit_out;
integer br_misprediction_out, br_out, stall_out;

lc3b_opcode MEM_opcode_out;
lc3b_nzp nzp_val;
logic branch_enable;
logic counter_write, counter_read;
lc3b_word counter_data;

cpu cpu_inst
(
    .clk(clk),
	 .resp_a(resp_a), //a-dcache, b-icache
	 .rdata_a(rdata_a),
	 .resp_b(resp_b),
	 .rdata_b(rdata_b),
	 .icache_read(icache_read),
	 .dcache_read(dcache_read),
	 .dcache_write(dcache_write),
	 .counter_data(counter_data),

	 .read_a(read_a),
	 .write_a(write_a),
	 .wmask_a(wmask_a),
	 .address_a(address_a),
	 .wdata_a(wdata_a),
	 .read_b(read_b),
	 .write_b(write_b),
	 .wmask_b(wmask_b),
	 .address_b(address_b),
	 .wdata_b(wdata_b),
	 .MEM_opcode_out(MEM_opcode_out),
	 .nzp_val(nzp_val),
	 .branch_enable(branch_enable),
	 .is_nop,
	 .counter_read,
	 .counter_write
	 //.REG_FLUSH //need to declare 
);


dcache dcache_inst
(
	.clk(clk),
	.pmem_rdata(dcache_rdata),
	.pmem_resp(dcache_mem_resp),
	.mem_address(address_a),
	.mem_read(read_a),
	.mem_write(write_a),
	.mem_byte_enable(wmask_a),
	
	.mem_rdata(rdata_a),
	.mem_wdata(wdata_a),
	.mem_resp(resp_a),
	.pmem_read(dcache_read),
	.pmem_write(dcache_write),
	.pmem_wdata(dcache_wdata),
	.pmem_address(dcache_address)
);

icache icache_inst
(
	.clk(clk),
	.pmem_rdata(icache_rdata),
	.pmem_resp(icache_mem_resp),
	.mem_address(address_b),
	.mem_read(read_b),
	.mem_write(write_b),
	.mem_byte_enable(wmask_b),
	
	.mem_rdata(rdata_b),
	.mem_wdata(wdata_b),
	.mem_resp(resp_b),
	.pmem_read(icache_read),
	.pmem_write(icache_write),
	.pmem_wdata(icache_wdata),
	.pmem_address(icache_address)
);

arbiter_logic arbiter_inst
(
	.clk(clk),
	.icache_read(icache_read),
	.dcache_read(dcache_read), 
	.dcache_write(dcache_write),
	.pmem_resp(L2_resp), 
	.icache_address(icache_address), 
	.dcache_address(dcache_address),
	.dcache_wdata(dcache_wdata), 
	.pmem_rdata(L2_rdata),
	
	.icache_mem_resp(icache_mem_resp), 
	.dcache_mem_resp(dcache_mem_resp), //send to L1 
	.pmem_read(L2_read), 
	.pmem_write(L2_write), 		//send to L2
	.pmem_address(L2_address), 	//send to L2
	.dcache_rdata(dcache_rdata), 
	.icache_rdata(icache_rdata), 	//send to L1
	.pmem_wdata(L2_wdata) 		//send to L2
);

L2cache L2cache_inst
(
	.clk,
	.pmem_rdata(buf_rdata), 
	.pmem_resp(buf_resp),	
	.mem_wdata(L2_wdata),
	.mem_address(L2_address),
	.mem_read(L2_read),
	.mem_write(L2_write),
	
	//without ewb
	/*.mem_rdata(L2_rdata),
	.mem_resp(L2_resp),
	.pmem_read,
	.pmem_write,
	.pmem_wdata,
	.pmem_address
	*/
	
	
	//with ewb
	.mem_rdata(L2_rdata),
	.mem_resp(L2_resp),
	.pmem_read(L2_read_out),
	.pmem_write(L2_write_out),
	.pmem_wdata(L2_wdata_out),
	.pmem_address(L2_address_out)
	
);

ewb ewb_inst
(
	.clk(clk),
	.buf_write(L2_write_out),
	.buf_read(L2_read_out),
	.pmem_resp(pmem_resp),
	.buf_wdata(L2_wdata_out),
	.buf_address(L2_address_out),
	.pmem_rdata(pmem_rdata),
	
	.buf_resp,
	.pmem_read,
	.pmem_write,
	.buf_rdata,   
	.pmem_wdata,
	.pmem_address
);

performance_counter performance_counter_inst
(
	.clk,
	.icache_read(read_b), .icache_write(write_b), .icache_mem_resp(resp_b),
	.dcache_read(read_a), .dcache_write(write_a), .dcache_mem_resp(resp_a),
	.L2_read(L2_read), .L2_write(L2_write), .L2_mem_resp(L2_resp),
	.MEM_opcode_out, 
	.nzp_val,
	.branch_enable,
	.is_nop, 
	.counter_write, .counter_read,
	.dcache_address(address_a),
	
	.icache_miss_out,
	.icache_hit_out,
	.dcache_miss_out,
	.dcache_hit_out,
	.L2_miss_out,
	.L2_hit_out,
	.br_misprediction_out,
	.br_out,
	.stall_out,
	.counter_data
);

endmodule : mp3
