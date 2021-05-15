class my_scoreboard_crc_comb extends uvm_scoreboard ; //check crc
	`uvm_component_utils(my_scoreboard_crc_comb)

	uvm_tlm_analysis_fifo #(my_monitor_crc_out_message) mon_out_port_sbc_comb;
	uvm_analysis_port #(crc_output_packet) crc_out_port;

	my_monitor_crc_out_message mon_out;
	crc_output_packet crc_packet;

	virtual intf vif ;
	logic [1:0] start = 0;

	function new (string name = "my_scoreboard_crc_comb",uvm_component parent);
		super.new(name,parent);
       		//generate_disparity_table();
		if(!uvm_config_db #(virtual intf) :: get(null,"db", "int_f",vif)) begin
			`uvm_fatal("Error in monitor", "monitor cannot get interface");
		end
	endfunction

	function void build_phase(uvm_phase phase);
		mon_out_port_sbc_comb=new("mon_out_port",this);
		crc_out_port=new("crc_out_port",this);
	endfunction : build_phase

	virtual task run_phase(uvm_phase phase);
		super.run_phase(phase);
		forever begin
			@(posedge this.vif.clk);
			mon_out = new();
			crc_packet = new();
			mon_out_port_sbc_comb.get(mon_out);
			if((mon_out.pushout == 1) && (mon_out.dataout  )) begin // fill the code  before crc comes out
				case (start)
					2'b00: begin
						crc_packet.crc_out [9:0] = mon_out.dataout;
						start = 2'b01;
					end
					2'b01: begin
						crc_packet.crc_out [19:10] = mon_out.dataout;
						start = 2'b10;
					end
					2'b10: begin
						crc_packet.crc_out [29:20] = mon_out.dataout;
						start = 2'b11;
					end
					2'b11: begin
						crc_packet.crc_out [39:20] = mon_out.dataout;
						start = 2'b00;
					end	
				endcase
				
				crc_out_port.write(crc_packet);
			end

		end
	endtask

endclass : my_scoreboard_crc_comb

