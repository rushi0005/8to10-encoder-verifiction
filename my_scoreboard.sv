//--------------------------------------------------------------------------------------------------//
//---------------This is scoreboard class for 8to10 bit encoder-------------------------------------//
//--------------------------------------------------------------------------------------------------//

class my_scoreboard extends uvm_scoreboard ;
	`uvm_component_utils(my_scoreboard)

	my_sequence_item res ;
	virtual intf vif     ;

	uvm_analysis_imp #(my_sequence_item, my_scoreboard) trans_in ;
	
	bit[19:0] disparity_table [int]  ;   //Used in reference model to get output data signal
	bit[19:0] disparity_table_k [int];   //Used in reference model to get output k signal
       
	bit[31:0] crc_out                ;   //32 bit output of CRC
	
	bit [10:0] data_o[]              ;   //dynamic array to store encoded output 
        
        my_sequence_item drv_q[$]        ;   //output from DRV will be stored in this queue
        my_sequence_item mon_q[$]        ;   //output from DUT will be stored in this queue
	
	int crc_out                      ;   //32 bit output of CRC
	int diff                         ;   //used to count no. ones in disparity
	int temp                         ;
        

	function new (string name = "my_scoreboard",uvm_component parent);
		super.new(name,parent)       ;
       		generate_disparity_table()   ;
		generate_disparity_table_k() ;

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
        	end
		else begin
        		`uvm_info("SCBD","DRV Packet Received",UVM_NONE)
			ref_model_convert(pkt);  // ref model - convert raw data to encoded data from comparision
			pkt.print();
                	drv_q.push_back(pkt);
           
		    
       		end
	endtask
	

	virtual task ref_model_convert(my_sequence_item pkt);          //disparity & ENcoding task

        	bit [19:0] encoded_data ;
        	bit neg_disparity = 1;
		int ones,max,min;
		
		int datain_size;
        	pkt.dataout = new[pkt.datain.size()+5];
		data_o      = new[pkt.datain.size()+5];
 		
		calculate_crc(pkt,crc_out);                             //  task cal crc function
		datain_size = pkt.datain.size();                        //  localvariable me original size 
		
		pkt.datain[datain_size-1]= 8'd247;
		pkt.cntr[datain_size-1]	= 1'b1 ;
		pkt.cntr =   new[datain_size + 5](pkt.cntr);
		pkt.datain = new[datain_size + 5](pkt.datain);	       // resize pkt.datain array 
        	pkt.datain[datain_size ] = crc_out[7:0];               // putting 8 bit value of CRC for ENcoding in datain
		pkt.datain[datain_size + 1] = crc_out[15:8];	       // putting 8 bit value of CRC for ENcoding in datain
		pkt.datain[datain_size + 2] = crc_out[23:16];          // putting 8 bit value of CRC for ENcoding in datain
		pkt.datain[datain_size + 3] = crc_out[31:24];          // putting 8 bit value of CRC for ENcoding in datain
		pkt.datain[datain_size + 4] = 8'b101_11100;            // 28.5 for ENcoding
		pkt.cntr[datain_size] = 1'b0 ;
		pkt.cntr[datain_size +1] = 1'b0 ;
		pkt.cntr[datain_size +2] = 1'b0 ;
		pkt.cntr[datain_size +3] = 1'b0 ;
		pkt.cntr[datain_size +4] = 1'b1;

        	for(int i=0;i<pkt.datain.size();i++)begin

			if(pkt.cntr[i] == 0)
            			encoded_data = disparity_table[pkt.datain[i]];
			else begin
				encoded_data = disparity_table_k[pkt.datain[i]];
			end

            		if(i==0) begin
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
	
	virtual task expt_data(my_sequence_item pkt);                      //Inverting ENcoded output and storing it in dataout
			
			for(int i = 0 ; i <pkt.datain.size(); i ++) begin  
				for(int j = 0 ; j<5 ; j++)begin
					int temp = data_o[i][j];
					pkt.dataout[i][j] = data_o[i][9-j];
					pkt.dataout[i][9-j]= temp ;	
				end
			end
	endtask

        virtual task compare_data();                                      //Comparing data of reference model and DUT
        	my_sequence_item drv_pkt,mon_pkt;
        	while(1) begin
	  		@(posedge this.vif.clk);
          		if(drv_q.size() >0 && mon_q.size() >0) begin
            			drv_pkt = drv_q.pop_front();
            			mon_pkt = mon_q.pop_front();
	   			for(int i = 0 ; i <drv_pkt.dataout.size();i++)begin  
						if(drv_pkt.dataout[i] == mon_pkt.dataout[i])
							`uvm_info("scoreboard",$sformatf("pkt passed got = %0b and expected = %b", mon_pkt.dataout[i], drv_pkt.dataout[i]), UVM_LOW)

						else begin
							`uvm_error("scoreboard",$sformatf("pkt failed got = %0b and expected = %0b", mon_pkt.dataout[i],drv_pkt.dataout[i]))
						end
					   end
					end
			else
					`uvm_info("scoreboard",$sformatf("NO data in Queue mon size = %0d  = drv %0d",mon_q.size(),drv_q.size()), UVM_NONE)


        	end
        endtask

	virtual task run_phase(uvm_phase phase);
		super.run_phase(phase);
		forever begin
			@(posedge this.vif.clk);
			compare_data();
		end
	endtask

 
       task calculate_crc(my_sequence_item pkt,output bit [31:0] crc_out);    //Task to calculate CRC
       
       bit [31:0] crc_out;
       bit [31:0] intr_crc = 32'hFFFF_FFFF;
     

       for ( int i =0 ;i<pkt.datain.size();i++)begin
		if(pkt.cntr[i] == 0) begin
           		intr_crc = (intr_crc >> 8) ^ crc_table(pkt.datain[i] ^ intr_crc[7:0]); 
			//crc_out = ~intr_crc ;
        	end
		else
			intr_crc = intr_crc ;
		 //crc_out = ~intr_crc;
           end 
    		crc_out = ~intr_crc;
      endtask 


      function bit[31:0] crc_table(bit[7:0] datain);
      	 bit [31:0] cal_crc ;
      	 case(datain)
	        8'd0   : cal_crc = 32'h0;
	        8'd1   : cal_crc = 32'h77073096;
	        8'd2   : cal_crc = 32'hee0e612c;
	        8'd3   : cal_crc = 32'h990951ba;
	        8'd4   : cal_crc = 32'h76dc419;
	        8'd5   : cal_crc = 32'h706af48f;
	        8'd6   : cal_crc = 32'he963a535;
	        8'd7   : cal_crc = 32'h9e6495a3;
	        8'd8   : cal_crc = 32'hedb8832;
	        8'd9   : cal_crc = 32'h79dcb8a4;
	        8'd10  : cal_crc = 32'he0d5e91e;
	        8'd11  : cal_crc = 32'h97d2d988;
	        8'd12  : cal_crc = 32'h9b64c2b;
	        8'd13  : cal_crc = 32'h7eb17cbd;
	        8'd14  : cal_crc = 32'he7b82d07;
	        8'd15  : cal_crc = 32'h90bf1d91;
	        8'd16  : cal_crc = 32'h1db71064;
	        8'd17  : cal_crc = 32'h6ab020f2;
	        8'd18  : cal_crc = 32'hf3b97148;
	        8'd19  : cal_crc = 32'h84be41de;
	        8'd20  : cal_crc = 32'h1adad47d;
	        8'd21  : cal_crc = 32'h6ddde4eb;
	        8'd22  : cal_crc = 32'hf4d4b551;
	        8'd23  : cal_crc = 32'h83d385c7;
	        8'd24  : cal_crc = 32'h136c9856;
	        8'd25  : cal_crc = 32'h646ba8c0;
	        8'd26  : cal_crc = 32'hfd62f97a;
	        8'd27  : cal_crc = 32'h8a65c9ec;
	        8'd28  : cal_crc = 32'h14015c4f;
	        8'd29  : cal_crc = 32'h63066cd9;
	        8'd30  : cal_crc = 32'hfa0f3d63;
	        8'd31  : cal_crc = 32'h8d080df5;
	        8'd32  : cal_crc = 32'h3b6e20c8;
	        8'd33  : cal_crc = 32'h4c69105e;
	        8'd34  : cal_crc = 32'hd56041e4;
	        8'd35  : cal_crc = 32'ha2677172;
	        8'd36  : cal_crc = 32'h3c03e4d1;
	        8'd37  : cal_crc = 32'h4b04d447;
	        8'd38  : cal_crc = 32'hd20d85fd;
	        8'd39  : cal_crc = 32'ha50ab56b;
	        8'd40  : cal_crc = 32'h35b5a8fa;
	        8'd41  : cal_crc = 32'h42b2986c;
	        8'd42  : cal_crc = 32'hdbbbc9d6;
	        8'd43  : cal_crc = 32'hacbcf940;
	        8'd44  : cal_crc = 32'h32d86ce3;
	        8'd45  : cal_crc = 32'h45df5c75;
	        8'd46  : cal_crc = 32'hdcd60dcf;
	        8'd47  : cal_crc = 32'habd13d59;
	        8'd48  : cal_crc = 32'h26d930ac;
	        8'd49  : cal_crc = 32'h51de003a;
	        8'd50  : cal_crc = 32'hc8d75180;
	        8'd51  : cal_crc = 32'hbfd06116;
	        8'd52  : cal_crc = 32'h21b4f4b5;
	        8'd53  : cal_crc = 32'h56b3c423;
	        8'd54  : cal_crc = 32'hcfba9599;
	        8'd55  : cal_crc = 32'hb8bda50f;
	        8'd56  : cal_crc = 32'h2802b89e;
	        8'd57  : cal_crc = 32'h5f058808;
	        8'd58  : cal_crc = 32'hc60cd9b2;
	        8'd59  : cal_crc = 32'hb10be924;
	        8'd60  : cal_crc = 32'h2f6f7c87;
	        8'd61  : cal_crc = 32'h58684c11;
	        8'd62  : cal_crc = 32'hc1611dab;
	        8'd63  : cal_crc = 32'hb6662d3d;
	        8'd64  : cal_crc = 32'h76dc4190;
	        8'd65  : cal_crc = 32'h1db7106;
	        8'd66  : cal_crc = 32'h98d220bc;
	        8'd67  : cal_crc = 32'hefd5102a;
	        8'd68  : cal_crc = 32'h71b18589;
	        8'd69  : cal_crc = 32'h6b6b51f;
	        8'd70  : cal_crc = 32'h9fbfe4a5;
	        8'd71  : cal_crc = 32'he8b8d433;
	        8'd72  : cal_crc = 32'h7807c9a2;
	        8'd73  : cal_crc = 32'hf00f934;
	        8'd74  : cal_crc = 32'h9609a88e;
	        8'd75  : cal_crc = 32'he10e9818;
	        8'd76  : cal_crc = 32'h7f6a0dbb;
	        8'd77  : cal_crc = 32'h86d3d2d;
	        8'd78  : cal_crc = 32'h91646c97;
	        8'd79  : cal_crc = 32'he6635c01;
	        8'd80  : cal_crc = 32'h6b6b51f4;
	        8'd81  : cal_crc = 32'h1c6c6162;
	        8'd82  : cal_crc = 32'h856530d8;
	        8'd83  : cal_crc = 32'hf262004e;
	        8'd84  : cal_crc = 32'h6c0695ed;
	        8'd85  : cal_crc = 32'h1b01a57b;
	        8'd86  : cal_crc = 32'h8208f4c1;
	        8'd87  : cal_crc = 32'hf50fc457;
	        8'd88  : cal_crc = 32'h65b0d9c6;
	        8'd89  : cal_crc = 32'h12b7e950;
	        8'd90  : cal_crc = 32'h8bbeb8ea;
	        8'd91  : cal_crc = 32'hfcb9887c;
	        8'd92  : cal_crc = 32'h62dd1ddf;
	        8'd93  : cal_crc = 32'h15da2d49;
	        8'd94  : cal_crc = 32'h8cd37cf3;
	        8'd95  : cal_crc = 32'hfbd44c65;
	        8'd96  : cal_crc = 32'h4db26158;
	        8'd97  : cal_crc = 32'h3ab551ce;
	        8'd98  : cal_crc = 32'ha3bc0074;
	        8'd99  : cal_crc = 32'hd4bb30e2;
	        8'd100 : cal_crc = 32'h4adfa541;
	        8'd101 : cal_crc = 32'h3dd895d7;
	        8'd102 : cal_crc = 32'ha4d1c46d;
	        8'd103 : cal_crc = 32'hd3d6f4fb;
	        8'd104 : cal_crc = 32'h4369e96a;
	        8'd105 : cal_crc = 32'h346ed9fc;
	        8'd106 : cal_crc = 32'had678846;
	        8'd107 : cal_crc = 32'hda60b8d0;
	        8'd108 : cal_crc = 32'h44042d73;
	        8'd109 : cal_crc = 32'h33031de5;
	        8'd110 : cal_crc = 32'haa0a4c5f;
	        8'd111 : cal_crc = 32'hdd0d7cc9;
	        8'd112 : cal_crc = 32'h5005713c;
	        8'd113 : cal_crc = 32'h270241aa;
	        8'd114 : cal_crc = 32'hbe0b1010;
	        8'd115 : cal_crc = 32'hc90c2086;
	        8'd116 : cal_crc = 32'h5768b525;
	        8'd117 : cal_crc = 32'h206f85b3;
	        8'd118 : cal_crc = 32'hb966d409;
	        8'd119 : cal_crc = 32'hce61e49f;
	        8'd120 : cal_crc = 32'h5edef90e;
	        8'd121 : cal_crc = 32'h29d9c998;
	        8'd122 : cal_crc = 32'hb0d09822;
	        8'd123 : cal_crc = 32'hc7d7a8b4;
	        8'd124 : cal_crc = 32'h59b33d17;
	        8'd125 : cal_crc = 32'h2eb40d81;
	        8'd126 : cal_crc = 32'hb7bd5c3b;
	        8'd127 : cal_crc = 32'hc0ba6cad;
	        8'd128 : cal_crc = 32'hedb88320;
	        8'd129 : cal_crc = 32'h9abfb3b6;
	        8'd130 : cal_crc = 32'h3b6e20c;
	        8'd131 : cal_crc = 32'h74b1d29a;
	        8'd132 : cal_crc = 32'head54739;
	        8'd133 : cal_crc = 32'h9dd277af;
	        8'd134 : cal_crc = 32'h4db2615;
	        8'd135 : cal_crc = 32'h73dc1683;
	        8'd136 : cal_crc = 32'he3630b12;
	        8'd137 : cal_crc = 32'h94643b84;
	        8'd138 : cal_crc = 32'hd6d6a3e;
	        8'd139 : cal_crc = 32'h7a6a5aa8;
	        8'd140 : cal_crc = 32'he40ecf0b;
	        8'd141 : cal_crc = 32'h9309ff9d;
	        8'd142 : cal_crc = 32'ha00ae27;
	        8'd143 : cal_crc = 32'h7d079eb1;
	        8'd144 : cal_crc = 32'hf00f9344;
	        8'd145 : cal_crc = 32'h8708a3d2;
	        8'd146 : cal_crc = 32'h1e01f268;
	        8'd147 : cal_crc = 32'h6906c2fe;
	        8'd148 : cal_crc = 32'hf762575d;
	        8'd149 : cal_crc = 32'h806567cb;
	        8'd150 : cal_crc = 32'h196c3671;
	        8'd151 : cal_crc = 32'h6e6b06e7;
	        8'd152 : cal_crc = 32'hfed41b76;
	        8'd153 : cal_crc = 32'h89d32be0;
	        8'd154 : cal_crc = 32'h10da7a5a;
	        8'd155 : cal_crc = 32'h67dd4acc;
	        8'd156 : cal_crc = 32'hf9b9df6f;
	        8'd157 : cal_crc = 32'h8ebeeff9;
	        8'd158 : cal_crc = 32'h17b7be43;
	        8'd159 : cal_crc = 32'h60b08ed5;
	        8'd160 : cal_crc = 32'hd6d6a3e8;
	        8'd161 : cal_crc = 32'ha1d1937e;
	        8'd162 : cal_crc = 32'h38d8c2c4;
	        8'd163 : cal_crc = 32'h4fdff252;
	        8'd164 : cal_crc = 32'hd1bb67f1;
	        8'd165 : cal_crc = 32'ha6bc5767;
	        8'd166 : cal_crc = 32'h3fb506dd;
	        8'd167 : cal_crc = 32'h48b2364b;
	        8'd168 : cal_crc = 32'hd80d2bda;
	        8'd169 : cal_crc = 32'haf0a1b4c;
	        8'd170 : cal_crc = 32'h36034af6;
	        8'd171 : cal_crc = 32'h41047a60;
	        8'd172 : cal_crc = 32'hdf60efc3;
	        8'd173 : cal_crc = 32'ha867df55;
	        8'd174 : cal_crc = 32'h316e8eef;
	        8'd175 : cal_crc = 32'h4669be79;
	        8'd176 : cal_crc = 32'hcb61b38c;
	        8'd177 : cal_crc = 32'hbc66831a;
	        8'd178 : cal_crc = 32'h256fd2a0;
	        8'd179 : cal_crc = 32'h5268e236;
	        8'd180 : cal_crc = 32'hcc0c7795;
	        8'd181 : cal_crc = 32'hbb0b4703;
	        8'd182 : cal_crc = 32'h220216b9;
	        8'd183 : cal_crc = 32'h5505262f;
	        8'd184 : cal_crc = 32'hc5ba3bbe;
	        8'd185 : cal_crc = 32'hb2bd0b28;
	        8'd186 : cal_crc = 32'h2bb45a92;
	        8'd187 : cal_crc = 32'h5cb36a04;
	        8'd188 : cal_crc = 32'hc2d7ffa7;
	        8'd189 : cal_crc = 32'hb5d0cf31;
	        8'd190 : cal_crc = 32'h2cd99e8b;
	        8'd191 : cal_crc = 32'h5bdeae1d;
	        8'd192 : cal_crc = 32'h9b64c2b0;
	        8'd193 : cal_crc = 32'hec63f226;
	        8'd194 : cal_crc = 32'h756aa39c;
	        8'd195 : cal_crc = 32'h26d930a;
	        8'd196 : cal_crc = 32'h9c0906a9;
	        8'd197 : cal_crc = 32'heb0e363f;
	        8'd198 : cal_crc = 32'h72076785;
	        8'd199 : cal_crc = 32'h5005713;
	        8'd200 : cal_crc = 32'h95bf4a82;
	        8'd201 : cal_crc = 32'he2b87a14;
	        8'd202 : cal_crc = 32'h7bb12bae;
	        8'd203 : cal_crc = 32'hcb61b38;
	        8'd204 : cal_crc = 32'h92d28e9b;
	        8'd205 : cal_crc = 32'he5d5be0d;
	        8'd206 : cal_crc = 32'h7cdcefb7;
	        8'd207 : cal_crc = 32'hbdbdf21;
	        8'd208 : cal_crc = 32'h86d3d2d4;
	        8'd209 : cal_crc = 32'hf1d4e242;
	        8'd210 : cal_crc = 32'h68ddb3f8;
	        8'd211 : cal_crc = 32'h1fda836e;
	        8'd212 : cal_crc = 32'h81be16cd;
	        8'd213 : cal_crc = 32'hf6b9265b;
	        8'd214 : cal_crc = 32'h6fb077e1;
	        8'd215 : cal_crc = 32'h18b74777;
	        8'd216 : cal_crc = 32'h88085ae6;
	        8'd217 : cal_crc = 32'hff0f6a70;
	        8'd218 : cal_crc = 32'h66063bca;
	        8'd219 : cal_crc = 32'h11010b5c;
	        8'd220 : cal_crc = 32'h8f659eff;
	        8'd221 : cal_crc = 32'hf862ae69;
	        8'd222 : cal_crc = 32'h616bffd3;
	        8'd223 : cal_crc = 32'h166ccf45;
	        8'd224 : cal_crc = 32'ha00ae278;
	        8'd225 : cal_crc = 32'hd70dd2ee;
	        8'd226 : cal_crc = 32'h4e048354;
	        8'd227 : cal_crc = 32'h3903b3c2;
	        8'd228 : cal_crc = 32'ha7672661;
	        8'd229 : cal_crc = 32'hd06016f7;
	        8'd230 : cal_crc = 32'h4969474d;
	        8'd231 : cal_crc = 32'h3e6e77db;
	        8'd232 : cal_crc = 32'haed16a4a;
	        8'd233 : cal_crc = 32'hd9d65adc;
	        8'd234 : cal_crc = 32'h40df0b66;
	        8'd235 : cal_crc = 32'h37d83bf0;
	        8'd236 : cal_crc = 32'ha9bcae53;
	        8'd237 : cal_crc = 32'hdebb9ec5;
	        8'd238 : cal_crc = 32'h47b2cf7f;
	        8'd239 : cal_crc = 32'h30b5ffe9;
	        8'd240 : cal_crc = 32'hbdbdf21c;
	        8'd241 : cal_crc = 32'hcabac28a;
	        8'd242 : cal_crc = 32'h53b39330;
	        8'd243 : cal_crc = 32'h24b4a3a6;
	        8'd244 : cal_crc = 32'hbad03605;
	        8'd245 : cal_crc = 32'hcdd70693;
	        8'd246 : cal_crc = 32'h54de5729;
	        8'd247 : cal_crc = 32'h23d967bf;
	        8'd248 : cal_crc = 32'hb3667a2e;
	        8'd249 : cal_crc = 32'hc4614ab8;
	        8'd250 : cal_crc = 32'h5d681b02;
	        8'd251 : cal_crc = 32'h2a6f2b94;
	        8'd252 : cal_crc = 32'hb40bbe37;
	        8'd253 : cal_crc = 32'hc30c8ea1;
	        8'd254 : cal_crc = 32'h5a05df1b;
	        8'd255 : cal_crc = 32'h2d02ef8d;
               default: cal_crc = 32'h0;
          endcase
         return cal_crc;			
    endfunction : crc_table
    

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
 	endfunction 

	virtual function generate_disparity_table_k();
		disparity_table_k[8'b000_11100] = {10'b001111_0100, 10'b110000_1011};
	 	disparity_table_k[8'b001_11100] = {10'b001111_1001, 10'b110000_0110};
    		disparity_table_k[8'b010_11100] = {10'b001111_0101, 10'b110000_1010};
    		disparity_table_k[8'b011_11100] = {10'b001111_0011, 10'b110000_1100};
	    	disparity_table_k[8'b100_11100] = {10'b001111_0010, 10'b110000_1101};
    		disparity_table_k[8'b101_11100] = {10'b001111_1010, 10'b110000_0101};
    		disparity_table_k[8'b110_11100] = {10'b001111_0110, 10'b110000_1001};
    		disparity_table_k[8'b111_11100] = {10'b001111_1000, 10'b110000_0111};
    		disparity_table_k[8'b111_10111] = {10'b111010_1000, 10'b000101_0111};
    		disparity_table_k[8'b111_11011] = {10'b110110_1000, 10'b001001_0111};
    		disparity_table_k[8'b111_11101] = {10'b101110_1000, 10'b010001_0111};
    		disparity_table_k[8'b111_11110] = {10'b011110_1000, 10'b100001_0111};
	endfunction

endclass
