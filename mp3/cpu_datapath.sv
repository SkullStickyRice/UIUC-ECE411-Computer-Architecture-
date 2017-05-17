import lc3b_types::*;

module cpu_datapath
(
    input clk,
	 input resp_a, // TODO: magic memory
    input lc3b_word rdata_a,
	 input resp_b, // TODO: magic memory
    input lc3b_word rdata_b,
	 input lc3b_control_word ctrl,
	 input icache_read, dcache_read, dcache_write,
	 input lc3b_word counter_data,
	 
	 output lc3b_word instr,
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
	 output logic counter_write, counter_read
);

lc3b_word dcache_rdata_a;
lc3b_word icache_rdata_a;
logic stall_reg_out;
logic stall_reg_in;
logic load_stall_reg;
logic byteposmux_sel, byteposmux2_sel;
logic load_pc;
logic load_IF, load_ID, load_EX, load_MEM; /*replace the previous load_reg signal*/
logic ctrl_mux_sel;    	/*select between ctrl_word OR 35'b0*/
lc3b_control_word ctrl_mux_out;

lc3b_mem_wmask mem_wmask, EX_mem_wmask_out;
lc3b_word mem_wdata;
lc3b_word pcmux_out;
lc3b_word pc_out;
lc3b_word br_add_out;
lc3b_word pc_plus2_out;
lc3b_reg storemux_out;
lc3b_word sr1_out;
lc3b_word sr2_out;
lc3b_word alumux_out;
lc3b_word regfilemux_out;
lc3b_word marmux_out;
lc3b_word mdrmux_out;
lc3b_word alu_out;
lc3b_word sr2mux_out;
lc3b_word jmpmux_out;
lc3b_word leamux_out;
lc3b_word offset6mux_out;
lc3b_word bytemux_out;
lc3b_word byteposmux_out;
lc3b_word wdatamux_out;
lc3b_word offset4mux_out;
lc3b_word bytemux2_out;
lc3b_word byteposmux2_out;
lc3b_word adj8mux_out;
lc3b_word trapmux_out;

lc3b_word offset4_word;
lc3b_word offset5_word;
lc3b_word offset6_word;
lc3b_word adj6_out;
lc3b_word adj8_out;
lc3b_word adj9_out;
lc3b_word adj11_out;

lc3b_nzp gencc_out;
lc3b_nzp cc_out;

lc3b_word offsetmux_out;
lc3b_reg r7_signal;
lc3b_reg r7mux_out;
lc3b_word jsrmux_out;

lc3b_word mem_rdata_byte_low;
lc3b_word mem_rdata_byte_high;
lc3b_word mem_wdata_byte_low;
lc3b_word mem_wdata_byte_high;

logic IF_FLUSH, REG_FLUSH;

lc3b_reg IF_dest_out;
lc3b_reg IF_sr1_out;
lc3b_reg IF_sr2_out;
lc3b_opcode IF_opcode_out;
lc3b_word IF_pc_out, ID_pc_out, EX_pc_out, MEM_pc_out;
lc3b_offset4 IF_offset4_out, ID_offset4_out;
lc3b_offset5 IF_offset5_out, ID_offset5_out;
lc3b_offset6 IF_offset6_out, ID_offset6_out;
lc3b_offset8 IF_offset8_out, ID_offset8_out, EX_offset8_out, MEM_offset8_out;
lc3b_offset9 IF_offset9_out, ID_offset9_out, EX_offset9_out, MEM_offset9_out;
lc3b_offset11 IF_offset11_out, ID_offset11_out, EX_offset11_out, MEM_offset11_out;
lc3b_reg ID_sr1_out, ID_sr2_out;
lc3b_reg ID_dest_out, EX_dest_out, MEM_dest_out;
lc3b_word EX_mar_out;
lc3b_word EX_mdr_out;
lc3b_word EX_alu_out, MEM_alu_out;
lc3b_word MEM_rdata_out;
lc3b_word ID_sr1_data_out, EX_sr1_out, MEM_sr1_out;
lc3b_word ID_sr2_data_out;
lc3b_word IF_instr_out;

