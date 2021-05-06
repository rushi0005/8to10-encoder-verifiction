module enc5to6( input [4:0] datain, 
            input RD,
            output [5:0] dataout);

reg [5:0] abcdei_d;
assign dataout = abcdei_d;
always @(*) begin
	case (datain)
		0: begin if(!RD) abcdei_d= 6'b100111; else abcdei_d= 6'b011000; end
		1: begin if(!RD) abcdei_d= 6'b011101; else abcdei_d= 6'b100010; end
		2: begin if(!RD) abcdei_d= 6'b101101; else abcdei_d= 6'b010010; end
		3: begin  abcdei_d= 6'b110001; end
		4: begin if(!RD) abcdei_d= 6'b110101; else abcdei_d= 6'b001010; end
		5: begin abcdei_d= 6'b101001;  end
		6: begin abcdei_d= 6'b011001;  end
		7: begin if(!RD) abcdei_d= 6'b111000; else abcdei_d= 6'b000111; end
		8: begin if(!RD) abcdei_d= 6'b111001; else abcdei_d= 6'b000110; end
		9: begin  abcdei_d= 6'b100101; end
		10: begin abcdei_d= 6'b010101; end 
		11: begin abcdei_d= 6'b110100; end 
		12: begin abcdei_d= 6'b001101; end 
		13: begin abcdei_d= 6'b101100; end 
		14: begin abcdei_d= 6'b011100; end 
		15: begin if(!RD)abcdei_d= 6'b010111; else abcdei_d= 6'b101000;   end 
		16: begin if(!RD)abcdei_d= 6'b011011; else abcdei_d= 6'b100100;   end
		17: begin abcdei_d= 6'b100011; end 
		18: begin abcdei_d= 6'b010011; end 
		19: begin abcdei_d= 6'b110010; end 
		20: begin abcdei_d= 6'b001011; end 
		21: begin abcdei_d= 6'b101010; end 
		22: begin abcdei_d= 6'b011010; end 
		23: begin if(!RD)abcdei_d= 6'b111010; else abcdei_d= 6'b000101;   end 
		24: begin if(!RD)abcdei_d= 6'b110011; else abcdei_d= 6'b001100;   end 
		25: begin abcdei_d= 6'b100110; end 
		26: begin abcdei_d= 6'b010110; end 
		27: begin if(!RD)abcdei_d= 6'b110110; else abcdei_d= 6'b001001;   end 
		28: begin if(!RD)abcdei_d=6'b001111; else abcdei_d=6'b110000;     end   // with control bit
		29: begin if(!RD)abcdei_d= 6'b101110; else abcdei_d= 6'b010001;   end 
		30: begin if(!RD)abcdei_d= 6'b011110; else abcdei_d= 6'b100001;   end 
		31: begin if(!RD)abcdei_d= 6'b101011; else abcdei_d= 6'b010100;   end 
	endcase
end

endmodule