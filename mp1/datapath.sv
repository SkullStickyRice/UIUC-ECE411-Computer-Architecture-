import lc3b_types::*;

module datapath
(
    input clk,

    /* control signals */
    input logic pcmux_sel,
     load_pc,
	  load_cc,
	  load_ir,
	  load_regfile,
	  load_mar,
	  load_mdr,
	  trap_mar_mux_sel,
	  ldb_alu_mux_sel,
	  ldi_mar_mux_sel,
	  ldb_mux_sel,
	  jsr_reg_mux_sel,
	  add_and,
	  shf_mux_sel,
	 storemux_sel,
	 alumux_sel,
	 regfilemux_sel,
	 marmux_sel,
	 mdrmux_sel,
	 DR7_mux_sel,
	 pcjmpmux_sel, pcjsrmux_sel, trapmux_sel,
	 regf_lea_mux_sel,
	 stb_alu_mdr_mux_sel,
	 input lc3b_aluop aluop,
	 
	 input lc3b_word mem_rdata,
	 output lc3b_opcode  opcode,
    output lc3b_word mem_address,
	 output logic branch_enable,
	 output logic mem_LU_sel,
	 output logic [1:0] AD,
    output lc3b_word mem_wdata
    /* declare more ports here */
);

/* declare internal signals */
lc3b_byte trapvect8;
lc3b_word mar_out;
lc3b_word mdr_out;
lc3b_word imm5_out;
lc3b_word sr_imm_mux_out;
lc3b_word pcmux_out;
lc3b_word pc_out;
lc3b_word trap_mar_mux_out;
lc3b_word shf_mux_out;
lc3b_word imm4_16_out;
lc3b_word ldb_mux_out;
lc3b_word br_add_out;
lc3b_word pc_plus2_out;
lc3b_word sr1_out, sr2_out;
lc3b_word adj6_out, adj9_out;
lc3b_word alumux_out,regfilemux_out,marmux_out, mdrmux_out, alu_out;
lc3b_word ldb_alu_mux_out;
lc3b_offset6 offset6;
lc3b_offset9 offset9;
lc3b_offset11 offset11;
lc3b_reg sr1, sr2, dest, storemux_out, DR7_mux_out;
lc3b_nzp gencc_out, cc_out;
lc3b_word seoffset6_out;
lc3b_word pcjmpmux_out, pcjsrmux_out, jsrcmux_out , trapvect8_out, trapmux_out, aluleamux_out, adj11_out, lea_adj9_out, jsr_adj11_out, regf_lea_out;
lc3b_word jsr_reg_mux_out;
lc3b_word ldi_mar_mux_out;
lc3b_word ldb_UL_mux_out;
lc3b_word stb_alu_ul_mdr_mux_out;
lc3b_word stb_alu_mdr_mux_out;
lc3b_imm5 vimm5;
logic immsel;
//logic ldst_UL_sel;
logic jsrcmux_sel;
assign mem_wdata = mdr_out;
assign mem_address = mar_out;
assign mem_LU_sel = mar_out[0];
/*
 * PC
 */
assign AD = offset6[5:4];
 ir ins_reg (.clk,
    .load(load_ir),
    .in(mdr_out),
	 .opcode,
    .dest, .src1(sr1), .src2(sr2),
	 .vimm5,
	 .trapvect8,
	 .offset11,
    .offset6,
	 .jsrcmux_sel,
    .offset9);
mux2 #(.width(3)) storemux (.sel(storemux_sel),
					.a(sr1),
					.b(dest),
					.f(storemux_out)
						);
				
mux2 pcmux
(
    .sel(pcmux_sel),
    .a(pc_plus2_out),
    .b(trapmux_out),
    .f(pcmux_out)
);
zadj exttrapvect (.in(trapvect8),.out(trapvect8_out));
adj #(.width(9)) ofs9(.in(offset9),.out(adj9_out));

adj #(.width(6)) ofs6 (.in(offset6),.out(adj6_out));

mux2 regfilemux(.sel(regfilemux_sel),.a(regf_lea_out),.b(ldb_mux_out),.f(regfilemux_out));

register pc
(
    .clk,
    .load(load_pc),
    .in(pcmux_out),
    .out(pc_out)
);

br_add b_a (.in(pc_out),.adj(adj9_out),.out(br_add_out));

gencc gcc (.in(regfilemux_out),.out(gencc_out));
plus2 pcpls2 (.in(pc_out),
					.out(pc_plus2_out)
					);
	regfile regf (.clk,
    .load(load_regfile),
    .in(jsr_reg_mux_out),
    .src_a(storemux_out), 
	 .src_b(sr2), 
	 .dest(DR7_mux_out),
    .reg_a(sr1_out), 
	 .reg_b(sr2_out));
	 
