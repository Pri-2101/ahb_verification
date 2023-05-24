import uvm_pkg::*;
`include "uvm_macros.svh"
import apb_slave_agent_pkg::*;

class LOW_OKAY_state extends slave_base_state;
   `uvm_object_utils(LOW_OKAY_state);
   protected int no_of_transfers;
   protected bit transfer_not_complete;
   
//-----------------------------------------------------------------------------------
   //User Functions
//   extern function void set_size_increment_values;
   extern function void set_data_items;
   extern function bit[1:0] determine_and_change_to_next_state();
   extern function void perform_action(ref apb_slave_access_item current_rsp);
  
//-----------------------------------------------------------------------------------
   //standard UVM object functions   
   extern function new(string name = "LOW_OKAY_state");
   extern function void do_copy(uvm_object rhs);
   //extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
   extern function string convert2string();
   extern function void do_print(uvm_printer printer);
   extern function void do_record(uvm_recorder recorder);
endclass : LOW_OKAY_state

//-----------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------
   //User Functions

//-----------------------SET_DATA_ITEMS------------------------------

function void LOW_OKAY_state::set_data_items;
   rsp_item_to_be_sent.HREADY = param_enums::LOW;
   rsp_item_to_be_sent.HRESP = param_enums::OKAY;
   if(prev_req_item.HWRITE == 1'b1)
       rsp_item_to_be_sent.HRDATA = 32'h0;
endfunction : set_data_items


//-----------------------PERFORM_ACTION------------------------------

function void LOW_OKAY_state::perform_action(ref apb_slave_access_item current_rsp);
   rsp_item_to_be_sent = apb_slave_access_item::type_id::create("rsp_item_to_be_sent");
   rsp_item_to_be_sent.randomize();
   set_data_items();
   current_rsp.copy(rsp_item_to_be_sent);
endfunction : perform_action

//-----------------------DETERMINE_AND_CHANGE_TO_NEXT_STATE------------------------------

function bit[1:0] LOW_OKAY_state::determine_and_change_to_next_state;
   if(no_of_transfers > 1) begin
      std::randomize(next_state) with {next_state inside {param_enums::LOW_OKAY, param_enums::LOW_ERROR};};
   end
   else begin
      std::randomize(next_state) with {next_state inside {param_enums::HIGH_OKAY, param_enums::LOW_ERROR};};
   end
   return next_state;
endfunction : determine_and_change_to_next_state
    

//-----------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------
   //Standard UVM object functions

//-----------------------NEW------------------------------

function LOW_OKAY_state::new(string name = "LOW_OKAY_state");
   super.new(name);
endfunction

//-----------------------DO_COPY------------------------------
 
function void LOW_OKAY_state::do_copy(uvm_object rhs);
//
endfunction : do_copy

function string LOW_OKAY_state::convert2string();
   string s;
   $sformat(s, "%s\n", super.convert2string());
   $sformat(s, "%s\n LOW_OKAY_state", s);
   return s;
endfunction: convert2string

function void LOW_OKAY_state::do_print(uvm_printer printer);
   printer.m_string = convert2string();
endfunction : do_print

function void LOW_OKAY_state::do_record(uvm_recorder recorder);
//
endfunction: do_record
