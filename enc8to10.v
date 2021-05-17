
// Code your design here
module enc8to10(input clk, 
                input reset, 
                input pushin, 
                input [8:0]datain, 
                input startin, 
                output reg pushout,
                output[9:0]dataout, 
                output reg startout);

  localparam K280 = 8'h1c,
         K281 = 8'h3c,
         K282 = 8'h5c,
         K283 = 8'h7c,
         K284 = 8'h9c,
         K285 = 8'hbc,
         K286 = 8'hdc,
         K237 = 8'hf7,
         K277 = 8'hfb,
         K297 = 8'hfd,
         K307 = 8'hfe,
         S0_K281 = 2'd0,
         S1_DATA = 2'd1,
         S2_K285 = 2'd2;

  wire Kbit;  // control bit
  wire RD6B, RD4B, RD, curRD; // running disparity    0 for -1  and 1 for 1
  wire [31:0] crcResult;
  reg  [31:0] crcData;
 
  reg curRD6B, curRD4B, curRD0; 
  wire [9:0] outTemp, kcode, kcodeCRC0, kcodeCRC1, firstCRC, secondCRC, thirdCRC, fourthCRC;
  reg [9:0] trueOutput;
  reg [3:0] counterK281, counterK285;
  reg [1:0] currentState, nextState;

  assign dataout = trueOutput ;
  assign Kbit = datain[8];
  assign curRD = (startin) ? 1'b0 : curRD0;
  
  // the running disparity will always be active when trueOutput is available (pushout is high).
  // the RD FSM will reset at the start of sequence (startin is high)
  runningDisparity #(.WIDTH(6)) rd6b (.clk(clk), .reset(reset), .dataout(trueOutput[5:0]), .startin(startin), .RDout(RD6B), .pushout(pushout));

  runningDisparity #(.WIDTH(4)) rd4b (.clk(clk), .reset(reset), .dataout(trueOutput[9:6]), .startin(startin), .RDout(RD4B), .pushout(pushout));

  runningDisparity #(.WIDTH(10)) rd10b (.clk(clk), .reset(reset), .dataout(trueOutput), .startin(startin), .RDout(RD), .pushout(pushout));


  //8/10b Encoding the data byte
  enc5to6 ec0 (.datain(datain[4:0]), .RD(curRD), .dataout(outTemp[9:4]));
  enc3to4 ec1 (.datain(datain[7:5]), .RD(~curRD), .dataout(outTemp[3:0]), .lower(datain[4:0]));

  // 8/10b Encoding the first CRC byte 
  enc5to6 ec2 (.datain(crcData[4:0]), .RD(curRD), .dataout(firstCRC[9:4]));
  enc3to4 ec3 (.datain(crcData[7:5]), .RD(~curRD), .dataout(firstCRC[3:0]), .lower(crcData[4:0]));

  // 8/10b Encoding the second CRC byte 
  enc5to6 ec4 (.datain(crcData[12:8]), .RD(curRD), .dataout(secondCRC[9:4]));
  enc3to4 ec5 (.datain(crcData[15:13]), .RD(~curRD), .dataout(secondCRC[3:0]), .lower(crcData[12:8]));

  // 8/10b Encoding the third CRC byte 
  enc5to6 ec6 (.datain(crcData[20:16]), .RD(curRD), .dataout(thirdCRC[9:4]));
  enc3to4 ec7 (.datain(crcData[23:21]), .RD(~curRD), .dataout(thirdCRC[3:0]), .lower(crcData[20:16]));

  // 8/10b Encoding the fourth CRC byte 
  enc5to6 ec8 (.datain(crcData[28:24]), .RD(curRD), .dataout(fourthCRC[9:4]));
  enc3to4 ec9 (.datain(crcData[31:29]), .RD(~curRD), .dataout(fourthCRC[3:0]), .lower(crcData[28:24]));

  // 8/10b Encoding the kcode 
  kcode8to10 kc0 (.datain(datain[7:0]), .RD(curRD), .dataout(kcode));

  // 8/10b Encoding the K285 code
  kcode8to10 kc1 (.datain(K285), .RD(curRD), .dataout(kcodeCRC0));

  // 8/10b Encoding the K237 code
  kcode8to10 kc2 (.datain(K237), .RD(curRD), .dataout(kcodeCRC1));

  // CRC calculation of the packet
  crc32 crc0 (.clk(clk), .rst(reset), .crc32_in(datain[7:0]), .valid(pushin && (currentState == S1_DATA) && (datain[7:0] != K285) && ( Kbit==0)), 
              .is_S1DATA(currentState == S1_DATA) ,.crc32_out(crcResult));

