class my_monitor_crc_out extends uvm_monitor  ;
	`uvm_component_utils(my_monitor_crc_out)

	virtual intf vif ;
	
	uvm_analysis_port #(my_monitor_crc_out_message) mon_out_msg_port ;
	my_monitor_crc_out_message mon_out_msg;

	//my_monitor_crc_in_message res ;


    //bit prev_startout = 0;

	function new (string name = "my_monitor_crc_out", uvm_component parent);
		super.new(name,parent);
		mon_out_msg_port = new ("mon_out_msg_port",this);
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
			mon_out_msg = new();
			mon_out_msg.pushout = vif.pushout;
			mon_out_msg.dataout = vif.dataout;
			mon_out_msg.startout = vif.startout;
			mon_out_msg_port.write(mon_out_msg);
                        end
		end
	endtask
	
	
endclass
