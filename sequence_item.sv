//--------------------------------------------------------------------------------------------------//
//---------------This is sequence item class for 8to10 bit encoder----------------------------------//
//--------------------------------------------------------------------------------------------------//



class my_sequence_item extends uvm_sequence_item ;
	rand bit st                ;   // 0 - drive k signal in between datain
	rand bit [7:0] datain[]    ;   // input data
	bit cntr[]                 ;   // 9th bit of datain, control signal 1 - ksignal

    	bit pkt_rcvd_comp=0        ;   // 0 - Driver, 1 - Monitor
	bit    pushout             ;   // output pushout 
	bit [9:0] dataout[]        ;   // 10 bit dynamic array
	bit startout               ;   // output startout



	function new (string name = "sequence_item");
		super.new(name);
	endfunction
	
	constraint a_b {st dist {0:= 60 , 1:=40};}
	constraint a_c {datain.size() inside {[8:12]};			
			foreach(datain[i])	
				if (i < 4)                     
					datain[i] == 8'd60 ;
				else if (i == datain.size -1)
					datain[i] == 8'd188 ;
				else datain[i] inside{8'd0 ,8'd255};}
	
	`uvm_object_utils_begin(my_sequence_item)
		`uvm_field_int( st,         UVM_ALL_ON)
		`uvm_field_array_int(dataout,     UVM_ALL_ON)
		`uvm_field_array_int(datain,UVM_ALL_ON)
	`uvm_object_utils_end
endclass

