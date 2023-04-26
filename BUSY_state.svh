import uvm_pkg::*;
`include "uvm_macros.svh"
import apb_master_agent_pkg::*;

class BUSY_state extends base_state;
   `uvm_object_utils(BUSY_state);

   bit transfer_not_complete;
   int no_of_transfers;
   bit is_burst;
   bit is_wrapping_burst;
   
   logic [31:0] HADDR_boundary;
   logic [7:0] size_increment;
   logic [31:0] HADDR_wrap_start_address;
   
//-----------------------------------------------------------------------------------
   //User Functions
   extern function void update_transfer_variables;

   extern function void set_data_items;
   extern function bit[1:0] determine_and_change_to_next_state();
   extern function void perform_action(ref apb_master_setup_item current_req);
   
//-----------------------------------------------------------------------------------
   //standard UVM object functions   
   extern function new(string name = "BUSY_state");
   extern function void do_copy(uvm_object rhs);
   extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
   extern function string convert2string();
   extern function void do_print(uvm_printer printer);
   extern function void do_record(uvm_recorder recorder);
endclass : BUSY_state

//-----------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------
   //User Functions

//-----------------------PERFORM_ACTION------------------------------

function void BUSY_state::perform_action(ref apb_master_setup_item current_req);
   req_item_to_be_sent = apb_master_setup_item::type_id::create("req_item_to_be_sent");
   //this.IDLE_state_to_next_state_constraint::constraint_mode(0);
   req_item_to_be_sent.randomize();
   set_data_items();
   update_transfer_variables();

   current_req = req_item_to_be_sent;
endfunction : perform_action

//-----------------------SET_DATA_ITEMS------------------------------

function void BUSY_state::set_data_items;

 req_item_to_be_sent.HWRITE = prev_req_item.HWRITE;
 req_item_to_be_sent.HBURST = prev_req_item.HBURST;
 req_item_to_be_sent.HSIZE = prev_req_item.HSIZE;
  //if slave wasn't ready, hold the data
 if(prev_rsp_item.HREADY == LOW) begin
    req_item_to_be_sent.HADDR = prev_req_item.HADDR;
 end
 else begin
    req_item_to_be_sent.HADDR = prev_req_item.HADDR + size_increment;

    if(is_wrapping_burst) begin
       if(req_item_to_be_sent.HADDR == HADDR_boundary) begin
	  req_item_to_be_sent.HADDR = HADDR_wrap_start_address;
       end
   end
 end // else: !if(prev_rsp_item.HREADY == LOW)

endfunction : set_data_items

//-----------------------UPDATE_TRANSFER_VARIABLES------------------------------

function void BUSY_state::update_transfer_variables;
   no_of_transfers--;
   if(no_of_transfers == 0) begin
      transfer_not_complete = 0;
   end
endfunction : update_transfer_variables

//-----------------------DETERMINE_AND_CHANGE_TO_NEXT_STATE----------------------
function bit[1:0] BUSY_state::determine_and_change_to_next_state;
   //We are only talking about multiple burst transfers, as the any transfer must start with a NONSEQ transfer type
    if(no_of_transfers > 1) begin
	    if(prev_req_item.HTRANS == NONSEQ) begin
	       std::randomize(next_state) with {next_state inside {IDLE, SEQ, BUSY};};
    	    end
	    else begin
	        if(prev_req_item.HTRANS == SEQ) begin
	            std::randomize(next_state) with {next_state inside {SEQ, BUSY};};
	        end
  	    end
    end
    else begin
        std::randomize(next_state) with {next_state inside {IDLE, NONSEQ};};
    end

    return next_state;
endfunction : determine_and_change_to_next_state


//-----------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------
   //Standard UVM object functions

//-----------------------NEW------------------------------

function BUSY_state::new(string name = "BUSY_state");
   super.new(name);
   next_state = IDLE;
   no_of_transfers = 1;
   is_wrapping_burst = 0;
//next_state_candidates = {idle_state_obj, seq_state_obj, nonseq_state_obj, busy_state_obj};
endfunction

