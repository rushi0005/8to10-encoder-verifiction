//This is DUT...




module dut (intf dif);

	logic [9:0] dataout_d ;
	logic startout_d ;
	logic pushout_d  ;
	int count        ;
	always@(posedge dif.clk or posedge dif.reset) begin
		if(dif.reset) begin
			dif.dataout <= 0 ;
			dif.startout<= 0 ;
			dif.pushout <= 0 ;
		end
		else begin
			if(dif.pushin == 1) begin
				dif.startout <= startout_d ;
				dif.dataout  <= dataout_d ;
				dif.pushout  <= pushout_d ;
			end
		end
	end

	always@(*) begin
		if (dif.datain[8] == 1) begin
			startout_d = 0 ;
			//pushout_d  = 0 ;
		end
		else begin
		
			dataout_d = {1'b0,dif.datain[8:0]};
			startout_d = 1 ;
		end
	end
	initial begin
		count = 0 ;
		pushout_d = 0 ;
		#53
		for(int i = 0 ; i < 1 ; i ++)begin
			if (count == 0 ) begin
				pushout_d = 1 ;
				count = count + 1 ;
				$display("from design pusout %0d %0t", pushout_d,$time);
				#5 ;
				pushout_d = 0 ;
				$display("from design pusout %0d %0t", pushout_d,$time);
			end
			else begin
				pushout_d = 0 ;
				$display("from design ele pusout %0d %0t", pushout_d,$time);
			end
	end
	pushout_d = 0 ;
	$display("from design bahar pusout %0d %0t", pushout_d,$time);	
	end
endmodule

