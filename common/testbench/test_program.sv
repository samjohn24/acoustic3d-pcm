//--------------------------------------------------------------------------
// test_program.sv 
// This is the test program for Custom Pattern Generator which is used to
// test memory controller.
// Test cases:
// 1. Walking ones
// 2. Low frequency
// 3. Random numbers
//
// Revised 2011/09/30
//
//--------------------------------------------------------------------------

`include "test_include.svh"

module test_program();

  //----------------------------------------------------------------------------------
  // Importing verbosity and avalon_mm packages
  //----------------------------------------------------------------------------------
  import verbosity_pkg::*;
  //import avalon_mm_pkg::*;
  
  //----------------------------------------------------------------------------------
  // Internal variables here
  //----------------------------------------------------------------------------------
  string INPUT_FILE, BYTE_REVERSED_INPUT_FILE;  
  int       test_pattern[`NUM_OF_PATTERN];
  int       reversed_test_pattern[`NUM_OF_PATTERN];
  int		data_received[`NUM_OF_PAYLOAD_WORDS];
  int		test_result;  

  logic ipg_clk_dec_latched;  
  logic ipg_clk_dec16_latched; 
  
  //----------------------------------------------------------------------------------
  // Set verbosity before the test starts
  // Qsys-generated testbench activates clock and reset BMFs
  //----------------------------------------------------------------------------------
  initial
  begin
	set_verbosity(`VERBOSITY);
  end
  

  //----------------------------------------------------------------------------------
  // Main test block
  //----------------------------------------------------------------------------------
  initial
  begin    		
    wait(`MIC_IF_INST.ipg_hard_async_reset_b == 1); //wait for reset inactive
    mic_if_init;
    repeat (10000)  @(posedge `CLOCK_BFM.clk);
    force `JTAG_UART.fifo_FF = 1'b1; 
    repeat (5000)  @(posedge `CLOCK_BFM.clk);
    release `JTAG_UART.fifo_FF; 

//    wait(`CSR_MASTER.reset == 0); //wait for reset inactive
//	
//	//initialize BFMs
//	`CSR_MASTER.init();
//	`PATTERN_MASTER.init();
//	`PATTERN_SINK.init();
//	`PATTERN_SINK.set_ready(1); //the SINK BFM is always ready for data
//	
//	$sformat(message, "%m: Starting test %s", `FILENAME);
//	print(VERBOSITY_INFO, message);
//	
//	//read test pattern into arrays. The data output by generator is in byte-reversed orders, 
//	//hence another reversed pattern file is used for verification purpose
//	read_file(`FILENAME, test_pattern);	  
//	read_file(`FILENAME_REV, reversed_test_pattern);	  
//	  
//	//make sure the generator is stopped
//	csr_master_set_cmd(REQ_WRITE, `CONTROL_REG, 32'h0, `FULL_BYTE);
//	
//	//populate test pattern into the generator
//  for(int i=0; i<(`NUM_OF_PATTERN); i=i+1)
//	begin
//	  pattern_master_set_cmd(i, test_pattern[i], `FULL_BYTE);
//	end
//	
//	//disable infinite payload length
//	csr_master_set_cmd(REQ_WRITE, `CONTROL_REG, 32'h0, `FULL_BYTE);
//	
//	//set payload length
//	csr_master_set_cmd(REQ_WRITE, `PAYLOAD_LENGTH_REG, `NUM_OF_PAYLOAD_BYTES, `FULL_BYTE);
//	
//	//set pattern length
//	csr_master_set_cmd(REQ_WRITE, `PATTERN_SETTINGS_REG, `NUM_OF_PATTERN, `LOWER_HALFBYTE);	
//	
//	//set pattern position
//	csr_master_set_cmd(REQ_WRITE, `PATTERN_SETTINGS_REG, `PATTERN_POSITION_SHIFT, `UPPER_HALFBYTE);
//	
//	//wait until all patterns being writen to the pattern generator and only start
//	while(`PATTERN_MASTER.all_transactions_complete() == 0)
//	begin
//	  @(posedge `CLOCK_BFM.clk);
//	end
//	
//	//start the generator
//	csr_master_set_cmd(REQ_WRITE, `CONTROL_REG, 32'h01000000, `FULL_BYTE);
//	
//	//get the data from generator and populate them into array
//	for(int j=0; j<`NUM_OF_PAYLOAD_WORDS; j=j+1)
//	begin
//	  @(`PATTERN_SINK.signal_transaction_received);
//	  `PATTERN_SINK.pop_transaction();    
//	  data_received[j] = `PATTERN_SINK.get_transaction_data();
//	end	
//	
//	//verify the data from generator with the initial pattern
//	compare_result(reversed_test_pattern, data_received, test_result);
//	
//	if(test_result == 0)
//	begin
//	  $sformat(message, "%m: Test %s passed", `FILENAME);
//	  print(VERBOSITY_INFO, message);
//	end
//	else begin
//	  $sformat(message, "%m: Test %s failed with %0d mismatches", `FILENAME, test_result);
//	  print(VERBOSITY_INFO, message);
//	end			
  end

  // ==========
  //  PDM data
  // ==========
  always @(`PDM_BFM.signal_input_pdm_clk_ff_change)
    `PDM_BFM.set_pdm_data($random);

  // ==============
  //  CLOCK GATING
  // ==============

  // Clock gating latches
  always_latch
  if (!`MIC_IF_INST.ipg_clk)
  begin
    ipg_clk_dec_latched   = `PDM_CG.get_enable_clk_dec();
    ipg_clk_dec16_latched = `PDM_CG.get_enable_clk_dec16();
  end

  always_comb
  begin
  // Clock gating and
  force `MIC_IF_INST.ipg_clk_dec = `MIC_IF_INST.ipg_clk & ipg_clk_dec_latched;
  force `MIC_IF_INST.ipg_clk_dec16 = `MIC_IF_INST.ipg_clk & ipg_clk_dec16_latched;
  end

  //----------------------------------------------------------------------------------
  // Tasks
  //----------------------------------------------------------------------------------
  
  task mic_if_init;
  begin
  @(posedge `CLOCK_BFM.clk);
  //force `MIC_IF_INST.mic_hiu.cic_osr_ff = 8'd51;
  //force `MIC_IF_INST.mic_hiu.shiftr_num_ff = 8'd17;
  //force `MIC_IF_INST.mic_hiu.clk_div_ff = 8'd10;
  force `MIC_IF_INST.mic_hiu.cic_osr_ff = 8'd25;
  //force `MIC_IF_INST.mic_hiu.shiftr_num_ff = 8'd12;
  force `MIC_IF_INST.mic_hiu.shiftr_num_ff = 8'd0;
  force `MIC_IF_INST.mic_hiu.clk_div_ff = 8'd20;
  force `MIC_IF_INST.mic_hiu.ch_en_ff = 40'hff_ffff_ffff;
  force `MIC_IF_INST.mic_hiu.aud_st_dis_ff = 1'b0;
  force `MIC_IF_INST.mic_hiu.sat_ff = 1'b1;
  force `MIC_IF_INST.mic_hiu.round_ff = 1'b1;
  force `MIC_IF_INST.mic_hiu.delay_reg_ff = '{1,2,3,4,5,6,7,8,9,10,
					      11,12,13,14,15,16,17,18,19,20,
					      21,22,23,24,25,26,27,28,29,30,
					      31,32,33,34,35,36,37,38,39,40};
	
  // Frame config
  force `MIC_IF_INST.mic_hiu.frame_en_ff = 1'b1;
  force `MIC_IF_INST.mic_hiu.frame_len_ff = 4'd5;//  (2**8 = 256)
  force `MIC_IF_INST.mic_hiu.frame_tag_ff = 8'd3; 
  @(posedge `CLOCK_BFM.clk);
  force `MIC_IF_INST.mic_enable_ff = 1'b1;
  end
  endtask
  
//  //this task read file and store the pattern into array
//  task read_file;
//    input string file_name;
//	output int data_array[`NUM_OF_PATTERN];
//	int	   file;
//	
//	begin
//	  file = $fopen(file_name, "r");
//      if (file != 0)
//	  begin
//        $fclose(file);
//        $sformat(message, "%m: Read file %s success", file_name);
//        print(VERBOSITY_INFO, message);
//        $readmemh(file_name, data_array);
//      end
//	  else begin
//        $fclose(file);
//        $sformat(message, "%m: Cannot open file: %s", file_name);
//        print(VERBOSITY_WARNING, message);
//	    $stop;
//      end
//	end  
//  endtask
//  
//  //this task sets the command descriptor for CSR_MASTER BFM and push it to the queue
//  task csr_master_set_cmd;
//	input Request_t request;
//	input [`CSR_MASTER_ADDRESS_W-1:0] addr;
//	input [`CSR_MASTER_DATA_W-1:0] data;
//	input [`CSR_MASTER_NUMSYMBOLS-1:0] byte_enable;	
//    
//	begin
//	  `CSR_MASTER.set_command_request(request);
//	  `CSR_MASTER.set_command_address(addr);    
//	  `CSR_MASTER.set_command_byte_enable(byte_enable, `INDEX_ZERO);
//	  `CSR_MASTER.set_command_idle(0, `INDEX_ZERO);
//	  `CSR_MASTER.set_command_init_latency(0);
//	
//	  if (request == REQ_WRITE)
//	  begin
//	    `CSR_MASTER.set_command_data(data, `INDEX_ZERO);      
//	  end
//		
//	  `CSR_MASTER.push_command();
//    end
//  endtask
//  
//  //this task sets the command descriptor for PATTERN_MASTER BFM and push it to the queue
//  task pattern_master_set_cmd;
//	input [`PATTERN_MASTER_ADDRESS_W-1:0] addr;
//	input [`PATTERN_MASTER_DATA_W-1:0] data;
//	input [`PATTERN_MASTER_NUMSYMBOLS-1:0] byte_enable;	
//    
//	begin
//	  `PATTERN_MASTER.set_command_request(REQ_WRITE);
//	  `PATTERN_MASTER.set_command_address(addr);    
//	  `PATTERN_MASTER.set_command_byte_enable(byte_enable, `INDEX_ZERO);
//	  `PATTERN_MASTER.set_command_idle(0, `INDEX_ZERO);
//	  `PATTERN_MASTER.set_command_init_latency(0);
//	  `PATTERN_MASTER.set_command_data(data, `INDEX_ZERO);      
//	  `PATTERN_MASTER.push_command();
//    end
//  endtask  
//  
//  //this task compare the expected pattern with the actual pattern generated
//  task compare_result;
//    input int original_data[`NUM_OF_PATTERN];
//	input int received_data[`NUM_OF_PAYLOAD_WORDS];
//	output int failure;
//	int pointer;
//	
//	begin
//	  failure = 0;
//	  
//	  for(int i=0; i<`NUM_OF_PAYLOAD_WORDS; i=i+1)
//	  begin
//		pointer = (i+`PATTERN_POSITION) % `NUM_OF_PATTERN;
//	    if (original_data[pointer] != received_data[i])
//	    begin
//		  $sformat(message, "%m: Pattern mismatch. Expected at %0d: %0h, Actual at %0d: %0h", pointer, original_data[pointer], i, received_data[i]);
//		  print(VERBOSITY_INFO, message);
//		  failure = failure + 1;
//	    end	  
//	  end	    
//	end
//  endtask  
  
endmodule
