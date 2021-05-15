
class my_scoreboard_crc extends uvm_scoreboard ; //calculate crc
	`uvm_component_utils(my_scoreboard_crc)

	parameter logic [7:0] k28_5 = 8'hBC, k28_1 = 8'h3c;
	logic start = 0;
	logic [8:0] prev_datain;
        virtual intf vif ;
        uvm_tlm_analysis_fifo #(my_monitor_crc_in_message) mon_in_port;

	uvm_analysis_port #(crc_output_packet) crc_in_port;
	
        my_monitor_crc_in_message mon_in;
	

	crc_output_packet crc_in;

	logic [31:0] crc_intm, crc_out;
	

	function new (string name = "my_scoreboard_crc",uvm_component parent);
		super.new(name,parent);
       		
		if(!uvm_config_db #(virtual intf) :: get(null,"db", "int_f",vif)) begin
			`uvm_fatal("Error in monitor", "monitor cannot get interface");
		end
	endfunction

	function void build_phase(uvm_phase phase);
		mon_in_port=new("mon_in_port",this);
		crc_in_port=new("crc_in_port",this);
		
	endfunction : build_phase

	virtual task run_phase(uvm_phase phase);
		super.run_phase(phase);
		forever begin
			@(posedge this.vif.clk);
			mon_in = new();
			
			mon_in_port.get(mon_in);
			
			if ((prev_datain [7:0] == k28_1) && mon_in.datain [8] == 0 ) begin
				start = 1;
				// start calculating crc
			end
			else if ((start == 1) && (mon_in.datain[8] == 0)) begin
				//keep calculating crc
			end
			else if ((mon_in.datain [8] == 1) && (mon_in.datain [7:0] == k28_5)) begin
				start = 0; //final calculated crc value the reverse or encode if needed
			end
			
					end

		crc_in_port.write(crc_in);
		prev_datain = mon_in.datain;
	endtask

        virtual function crc_32_ref (logic [8:0] in);
        if  (in[8] == 0) begin
		case ( in [7:0] )
			8'd0   : crc_intm = 32'h0;
			8'd1   : crc_intm = 32'h77073096;
			8'd2   : crc_intm = 32'hee0e612c;
			8'd3   : crc_intm = 32'h990951ba;
			8'd4   : crc_intm = 32'h76dc419;
			8'd5   : crc_intm = 32'h706af48f;
			8'd6   : crc_intm = 32'he963a535;
			8'd7   : crc_intm = 32'h9e6495a3;
			8'd8   : crc_intm = 32'hedb8832;
			8'd9   : crc_intm = 32'h79dcb8a4;
			8'd10  : crc_intm = 32'he0d5e91e;
			8'd11  : crc_intm = 32'h97d2d988;
			8'd12  : crc_intm = 32'h9b64c2b;
			8'd13  : crc_intm = 32'h7eb17cbd;
			8'd14  : crc_intm = 32'he7b82d07;
			8'd15  : crc_intm = 32'h90bf1d91;
			8'd16  : crc_intm = 32'h1db71064;
			8'd17  : crc_intm = 32'h6ab020f2;
			8'd18  : crc_intm = 32'hf3b97148;
			8'd19  : crc_intm = 32'h84be41de;
			8'd20  : crc_intm = 32'h1adad47d;
			8'd21  : crc_intm = 32'h6ddde4eb;
			8'd22  : crc_intm = 32'hf4d4b551;
			8'd23  : crc_intm = 32'h83d385c7;
			8'd24  : crc_intm = 32'h136c9856;
			8'd25  : crc_intm = 32'h646ba8c0;
			8'd26  : crc_intm = 32'hfd62f97a;
			8'd27  : crc_intm = 32'h8a65c9ec;
			8'd28  : crc_intm = 32'h14015c4f;
			8'd29  : crc_intm = 32'h63066cd9;
			8'd30  : crc_intm = 32'hfa0f3d63;
			8'd31  : crc_intm = 32'h8d080df5;
			8'd32  : crc_intm = 32'h3b6e20c8;
			8'd33  : crc_intm = 32'h4c69105e;
			8'd34  : crc_intm = 32'hd56041e4;
			8'd35  : crc_intm = 32'ha2677172;
			8'd36  : crc_intm = 32'h3c03e4d1;
			8'd37  : crc_intm = 32'h4b04d447;
			8'd38  : crc_intm = 32'hd20d85fd;
			8'd39  : crc_intm = 32'ha50ab56b;
			8'd40  : crc_intm = 32'h35b5a8fa;
			8'd41  : crc_intm = 32'h42b2986c;
			8'd42  : crc_intm = 32'hdbbbc9d6;
			8'd43  : crc_intm = 32'hacbcf940;
			8'd44  : crc_intm = 32'h32d86ce3;
			8'd45  : crc_intm = 32'h45df5c75;
			8'd46  : crc_intm = 32'hdcd60dcf;
			8'd47  : crc_intm = 32'habd13d59;
			8'd48  : crc_intm = 32'h26d930ac;
			8'd49  : crc_intm = 32'h51de003a;
			8'd50  : crc_intm = 32'hc8d75180;
			8'd51  : crc_intm = 32'hbfd06116;
			8'd52  : crc_intm = 32'h21b4f4b5;
			8'd53  : crc_intm = 32'h56b3c423;
			8'd54  : crc_intm = 32'hcfba9599;
			8'd55  : crc_intm = 32'hb8bda50f;
			8'd56  : crc_intm = 32'h2802b89e;
			8'd57  : crc_intm = 32'h5f058808;
			8'd58  : crc_intm = 32'hc60cd9b2;
			8'd59  : crc_intm = 32'hb10be924;
			8'd60  : crc_intm = 32'h2f6f7c87;
			8'd61  : crc_intm = 32'h58684c11;
			8'd62  : crc_intm = 32'hc1611dab;
			8'd63  : crc_intm = 32'hb6662d3d;
			8'd64  : crc_intm = 32'h76dc4190;
			8'd65  : crc_intm = 32'h1db7106;
			8'd66  : crc_intm = 32'h98d220bc;
			8'd67  : crc_intm = 32'hefd5102a;
			8'd68  : crc_intm = 32'h71b18589;
			8'd69  : crc_intm = 32'h6b6b51f;
			8'd70  : crc_intm = 32'h9fbfe4a5;
			8'd71  : crc_intm = 32'he8b8d433;
			8'd72  : crc_intm = 32'h7807c9a2;
			8'd73  : crc_intm = 32'hf00f934;
			8'd74  : crc_intm = 32'h9609a88e;
			8'd75  : crc_intm = 32'he10e9818;
			8'd76  : crc_intm = 32'h7f6a0dbb;
			8'd77  : crc_intm = 32'h86d3d2d;
			8'd78  : crc_intm = 32'h91646c97;
			8'd79  : crc_intm = 32'he6635c01;
			8'd80  : crc_intm = 32'h6b6b51f4;
			8'd81  : crc_intm = 32'h1c6c6162;
			8'd82  : crc_intm = 32'h856530d8;
			8'd83  : crc_intm = 32'hf262004e;
			8'd84  : crc_intm = 32'h6c0695ed;
			8'd85  : crc_intm = 32'h1b01a57b;
			8'd86  : crc_intm = 32'h8208f4c1;
			8'd87  : crc_intm = 32'hf50fc457;
			8'd88  : crc_intm = 32'h65b0d9c6;
			8'd89  : crc_intm = 32'h12b7e950;
			8'd90  : crc_intm = 32'h8bbeb8ea;
			8'd91  : crc_intm = 32'hfcb9887c;
			8'd92  : crc_intm = 32'h62dd1ddf;
			8'd93  : crc_intm = 32'h15da2d49;
			8'd94  : crc_intm = 32'h8cd37cf3;
			8'd95  : crc_intm = 32'hfbd44c65;
			8'd96  : crc_intm = 32'h4db26158;
			8'd97  : crc_intm = 32'h3ab551ce;
			8'd98  : crc_intm = 32'ha3bc0074;
			8'd99  : crc_intm = 32'hd4bb30e2;
			8'd100 : crc_intm = 32'h4adfa541;
			8'd101 : crc_intm = 32'h3dd895d7;
			8'd102 : crc_intm = 32'ha4d1c46d;
			8'd103 : crc_intm = 32'hd3d6f4fb;
			8'd104 : crc_intm = 32'h4369e96a;
			8'd105 : crc_intm = 32'h346ed9fc;
			8'd106 : crc_intm = 32'had678846;
			8'd107 : crc_intm = 32'hda60b8d0;
			8'd108 : crc_intm = 32'h44042d73;
			8'd109 : crc_intm = 32'h33031de5;
			8'd110 : crc_intm = 32'haa0a4c5f;
			8'd111 : crc_intm = 32'hdd0d7cc9;
			8'd112 : crc_intm = 32'h5005713c;
			8'd113 : crc_intm = 32'h270241aa;
			8'd114 : crc_intm = 32'hbe0b1010;
			8'd115 : crc_intm = 32'hc90c2086;
			8'd116 : crc_intm = 32'h5768b525;
			8'd117 : crc_intm = 32'h206f85b3;
			8'd118 : crc_intm = 32'hb966d409;
			8'd119 : crc_intm = 32'hce61e49f;
			8'd120 : crc_intm = 32'h5edef90e;
			8'd121 : crc_intm = 32'h29d9c998;
			8'd122 : crc_intm = 32'hb0d09822;
			8'd123 : crc_intm = 32'hc7d7a8b4;
			8'd124 : crc_intm = 32'h59b33d17;
			8'd125 : crc_intm = 32'h2eb40d81;
			8'd126 : crc_intm = 32'hb7bd5c3b;
			8'd127 : crc_intm = 32'hc0ba6cad;
			8'd128 : crc_intm = 32'hedb88320;
			8'd129 : crc_intm = 32'h9abfb3b6;
			8'd130 : crc_intm = 32'h3b6e20c;
			8'd131 : crc_intm = 32'h74b1d29a;
			8'd132 : crc_intm = 32'head54739;
			8'd133 : crc_intm = 32'h9dd277af;
			8'd134 : crc_intm = 32'h4db2615;
			8'd135 : crc_intm = 32'h73dc1683;
			8'd136 : crc_intm = 32'he3630b12;
			8'd137 : crc_intm = 32'h94643b84;
			8'd138 : crc_intm = 32'hd6d6a3e;
			8'd139 : crc_intm = 32'h7a6a5aa8;
			8'd140 : crc_intm = 32'he40ecf0b;
			8'd141 : crc_intm = 32'h9309ff9d;
			8'd142 : crc_intm = 32'ha00ae27;
			8'd143 : crc_intm = 32'h7d079eb1;
			8'd144 : crc_intm = 32'hf00f9344;
			8'd145 : crc_intm = 32'h8708a3d2;
			8'd146 : crc_intm = 32'h1e01f268;
			8'd147 : crc_intm = 32'h6906c2fe;
			8'd148 : crc_intm = 32'hf762575d;
			8'd149 : crc_intm = 32'h806567cb;
			8'd150 : crc_intm = 32'h196c3671;
			8'd151 : crc_intm = 32'h6e6b06e7;
			8'd152 : crc_intm = 32'hfed41b76;
			8'd153 : crc_intm = 32'h89d32be0;
			8'd154 : crc_intm = 32'h10da7a5a;
			8'd155 : crc_intm = 32'h67dd4acc;
			8'd156 : crc_intm = 32'hf9b9df6f;
			8'd157 : crc_intm = 32'h8ebeeff9;
			8'd158 : crc_intm = 32'h17b7be43;
			8'd159 : crc_intm = 32'h60b08ed5;
			8'd160 : crc_intm = 32'hd6d6a3e8;
			8'd161 : crc_intm = 32'ha1d1937e;
			8'd162 : crc_intm = 32'h38d8c2c4;
			8'd163 : crc_intm = 32'h4fdff252;
			8'd164 : crc_intm = 32'hd1bb67f1;
			8'd165 : crc_intm = 32'ha6bc5767;
			8'd166 : crc_intm = 32'h3fb506dd;
			8'd167 : crc_intm = 32'h48b2364b;
			8'd168 : crc_intm = 32'hd80d2bda;
			8'd169 : crc_intm = 32'haf0a1b4c;
			8'd170 : crc_intm = 32'h36034af6;
			8'd171 : crc_intm = 32'h41047a60;
			8'd172 : crc_intm = 32'hdf60efc3;
			8'd173 : crc_intm = 32'ha867df55;
			8'd174 : crc_intm = 32'h316e8eef;
			8'd175 : crc_intm = 32'h4669be79;
			8'd176 : crc_intm = 32'hcb61b38c;
			8'd177 : crc_intm = 32'hbc66831a;
			8'd178 : crc_intm = 32'h256fd2a0;
			8'd179 : crc_intm = 32'h5268e236;
			8'd180 : crc_intm = 32'hcc0c7795;
			8'd181 : crc_intm = 32'hbb0b4703;
			8'd182 : crc_intm = 32'h220216b9;
			8'd183 : crc_intm = 32'h5505262f;
			8'd184 : crc_intm = 32'hc5ba3bbe;
			8'd185 : crc_intm = 32'hb2bd0b28;
			8'd186 : crc_intm = 32'h2bb45a92;
			8'd187 : crc_intm = 32'h5cb36a04;
			8'd188 : crc_intm = 32'hc2d7ffa7;
			8'd189 : crc_intm = 32'hb5d0cf31;
			8'd190 : crc_intm = 32'h2cd99e8b;
			8'd191 : crc_intm = 32'h5bdeae1d;
			8'd192 : crc_intm = 32'h9b64c2b0;
			8'd193 : crc_intm = 32'hec63f226;
			8'd194 : crc_intm = 32'h756aa39c;
			8'd195 : crc_intm = 32'h26d930a;
			8'd196 : crc_intm = 32'h9c0906a9;
			8'd197 : crc_intm = 32'heb0e363f;
			8'd198 : crc_intm = 32'h72076785;
			8'd199 : crc_intm = 32'h5005713;
			8'd200 : crc_intm = 32'h95bf4a82;
			8'd201 : crc_intm = 32'he2b87a14;
			8'd202 : crc_intm = 32'h7bb12bae;
			8'd203 : crc_intm = 32'hcb61b38;
			8'd204 : crc_intm = 32'h92d28e9b;
			8'd205 : crc_intm = 32'he5d5be0d;
			8'd206 : crc_intm = 32'h7cdcefb7;
			8'd207 : crc_intm = 32'hbdbdf21;
			8'd208 : crc_intm = 32'h86d3d2d4;
			8'd209 : crc_intm = 32'hf1d4e242;
			8'd210 : crc_intm = 32'h68ddb3f8;
			8'd211 : crc_intm = 32'h1fda836e;
			8'd212 : crc_intm = 32'h81be16cd;
			8'd213 : crc_intm = 32'hf6b9265b;
			8'd214 : crc_intm = 32'h6fb077e1;
			8'd215 : crc_intm = 32'h18b74777;
			8'd216 : crc_intm = 32'h88085ae6;
			8'd217 : crc_intm = 32'hff0f6a70;
			8'd218 : crc_intm = 32'h66063bca;
			8'd219 : crc_intm = 32'h11010b5c;
			8'd220 : crc_intm = 32'h8f659eff;
			8'd221 : crc_intm = 32'hf862ae69;
			8'd222 : crc_intm = 32'h616bffd3;
			8'd223 : crc_intm = 32'h166ccf45;
			8'd224 : crc_intm = 32'ha00ae278;
			8'd225 : crc_intm = 32'hd70dd2ee;
			8'd226 : crc_intm = 32'h4e048354;
			8'd227 : crc_intm = 32'h3903b3c2;
			8'd228 : crc_intm = 32'ha7672661;
			8'd229 : crc_intm = 32'hd06016f7;
			8'd230 : crc_intm = 32'h4969474d;
			8'd231 : crc_intm = 32'h3e6e77db;
			8'd232 : crc_intm = 32'haed16a4a;
			8'd233 : crc_intm = 32'hd9d65adc;
			8'd234 : crc_intm = 32'h40df0b66;
			8'd235 : crc_intm = 32'h37d83bf0;
			8'd236 : crc_intm = 32'ha9bcae53;
			8'd237 : crc_intm = 32'hdebb9ec5;
			8'd238 : crc_intm = 32'h47b2cf7f;
			8'd239 : crc_intm = 32'h30b5ffe9;
			8'd240 : crc_intm = 32'hbdbdf21c;
			8'd241 : crc_intm = 32'hcabac28a;
			8'd242 : crc_intm = 32'h53b39330;
			8'd243 : crc_intm = 32'h24b4a3a6;
			8'd244 : crc_intm = 32'hbad03605;
			8'd245 : crc_intm = 32'hcdd70693;
			8'd246 : crc_intm = 32'h54de5729;
			8'd247 : crc_intm = 32'h23d967bf;
			8'd248 : crc_intm = 32'hb3667a2e;
			8'd249 : crc_intm = 32'hc4614ab8;
			8'd250 : crc_intm = 32'h5d681b02;
			8'd251 : crc_intm = 32'h2a6f2b94;
			8'd252 : crc_intm = 32'hb40bbe37;
			8'd253 : crc_intm = 32'hc30c8ea1;
			8'd254 : crc_intm = 32'h5a05df1b;
			8'd255 : crc_intm = 32'h2d02ef8d;
		    default: crc_intm = 32'h0;			
		    endcase
		    crc_out = (crc_out >> 8) ^ crc_intm;
		return 0;
	end 
	
	else if (in[8] == 1 && in[7:0] == k28_5) begin
		return crc_out;
	end
	

	endfunction : crc_32_ref

endclass : my_scoreboard_crc
