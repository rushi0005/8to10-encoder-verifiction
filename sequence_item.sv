class my_sequence_item extends uvm_sequence_item ;
	rand bit st ;
	rand bit [7:0] datain[]    ;
	bit cntr[] ;  

    bit pkt_rcvd_comp=0;   // 0 - Driver, 1 - Monitor
	bit    pushout ;
	bit [9:0] dataout[]     ;
	bit startout ;   



	function new (string name = "sequence_item");
		super.new(name);
	endfunction
	
	constraint a_b {st dist {0:= 80 , 1:=20};}
	constraint a_c {datain.size() inside {[8 : 12]};			
			foreach(datain[i])	
				if (i < 4)
					datain[i] == 8'd60 ;
				else if (i == datain.size -1)
					datain[i] == 8'd188 ;
				else 
					datain[i] != 8'd252 ;}
	function void post_randomize();
	
		foreach(datain[i]) begin	
			cntr = new[i + 1](cntr);
			if (datain[i] inside{ 8'd28 , 8'd60 , 8'd92 , 8'd124 , 8'd156, 8'd220 , 8'd247 ,8'd251 ,8'd253,8'd254, 8'd188 })
				cntr[i] = 1;
			else
				cntr[i] = 0 ;
			end
	endfunction			

	
	`uvm_object_utils_begin(my_sequence_item)
		`uvm_field_int( st,         UVM_ALL_ON)
		`uvm_field_array_int(dataout,     UVM_ALL_ON)
		`uvm_field_array_int(datain,UVM_ALL_ON)
	//	`uvm_field_int(cntr        ,UVM_ALL_ON)
		`uvm_field_int( pushout,         UVM_ALL_ON)
	`uvm_object_utils_end
endclass

