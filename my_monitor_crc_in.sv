

class my_monitor_crc_in extends uvm_monitor  ;
	`uvm_component_utils(my_monitor_crc_in)

	virtual intf vif ;
	
	uvm_analysis_port #(my_monitor_crc_in_message) mon_in_msg_port ;
	my_monitor_crc_in_message mon_in_msg;

	//my_monitor_crc_in_message res ;


    //bit prev_startout = 0;

	function new (string name = "my_monitor_crc_in", uvm_component parent);
		super.new(name,parent);
		mon_in_msg_port = new ("mon_in_msg_port",this);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		
		if(!uvm_config_db #(virtual intf) :: get(null,"db", "int_f",vif)) begin
			`uvm_fatal("Error in monitor", "monitor cannot get interface");
		end		
	endfunction
	
	virtual task run_phase(uvm_phase phase);
		super.run_phase(phase);
			    `uvm_info("Monitor",$psprintf("time %0t",$time),UVM_NONE);
		
		forever begin			
			@(posedge this.vif.clk);
            		if(!vif.reset)	begin
			mon_in_msg = new();
			mon_in_msg.pushin = vif.pushin;
			mon_in_msg.datain = vif.datain;
			mon_in_msg.startin = vif.startin;
			mon_in_msg_port.write(mon_in_msg);
                        end
		end
	endtask
	
	
endclass