lc3b_control_word ID_ctrl_out, EX_ctrl_out, MEM_ctrl_out;
lc3b_word temp_mar_out;
logic icache_stall, dcache_stall;
logic [1:0] forward_a, forward_b;
logic forward_sr1, forward_sr2;
lc3b_reg dest_sr2_mux_out;
lc3b_reg if_dest_mux_out;
lc3b_word forward_a_mux_out, forward_b_mux_out;
lc3b_word alu_lea_mux_out;
lc3b_word alu_lea_adj9_out;
lc3b_word forward_sr1_mux_out, forward_sr2_mux_out;
lc3b_word pc_zero_mux_out;
lc3b_word adj9_zero_mux_out;
logic adj9_zero_mux_sel;
lc3b_word MEM_pc_mux_out;
logic resp_a_out;
logic is_branch;
//lc3b_word nopmux_out;
//logic nopmux_sel;
lc3b_word mem_rdata_byte_low_forward, mem_rdata_byte_high_forward;

logic byteposmux_forward_sel;
lc3b_word byteposmux_forward_out, bytemux_forward_out;
assign byteposmux_forward_sel = EX_sr1_out[0] ^ EX_offset9_out[0];

always_comb
begin
	is_branch = 1'b0;
	counter_write = 1'b0;
	counter_read = 1'b0;
	MEM_opcode_out = MEM_ctrl_out.opcode;
	is_nop = MEM_ctrl_out.nop_pc;
	nzp_val = MEM_dest_out;
	dcache_rdata_a = rdata_a;
	icache_rdata_a = rdata_b;
	read_a = EX_ctrl_out.mem_read;
	write_a = EX_ctrl_out.mem_write;
	wmask_a = EX_mem_wmask_out;
	wmask_b = 2'b0;
	address_a = EX_mar_out;
	wdata_a = EX_mdr_out;
	wdata_b = 1'b0;
	//read_b = load_reg;
	//read_b = load_IF; //////////////????????????????????? needs to check
	read_b = 1'b1;
	write_b = 1'b0;
	address_b = pc_out;
	instr = IF_instr_out;
	resp_a_out = resp_a;
	if (stall_reg_out)
		address_a = temp_mar_out;
	if (stall_reg_out == 1'b0 && (EX_ctrl_out.opcode == op_ldi || EX_ctrl_out.opcode == op_sti))
	begin
		read_a = 1'b1;
		write_a = 1'b0;
	end
	if (EX_ctrl_out.mem_write && ((16'hffe0 & address_a) == 16'hffe0))
	begin
		write_a = 0;
		counter_write = 1;
		resp_a_out = 1;
	end
	if (EX_ctrl_out.mem_read && ((16'hffe0 & address_a) == 16'hffe0))
	begin
		read_a = 0;
		counter_read = 1;
		dcache_rdata_a = counter_data;
		resp_a_out = 1;
	end
	/* control hazard (br taken): flush pipeline */
	if (MEM_ctrl_out.opcode == op_br && branch_enable)
	begin
		write_a = 0;
		read_a = 0;
	end
	
	if (MEM_ctrl_out.opcode == op_jmp || MEM_ctrl_out.opcode == op_jsr || MEM_ctrl_out.opcode == op_trap)
	begin
		write_a = 0;
		read_a = 0;
	end
	
	if (MEM_ctrl_out.opcode == op_br && nzp_val != 0)
		is_branch = 1;
end


always_comb
begin
	icache_stall = 1'b0;
	dcache_stall = 1'b0;
	//nopmux_sel = 1'b0;
	//dcache
	if ((read_a || write_a) && (resp_a == 0))
	begin
		dcache_stall = 1'b1;
		//nopmux_sel = 1'b1;
	end
	//icache
	else if ((read_b) && (resp_b == 0))
	begin
		icache_stall = 1'b1;
		//nopmux_sel = 1'b1;
	end
end

data_forwarding_unit data_forwarding_unit_inst
(
	.EX_ctrl_out_load_regfile(EX_ctrl_out.load_regfile), .MEM_ctrl_out_load_regfile(MEM_ctrl_out.load_regfile), .jsr_imm(ID_dest_out[2]),
	.EX_dest_out(EX_dest_out), .MEM_dest_out(MEM_dest_out), .ID_sr1_out(ID_sr1_out), .ID_sr2_out(dest_sr2_mux_out), 
	.IF_sr1_out(IF_sr1_out), .IF_sr2_out(storemux_out),
	.ID_opcode_out(ID_ctrl_out.opcode), .EX_opcode_out(EX_ctrl_out.opcode), .ID_imm_bit(ID_offset6_out[5]),
	.forward_a(forward_a), .forward_b(forward_b), .forward_sr1(forward_sr1), .forward_sr2(forward_sr2)
);

mux2 #(.width(3)) dest_sr2_mux
(
	.sel(ID_ctrl_out.storemux_sel),
	.a(ID_sr2_out), .b(ID_dest_out),
	.f(dest_sr2_mux_out)
);

hazard_detection_unit hazard_detection_unit_inst
(
    .clk(clk),
	 .mem_read(ID_ctrl_out.mem_read),
	 .resp_a(resp_a_out),
	 .MEM_dest(MEM_dest_out),
	 .ID_dest(ID_dest_out),
	 .IF_dest(IF_dest_out),
	 .IF_sr1(IF_sr1_out),
	 .IF_sr2(IF_sr2_out),
	 .stall_reg_out(stall_reg_out),
	 .IF_opcode(IF_opcode_out),
	 .opcode(ID_ctrl_out.opcode),
	 .opcode_stall(EX_ctrl_out.opcode),
	 .MEM_opcode(MEM_ctrl_out.opcode),
	 .icache_stall(icache_stall),
	 .dcache_stall(dcache_stall),
	 .branch_enable(branch_enable),
	 
	 .load_pc(load_pc),
	 .load_IF(load_IF), 
	 .load_ID(load_ID), 
	 .load_EX(load_EX), 
	 .load_MEM(load_MEM),
	 .ctrl_mux_sel(ctrl_mux_sel),
	 .IF_FLUSH(IF_FLUSH),
	 .REG_FLUSH(REG_FLUSH),
	 .adj9_zero_mux_sel(adj9_zero_mux_sel),
	 .load_stall_reg(load_stall_reg)
);


IF_REG IF_REG_inst
(
    .clk(clk),
    .load_ir(load_IF),
	 .IF_FLUSH(IF_FLUSH),
	 .pc(pc_plus2_out),
    .in(icache_rdata_a),
	 
	 .sr1(IF_sr1_out),
	 .sr2(IF_sr2_out),
	 .dest(IF_dest_out),
    .pc_out(IF_pc_out),
	 .offset4(IF_offset4_out),
	 .offset5(IF_offset5_out),
	 .offset6(IF_offset6_out),
	 .offset8(IF_offset8_out),
	 .offset9(IF_offset9_out),
	 .offset11(IF_offset11_out),
	 .instr(IF_instr_out),
	 .opcode(IF_opcode_out)
);

// TODO: make sure that the pc is updated correctly for control hazards
/*
mux2 #(.width(36)) EX_flush_mux
(
	.sel(REG_FLUSH),
	.a(ID_ctrl_out), .b(36'b1),
	.f(EX_flush_mux_out)
);

mux2 #(.width(36)) MEM_flush_mux
(
	.sel(REG_FLUSH),
	.a(EX_ctrl_out), .b(36'b1),
	.f(MEM_flush_mux_out)
);

mux2 #(.width(3)) MEM_dest_flush_mux
(
	.sel(REG_FLUSH),
	.a(EX_dest_out), .b(3'b0),
	.f(MEM_dest_flush_mux_out)
);*/

mux2 #(.width(3)) if_dest_mux
(
	.sel(ctrl_mux_sel),
	.a(IF_dest_out), .b(3'b0),
	.f(if_dest_mux_out)
);

mux2 pc_zero_mux
(
	.sel(ctrl_mux_sel),
	.a(IF_pc_out), .b(16'b0),
	.f(pc_zero_mux_out)
);

ID_REG ID_REG_inst
(
    .clk(clk),
    .load_id(load_ID),
	 .dest(if_dest_mux_out),
	 .sr1(IF_sr1_out),
	 .sr2(storemux_out),
	 .sr1_data(forward_sr1_mux_out),
	 .sr2_data(forward_sr2_mux_out),
	 .pc(pc_zero_mux_out),
	 .offset4(IF_offset4_out),
	 .offset5(IF_offset5_out),
	 .offset6(IF_offset6_out),
	 .offset8(IF_offset8_out),
	 .offset9(IF_offset9_out),
	 .offset11(IF_offset11_out),
	 .ctrl(ctrl_mux_out),
	 
	 .dest_out(ID_dest_out),
	 .sr1_out(ID_sr1_out),
	 .sr2_out(ID_sr2_out),
	 .sr1_data_out(ID_sr1_data_out),
	 .sr2_data_out(ID_sr2_data_out),
	 .pc_out(ID_pc_out),
	 .offset4_out(ID_offset4_out),
	 .offset5_out(ID_offset5_out),
	 .offset6_out(ID_offset6_out),
	 .offset8_out(ID_offset8_out),
	 .offset9_out(ID_offset9_out),
	 .offset11_out(ID_offset11_out),
	 .ctrl_out(ID_ctrl_out)
);


EX_REG EX_REG_inst
(
    .clk(clk),
    .load_ex(load_EX),
	 .EX_FLUSH(REG_FLUSH),
	 .mar(marmux_out),
	 .mdr(mdrmux_out),
	 .sr1(forward_a_mux_out),
	 .pc(ID_pc_out),
	 .alu(alu_lea_mux_out),
	 .ctrl(ID_ctrl_out),
	 .offset8(ID_offset8_out),
	 .offset9(ID_offset9_out),
	 .offset11(ID_offset11_out),
	 .dest(ID_dest_out),
	 .mem_wmask(mem_wmask),
	 
	 .mar_out(EX_mar_out),
	 .mdr_out(EX_mdr_out),
	 .sr1_out(EX_sr1_out),
	 .pc_out(EX_pc_out),
	 .alu_out(EX_alu_out),
	 .ctrl_out(EX_ctrl_out),
	 .offset8_out(EX_offset8_out),
	 .offset9_out(EX_offset9_out),
	 .offset11_out(EX_offset11_out),
	 .dest_out(EX_dest_out),
	 .mem_wmask_out(EX_mem_wmask_out)
);

MEM_REG MEM_REG_inst
(
    .clk(clk),
    .load_mem(load_MEM),
	 .MEM_FLUSH(REG_FLUSH),
	 .pc(EX_pc_out),
	 .sr1(EX_sr1_out),
	 .ctrl(EX_ctrl_out),
	 .offset8(EX_offset8_out),
	 .offset9(EX_offset9_out),
	 .offset11(EX_offset11_out),
	 .alu(EX_alu_out),
	 .rdata(dcache_rdata_a),
	 .dest(EX_dest_out),
	 
	 .pc_out(MEM_pc_out),
	 .sr1_out(MEM_sr1_out),
	 .ctrl_out(MEM_ctrl_out),
	 .offset8_out(MEM_offset8_out),
	 .offset9_out(MEM_offset9_out),
	 .offset11_out(MEM_offset11_out),
	 .alu_out(MEM_alu_out),
	 .rdata_out(MEM_rdata_out),
	 .dest_out(MEM_dest_out)
);

mux2 MEM_pc_mux
(
	.sel(MEM_ctrl_out.nop_pc),
	.a(MEM_pc_out), .b(16'b0),
	.f(MEM_pc_mux_out)
);

/*************************************
          IF-ID phase
 *************************************/

/* mux used for load and store */
/*mux2 #(.width(3)) storemux
(
	.sel(ctrl.storemux_sel),
	.a(IF_sr1_out),
	.b(MEM_dest_out),
	.f(storemux_out)
);*/

logic btb_hit;
lc3b_word btb_out;

btb btb_inst
(		
	.clk(clk), 
	.br_pc_in(MEM_pc_out),  						//branch instr pc
	.cur_pc_in(pc_plus2_out),
	.br_target_pc(br_add_out),  					//branch instr target
	.load(is_branch), 								//if instr is br, load the btb

	.hit(btb_hit),				//output whether we find a pc target or not
	.outcome(btb_out)			//output the target pc
);

mux2 forward_sr1_mux
(
	.sel(forward_sr1),
	.a(sr1_out), .b(jsrmux_out),
	.f(forward_sr1_mux_out)
);

mux2 forward_sr2_mux
(
	.sel(forward_sr2),
	.a(sr2_out), .b(jsrmux_out),
	.f(forward_sr2_mux_out)
);

mux2 #(.width(3)) storemux
(
	.sel(ctrl.storemux_sel),
	.a(IF_sr2_out),
	.b(IF_dest_out),
	.f(storemux_out)
);

mux2 #(.width(3)) r7mux
(
	.sel(MEM_ctrl_out.r7mux_sel),
	.a(MEM_dest_out),
	.b(r7_signal),
	.f(r7mux_out)
);

/* general purpose register file */
regfile register_file
(
    .clk(clk),
    .load(MEM_ctrl_out.load_regfile),
    .in(jsrmux_out),
    .src_a(IF_sr1_out), .src_b(storemux_out), .dest(r7mux_out),
    .reg_a(sr1_out), .reg_b(sr2_out)
);



mux2 #(.width(36)) ctrl_mux
(
	.sel(ctrl_mux_sel),
	.a(ctrl),
	.b(36'b1),
	.f(ctrl_mux_out)
);


always_comb
begin
r7_signal = 3'b111;
end

/*************************************
          ID-EX phase
 *************************************/

/* arithmetic logic unit (ALU) */
alu ALU
(
	.aluop(ID_ctrl_out.aluop),
   .a(forward_a_mux_out), .b(alumux_out),
   .f(alu_out)
);

mux2 alu_lea_mux
(
	.sel(ID_ctrl_out.leamux_sel),
	.a(alu_out), .b(alu_lea_adj9_out + ID_pc_out),
	.f(alu_lea_mux_out)
);

adj #(.width(9)) alu_lea_adj9
(
	.in(ID_offset9_out),
	.out(alu_lea_adj9_out)
);

mux2 sr2mux
(
	.sel(ID_ctrl_out.sr2mux_sel),
	.a(forward_b_mux_out),
	.b(offset4mux_out),
	.f(sr2mux_out)
);

mux2 alumux
(
	.sel(ID_ctrl_out.alumux_sel),
	.a(sr2mux_out),
	.b(offset6mux_out),
	.f(alumux_out)
);

mux2 offset6mux
(
	.sel(ID_ctrl_out.offset6mux_sel),
	.a(adj6_out),
	.b(offset6_word),
	.f(offset6mux_out)
);

adj #(.width(6)) adj6
(
	.in(ID_offset6_out),
	.out(adj6_out)
);

/* logic used for SHF instruction */
mux2 offset4mux
(
	.sel(ID_ctrl_out.offset4mux_sel),
	.a(offset5_word),
	.b(offset4_word),
	.f(offset4mux_out)
);

/* logic used for TRAP instruction */
mux2 adj8mux
(
	.sel(ID_ctrl_out.adj8mux_sel),
	.a(alu_out),
	.b(adj8_out),
	.f(adj8mux_out)
);

mux2 marmux
(
	.sel(ID_ctrl_out.marmux_sel),
	.a(adj8mux_out),
	.b(wdatamux_out),
	.f(marmux_out)
);

mux2 mdrmux
(
	.sel(ID_ctrl_out.mdrmux_sel),
	.a(bytemux2_out),
	.b(mem_wdata),  
	.f(mdrmux_out)
);

/* logic used for LDI instruction */
mux2 wdatamux
(
	.sel(ID_ctrl_out.wdatamux_sel),
	.a(ID_pc_out),
	.b(dcache_rdata_a),   /*??? wher is wdata,ux ???*/
	.f(wdatamux_out)
);

/* logic used for STB instruction */
mux2 bytemux2
(
	.sel(ID_ctrl_out.bytemux2_sel),
	.a(forward_b_mux_out),
	.b(byteposmux2_out),
	.f(bytemux2_out)
);

mux2 byteposmux2
(
	.sel(byteposmux2_sel),
	.a(mem_wdata_byte_low),
	.b(mem_wdata_byte_high),
	.f(byteposmux2_out)
);

mux4 forward_a_mux
(
	.sel(forward_a),
	.a(ID_sr1_data_out), .b(jsrmux_out), .c(EX_alu_out), .d(bytemux_forward_out),
	.f(forward_a_mux_out)
);

mux4 forward_b_mux
(
	.sel(forward_b),
	.a(ID_sr2_data_out), .b(jsrmux_out), .c(EX_alu_out), .d(bytemux_forward_out),
	.f(forward_b_mux_out)
);


always_comb
begin
byteposmux2_sel = forward_a_mux_out[0] ^ ID_offset9_out[0];
mem_wmask = 2'b11;
if (ID_ctrl_out.opcode == op_stb) begin
	if (byteposmux2_sel)
		mem_wmask = 2'b10;
	else
		mem_wmask = 2'b01;
end
end

always_comb
begin
offset4_word = {12'b0, ID_offset4_out};
offset5_word = $signed(ID_offset5_out);
offset6_word = $signed({ID_offset6_out[5:1], 1'b0});
adj8_out = {7'b0,ID_offset8_out,1'b0};
mem_wdata_byte_low = {8'b0, forward_b_mux_out[7:0]};
mem_wdata_byte_high = {forward_b_mux_out[7:0], 8'b0};
end


/*************************************
          EX-MEM phase
 *************************************/
 
always_comb
begin
	stall_reg_in = stall_reg_out;
	if (stall_reg_out == 1'b0 && (EX_ctrl_out.opcode == op_ldi || EX_ctrl_out.opcode == op_sti) && resp_a_out)
		stall_reg_in = 1'b1;
	if (stall_reg_out == 1'b1 && (EX_ctrl_out.opcode == op_ldi || EX_ctrl_out.opcode == op_sti) && resp_a_out)
		stall_reg_in = 1'b0;
	if (MEM_ctrl_out.opcode == op_br && branch_enable)
	begin
		stall_reg_in = 0;
	end
	if (MEM_ctrl_out.opcode == op_jmp || MEM_ctrl_out.opcode == op_jsr || MEM_ctrl_out.opcode == op_trap)
	begin
		stall_reg_in = 0;
	end
end

register #(.width(1)) stall_reg
(
	.clk(clk),
	.load(load_stall_reg),
	.in(stall_reg_in),
	.out(stall_reg_out)
);

register #(.width(16)) temp_mar
(
	.clk(clk),
	.load(!stall_reg_out),
	.in(dcache_rdata_a),
	.out(temp_mar_out)
);

/*************************************
          MEM-WB phase
 *************************************/

 mux2 jsrmux
(
	.sel(MEM_ctrl_out.jsrmux_sel),
	.a(leamux_out),
	.b(MEM_pc_mux_out),
	.f(jsrmux_out)
);

/* mux used for LEA instruction */
mux2 leamux
(
	.sel(MEM_ctrl_out.leamux_sel),
	.a(bytemux_out),
	.b(br_add_out),
	.f(leamux_out)
);

adder br_add
(
	.a(offsetmux_out), //.b(pc_out),
	.b(MEM_pc_mux_out), /*LIHAO*/
	.f(br_add_out)
);


/* logic used for LDB instruction */
mux2 bytemux
(
	.sel(MEM_ctrl_out.bytemux_sel),
	.a(regfilemux_out),
	.b(byteposmux_out),
	.f(bytemux_out)
);

assign byteposmux_sel = MEM_sr1_out[0] ^ MEM_offset9_out[0];

mux2 byteposmux
(
	.sel(byteposmux_sel),
	.a(mem_rdata_byte_low),
	.b(mem_rdata_byte_high),
	.f(byteposmux_out)
);

mux2 regfilemux
(
	.sel(MEM_ctrl_out.regfilemux_sel),
	.a(MEM_alu_out),
	.b(MEM_rdata_out),
	.f(regfilemux_out)
);

adj #(.width(9)) adj9
(
	.in(MEM_offset9_out),
	.out(adj9_out)
);

adj #(.width(11)) adj11
(
	.in(MEM_offset11_out),
	.out(adj11_out)
);

/* mux that decides whether to load register value into PC */
mux2 jmpmux
(
	.sel(MEM_ctrl_out.jmpmux_sel),
	.a(br_add_out),
	.b(MEM_sr1_out),
	.f(jmpmux_out)
);

/* PC */
mux2 pcmux
(
    .sel(MEM_ctrl_out.pcmux_sel || (MEM_ctrl_out.opcode == op_br && branch_enable)),
    .a(trapmux_out),
    .b(jmpmux_out),
    .f(pcmux_out)
);
/////////////////////////////////////////
/*
mux2 nopmux
(
	.sel(nopmux_sel),
	.a(pcmux_out),
	.b(pc_out),
	.f(nopmux_out)
);
*/
register pc
(
    .clk(clk),
    .load(load_pc),
	 .in(pcmux_out),
    //.in(nopmux_out),
    .out(pc_out)
);

plus2 pc_plus2
(
	.in(pc_out),
	.out(pc_plus2_out)
);

/* logic used for JSR instruction */


mux2 adj9_zero_mux
(
	.sel(adj9_zero_mux_sel),
	.a(adj9_out), .b(16'b0),
	.f(adj9_zero_mux_out)
);

mux2 offsetmux
(
	.sel(MEM_ctrl_out.offsetmux_sel),
	.a(adj9_zero_mux_out),
	.b(adj11_out),
	.f(offsetmux_out)
);

mux2 trapmux
(
	.sel(MEM_ctrl_out.trapmux_sel),
	.a(pc_plus2_out),
	.b(MEM_rdata_out),
	.f(trapmux_out)
);

/* condition codes (NZP) */
register #(.width(3)) CC
(
	.clk(clk),
	.load(MEM_ctrl_out.load_cc),
	.in(gencc_out),
	.out(cc_out)
);

gencc gen_cc
(
	.in(leamux_out),
	.out(gencc_out)
);

nzp_comparator cccomp
(
	.a(MEM_dest_out), .b(cc_out),
	.f(branch_enable)
);



mux2 bytemux_forward
(
	.sel(EX_ctrl_out.bytemux_sel),
	.a(dcache_rdata_a),
	.b(byteposmux_forward_out),
	.f(bytemux_forward_out)
);

mux2 byteposmux_forward
(
	.sel(byteposmux_forward_sel),
	.a(mem_rdata_byte_low_forward),
	.b(mem_rdata_byte_high_forward),
	.f(byteposmux_forward_out)
);

always_comb
begin
	 mem_rdata_byte_low = {8'b0, regfilemux_out[7:0]};
	 mem_rdata_byte_high = {8'b0, regfilemux_out[15:8]};
	 mem_rdata_byte_low_forward = {8'b0, dcache_rdata_a[7:0]};
	 mem_rdata_byte_high_forward = {8'b0, dcache_rdata_a[15:8]};
end

endmodule : cpu_datapath