register #(.width(3)) cc (.clk, 
             .load(load_cc),
				 .in(gencc_out),
				 .out(cc_out));

mux2 alumux (.sel(alumux_sel),
				 .a(sr2_out),
				 .b(adj6_out),
				 .f(alumux_out));
				 
mux2 mdrmux (.sel(mdrmux_sel),
				 .a(stb_alu_mdr_mux_out),
				 .b(mem_rdata),
				 .f(mdrmux_out));
				 
mux2 marmux (.sel(marmux_sel),
				 .a(ldi_mar_mux_out),
				 .b(pc_out),
				 .f(marmux_out));
				 
register mar (.clk,
				  .load(load_mar),
				  .in(marmux_out),
				  .out(mar_out));

register mdr (.clk,
				  .load(load_mdr),
				  .in(mdrmux_out),
				  .out(mdr_out));
alu sgalu (.aluop,
    .a(sr1_out), .b(shf_mux_out),
    .f(alu_out));
	 
cccomp cmpcc (.cc_in(cc_out),
				  .NZP_in(dest),
				  .branch_enable);
assign immsel = add_and && offset6[5];
imm5 ir40imm5 (.in(vimm5),.out(imm5_out));
mux2 sr_imm (.sel(immsel),.a(alumux_out),.b(imm5_out),.f(sr_imm_mux_out));
mux2 pcjmpmux (
					.sel(pcjmpmux_sel),
					.a(br_add_out),
					.b(alu_out),
					.f(pcjmpmux_out)
					);

mux2 pcjsrmux (
					.sel(pcjsrmux_sel),
					.a(pcjmpmux_out),
					.b(jsrcmux_out),
					.f(pcjsrmux_out)
					);
				
mux2 jsrcmux (
					.sel(jsrcmux_sel),
					.a(alu_out),
					.b(jsr_adj11_out),
					.f(jsrcmux_out)
					);

mux2 trapmux (
				  .sel(trapmux_sel),
				  .a(pcjsrmux_out),
				  .b(mdr_out),
				  .f(trapmux_out)
				  );

mux2 jsr_reg_mux (.sel(jsr_reg_mux_sel),
						.a(regfilemux_out),
						.b(pc_out),
						.f(jsr_reg_mux_out));
						

adj #(.width(11)) adj11 (.in(offset11),.out(adj11_out));

br_add lea_adj9(.adj(adj9_out),.in(pc_out),.out(lea_adj9_out));

br_add jsr_adj11(.adj(adj11_out), .in(pc_out),.out(jsr_adj11_out));

mux2 regf_lea_mux (
					 .sel(regf_lea_mux_sel),
					 .a(alu_out),
					 .b(lea_adj9_out),
					 .f(regf_lea_out)
					 );
			
mux2 ldb_mux (
					.sel(ldb_mux_sel),
					.a(mdr_out),
					.b(ldb_UL_mux_out),
					.f(ldb_mux_out)
					);
					
sextoffset seoffs6 (.in(offset6),.out(seoffset6_out));

mux2 ldb_alu_mux (
						.sel(ldb_alu_mux_sel),
						.a(sr_imm_mux_out),
						.b(seoffset6_out),
						.f(ldb_alu_mux_out)
						);
mux2 ldi_mar_mux (
						.sel(ldi_mar_mux_sel),
						.a(trap_mar_mux_out),
						.b(mdr_out),
						.f(ldi_mar_mux_out)
						);
				
mux2 #(.width(3)) DR7_mux (
					.sel(DR7_mux_sel),
					.a(dest),
					.b(3'b111),
					.f(DR7_mux_out));
assign imm4_16_out = $unsigned(offset6[3:0]);
mux2 shf_mux (.sel(shf_mux_sel),
				  .a(ldb_alu_mux_out),
				  .b(imm4_16_out),
				  .f(shf_mux_out)
				  );
mux2 trap_mar_mux (.sel(trap_mar_mux_sel),
						 .a(alu_out),
						 .b(trapvect8_out),
						 .f(trap_mar_mux_out));
					
mux2 ldb_UL_mux (.sel(mar_out[0]),//since the memory always ignores the lower bit, we have to do the interpratienat
						.a({8'b0,mdr_out[7:0]}),
						.b({8'b0,mdr_out[15:8]}),
						.f(ldb_UL_mux_out)
						);
						
mux2 stb_alu_mdr_mux (.sel(stb_alu_mdr_mux_sel),
							  .a(alu_out),
							  .b(stb_alu_ul_mdr_mux_out),
							  .f(stb_alu_mdr_mux_out));
mux2 stb_alu_ul_mdr_mux(.sel(mar_out[0]),
								 .a({8'b0,alu_out[7:0]}),
								 .b({alu_out[7:0], 8'b0}),
								 .f(stb_alu_ul_mdr_mux_out));
//assign trapvect8_out = 16'b0;
endmodule : datapath
