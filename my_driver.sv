//--------------------------------------------------------------------------------------------------//
//---------------This is Driver class for 8to10 bit encoder-----------------------------------------//
//--------------------------------------------------------------------------------------------------//

class my_driver extends uvm_driver #(my_sequence_item);
	`uvm_component_utils(my_driver)
	
	virtual intf vif ;

	uvm_analysis_port #(my_sequence_item) trans_out ;

	function new (string name = "my_driver", uvm_component parent);
		super.new(name,parent);
		trans_out = new ("trans_out",this);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(virtual intf) :: get(null,"db", "int_f",vif)) begin
			`uvm_fatal("Error in driver", "driver cannot get interface");
		end
	endfunction

	virtual task run_phase(uvm_phase phase);
		super.run_phase(phase);
		
		forever begin
			my_sequence_item req ;
			seq_item_port.get_next_item(req);
            `uvm_info("DRIVER","Received packet to driver",UVM_NONE)
            req.print();
			case (req.st)
				0 : drv_k(req); //drive k signal in between data
				1 : drv_d(req); //drive only data signal	
			endcase
			seq_item_port.item_done();
		end
	endtask
	
	virtual task drv_k(my_sequence_item req);
		
		foreach(req.datain[i]) begin	
			req.cntr = new[i + 1](req.cntr);
			if (req.datain[i] inside{ 8'd28 ,8'd60 , 8'd92 , 8'd124 , 8'd156, 8'd220 , 8'd247 ,8'd251 ,8'd253,8'd254, 8'd188 })
				req.cntr[i] = 1;
			else
				req.cntr[i] = 0 ;
			end
		data(req);
	endtask

	virtual task drv_d(my_sequence_item req);
			
		foreach(req.datain[i]) begin	
			req.cntr = new[i + 1](req.cntr);
			if (req.datain[i] inside{ 8'd60 , 8'd188 })
				req.cntr[i] = 1;
			else
				req.cntr[i] = 0 ;
			end
		data(req);
	endtask

	virtual task data(my_sequence_item req);
		this.vif.datain <= 9'b0;
		this.vif.pushin <= 1'b0 ;
		this.vif.startin <= 1'b0 ;
		@(posedge (this.vif.clk));
		this.vif.startin <= 1'b1 ;
		this.vif.pushin<= 1'b1 ;

		for(int i = 0 ; i <req.datain.size();i++) begin
			this.vif.datain <= {req.cntr[i],req.datain[i]};
			$display("datain[8] %0d datain[7:0] is %0d", req.cntr[i],req.datain[i]);
			@(posedge (this.vif.clk));
			this.vif.startin <= 1'b0 ;
		end

       		`uvm_info("DRIVER","Sending packet to scoreboard",UVM_NONE)
		trans_out.write(req);	
		for(int i = 0 ; i <9 ;i++) begin
			this.vif.pushin <= 1'b0  ;
			@(posedge(this.vif.clk));
		end
	endtask		
		
	
endclass
			

	
