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
				if (countOnes(dataout) > 3'd5 && pushout) begin
					nextState = S1;
				end
			end
			S1: begin
				RDout = 1'b1;
				if (countOnes(dataout) < 3'd5 && pushout) begin
					nextState = S0;
				end
			end
		endcase
	end

	function [2:0] countOnes;
		input [9:0] data;

		integer i;

	begin
		countOnes = 'd0;
		for (i = 0; i < 10; i = i+1) begin
			countOnes = countOnes + data[i];
		end
	end
	endfunction 
endmodule
