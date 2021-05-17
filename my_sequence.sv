//--------------------------------------------------------------------------------------------------//
//---------------This is sequence class for 8to10 bit encoder---------------------------------------//
//--------------------------------------------------------------------------------------------------//

class my_sequence extends uvm_sequence #(my_sequence_item) ;
	`uvm_object_utils(my_sequence)
	my_sequence_item req ;

	function new(string name = "my_sequence");
		super.new(name);
	endfunction

	virtual task body() ;
		repeat(16) begin
			req = my_sequence_item :: type_id :: create("req");
			wait_for_grant();
			req.randomize();
			send_request(req);
			wait_for_item_done();
		end
	endtask
endclass
			
