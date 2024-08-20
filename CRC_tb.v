`timescale 1ns/1ps
module CRC_tb ();
  
  ///////////// DUT signals ///////
  reg   DATA_tb;
  reg   Active_tb;
  reg   clk_tb;
  reg   RST_tb;
  wire  CRC_tb;
  wire  Valid_tb;
  
  /////////// parameters /////////
  parameter clock_period = 100;
  parameter Data_bits    = 8;
  parameter out_bits    = 8;
  parameter Test_Cases = 10;
  
  ///////// loop variable //////
  integer test_num ;
  
  //////// memories ///////
  reg [Data_bits-1 :0] DATA_test [Test_Cases-1 :0];
  reg [out_bits-1 :0] Expec_crc [Test_Cases-1 :0];
  
  //////// initial block ////////
  
  initial
   begin
     $dumpfile("CRC.vcd") ;       
     $dumpvars;
     
     $readmemh("DATA_h.txt", DATA_test);
     $readmemh("Expec_Out_h.txt", Expec_crc);
     
     initialize();
     
     for (test_num = 0; test_num < Test_Cases; test_num = test_num+1)
      begin
        do_operation(DATA_test [test_num]);
        
        check_operation(Expec_crc [test_num],test_num);
      end
      
      #200 $stop;
   end
   
   /////// initialize task //////
   task initialize ;
     begin
       clk_tb    = 1'b0;
       DATA_tb   = 1'b0;
       Active_tb = 1'b0;
       RST_tb    = 1'b0;
     end
    endtask
    
   //////// reset task ////////
   task reset ;
     begin
       RST_tb = 1'b1;
       #20
       RST_tb = 1'b0;
       #20
       RST_tb = 1'b1;
     end
    endtask
   
   ////// do_operation task ////
   task do_operation ;
    input reg [Data_bits-1 :0] data_in;
    integer i ;
    begin
      reset();
      @(negedge clk_tb)
      Active_tb = 1'b1;
      for(i=0; i < Data_bits; i = i+1)
      begin
        DATA_tb = data_in[i];
        #clock_period ;
      end
      Active_tb = 1'b0;
    end
  endtask
    
    /////check_operation task ///
    task check_operation ;
     input reg [out_bits-1 :0] exp_crc;
     input  integer             case_num ;
     reg       [out_bits-1 :0] generated_crc;
     integer x;
     begin
       @(posedge Valid_tb)
       for (x=0; x < out_bits; x = x+1)
       begin
         @(negedge clk_tb)
         generated_crc[x] = CRC_tb;
       end
       if (generated_crc == exp_crc)
         $display("Test Case %d is succeeded",case_num+1);
       else
         $display("Test Case %d is failed with CRC_out %h", case_num+1,generated_crc);
     end
    endtask
   
   //////////clock gnerating //////
   always #(clock_period/2) clk_tb = !clk_tb;
   
   //////// DUT Instantation ///////
  CRC DUT (
  .DATA(DATA_tb),
  .Active(Active_tb),
  .clk(clk_tb),
  .RST(RST_tb),
  .CRC(CRC_tb),
  .Valid(Valid_tb)
  );
   
   
 endmodule
