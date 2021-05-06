
class my_env extends uvm_env ;
	`uvm_component_utils(my_env);

	my_agent agn ;
	my_scoreboard scb ;
	function new (string name = "",uvm_component parent);
		super.new(name,parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		agn = my_agent :: type_id :: create("agn",this);
		scb = my_scoreboard :: type_id :: create("scb",this);
	endfunction

	 virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		agn.mon.trans_out.connect(scb.trans_in);
		agn.drv.trans_out.connect(scb.trans_in);
	endfunction
	
	virtual function void end_of_elaboration_phase(uvm_phase phase) ;
		uvm_top.print_topology();
	endfunction
endclass
