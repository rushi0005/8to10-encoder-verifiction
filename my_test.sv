
class my_test extends uvm_test ;
	`uvm_component_utils(my_test)

	function new(string name = "my_test", uvm_component parent);
		super.new(name,parent);
	endfunction

	my_env env ;
	my_sequence seq ;

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		env = my_env :: type_id :: create("env",this);
		seq = my_sequence :: type_id :: create("seq",this);
	endfunction

	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		seq.start(env.agn.sqr);
		phase.drop_objection(this);
	endtask
endclass
