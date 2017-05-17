import lc3b_types::*; /* Import types defined in lc3b_types.sv */

module control
(
    /* Input and output port declarations */
	 input clk,
/* Datapath controls */
input lc3b_opcode opcode,
input logic branch_enable,
input logic [1:0] AD,
input logic mem_LU_sel,
output logic ldb_alu_mux_sel,
output logic load_pc,
output logic load_ir,
output logic load_regfile,
output logic load_mar,
output logic trap_mar_mux_sel,
output logic shf_mux_sel,
output logic ldb_mux_sel,
output logic ldi_mar_mux_sel,
output logic load_mdr,
output logic load_cc,
output logic jsr_reg_mux_sel,
output logic pcmux_sel,
output logic storemux_sel,
output logic alumux_sel,
output logic regfilemux_sel,
output logic marmux_sel,
output logic mdrmux_sel,
output logic pcjmpmux_sel,
output logic pcjsrmux_sel,
output logic trapmux_sel,
output logic regf_lea_mux_sel,
output logic add_and,
output logic stb_alu_mdr_mux_sel,
output logic DR7_mux_sel,
output lc3b_aluop aluop,

/* et cetera */
/* Memory signals */
input mem_resp,
output logic mem_read,
output logic mem_write,
output lc3b_mem_wmask mem_byte_enable
);

enum int unsigned {
    /* List of states */
	 fetch1,
	 fetch2,
	 fetch3,
	 decode,
	 s_add,
	 s_and,
	 s_not,
	 br,
	 br_taken,
	 jmp,
	 lea,
	 jsr,
	 trap1,
	 trap2,
	 trap3,
	 calc_addr,
	 ldb1,
	 ldb2,
	 ldr1,
	 ldr2,
	 ldi1,
	 ldi2,
	 str1,
	 str2,
	 stb1,
	 stb2,
	 sti1,
	 sti2,
	 shf
} state, next_states;

always_comb
begin : state_actions
    /* Default output assignments */
    /* Actions for each state */
	 		load_pc = 1'b0;
		load_ir = 1'b0;
		DR7_mux_sel = 1'b0;
		load_regfile = 1'b0;
		load_mar = 1'b0;
		load_mdr = 1'b0;
		load_cc = 1'b0;
		trap_mar_mux_sel = 1'b0;
		shf_mux_sel = 1'b0;
		ldb_mux_sel = 1'b0;
		jsr_reg_mux_sel = 1'b0;
		pcjmpmux_sel = 1'b0;
		pcjsrmux_sel = 1'b0;
		trapmux_sel =1'b0;
		pcmux_sel = 1'b0;
		storemux_sel = 1'b0;
		alumux_sel = 1'b0;
		ldb_alu_mux_sel = 1'b0;
		ldi_mar_mux_sel = 1'b0;
		regfilemux_sel = 1'b0;
		marmux_sel = 1'b0;
		mdrmux_sel = 1'b0;
		regf_lea_mux_sel = 1'b0;
		stb_alu_mdr_mux_sel = 1'b0;
		aluop = alu_add;
      add_and = 1'b0;
		mem_read = 1'b0;
		mem_write = 1'b0;
		mem_byte_enable = 2'b11;
