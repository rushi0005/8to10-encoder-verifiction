module enc3to4 (input [2:0] datain, 
            input RD,
			input [4:0] lower,
            output [3:0] dataout);
	
	reg [3:0] fghj_d;
	wire RD0;

	assign dataout = fghj_d;
	assign RD0 = ((lower == 'd3) || (lower == 'd5) || (lower == 'd6) || (lower == 'd9) || (lower == 'd10) || (lower == 'd11) || (lower == 'd12) || (lower == 'd13) || (lower == 'd14) || (lower == 'd17) || (lower == 'd18) || (lower == 'd19) || (lower == 'd20) || (lower == 'd21) || (lower == 'd22) || (lower == 'd25) || (lower == 'd26) || (lower == 'd28) ) ? ~RD : RD;

  always @(*) begin
  
    case(datain)
      0: begin 
      		fghj_d = (RD0) ? 4'b0100 : 4'b1011; 
      	 end
      1: begin
      		fghj_d = 4'b1001;
      	end
      2: begin
      		fghj_d = 4'b0101;
      	end 
      3: begin
      		fghj_d = (RD0) ? 4'b0011 : 4'b1100;
      	 end
      4: begin
      		fghj_d = (RD0) ?  4'b0010 : 4'b1101;
      	 end
      5: begin
      		fghj_d = 4'b1010;
      	 end
      6: begin
      		fghj_d = 4'b0110;
      	 end
      7: begin 
			if (RD0 == 0) begin
				if ((lower == 'd17) || (lower == 'd18) || (lower == 'd20)) begin
					fghj_d = 4'b0111;
				end else begin
					fghj_d = 4'b1110;
				end
			end else begin
				if ((lower == 'd11) || (lower == 'd13) || (lower == 'd14)) begin
					fghj_d = 4'b1000;
				end else begin
					fghj_d = 4'b0001;
				end
			end 
     	 end
    endcase
  end
endmodule
