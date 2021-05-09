

class my_driver extends uvm_driver #(my_sequence_item);
	`uvm_component_utils(my_driver)
	parameter logic [7:0] k28_1 = 8'h3C;
	parameter logic [7:0] k28_5 = 8'hBC;
	
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
				0 : strt(req);
				1 : err();
			endcase
			seq_item_port.item_done();
		end
	endtask

	virtual task strt(my_sequence_item req);
		this.vif.datain <= 9'b0;
		this.vif.pushin <= 1'b0 ;
		this.vif.datain_size <= req.datain_size ;
		//$display("size is %0d",req.datain_size);
		@(posedge (this.vif.clk));
		this.vif.startin <= 1'b1 ;
		this.vif.datain <= {1'b1,k28_1} ;
		this.vif.pushin<= 1'b1 ;
		@(posedge (this.vif.clk));
		this.vif.startin <= 1'b0  ;
		for(int i = 0 ; i <2; i++) begin
			//@(posedge (this.vif.clk));
			this.vif.datain <= {1'b1,k28_1} ;
			this.vif.pushin<= 1'b1 ;
			@(posedge (this.vif.clk));
			
		end
		//for(int i = 0 ; i <req.datain.size();i++) begin
			@(posedge (this.vif.clk));
			this.vif.datain <= {req.cntr,req.datain[0]};
			//@(this.vif.clk);
		//end
       		`uvm_info("DRIVER","Sending packet to scoreboard",UVM_NONE)
		trans_out.write(req);	
		@(posedge (this.vif.clk));			
		this.vif.datain <= {1'b1,k28_5} ;
		//@(this.vif.clk);
		for(int i = 0 ; i <10 ;i++) begin
			@(posedge(this.vif.clk));
			this.vif.pushin <= 1'b0  ;
			//@(this.vif.clk);
		end
			
	endtask

	virtual task err();
	
	endtask
			
		
	/*virtual task drive (my_sequence_item req);
		@(this.vif.driver_cb);
			this.vif.driver_cb.datain <= req.datain ;
		this.vif.driver_cb.pushin <= 1'b1 ;
		this.vif.driver_cb.startin <= 1'b1 ;
			
	endtask*/
endclass
			

	
