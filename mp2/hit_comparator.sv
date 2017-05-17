import lc3b_types::*;

module hit_comparator
(
  input lc3b_tag tag, curTag,
  input logic isValid,
  output logic result
);

always_comb
begin
    if (tag == curTag && isValid)
		result = 1;
	 else
	   result = 0; 
end

endmodule : hit_comparator