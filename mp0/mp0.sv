import lc3b_types::*;

module mp0
(
    input clk,

    /* Memory signals */
    input mem_resp,
    input lc3b_word mem_rdata,
    output mem_read,
    output mem_write,
    output lc3b_mem_wmask mem_byte_enable,
    output lc3b_word mem_address,
    output lc3b_word mem_wdata
);

/* Instantiate MP 0 top level blocks here */
logic pcmux_sel;
logic load_pc;
logic storemux_sel;
logic load_ir;
logic load_regfile;
logic alumux_sel;
logic load_mar;
logic marmux_sel;
logic mdrmux_sel;
logic load_mdr;
logic load_cc;
logic regfilemux_sel;
logic branch_enable;
lc3b_aluop aluop;
lc3b_opcode opcode;

datapath datapath_module
(
	.clk,
	.pcmux_sel,
   .load_pc,
	.storemux_sel,
	.load_ir,
	.load_regfile,
	.alumux_sel,
	.load_mar,
	.marmux_sel,
	.mdrmux_sel,
	.load_mdr,
	.load_cc,
	.regfilemux_sel,
	.aluop,
	.mem_rdata,
	.opcode,
	.mem_wdata,
	.branch_enable,
	.mem_address
);

control control_unit
(
    .clk,
	 .opcode,
	 .branch_enable,
	 .load_pc,
	 .load_ir,
	 .load_regfile,
	 .load_mar, 
	 .load_mdr,
	 .load_cc,
	 .pcmux_sel, 
	 .storemux_sel, 
	 .alumux_sel, 
	 .regfilemux_sel, 
	 .marmux_sel, 
	 .mdrmux_sel,
	 .aluop,
	 .mem_resp,
	 .mem_read,
	 .mem_write,
	 .mem_byte_enable
);

endmodule : mp0
