//--------------------------------------------------------------------------------------------------//
//---------------This is Monitor class for 8to10 bit encoder----------------------------------------//
//--------------------------------------------------------------------------------------------------//

class my_monitor extends uvm_monitor  ;
	`uvm_component_utils(my_monitor)

	virtual intf vif ;
	
	uvm_analysis_port #(my_sequence_item) trans_out ;

	my_sequence_item res ;


    bit prev_startout = 0;

	function new (string name = "my_monitor", uvm_component parent);
		super.new(name,parent);
		trans_out = new ("trans_out",this);
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

            		if(vif.startout == 1) begin
            		  res = new();
              		  res.pkt_rcvd_comp = 1;
           		end

			if(vif.pushout == 1) begin
			    `uvm_info("Monitor",$psprintf("time %0t",$time),UVM_NONE);
			     res.dataout     = new[res.dataout.size() + 1](res.dataout);
			     res.dataout[res.dataout.size - 1]  = this.vif.dataout[9:0] ;
			    `uvm_info("Monitor",$psprintf("dataout from monitor %0h",this.res.dataout[res.dataout.size - 1]),UVM_NONE);
                	     prev_startout = 1'b1;
			end

            		if(vif.pushout == 0 && prev_startout == 1) begin
                		prev_startout = 0;
		        	trans_out.write(res);	
			       `uvm_info("Monitor",$psprintf("time %0t sending packet to scoreboaed",$time),UVM_NONE);
			       
            		end
		end
	endtask
	
	
endclass


