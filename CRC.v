module CRC (
  input  wire   DATA,
  input  wire   Active,
  input  wire   clk,
  input  wire   RST,
  output reg    CRC,
  output reg    Valid
  );

 reg [7:0] LFSR ;
 reg [3:0] counter;
 reg       rest_flag;
 wire      feedback;
 parameter [7:0] seed = 8'hD8;
 
 assign feedback = LFSR[0] ^ DATA ;
 
 always@(posedge clk, negedge RST)
  begin
    
    if(!RST)
      begin
        LFSR      <=  seed;
        CRC       <= 1'b0 ;
        Valid     <= 1'b0;
        counter   <= 4'b0;
        rest_flag <= 1'b0;
      end
      
    else if (Active)
      begin
   			 LFSR[7] <= feedback;
			 LFSR[6] <= LFSR[7] ^ feedback;
			 LFSR[5] <= LFSR[6] ;
			 LFSR[4] <= LFSR[5] ;
			 LFSR[3] <= LFSR[4] ;
			 LFSR[2] <= LFSR[3] ^ feedback;
			 LFSR[1] <= LFSR[2] ;
			 LFSR[0] <= LFSR[1] ;
			 rest_flag <= 1'b1;
      end
    else if (counter != 4'd8 && rest_flag )
      begin 
       counter <= counter + 1;
   			 {LFSR[6:0],CRC} <= LFSR ;
			 Valid <= 1'b1;
			end
	else
             begin
              Valid <=1'b0 ; 
              CRC <= 1'b0 ;
             end 
  end
  
endmodule
