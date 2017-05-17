module mux8 #(parameter width = 16)
(
	input [2:0] sel,
	input [width-1:0] a, b, c, d, e, f, g, h,
	output logic [width-1:0] out
);

always_comb
begin
	/*
	case(sel)
		0:
			out = a;
		1:
			out = b;
		2:
			out = c;
		3:
			out = d;
		4:
			out = e;
		5:
			out = f;
		6:
			out = g;
		7:
			out = h;
		endcase
		*/
		if (sel == 0)
			out=a;
		else if (sel == 1)
			out=b;
		else if (sel == 2)
			out=c;
		else if (sel == 3)
			out=d;
		else if (sel == 4)
			out=e;
		else if (sel == 5)
			out=f;
		else if (sel == 6)
			out=g;
		else 
			out=h;
		
end
endmodule:mux8