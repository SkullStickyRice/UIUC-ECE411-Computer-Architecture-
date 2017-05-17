import lc3b_types::*;

module cpu
(
    input clk,
	 input resp_a,
	 input lc3b_word rdata_a,
	 input resp_b,
	 input lc3b_word rdata_b,
	 input icache_read, dcache_read, dcache_write,
	 input lc3b_word counter_data,
	 
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
	 output lc3b_opcode MEM_opcode_out,
	 output lc3b_nzp nzp_val,
	 output logic branch_enable,
	 output logic is_nop,
	 output logic counter_write,
	 output logic counter_read
);

lc3b_word instr;
lc3b_control_word ctrl;

cpu_datapath cpu_datapath_inst
(
    .clk(clk),
	 .resp_a(resp_a),
    .rdata_a(rdata_a),
	 .resp_b(resp_b),
    .rdata_b(rdata_b),
	 .ctrl(ctrl),
	 .icache_read, 
	 .dcache_read,
	 .dcache_write,
	 .counter_data,
	 
	 .instr(instr),
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
	 .is_nop(is_nop),
	 .counter_write(counter_write),
	 .counter_read(counter_read)
);

cpu_control cpu_control_inst
(
	 .clk(clk),
	 .instr(instr),
	 .ctrl(ctrl)
);

endmodule : cpu
