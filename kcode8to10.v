module kcode8to10 (input [7:0] datain, 
            input RD,
            output [9:0] dataout);

	reg [9:0] outTemp;
	localparam K280 = 8'h1c,
			   K281 = 8'h3c,
			   K282 = 8'h5c,
			   K283 = 8'h7c,
			   K284 = 8'h9c,
			   K285 = 8'hbc,
			   K286 = 8'hdc,
			   K237 = 8'hf7,
			   K277 = 8'hfb,
			   K297 = 8'hfd,
			   K307 = 8'hfe;

	assign dataout = outTemp;

	always @(*) begin
		case (datain)
			K280: begin
				outTemp = (RD) ? 10'b110000_1011 : 10'b001111_0100;
			end
			K281: begin
				outTemp = (RD) ? 10'b110000_0110 : 10'b001111_1001;
			end
			K282: begin
				outTemp = (RD) ? 10'b110000_1010 : 10'b001111_0101;
			end
			K283: begin
				outTemp = (RD) ? 10'b110000_1100 : 10'b001111_0011;
			end
			K284: begin
				outTemp = (RD) ? 10'b110000_1101 : 10'b001111_0010;
			end
			K285: begin
				outTemp = (RD) ? 10'b110000_0101 : 10'b001111_1010;
			end
			K286: begin
				outTemp = (RD) ? 10'b110000_1001 : 10'b00111_0110;
			end
			K237: begin
				outTemp = (RD) ? 10'b000101_0111 : 10'b111010_1000;
			end
			K277: begin
				outTemp = (RD) ? 10'b001001_0111 : 10'b110110_1000;
			end
			K297: begin
				outTemp = (RD) ? 10'b010001_0111 : 10'b101110_1000;
			end
			K307: begin
				outTemp = (RD) ? 10'b100001_0111 : 10'b011110_1000;
			end
			default: outTemp = 10'b0;
		endcase
	end

endmodule
