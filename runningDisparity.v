module runningDisparity (input clk,
						 input reset,
						 input startin,
						 input [9:0] dataout,
						 input pushout,
						 output reg RDout);


	localparam S0 = 1'b0, S1 = 1'b1;

	reg currentState, nextState;

	always @(posedge clk or posedge reset or posedge startin) begin
		if (reset || startin) begin
			currentState <= S0;
		end
		else begin
			currentState <= nextState;
		end
	end
	
	always @(*) begin
		nextState = currentState;
		RDout = 1'b0;
		case (currentState)
			S0: begin
				RDout = 1'b0;
				if (countOnes(dataout) == 2'd1 && pushout) begin
					nextState = S1;
				end
			end
			S1: begin
				RDout = 1'b1;
				if (countOnes(dataout) == 2'd0 && pushout) begin
					nextState = S0;
				end
			end
		endcase
	end

	function [1:0] countOnes;
		input [9:0] data;

		reg [3:0] ones, zeros;
		integer i;

	begin
		for (i = 0; i < 10; i = i+1) begin
			if (data[i]) begin
				ones = ones + 1;
			end else begin
				zeros = zeros + 1;
			end
		end

		if (ones > zeros) begin
			countOnes = 2'd1;
		end else if(zeros > ones) begin
			countOnes = 2'd0;
		end else begin
			countOnes = 2'd3;
		end
	end
	endfunction 
endmodule