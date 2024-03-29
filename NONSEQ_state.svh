import uvm_pkg::*;
`include "uvm_macros.svh"
import apb_master_agent_pkg::*;

class NONSEQ_state extends base_state;
   `uvm_object_utils(NONSEQ_state);

   rand int no_of_transfers;
   bit is_wrapping_burst;
   bit is_burst;
   
   logic [31:0] HADDR_boundary;
   logic [7:0] size_increment;
   logic [31:0] HADDR_wrap_start_address;
   
//-----------------------------------------------------------------------------------
   //User Functions
   extern function void set_size_increment_values;

   extern function void set_data_items;
   extern function bit[1:0] determine_and_change_to_next_state();
   extern function void perform_action(ref apb_master_setup_item current_req);
  
//-----------------------------------------------------------------------------------
   //standard UVM object functions   
   extern function new(string name = "NONSEQ_state");
   extern function void do_copy(uvm_object rhs);
   extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
   extern function string convert2string();
   extern function void do_print(uvm_printer printer);
   extern function void do_record(uvm_recorder recorder);
endclass : NONSEQ_state

//-----------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------
   //User Functions

//-----------------------SET_DATA_ITEMS------------------------------

function void NONSEQ_state::set_data_items;
   int 		temp;
   req_item_to_be_sent.HTRANS = param_enums::NONSEQ;
   
   if(req_item_to_be_sent.HBURST !== param_enums::SINGLE || req_item_to_be_sent.HBURST !== param_enums::INCR ) begin
      is_burst = 1'b1;
      
      if(req_item_to_be_sent.HBURST == param_enums::WRAP4) begin
	 is_wrapping_burst = 1'b1;
	 no_of_transfers = 4;
	 temp = ($pow(2, req_item_to_be_sent.HSIZE)/4) * 4;
	 HADDR_wrap_start_address  = ($floor(req_item_to_be_sent.HADDR / temp )) * temp;
	 HADDR_boundary = HADDR_wrap_start_address + temp;
      end
      
      if(req_item_to_be_sent.HBURST == param_enums::WRAP8) begin
	 is_wrapping_burst = 1'b1;
	 no_of_transfers = 8;
	 temp = ($pow(2, req_item_to_be_sent.HSIZE)/4) * 8;
	 HADDR_wrap_start_address  = ($floor(req_item_to_be_sent.HADDR / temp )) * temp;
	 HADDR_boundary = HADDR_wrap_start_address + temp;
      end

      if(req_item_to_be_sent.HBURST == param_enums::WRAP16) begin
	 is_wrapping_burst = 1'b1;
	 no_of_transfers = 16;
	 temp = ($pow(2, req_item_to_be_sent.HSIZE)/4) * 16;
	 HADDR_wrap_start_address  = ($floor(req_item_to_be_sent.HADDR / temp )) * temp;
	 HADDR_boundary = HADDR_wrap_start_address + temp;
      end
      
      if(req_item_to_be_sent.HBURST == param_enums::INCR4)
	no_of_transfers = 4;
      if(req_item_to_be_sent.HBURST == param_enums::INCR8)
	no_of_transfers = 8;
      if(req_item_to_be_sent.HBURST == param_enums::INCR16)
	no_of_transfers = 16;
   end // else: !if(req_item_to_be_sent.HBURST !== SINGLE )
   else begin
      if(req_item_to_be_sent.HBURST == param_enums::INCR) begin
	 is_burst = 1;
	 is_wrapping_burst = 0;
	 std::randomize(no_of_transfers) with {no_of_transfers inside {[1:50]};};
      end
      else begin
	 is_burst = 1'b0;
	 is_wrapping_burst = 1'b0;
	 no_of_transfers = 1;
      end // else: !if(req_item_to_be_sent.HBURST == INCR)
   end // else: !if(req_item_to_be_sent.HBURST !== SINGLE )
   
   if(req_item_to_be_sent.HWRITE == 1'b0) begin
      req_item_to_be_sent.HWDATA = 32'hzzzz_zzzz;
   end
endfunction : set_data_items

//-----------------------SET_SIZE_INCREMENT_VALUES------------------------------

function void NONSEQ_state::set_size_increment_values;
   if(req_item_to_be_sent.HSIZE == param_enums::BYTE)
     size_increment = 8'h01;
   if(req_item_to_be_sent.HSIZE == param_enums::HALF_WORD)
     size_increment = 8'h02;
   if(req_item_to_be_sent.HSIZE == param_enums::WORD)
     size_increment = 8'h04;
   if(req_item_to_be_sent.HSIZE == param_enums::DOUBLE_WORD)
     size_increment = 8'h08;
   if(req_item_to_be_sent.HSIZE == param_enums::FOUR_WORD_LINE)
     size_increment = 8'h0F;
   if(req_item_to_be_sent.HSIZE == param_enums::EIGHT_WORD_LINE)
     size_increment = 8'h20;
   if(req_item_to_be_sent.HSIZE == param_enums::FIVE_TWELVE)
     size_increment = 8'h40;
   if(req_item_to_be_sent.HSIZE == param_enums::FIVE_TWELVE)
     size_increment = 8'h80;
endfunction : set_size_increment_values


//-----------------------PERFORM_ACTION------------------------------

function void NONSEQ_state::perform_action(ref apb_master_setup_item current_req);
   req_item_to_be_sent = apb_master_setup_item::type_id::create("req_item_to_be_sent");
   req_item_to_be_sent.randomize();
   set_size_increment_values();
   set_data_items();

   current_req.copy(req_item_to_be_sent);
endfunction : perform_action

//-----------------------DETERMINE_AND_CHANGE_TO_NEXT_STATE------------------------------

function bit[1:0] NONSEQ_state::determine_and_change_to_next_state;
    if(no_of_transfers > 1) begin
        std::randomize(next_state) with {next_state inside {param_enums::SEQ, param_enums::BUSY}; next_state dist {param_enums::SEQ := 200, param_enums::BUSY := 20};};
    end // if it is a burst transfer, go next to BUSY or SEQ state, irrespective of previous state
    else begin
        std::randomize(next_state) with {next_state inside {param_enums::IDLE, param_enums::NONSEQ}; next_state dist {param_enums::IDLE := 60, param_enums::NONSEQ := 25};};
    end

    return next_state;
endfunction : determine_and_change_to_next_state
    

//-----------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------
   //Standard UVM object functions

//-----------------------NEW------------------------------

function NONSEQ_state::new(string name = "NONSEQ_state");
   super.new(name);
   no_of_transfers = 1;
   next_state = param_enums::IDLE;
   is_wrapping_burst = 0;
   is_burst = 0;   
endfunction

//-----------------------DO_COPY------------------------------
 
function void NONSEQ_state::do_copy(uvm_object rhs);
    NONSEQ_state rhs_;
    if(!$cast(rhs_, rhs)) begin
        `uvm_fatal("do_copy_error", "Cannot cast rhs object into NONSEQ state");
    end   
    this.is_burst = rhs_.is_burst;
    this.is_wrapping_burst = rhs_.is_wrapping_burst;
    this.HADDR_boundary = rhs_.HADDR_boundary;
    this.HADDR_wrap_start_address = rhs_.HADDR_wrap_start_address;
    this.no_of_transfers = rhs_.no_of_transfers;
    this.size_increment = rhs_.size_increment;
endfunction : do_copy

function bit NONSEQ_state::do_compare(uvm_object rhs, uvm_comparer comparer);
    NONSEQ_state rhs_;
    if(!$cast(rhs_, rhs)) begin
        `uvm_error("do_compare_cast_error", "Cannot cast the RHS object into BUSY state object");
    end

    return (super.do_compare(rhs,comparer)) &&
           (rhs_.no_of_transfers == no_of_transfers) &&
           (rhs_.is_burst == is_burst) &&
           (rhs_.is_wrapping_burst == is_wrapping_burst) &&
           (rhs_.HADDR_boundary === HADDR_boundary) &&
           (rhs_.size_increment == size_increment) &&
           (rhs_.HADDR_wrap_start_address == HADDR_wrap_start_address);
endfunction: do_compare

function string NONSEQ_state::convert2string();
    string s;
    $sformat(s, "%s\n", super.convert2string());
    $sformat(s, "NONSEQ STATE \n%s\n No_OF_TRANSFERS\t%0d\n IS_BURST\t%b\n IS_WRAPPING_BURST\t%0b\n HADDR_BOUNDARY\t%0h\n SIZE_INCREMENT\t%0h\n HADDR_WRAP_START_ADDRESS\t%0h\n", s, no_of_transfers, is_burst, is_wrapping_burst, HADDR_boundary, size_increment, HADDR_wrap_start_address);
    return s;
endfunction: convert2string

function void NONSEQ_state::do_print(uvm_printer printer);
   printer.m_string = convert2string();
endfunction : do_print

function void NONSEQ_state::do_record(uvm_recorder recorder);
    super.do_record(recorder);
    `uvm_record_field("no_of_transfers", no_of_transfers);
    `uvm_record_field("is_burst", is_burst);
    `uvm_record_field("is_wrapping_burst", is_wrapping_burst);
    `uvm_record_field("HADDR_boundary", HADDR_boundary);
    `uvm_record_field("size_increment", size_increment);
    `uvm_record_field("HADDR_wrap_start_address", HADDR_wrap_start_address);
endfunction: do_record
