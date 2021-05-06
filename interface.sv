
interface intf(input logic clk, input logic reset);

	logic       pushin   ;// signal indiction data is present for encoding
	logic [8:0] datain   ;// 
	logic       startin  ;//
	logic       pushout  ;//
	logic [9:0] dataout  ;//
	logic       startout ;//
	logic [4:0] datain_size ;

/*
	clocking driver_cb @(posedge clk);
		output pushout , dataout, startout;
		input pushin,  datain,   startin ;
	endclocking

	clocking dut_cb     @(posedge clk );
		input  pushin,  datain,   startin ;
		output pushout, dataout, startout ;
	endclocking

	clocking monitor_cb @(posedge clk );
		input pushout , dataout, startout, pushin,  datain,   startin ;
	endclocking

	modport driver (clocking driver_cb);
	modport dut    (clocking dut_cb);
	modport monitor(clocking monitor_cb);*/

endinterface 
