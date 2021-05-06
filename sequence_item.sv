class my_sequence_item extends uvm_sequence_item ;
	rand bit st ;
	rand bit [7:0] datain[]    ;
	rand bit [5:0] datain_size ;
	rand bit [2:0] data3b[] ;
	rand bit [4:0] data4b[] ;
	rand bit cntr ;  

    bit pkt_rcvd_comp=0;   // 0 - Driver, 1 - Monitor
	bit    pushout ;
	bit [9:0] dataout[]     ;
	bit startout ;   



	function new (string name = "sequence_item");
		super.new(name);
	endfunction
	
	constraint a_b {st dist {0:= 80 , 1:=20};}
	constraint a_c {datain.size() inside {[20:30]};
			data3b.size() == datain.size();
			data4b.size() == datain.size();
			datain_size   == datain.size() ;
			foreach(datain[i])
			if(cntr == 1)
				{datain[i] inside{8'd28,8'd60,8'd92,8'd124,8'd156,8'd220,8'd247,8'd251,8'd253,8'd254}};
			else
				{datain[i] == {data3b[i],data4b[i]}};}

	`uvm_object_utils_begin(my_sequence_item)
		`uvm_field_int( st,         UVM_ALL_ON)
		`uvm_field_array_int(dataout,     UVM_ALL_ON)
		`uvm_field_array_int(datain,UVM_ALL_ON)
		`uvm_field_int(datain_size, UVM_ALL_ON)
		`uvm_field_int(cntr        ,UVM_ALL_ON)
		`uvm_field_int( pushout,         UVM_ALL_ON)
	`uvm_object_utils_end
endclass