unique case(state)
fetch1: begin
/* MAR <= PC */
marmux_sel = 1'b1;
load_mar = 1'b1;
/* PC <= PC + 2 */
pcmux_sel = 1'b0;
load_pc = 1'b1;
end
fetch2: begin
/* Read memory */
mem_read = 1'b1;
mdrmux_sel = 1'b1;
load_mdr = 1'b1;
end
fetch3: begin
/* Load IR */
load_ir = 1'b1;
end
decode: /* Do nothing */;
s_add: begin
/* DR <= SRA + SRB */
aluop = alu_add;
load_regfile = 1'b1;
regfilemux_sel = 1'b0;
load_cc = 1'b1;
add_and =1'b1;
end
s_and: begin
aluop = alu_and;
load_regfile = 1'b1;
load_cc = 1'b1;
add_and =1'b1;
end
s_not: begin
aluop = alu_not;
load_regfile = 1'b1;
load_cc = 1'b1;
end
br:begin
pcmux_sel = 1'b0;
end
br_taken: begin
pcmux_sel = 1'b1;
load_pc = 1'b1;
end
jmp:
begin
load_pc = 1'b1;
pcmux_sel = 1'b1;
aluop = alu_pass;
pcjmpmux_sel = 1'b1;
end
lea:
begin
load_cc = 1'b1;
load_regfile =1'b1;
regf_lea_mux_sel =1'b1;
end
jsr:
begin
jsr_reg_mux_sel = 1'b1;
load_pc = 1'b1;
pcmux_sel = 1'b1;
load_regfile = 1'b1;
pcjsrmux_sel = 1'b1;
aluop = alu_pass;
DR7_mux_sel = 1'b1;
end
calc_addr: begin
alumux_sel = 1'b1;
aluop = alu_add;
load_mar = 1'b1;
case (opcode)
default: ldb_alu_mux_sel = 1'b0;
op_ldr: ldb_alu_mux_sel = 1'b0;
op_str: ldb_alu_mux_sel = 1'b0;
op_ldi: ldb_alu_mux_sel = 1'b0;
op_sti: ldb_alu_mux_sel = 1'b0;
op_stb: ldb_alu_mux_sel = 1'b1;
op_ldb: ldb_alu_mux_sel =1'b1;
endcase
end
ldi1:
begin
mdrmux_sel = 1'b1;
load_mdr = 1'b1;
mem_read = 1'b1;
end
ldi2:
begin
load_mar = 1'b1;
ldi_mar_mux_sel = 1'b1;
end
ldb1:
begin
mdrmux_sel = 1'b1;
load_mdr = 1'b1;
mem_read = 1'b1;
end
ldb2:
begin
regfilemux_sel = 1'b1;
load_regfile =1'b1;
load_cc = 1'b1;
ldb_mux_sel = 1'b1;
end
ldr1: begin
mdrmux_sel = 1'b1;
load_mdr = 1'b1;
mem_read = 1'b1;
end
ldr2: begin
regfilemux_sel = 1'b1;
load_regfile =1'b1;
load_cc = 1'b1;
end
str1: begin
storemux_sel = 1'b1;
aluop = alu_pass;
load_mdr = 1'b1;
end
str2: begin
mem_write = 1'b1;
end
stb1:begin
storemux_sel = 1'b1;
aluop = alu_pass;
load_mdr = 1'b1;
stb_alu_mdr_mux_sel =1'b1;
end
stb2: begin
mem_write = 1'b1;
case(mem_LU_sel)
1'b0:mem_byte_enable = 2'b01;
1'b1:mem_byte_enable = 2'b10;
endcase
end
sti1:
begin
mdrmux_sel = 1'b1;
load_mdr = 1'b1;
mem_read = 1'b1;
end
sti2:
begin
load_mar = 1'b1;
ldi_mar_mux_sel = 1'b1;
end
shf:
begin
load_cc = 1'b1;
load_regfile = 1'b1;
shf_mux_sel = 1'b1;
case(AD)
2'b00: aluop = alu_sll;
2'b01: aluop = alu_srl;
2'b10: aluop = alu_sll;
2'b11: aluop = alu_sra;
endcase
end
trap1:
begin
DR7_mux_sel = 1'b1;
load_regfile = 1'b1;
jsr_reg_mux_sel = 1'b1;
trap_mar_mux_sel = 1'b1;
load_mar = 1'b1;
end
trap2:
begin
mem_read = 1'b1;
load_mdr = 1'b1;
mdrmux_sel =1'b1;
end
trap3:
begin
load_pc = 1'b1;
trapmux_sel =1'b1;
pcmux_sel = 1'b1;
end
		//end/* Do nothing */;
