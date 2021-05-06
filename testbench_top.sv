`include "interface.sv"

package rushi ;
	import uvm_pkg :: * ;
	`include "sequence_item.sv"
	`include "my_sequence.sv"
	`include "my_sequencer.sv"
	`include "my_driver.sv"
	`include "my_moniter.sv"
	`include "my_agent.sv"
	`include "my_scoreboard.sv"
	`include "my_env.sv"
	`include "my_test.sv"
endpackage

module top();
	import uvm_pkg :: * ;
	logic clk ;
	logic reset ;

	intf int_f(clk,reset); //interface
	dut  du(.dif(int_f)); //DUT_interface

	initial begin
		clk= 0 ;
		forever begin
			#5 clk =~clk ;
		end
	end

	initial begin
		reset = 1 ;
		#4 reset = 0 ;//for reset	
		
	end 

	initial begin
		uvm_config_db #(virtual intf) :: set(null,"db","int_f", int_f);
		run_test("my_test");
		end

	initial begin
		#500 $finish ;
	end

	initial begin
		$dumpfile("dump.vcd");
		$dumpvars;
	end
endmodule
`include "design.sv"
	


