
class my_agent extends uvm_agent;
	`uvm_component_utils(my_agent)

	my_driver drv ;
	my_sequencer sqr ;
	my_monitor   mon ;

	function new(string name = "my_agent", uvm_component parent);
		super.new(name,parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		drv = my_driver :: type_id :: create("drv",this);
		sqr = my_sequencer :: type_id :: create ("sqr",this);
		mon = my_monitor   :: type_id :: create("mon",this);
	endfunction

	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		drv.seq_item_port.connect(sqr.seq_item_export);
	endfunction

endclass
