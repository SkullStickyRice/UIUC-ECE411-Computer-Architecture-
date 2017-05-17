import lc3b_types::*;

module mp3_tb;

timeunit 1ns;
timeprecision 1ns;

logic clk;
//logic resp_a, resp_b;
//lc3b_word rdata_a, rdata_b;
//logic read_a, write_a, read_b, write_b;
//lc3b_mem_wmask wmask_a, wmask_b;
//lc3b_word address_a, wdata_a, address_b, wdata_b, 
lc3b_word pmem_address;
lc3b_8word pmem_wdata, pmem_rdata;
logic pmem_read, pmem_write, pmem_resp;

/* Clock generator */
initial clk = 0;
always #5 clk = ~clk;


mp3 dut
(
    .clk(clk),
	 .pmem_resp,
	 .pmem_rdata,
	 .pmem_read,
	 .pmem_write,
	 .pmem_address,
	 .pmem_wdata
	 /*
	 .resp_a(resp_a),
	 .rdata_a(rdata_a),
	 .resp_b(resp_b),
	 .rdata_b(rdata_b),
	 
	 .read_a(read_a),
	 .write_a(write_a),
	 .wmask_a(wmask_a),
	 .address_a(address_a),
	 .wdata_a(wdata_a),
	 .read_b(read_b),
	 .write_b(write_b),
	 .wmask_b(wmask_b),
	 .address_b(address_b),
	 .wdata_b(wdata_b)
	 */
);

physical_memory physical_memory_inst 
(
	 .clk,
    .read(pmem_read),
    .write(pmem_write),
    .address(pmem_address),
    .wdata(pmem_wdata),
    .resp(pmem_resp),
    .rdata(pmem_rdata)
);

endmodule : mp3_tb