//-----------------------DO_COPY------------------------------

function void BUSY_state::do_copy(uvm_object rhs);
   NONSEQ_state rhs_nonseq;
   SEQ_state rhs_seq;
   BUSY_state rhs_busy;

   if(!$cast(rhs_nonseq, rhs)) begin
       this.no_of_transfers = rhs_nonseq.no_of_transfers;
       this.is_burst = rhs_nonseq.is_burst;
       this.is_wrapping_burst = rhs_nonseq.is_wrapping_burst;
       this.HADDR_boundary = rhs_nonseq.HADDR_boundary;
       this.size_increment = rhs_nonseq.size_increment;
       this.HADDR_wrap_start_address = rhs_nonseq.HADDR_wrap_start_address;
       this.transfer_not_complete = 1;
   end

   if(!$cast(rhs_seq, rhs)) begin
       this.no_of_transfers = rhs_seq.no_of_transfers;
       this.is_burst = rhs_seq.is_burst;
       this.is_wrapping_burst = rhs_seq.is_wrapping_burst;
       this.HADDR_boundary = rhs_seq.HADDR_boundary;
       this.size_increment = rhs_seq.size_increment;
       this.HADDR_wrap_start_address = rhs_seq.HADDR_wrap_start_address;
       this.transfer_not_complete = 1;
   end

   if(!$cast(rhs_busy, rhs)) begin
       this.no_of_transfers = rhs_busy.no_of_transfers;
       this.is_burst = rhs_busy.is_burst;
       this.is_wrapping_burst = rhs_busy.is_wrapping_burst;
       this.HADDR_boundary = rhs_busy.HADDR_boundary;
       this.size_increment = rhs_busy.size_increment;
       this.HADDR_wrap_start_address = rhs_busy.HADDR_wrap_start_address;
       this.transfer_not_complete = 1;
   end
   
endfunction : do_copy

function bit BUSY_state::do_compare(uvm_object rhs, uvm_comparer comparer);
    BUSY_state rhs_;
    if(!$cast(rhs_, rhs)) begin
        `uvm_error("do_compare_cast_error", "Cannot cast the RHS object into BUSY state object");
    end

    return (super.do_compare(rhs,comparer)) &&
           (rhs_.transfer_not_complete == transfer_not_complete) &&
           (rhs_.no_of_transfers == no_of_transfers) &&
           (rhs_.is_burst == is_burst) &&
           (rhs_.is_wrapping_burst == is_wrapping_burst) &&
           (rhs_.HADDR_boundary === HADDR_boundary) &&
           (rhs_.size_increment == size_increment) &&
           (rhs_.HADDR_wrap_start_address == HADDR_wrap_start_address);
endfunction: do_compare

function string BUSY_state::convert2string();
    string s;
    $sformatf(s, "%s\n", super.convert2string());
    $sformatf(s, "%s\n TRANSFER_NOT_COMPLETE\t%0b\n No_OF_TRANSFERS\t%0d\n IS_BURST\t%b\n IS_WRAPPING_BURST\t%0b\n HADDR_BOUNDARY\t%0h\n SIZE_INCREMENT\t%0h\n HADDR_WRAP_START_ADDRESS\t%0h\n", s, transfer_not_complete, is_burst, is_wrapping_burst, HADDR_boundary, size_increment, HADDR_wrap_start_address);
    return s;
endfunction: convert2string

function void BUSY_state::do_print(uvm_printer printer);
   printer.m_string = convert2string();
endfunction : do_print

function void BUSY_state::do_record(uvm_recorder recorder);
    super.do_record(recorder);
    `uvm_record_field("transfer_not_complete", transfer_not_complete);
    `uvm_record_field("no_of_transfers", no_of_transfers);
    `uvm_record_field("is_burst", is_burst);
    `uvm_record_field("is_wrapping_burst", is_wrapping_burst);
    `uvm_record_field("HADDR_boundary", HADDR_boundary);
    `uvm_record_field("size_increment", size_increment);
    `uvm_record_field("HADDR_wrap_start_address", HADDR_wrap_start_address);
endfunction: do_record
