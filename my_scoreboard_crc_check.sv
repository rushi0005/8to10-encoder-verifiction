class my_scoreboard_crc_check extends uvm_scoreboard ; //check crc
	`uvm_component_utils(my_scoreboard_crc_check)

		uvm_tlm_analysis_fifo #(crc_output_packet) crc_out_port_sbc_1;
		uvm_tlm_analysis_fifo #(crc_output_packet) crc_in_port_sbc;

		crc_output_packet crc_out_sbc;
		crc_output_packet crc_in_sbc;

		virtual intf vif ;

	function new (string name = "my_scoreboard_crc_check",uvm_component parent);
		super.new(name,parent);
       		//generate_disparity_table();
		if(!uvm_config_db #(virtual intf) :: get(null,"db", "int_f",vif)) begin
			`uvm_fatal("Error in monitor", "monitor cannot get interface");
		end
	endfunction

	function void build_phase(uvm_phase phase);
		crc_out_port_sbc_1=new("crc_out_port_sbc_1",this);
		crc_in_port_sbc=new("crc_in_port_sbc",this);
	endfunction : build_phase

	virtual task run_phase(uvm_phase phase);
		super.run_phase(phase);
		forever begin
			@(posedge this.vif.clk);
			crc_out_port_sbc_1.get(crc_out_sbc);	
			crc_in_port_sbc.get(crc_in_sbc);
			if (crc_out_sbc.crc_out == crc_in_sbc.crc_out) begin
				`uvm_info("scoreboard_crc_checker",$sformatf("The crc matches! Well done guys!"),UVM_MEDIUM)	
			end
			else begin
				`uvm_info("scoreboard_crc_checker",$sformatf("crc needs work! Keep Hustling!"),UVM_MEDIUM)
			end

		end
	endtask

endclass : my_scoreboard_crc_check

