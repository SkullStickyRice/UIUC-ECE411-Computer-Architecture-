import lc3b_types::*;

module ewb
(
    input clk,
	 input buf_write,
	 input buf_read,
	 input pmem_resp,
	 input lc3b_8word buf_wdata,
	 input lc3b_word buf_address,
	 input lc3b_8word pmem_rdata,
	 
	 output logic buf_resp,
	 output logic pmem_write,
	 output logic pmem_read,
	 output lc3b_8word buf_rdata,
	 output lc3b_8word pmem_wdata,
	 output lc3b_word pmem_address
);

//lc3b_word write_addr; 
logic hit_signal;
logic data_read_sel;
logic data_write;
logic writing_to_mem;

/*assign pmem_address = buf_address;*/

ewb_datapath ewb_datapath_inst
(
	.clk,
   .data_write,
	.data_read_sel,
	.writing_to_mem,
	.buf_wdata,
	.buf_address,
	.pmem_rdata,
	
	.hit_signal,
	.buf_rdata,
	.pmem_wdata,
	.pmem_address
);

ewb_control ewb_control_inst
(
   .clk,
	.buf_read,	//pmem_read
	.buf_write,
	.hit_signal, //datapath
	.pmem_resp,
	
	.data_write,
	.writing_to_mem,
	.buf_resp,
	.pmem_write,
	.pmem_read,
	.data_read_sel
);

endmodule : ewb