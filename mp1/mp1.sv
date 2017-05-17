import lc3b_types::*;

module mp1
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
logic pcmux_sel, 
		load_pc,
	   load_cc,
	   load_ir,
	   load_regfile,
	   load_mar,
	   load_mdr,
		trap_mar_mux_sel,
		shf_mux_sel,
		DR7_mux_sel,
		ldi_mar_mux_sel,
		add_and,
		ldb_alu_mux_sel,
		ldb_mux_sel,
		jsr_reg_mux_sel,
	  storemux_sel,
	  stb_alu_mdr_mux_sel,
	  mem_LU_sel,
	 alumux_sel,
	 regfilemux_sel,
	 marmux_sel,
	 branch_enable,
	 mdrmux_sel,
	 pcjmpmux_sel, pcjsrmux_sel, jsrcmux_sel, trapmux_sel,
	 regf_lea_mux_sel
	 ;
	 
logic [1:0] AD;
lc3b_aluop aluop;
lc3b_word m_rdata;
lc3b_word m_address;
lc3b_word m_wdata;
lc3b_mem_wmask m_byte_enable;
lc3b_opcode opcode;
assign m_rdata = mem_rdata;
assign mem_address = m_address;
assign mem_wdata = m_wdata;
assign mem_byte_enable = m_byte_enable;
/* Instantiate MP 0 top level blocks here */
datapath dp (.clk,
				 .pcmux_sel,
				 .load_pc,
				 .load_cc,
				 .load_ir,
				 .load_regfile,
				 .load_mar,
				 .load_mdr,
				 .trap_mar_mux_sel,
				 .DR7_mux_sel,
				 .ldi_mar_mux_sel,
				 .ldb_alu_mux_sel,
				 .ldb_mux_sel,
				 .jsr_reg_mux_sel,
				 .storemux_sel,
				 .alumux_sel,
				 .regfilemux_sel,
				 .marmux_sel,
				 .mdrmux_sel,
				 .branch_enable,
				 .add_and,
				 .shf_mux_sel,
				 .AD,
				 .opcode,
				 .aluop,
				 .pcjmpmux_sel, 
				 .pcjsrmux_sel,
				 .trapmux_sel, 
				 .regf_lea_mux_sel,
				 .stb_alu_mdr_mux_sel,
				 .mem_LU_sel,
				 .mem_rdata(m_rdata),
				 .mem_address(m_address),
				 .mem_wdata(m_wdata));
control ctrl_unit (	 .clk,
/* Datapath controls */
	.opcode,
	.branch_enable,
     .load_pc,
     .load_ir,
     .load_regfile,
     .load_mar,
     .load_mdr,
     .load_cc,
	  .trap_mar_mux_sel,
	  .shf_mux_sel,
	  .DR7_mux_sel,
	  .ldi_mar_mux_sel,
	  .ldb_alu_mux_sel,
	  .ldb_mux_sel,
	  .jsr_reg_mux_sel,
	  .add_and,
     .pcmux_sel,
     .storemux_sel,
     .alumux_sel,
     .regfilemux_sel,
	  .stb_alu_mdr_mux_sel,
	  .mem_LU_sel,
     .marmux_sel,
     .mdrmux_sel,
	  .aluop,
	  .AD,
	  .pcjmpmux_sel, 
	  .pcjsrmux_sel,
	  .trapmux_sel,
	  .regf_lea_mux_sel,

/* et cetera */
/* Memory signals */
		.mem_resp,
     .mem_read,
     .mem_write,
	  .mem_byte_enable(m_byte_enable));
endmodule : mp1
