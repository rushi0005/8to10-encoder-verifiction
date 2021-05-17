//--------------------------------------------------------------------------------------------------//
//---------------This is Interface for 8to10 bit encoder--------------------------------------------//
//--------------------------------------------------------------------------------------------------//

interface intf(input logic clk, input logic reset);

	logic       pushin   ;// signal indiction data is present for encoding
	logic [8:0] datain   ;// Input data to DUT
	logic       startin  ;// Indicate 1st data is 28.1
	logic       pushout  ;// Output of DUT
	logic [9:0] dataout  ;// Output 10 bit data
	logic       startout ;// output


endinterface 
