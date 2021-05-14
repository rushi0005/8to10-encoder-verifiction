
class my_scoreboard extends uvm_scoreboard ;
	`uvm_component_utils(my_scoreboard)
	my_sequence_item res ;
	uvm_analysis_imp #(my_sequence_item, my_scoreboard) trans_in ;
	int diff ;
	bit [10:0] data_o[] ;
        virtual intf vif ;
        my_sequence_item drv_q[$];
        my_sequence_item mon_q[$];

	int temp ;
        bit[19:0] disparity_table [int];

	function new (string name = "my_scoreboard",uvm_component parent);
		super.new(name,parent);
       		generate_disparity_table();
		if(!uvm_config_db #(virtual intf) :: get(null,"db", "int_f",vif)) begin
			`uvm_fatal("Error in monitor", "monitor cannot get interface");
		end
	endfunction

	virtual	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		trans_in = new("trans_in",this);
		res = new();
	endfunction

	virtual task write(my_sequence_item pkt);
        if(pkt.pkt_rcvd_comp == 1'b1) begin
        	`uvm_info("SCBD","Mon Packet Received",UVM_NONE)
		pkt.print();
        	mon_q.push_back(pkt);
        end else begin
        	`uvm_info("SCBD","DRV Packet Received",UVM_NONE)
		ref_model_convert(pkt);
		pkt.print();
                drv_q.push_back(pkt);
            // ref model - convert raw data to encoded data from comparision
		    
        end
	endtask
	
    virtual function generate_disparity_table();
    // Generate the table for D-Values
    disparity_table[8'b000_00000] = {10'b100111_0100,10'b011000_1011};
    disparity_table[8'b000_00100] = {10'b110101_0100,10'b001010_1011};
    disparity_table[8'b001_00000] = {10'b100111_1001,10'b011000_1001};
    disparity_table[8'b001_00100] = {10'b110101_1001,10'b001010_1001};
    disparity_table[8'b010_00000] = {10'b100111_0101,10'b011000_0101};
    disparity_table[8'b010_00100] = {10'b110101_0101,10'b001010_0101};
    disparity_table[8'b011_00000] = {10'b100111_0011,10'b011000_1100};
    disparity_table[8'b011_00100] = {10'b110101_0011,10'b001010_1100};
    disparity_table[8'b100_00000] = {10'b100111_0010,10'b011000_1101};
    disparity_table[8'b100_00100] = {10'b110101_0010,10'b001010_1101};
    disparity_table[8'b101_00000] = {10'b100111_1010,10'b011000_1010};
    disparity_table[8'b101_00100] = {10'b110101_1010,10'b001010_1010};
    disparity_table[8'b110_00000] = {10'b100111_0110,10'b011000_0110};
    disparity_table[8'b110_00100] = {10'b110101_0110,10'b001010_0110};
    disparity_table[8'b111_00000] = {10'b100111_0001,10'b011000_1110};
    disparity_table[8'b111_00100] = {10'b110101_0001,10'b001010_1110};
    disparity_table[8'b000_00001] = {10'b011101_0100,10'b100010_1011};
    disparity_table[8'b000_00101] = {10'b101001_1011,10'b101001_0100};
    disparity_table[8'b001_00001] = {10'b011101_1001,10'b100010_1001};
    disparity_table[8'b001_00101] = {10'b101001_1001,10'b101001_1001};
    disparity_table[8'b010_00001] = {10'b011101_0101,10'b100010_0101};
    disparity_table[8'b010_00101] = {10'b101001_0101,10'b101001_0101};
    disparity_table[8'b011_00001] = {10'b011101_0011,10'b100010_1100};
    disparity_table[8'b011_00101] = {10'b101001_1100,10'b101001_0011};
    disparity_table[8'b100_00001] = {10'b011101_0010,10'b100010_1101};
    disparity_table[8'b100_00101] = {10'b101001_1101,10'b101001_0010};
    disparity_table[8'b101_00001] = {10'b011101_1010,10'b100010_1010};
    disparity_table[8'b101_00101] = {10'b101001_1010,10'b101001_1010};
    disparity_table[8'b110_00001] = {10'b011101_0110,10'b100010_0110};
    disparity_table[8'b110_00101] = {10'b101001_0110,10'b101001_0110};
    disparity_table[8'b111_00001] = {10'b011101_0001,10'b100010_1110};
    disparity_table[8'b111_00101] = {10'b101001_1110,10'b101001_0001};
    disparity_table[8'b000_00010] = {10'b101101_0100,10'b010010_1011};
    disparity_table[8'b000_00110] = {10'b011001_1011,10'b011001_0100};
    disparity_table[8'b001_00010] = {10'b101101_1001,10'b010010_1001};
    disparity_table[8'b001_00110] = {10'b011001_1001,10'b011001_1001};
    disparity_table[8'b010_00010] = {10'b101101_0101,10'b010010_0101};
    disparity_table[8'b010_00110] = {10'b011001_0101,10'b011001_0101};
    disparity_table[8'b011_00010] = {10'b101101_0011,10'b010010_1100};
    disparity_table[8'b011_00110] = {10'b011001_1100,10'b011001_0011};
    disparity_table[8'b100_00010] = {10'b101101_0010,10'b010010_1101};
    disparity_table[8'b100_00110] = {10'b011001_1101,10'b011001_0010};
    disparity_table[8'b101_00010] = {10'b101101_1010,10'b010010_1010};
    disparity_table[8'b101_00110] = {10'b011001_1010,10'b011001_1010};
    disparity_table[8'b110_00010] = {10'b101101_0110,10'b010010_0110};
    disparity_table[8'b110_00110] = {10'b011001_0110,10'b011001_0110};
    disparity_table[8'b111_00010] = {10'b101101_0001,10'b010010_1110};
    disparity_table[8'b111_00110] = {10'b011001_1110,10'b011001_0001};
    disparity_table[8'b000_00011] = {10'b110001_1011,10'b110001_0100};
    disparity_table[8'b000_00111] = {10'b111000_1011,10'b000111_0100};
    disparity_table[8'b001_00011] = {10'b110001_1001,10'b110001_1001};
    disparity_table[8'b001_00111] = {10'b111000_1001,10'b000111_1001};
    disparity_table[8'b010_00011] = {10'b110001_0101,10'b110001_0101};
    disparity_table[8'b010_00111] = {10'b111000_0101,10'b000111_0101};
    disparity_table[8'b011_00011] = {10'b110001_1100,10'b110001_0011};
    disparity_table[8'b011_00111] = {10'b111000_1100,10'b000111_0011};
    disparity_table[8'b100_00011] = {10'b110001_1101,10'b110001_0010};
    disparity_table[8'b100_00111] = {10'b111000_1101,10'b000111_0010};
    disparity_table[8'b101_00011] = {10'b110001_1010,10'b110001_1010};
    disparity_table[8'b101_00111] = {10'b111000_1010,10'b000111_1010};
    disparity_table[8'b110_00011] = {10'b110001_0110,10'b110001_0110};
    disparity_table[8'b110_00111] = {10'b111000_0110,10'b000111_0110};
    disparity_table[8'b111_00011] = {10'b110001_1110,10'b110001_0001};
    disparity_table[8'b111_00111] = {10'b111000_1110,10'b000111_0001};
    disparity_table[8'b000_01000] = {10'b111001_0100,10'b000110_1011};
    disparity_table[8'b000_01100] = {10'b001101_1011,10'b001101_0100};
    disparity_table[8'b001_01000] = {10'b111001_1001,10'b000110_1001};
    disparity_table[8'b001_01100] = {10'b001101_1001,10'b001101_1001};
    disparity_table[8'b010_01000] = {10'b111001_0101,10'b000110_0101};
    disparity_table[8'b010_01100] = {10'b001101_0101,10'b001101_0101};
    disparity_table[8'b011_01000] = {10'b111001_0011,10'b000110_1100};
    disparity_table[8'b011_01100] = {10'b001101_1100,10'b001101_0011};
    disparity_table[8'b100_01000] = {10'b111001_0010,10'b000110_1101};
    disparity_table[8'b100_01100] = {10'b001101_1101,10'b001101_0010};
    disparity_table[8'b101_01000] = {10'b111001_1010,10'b000110_1010};
    disparity_table[8'b101_01100] = {10'b001101_1010,10'b001101_1010};
    disparity_table[8'b110_01000] = {10'b111001_0110,10'b000110_0110};
    disparity_table[8'b110_01100] = {10'b001101_0110,10'b001101_0110};
    disparity_table[8'b111_01000] = {10'b111001_0001,10'b000110_1110};
    disparity_table[8'b111_01100] = {10'b001101_1110,10'b001101_0001};
    disparity_table[8'b000_01001] = {10'b100101_1011,10'b100101_0100};
    disparity_table[8'b000_01101] = {10'b101100_1011,10'b101100_0100};
    disparity_table[8'b001_01001] = {10'b100101_1001,10'b100101_1001};
    disparity_table[8'b001_01101] = {10'b101100_1001,10'b101100_1001};
    disparity_table[8'b010_01001] = {10'b100101_0101,10'b100101_0101};
    disparity_table[8'b010_01101] = {10'b101100_0101,10'b101100_0101};
    disparity_table[8'b011_01001] = {10'b100101_1100,10'b100101_0011};
    disparity_table[8'b011_01101] = {10'b101100_1100,10'b101100_0011};
    disparity_table[8'b100_01001] = {10'b100101_1101,10'b100101_0010};
    disparity_table[8'b100_01101] = {10'b101100_1101,10'b101100_0010};
    disparity_table[8'b101_01001] = {10'b100101_1010,10'b100101_1010};
    disparity_table[8'b101_01101] = {10'b101100_1010,10'b101100_1010};
    disparity_table[8'b110_01001] = {10'b100101_0110,10'b100101_0110};
    disparity_table[8'b110_01101] = {10'b101100_0110,10'b101100_0110};
    disparity_table[8'b111_01001] = {10'b100101_1110,10'b100101_0001};
    disparity_table[8'b111_01101] = {10'b101100_1110,10'b101100_1000};
    disparity_table[8'b000_01010] = {10'b010101_1011,10'b010101_0100};
    disparity_table[8'b000_01110] = {10'b011100_1011,10'b011100_0100};
    disparity_table[8'b001_01010] = {10'b010101_1001,10'b010101_1001};
    disparity_table[8'b001_01110] = {10'b011100_1001,10'b011100_1001};
    disparity_table[8'b010_01010] = {10'b010101_0101,10'b010101_0101};
    disparity_table[8'b010_01110] = {10'b011100_0101,10'b011100_0101};
    disparity_table[8'b011_01010] = {10'b010101_1100,10'b010101_0011};
    disparity_table[8'b011_01110] = {10'b011100_1100,10'b011100_0011};
    disparity_table[8'b100_01010] = {10'b010101_1101,10'b010101_0010};
    disparity_table[8'b100_01110] = {10'b011100_1101,10'b011100_0010};
    disparity_table[8'b101_01010] = {10'b010101_1010,10'b010101_1010};
    disparity_table[8'b101_01110] = {10'b011100_1010,10'b011100_1010};
    disparity_table[8'b110_01010] = {10'b010101_0110,10'b010101_0110};
    disparity_table[8'b110_01110] = {10'b011100_0110,10'b011100_0110};
    disparity_table[8'b111_01010] = {10'b010101_1110,10'b010101_0001};
    disparity_table[8'b111_01110] = {10'b011100_1110,10'b011100_1000};
    disparity_table[8'b000_01011] = {10'b110100_1011,10'b110100_0100};
    disparity_table[8'b000_01111] = {10'b010111_0100,10'b101000_1011};
    disparity_table[8'b001_01011] = {10'b110100_1001,10'b110100_1001};
    disparity_table[8'b001_01111] = {10'b010111_1001,10'b101000_1001};
    disparity_table[8'b010_01011] = {10'b110100_0101,10'b110100_0101};
    disparity_table[8'b010_01111] = {10'b010111_0101,10'b101000_0101};
    disparity_table[8'b011_01011] = {10'b110100_1100,10'b110100_0011};
    disparity_table[8'b011_01111] = {10'b010111_0011,10'b101000_1100};
    disparity_table[8'b100_01011] = {10'b110100_1101,10'b110100_0010};
    disparity_table[8'b100_01111] = {10'b010111_0010,10'b101000_1101};
    disparity_table[8'b101_01011] = {10'b110100_1010,10'b110100_1010};
    disparity_table[8'b101_01111] = {10'b010111_1010,10'b101000_1010};
    disparity_table[8'b110_01011] = {10'b110100_0110,10'b110100_0110};
    disparity_table[8'b110_01111] = {10'b010111_0110,10'b101000_0110};
    disparity_table[8'b111_01011] = {10'b110100_1110,10'b110100_1000};
    disparity_table[8'b111_01111] = {10'b010111_0001,10'b101000_1110};
    disparity_table[8'b000_10000] = {10'b011011_0100,10'b100100_1011};
    disparity_table[8'b000_10100] = {10'b001011_1011,10'b001011_0100};
    disparity_table[8'b001_10000] = {10'b011011_1001,10'b100100_1001};
    disparity_table[8'b001_10100] = {10'b001011_1001,10'b001011_1001};
    disparity_table[8'b010_10000] = {10'b011011_0101,10'b100100_0101};
    disparity_table[8'b010_10100] = {10'b001011_0101,10'b001011_0101};
    disparity_table[8'b011_10000] = {10'b011011_0011,10'b100100_1100};
    disparity_table[8'b011_10100] = {10'b001011_1100,10'b001011_0011};
    disparity_table[8'b100_10000] = {10'b011011_0010,10'b100100_1101};
    disparity_table[8'b100_10100] = {10'b001011_1101,10'b001011_0010};
    disparity_table[8'b101_10000] = {10'b011011_1010,10'b100100_1010};
    disparity_table[8'b101_10100] = {10'b001011_1010,10'b001011_1010};
    disparity_table[8'b110_10000] = {10'b011011_0110,10'b100100_0110};
    disparity_table[8'b110_10100] = {10'b001011_0110,10'b001011_0110};
    disparity_table[8'b111_10000] = {10'b011011_0001,10'b100100_1110};
    disparity_table[8'b111_10100] = {10'b001011_0111,10'b001011_0001};
    disparity_table[8'b000_10001] = {10'b100011_1011,10'b100011_0100};
    disparity_table[8'b000_10101] = {10'b101010_1011,10'b101010_0100};
    disparity_table[8'b001_10001] = {10'b100011_1001,10'b100011_1001};
    disparity_table[8'b001_10101] = {10'b101010_1001,10'b101010_1001};
    disparity_table[8'b010_10001] = {10'b100011_0101,10'b100011_0101};
    disparity_table[8'b010_10101] = {10'b101010_0101,10'b101010_0101};
    disparity_table[8'b011_10001] = {10'b100011_1100,10'b100011_0011};
    disparity_table[8'b011_10101] = {10'b101010_1100,10'b101010_0011};
    disparity_table[8'b100_10001] = {10'b100011_1101,10'b100011_0010};
    disparity_table[8'b100_10101] = {10'b101010_1101,10'b101010_0010};
    disparity_table[8'b101_10001] = {10'b100011_1010,10'b100011_1010};
    disparity_table[8'b101_10101] = {10'b101010_1010,10'b101010_1010};
    disparity_table[8'b110_10001] = {10'b100011_0110,10'b100011_0110};
    disparity_table[8'b110_10101] = {10'b101010_0110,10'b101010_0110};
    disparity_table[8'b111_10001] = {10'b100011_0111,10'b100011_0001};
    disparity_table[8'b111_10101] = {10'b101010_1110,10'b101010_0001};
    disparity_table[8'b000_10010] = {10'b010011_1011,10'b010011_0100};
    disparity_table[8'b000_10110] = {10'b011010_1011,10'b011010_0100};
    disparity_table[8'b001_10010] = {10'b010011_1001,10'b010011_1001};
    disparity_table[8'b001_10110] = {10'b011010_1001,10'b011010_1001};
    disparity_table[8'b010_10010] = {10'b010011_0101,10'b010011_0101};
    disparity_table[8'b010_10110] = {10'b011010_0101,10'b011010_0101};
    disparity_table[8'b011_10010] = {10'b010011_1100,10'b010011_0011};
    disparity_table[8'b011_10110] = {10'b011010_1100,10'b011010_0011};
    disparity_table[8'b100_10010] = {10'b010011_1101,10'b010011_0010};
    disparity_table[8'b100_10110] = {10'b011010_1101,10'b011010_0010};
    disparity_table[8'b101_10010] = {10'b010011_1010,10'b010011_1010};
    disparity_table[8'b101_10110] = {10'b011010_1010,10'b011010_1010};
    disparity_table[8'b110_10010] = {10'b010011_0110,10'b010011_0110};
    disparity_table[8'b110_10110] = {10'b011010_0110,10'b011010_0110};
    disparity_table[8'b111_10010] = {10'b010011_0111,10'b010011_0001};
    disparity_table[8'b111_10110] = {10'b011010_1110,10'b011010_0001};
    disparity_table[8'b000_10011] = {10'b110010_1011,10'b110010_0100};
    disparity_table[8'b000_10111] = {10'b111010_0100,10'b000101_1011};
    disparity_table[8'b001_10011] = {10'b110010_1001,10'b110010_1001};
    disparity_table[8'b001_10111] = {10'b111010_1001,10'b000101_1001};
    disparity_table[8'b010_10011] = {10'b110010_0101,10'b110010_0101};
    disparity_table[8'b010_10111] = {10'b111010_0101,10'b000101_0101};
    disparity_table[8'b011_10011] = {10'b110010_1100,10'b110010_0011};
    disparity_table[8'b011_10111] = {10'b111010_0011,10'b000101_1100};
    disparity_table[8'b100_10011] = {10'b110010_1101,10'b110010_0010};
    disparity_table[8'b100_10111] = {10'b111010_0010,10'b000101_1101};
    disparity_table[8'b101_10011] = {10'b110010_1010,10'b110010_1010};
    disparity_table[8'b101_10111] = {10'b111010_1010,10'b000101_1010};
    disparity_table[8'b110_10011] = {10'b110010_0110,10'b110010_0110};
    disparity_table[8'b110_10111] = {10'b111010_0110,10'b000101_0110};
    disparity_table[8'b111_10011] = {10'b110010_1110,10'b110010_0001};
    disparity_table[8'b111_10111] = {10'b111010_0001,10'b000101_1110};
    disparity_table[8'b000_11000] = {10'b110011_0100,10'b001100_1011};
    disparity_table[8'b000_11100] = {10'b001110_1011,10'b001110_0100};
    disparity_table[8'b001_11000] = {10'b110011_1001,10'b001100_1001};
    disparity_table[8'b001_11100] = {10'b001110_1001,10'b001110_1001};
    disparity_table[8'b010_11000] = {10'b110011_0101,10'b001100_0101};
    disparity_table[8'b010_11100] = {10'b001110_0101,10'b001110_0101};
    disparity_table[8'b011_11000] = {10'b110011_0011,10'b001100_1100};
    disparity_table[8'b011_11100] = {10'b001110_1100,10'b001110_0011};
    disparity_table[8'b100_11000] = {10'b110011_0010,10'b001100_1101};
    disparity_table[8'b100_11100] = {10'b001110_1101,10'b001110_0010};
    disparity_table[8'b101_11000] = {10'b110011_1010,10'b001100_1010};
    disparity_table[8'b101_11100] = {10'b001110_1010,10'b001110_1010};
    disparity_table[8'b110_11000] = {10'b110011_0110,10'b001100_0110};
    disparity_table[8'b110_11100] = {10'b001110_0110,10'b001110_0110};
    disparity_table[8'b111_11000] = {10'b110011_0001,10'b001100_1110};
    disparity_table[8'b111_11100] = {10'b001110_1110,10'b001110_0001};
    disparity_table[8'b000_11001] = {10'b100110_1011,10'b100110_0100};
    disparity_table[8'b000_11101] = {10'b101110_0100,10'b010001_1011};
    disparity_table[8'b001_11001] = {10'b100110_1001,10'b100110_1001};
    disparity_table[8'b001_11101] = {10'b101110_1001,10'b010001_1001};
    disparity_table[8'b010_11001] = {10'b100110_0101,10'b100110_0101};
    disparity_table[8'b010_11101] = {10'b101110_0101,10'b010001_0101};
    disparity_table[8'b011_11001] = {10'b100110_1100,10'b100110_0011};
    disparity_table[8'b011_11101] = {10'b101110_0011,10'b010001_1100};
    disparity_table[8'b100_11001] = {10'b100110_1101,10'b100110_0010};
    disparity_table[8'b100_11101] = {10'b101110_0010,10'b010001_1101};
    disparity_table[8'b101_11001] = {10'b100110_1010,10'b100110_1010};
    disparity_table[8'b101_11101] = {10'b101110_1010,10'b010001_1010};
    disparity_table[8'b110_11001] = {10'b100110_0110,10'b100110_0110};
    disparity_table[8'b110_11101] = {10'b101110_0110,10'b010001_0110};
    disparity_table[8'b111_11001] = {10'b100110_1110,10'b100110_0001};
    disparity_table[8'b111_11101] = {10'b101110_0001,10'b010001_1110};
    disparity_table[8'b000_11010] = {10'b010110_1011,10'b010110_0100};
    disparity_table[8'b000_11110] = {10'b011110_0100,10'b100001_1011};
    disparity_table[8'b001_11010] = {10'b010110_1001,10'b010110_1001};
    disparity_table[8'b001_11110] = {10'b011110_1001,10'b100001_1001};
    disparity_table[8'b010_11010] = {10'b010110_0101,10'b010110_0101};
    disparity_table[8'b010_11110] = {10'b011110_0101,10'b100001_0101};
    disparity_table[8'b011_11010] = {10'b010110_1100,10'b010110_0011};
    disparity_table[8'b011_11110] = {10'b011110_0011,10'b100001_1100};
    disparity_table[8'b100_11010] = {10'b010110_1101,10'b010110_0010};
    disparity_table[8'b100_11110] = {10'b011110_0010,10'b100001_1101};
    disparity_table[8'b101_11010] = {10'b010110_1010,10'b010110_1010};
    disparity_table[8'b101_11110] = {10'b011110_1010,10'b100001_1010};
    disparity_table[8'b110_11010] = {10'b010110_0110,10'b010110_0110};
    disparity_table[8'b110_11110] = {10'b011110_0110,10'b100001_0110};
    disparity_table[8'b111_11010] = {10'b010110_1110,10'b010110_0001};
    disparity_table[8'b111_11110] = {10'b011110_0001,10'b100001_1110};
    disparity_table[8'b000_11011] = {10'b110110_0100,10'b001001_1011};
    disparity_table[8'b000_11111] = {10'b101011_0100,10'b010100_1011};
    disparity_table[8'b001_11011] = {10'b110110_1001,10'b001001_1001};
    disparity_table[8'b001_11111] = {10'b101011_1001,10'b010100_1001};
    disparity_table[8'b010_11011] = {10'b110110_0101,10'b001001_0101};
    disparity_table[8'b010_11111] = {10'b101011_0101,10'b010100_0101};
    disparity_table[8'b011_11011] = {10'b110110_0011,10'b001001_1100};
    disparity_table[8'b011_11111] = {10'b101011_0011,10'b010100_1100};
    disparity_table[8'b100_11011] = {10'b110110_0010,10'b001001_1101};
    disparity_table[8'b100_11111] = {10'b101011_0010,10'b010100_1101};
    disparity_table[8'b101_11011] = {10'b110110_1010,10'b001001_1010};
    disparity_table[8'b101_11111] = {10'b101011_1010,10'b010100_1010};
    disparity_table[8'b110_11011] = {10'b110110_0110,10'b001001_0110};
    disparity_table[8'b110_11111] = {10'b101011_0110,10'b010100_0110};
    disparity_table[8'b111_11011] = {10'b110110_0001,10'b001001_1110};
    disparity_table[8'b111_11111] = {10'b101011_0001,10'b010100_1110};
    //for control signals(K)
    disparity_table[8'b000_11100] = {10'b001111_0100, 10'b110000_1011};
    disparity_table[8'b001_11100] = {10'b001111_1001, 10'b110000_0110};
    disparity_table[8'b010_11100] = {10'b001111_0101, 10'b110000_1010};
    disparity_table[8'b011_11100] = {10'b001111_0011, 10'b110000_1100};
    disparity_table[8'b100_11100] = {10'b001111_0010, 10'b110000_1101};
    disparity_table[8'b101_11100] = {10'b001111_1010, 10'b110000_0101};
    disparity_table[8'b110_11100] = {10'b001111_0110, 10'b110000_1001};
    disparity_table[8'b111_11100] = {10'b001111_1000, 10'b110000_0111};
    disparity_table[8'b111_10111] = {10'b111010_1000, 10'b000101_0111};
    disparity_table[8'b111_11011] = {10'b110110_1000, 10'b001001_0111};
    disparity_table[8'b111_11101] = {10'b101110_1000, 10'b010001_0111};
    disparity_table[8'b111_11110] = {10'b011110_1000, 10'b100001_0111};
endfunction 

	virtual task ref_model_convert(my_sequence_item pkt);//disparity
        bit [19:0] encoded_data ;
        bit neg_disparity = 1;
	int ones,max,min;
        pkt.dataout = new[pkt.datain.size()];
	data_o      = new[pkt.datain.size()];

        for(int i=0;i<pkt.datain.size();i++)begin
            encoded_data = disparity_table[pkt.datain[i]];
		
            if(i==0) begin
		//max = 9+10*neg_disparity ;
		//min = 9*neg_disparity   ;
              data_o[i] = encoded_data[19:10];
            end 
	    else begin
	      if (neg_disparity == 1)
	      	data_o[i] = encoded_data[19:10];
	      else if (neg_disparity == 0)
		data_o[i] = encoded_data[9:0];
	      else begin end
	    end
	    diff = $countones(data_o[i]);
            if(diff != 5) begin
              `uvm_info("SCBD",$psprintf("Number of One's are not 5 = %b ",data_o[i]),UVM_NONE)
               neg_disparity = ~neg_disparity;
              `uvm_info("SCBD",$psprintf("Disparity flipped, New disparity is %0b",neg_disparity),UVM_NONE)
            end
	    else begin
		`uvm_info("SCBD",$psprintf("Number of One's are 5 = %b ",data_o[i]),UVM_NONE)
		 neg_disparity = neg_disparity ;
		`uvm_info("SCBD",$psprintf("Disparity remains same, New disparity is %0b",neg_disparity),UVM_NONE)
		end 
	
        end
	expt_data(pkt);
	endtask
	
	virtual task expt_data(my_sequence_item pkt);
			for(int i = 0 ; i <pkt.datain.size(); i ++) begin
				for(int j = 0 ; j<5 ; j++)begin
					int temp = data_o[i][j];
					pkt.dataout[i][j] = data_o[i][9-j];
					pkt.dataout[i][9-j]= temp ;	
				end
			$display("%0b ref %0b",pkt.dataout[i], data_o[i]);
			end

	endtask

    virtual task compare_data();
      my_sequence_item drv_pkt,mon_pkt;
      while(1) begin
	  @(posedge this.vif.clk);
          		if(drv_q.size() >0 && mon_q.size() >0) begin
            			drv_pkt = drv_q.pop_front();
            			mon_pkt = mon_q.pop_front();
				//$display("drive %0d",drv_q.size());
	   			for(int i = 0 ; i <drv_pkt.dataout.size();i++)begin  
						if(drv_pkt.dataout[i] == mon_pkt.dataout[i])
							`uvm_info("scoreboard",$sformatf("pkt passed got = %0b and expected = %b",mon_pkt.dataout[i],drv_pkt.dataout[i]),UVM_LOW)

						else begin
							`uvm_error("scoreboard",$sformatf("pkt failed got = %0b and expected = %0b",mon_pkt.dataout[i],drv_pkt.dataout[i]))
						end
					   end
					end
			else
					`uvm_info("scoreboard",$sformatf("size mismatch mon size = %0d  = drv %0d",mon_q.size(),drv_q.size()), UVM_NONE)


      end
        
    endtask

	virtual task run_phase(uvm_phase phase);
		super.run_phase(phase);
		forever begin
			@(posedge this.vif.clk);
			compare_data();
		end
	endtask

endclass
