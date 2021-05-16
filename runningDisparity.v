module runningDisparity #(parameter WIDTH=10) (input clk,
						 input reset,
						 input startin,
						 input [WIDTH-1:0] dataout,
						 input pushout,
						 output reg RDout);


	localparam S0 = 1'b0, S1 = 1'b1, CWIDTH = WIDTH/2;

	reg currentState, nextState;

	always @(posedge clk or posedge reset) begin
		if (reset) begin
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
				//RDout = 1'b0;
				if ((countOnes(dataout) == CWIDTH && pushout)) begin
					nextState = S0;
					RDout = 1'b0;
				end
				else if (pushout) begin
					nextState = S1;
					RDout = 1'b1;
				end
			end
			S1: begin
				//RDout = 1'b1;
				if (startin) begin
					nextState = S0;
					RDout = 1'b0;
				end else begin
					if (countOnes(dataout) == CWIDTH && pushout) begin
						nextState = S1;
						RDout = 1'b1;
					end
					else if (pushout) begin
						nextState = S0;
						RDout = 1'b0;
					end

				end
			end
		endcase
	end

	function [2:0] countOnes;
		input [WIDTH-1:0] data;

		integer i;

	begin
		countOnes = 'd0;
		for (i = 0; i < WIDTH; i = i+1) begin
			countOnes = countOnes + data[i];
		end
	end
	endfunction 
endmodule