endcase
end

always_comb
begin : next_state_logic
    /* Next state information and conditions (if any)
     * for transitioning between states */
	  next_states = state;
	 unique case(state)
	 fetch1:begin
	 next_states = fetch2;
	 end
	 fetch2:begin
	 if (mem_resp == 1'b1)
	 next_states = fetch3;
	 else
	 next_states = fetch2;
	 end
	 fetch3: begin
	 next_states = decode;
	 end
	 decode:begin
	 case(opcode)
	 default: next_states = fetch1;
	 op_add: next_states = s_add;
	 op_and: next_states = s_and;
	 op_not: next_states = s_not;
	 op_ldr: next_states = calc_addr;
	 op_ldb: next_states = calc_addr;
	 op_str: next_states = calc_addr;
	 op_stb: next_states = calc_addr;
	 op_br: next_states = br;
	 op_trap: next_states = trap1;
	 op_jmp: next_states = jmp;
	 op_lea: next_states = lea;
	 op_jsr: next_states = jsr;
	 op_shf: next_states = shf;
	 op_ldi: next_states = calc_addr;
	 op_sti: next_states = calc_addr;
	 //op_trap: next_states = trap;
	 endcase
	 end
	 calc_addr:
	 begin
	 case(opcode)
	 default: next_states = ldr1;
	 op_ldr: next_states = ldr1;
	 op_ldb: next_states = ldb1;
	 op_str: next_states = str1;
	 op_ldi: next_states = ldi1;
	 op_stb: next_states = stb1;
	op_sti: next_states = sti1;
	 endcase
	 end
	 br:begin
	 if(branch_enable == 1'b1)
	 next_states = br_taken;
	 else
	 next_states = fetch1;
	 end
	 br_taken: 
	 begin
	 next_states = fetch1;
	 end
	 jmp:
	 begin
	 next_states = fetch1;
	 end
	 lea:
	 begin
	 next_states = fetch1;
	 end
	 ldi1:
	 begin
	 if (mem_resp == 1'b0)
	 next_states = ldi1;
	 else
	 next_states = ldi2;
	 end
	 ldi2:
	 begin
	 next_states = ldr1;
	 end
	 ldb1:
	 begin
	 if(mem_resp == 1'b0)
	 next_states = ldb1;
	 else
	 next_states = ldb2;
	 end
	 ldb2:begin
	 next_states = fetch1;
	 end
	 ldr1: begin
	 if(mem_resp == 1'b0)
	 next_states = ldr1;
	 else
	 next_states = ldr2;
	 end
	 ldr2: begin
	 next_states = fetch1;
	 end
	 str1:
	begin
	 next_states = str2;
	end
	 str2: begin
	 if(mem_resp == 1'b0)
	 next_states = str2;
	 else
	 next_states = fetch1;
	 end
	 stb1:
	 begin
	 next_states = stb2;
	 end
	 stb2:
	 begin
	 if(mem_resp == 1'b0)
	 next_states = stb2;
	 else
	 next_states = fetch1;
	 end
	 sti1:
	 begin
	 if (mem_resp == 1'b0)
	 next_states = sti1;
	 else
	 next_states = sti2;
	 end
	 sti2:
	 begin
	 next_states = str1;
	 end
	 s_add: next_states = fetch1;
	 s_and: next_states = fetch1;
	 s_not: next_states = fetch1;
	 shf: next_states = fetch1;
	 jsr: next_states = fetch1;
	 trap1:
	 next_states = trap2;
	 trap2:
	 if (mem_resp == 1'b0)
	 next_states = trap2;
	 else
	 next_states = trap3;
	 trap3:
	 next_states = fetch1;
	 endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
    /* Assignment of next state on clock edge */
	 state <= next_states;
end

endmodule : control
