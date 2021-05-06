module enc3to4 (input [2:0] datain, 
            input RD,
            output [3:0] dataout);
	
	reg [3:0] fghj_d;

	assign dataout = fghj_d;

    case(datain)
      0: begin 
      		fghj_d = (RD) ? 4'b0100 : 4'b1011; 
      	 end
      1: begin
      		fghj_d = 4'b1001;
      	end
      2: begin
      		fghj_d = 4'b0101;
      	end 
      3: begin
      		fghj_d = (RD) ? 4'b0011 : 4'b1100;
      	 end
      4: begin
      		fghj_d = (RD) ?  4'b0010 : 4'b1101;
      	 end
      5: begin
      		fghj_d = 4'b1010;
      	 end
      6: begin
      		fghj_d = 4'b0110;
      	 end
      7: begin 
      		fghj_d = (RD) ? 4'b0001 : 4'b1110;
     	 end
    endcase
  end

endmodule