always @(posedge clk or posedge reset) begin
	if (reset) begin
		curRD0 <= 'd0;
		curRD4B <= 'd0;
		curRD6B <= 'd0;
	end else begin
		curRD0 <= RD;
		curRD4B <= RD4B;
		curRD6B <= RD6B;
	end
end


  // State machine state variable
  always @ (posedge clk or posedge reset) begin
    if (reset) begin
        currentState <= S0_K281;
    end

    else begin
        currentState <= nextState;
    end
  end

  // Tracking current counter of K281 state. keep counting up to 4 K281 code
  always @ (posedge clk or posedge reset) begin
    if (reset) begin
        counterK281 <= 'd0;
    end
    else begin
        if ((currentState == S0_K281) && pushin) begin
            counterK281 <= counterK281 + 1;
        end else if (currentState != S0_K281) begin
            counterK281 <= 'd0;
        end
    end
  end

  always @ (posedge clk or posedge reset) begin
    if (reset) begin
        counterK285 <= 'd0;
    end
    else begin
        if (currentState == S2_K285) begin
            counterK285 <= counterK285 + 1;
        end else if (currentState != S2_K285) begin
            counterK285 <= 'd0;
        end else if (counterK285 > 'd0) begin
            counterK285 <= counterK285 + 1;
        end
    end
  end

  always @(*) begin
      nextState = currentState;
      trueOutput = 'd0;
      pushout = 1'b0;
      startout = 1'b0;
      case (currentState)
          S0_K281: begin
              crcData = 'd0;
              if (pushin) begin
                  trueOutput = rearrange(kcode);
                  pushout = 1'b1;
                  if (counterK281 == 'd3) begin
                      nextState = S1_DATA;
                  end
                  if (counterK281 == 'd0) begin
                      startout = 1'b1;
                  end else begin
                      startout = 1'b0;
                  end
              end
          end
          S1_DATA: begin
              if (pushin) begin
                  if (Kbit) begin
                      trueOutput = rearrange(kcode);
                  end else begin
                      trueOutput = rearrange(outTemp);
                  end
                  pushout = 1'b1;
                  if (datain[7:0] == K285) begin
                      nextState = S2_K285;
                      trueOutput = rearrange(kcodeCRC1);
                      crcData = crcResult;
                  end else begin
                      crcData = 'd0;
                  end
                  //crcData = crcResult;
                  //nextState = S2_K285;
              end else begin
                  crcData = 'd0;
              end
          end
          S2_K285: begin
              if (counterK285 == 'd0) begin
                  trueOutput = rearrange(firstCRC);
                  pushout = 1'b1;
              end else if (counterK285 == 'd1) begin
                  trueOutput = rearrange(secondCRC);
                  pushout = 1'b1;
              end else if (counterK285 == 'd2) begin
                  trueOutput = rearrange(thirdCRC);
                  pushout = 1'b1;
              end else if (counterK285 == 'd3) begin
                  trueOutput = rearrange(fourthCRC);
                  pushout = 1'b1;
              end else if (counterK285 == 'd4) begin
                  trueOutput = rearrange(kcodeCRC0);
                  pushout = 1'b1;
                  nextState = S0_K281;
                  crcData = 'd0;
              end
          end
      endcase
  end

function [9:0] rearrange;
    input [9:0] data;
    
    integer i;
  begin
    for (i = 0; i < 10; i = i+1) begin
        rearrange[i] = data[9-i];
    end
  end
endfunction

endmodule





// Code your testbench here
// or browse Examples
// module tb();
//   reg clk, reset, pushin, startin;
//   reg [8:0]datain;
  
//  wire pushout,startout;
//   wire [9:0] dataout;
  
//  enc8to10 enc(clk,reset,pushin,datain,startin,pushout,dataout,startout);

//   initial begin
//     clk=0;
//     repeat(100) begin
//       #2; clk=~clk;
//     end
    
//   end
  
//   initial begin 
//     reset=1;
//     #4; reset=0;
//   end
  
//   initial begin
//     datain = 9'b0_010_10011;  // 110010 0101
    
//   end
  
//   initial begin
//     $dumpfile("a.vcd");
//     $dumpvars();
//   end
  
  
// endmodule




