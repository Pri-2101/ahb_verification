import uvm_pkg::*;
`include "uvm_macros.svh"
import apb_slave_agent_pkg::*;

class HIGH_ERROR_state extends slave_base_state;
   `uvm_object_utils(HIGH_ERROR_state);
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
   extern function new(string name = "HIGH_ERROR_state");
   extern function void do_copy(uvm_object rhs);
   //extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
   extern function string convert2string();
   extern function void do_print(uvm_printer printer);
   extern function void do_record(uvm_recorder recorder);
endclass : HIGH_ERROR_state

//-----------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------
   //User Functions

//-----------------------SET_DATA_ITEMS------------------------------

function void HIGH_ERROR_state::set_data_items;
   rsp_item_to_be_sent.HREADY = param_enums::HIGH;
   rsp_item_to_be_sent.HRESP = param_enums::ERROR;
   if(prev_req_item.HWRITE == 1'b1 || prev_req_item.HTRANS ==  param_enums::IDLE)
       rsp_item_to_be_sent.HRDATA = 32'hzzzz_zzzz;
//   else begin
//       if(reserve.compare(prev_req_item)) begin
//            rsp_item_to_be_sent.HRDATA = reserve.HRDATA;
//       end
//   end
endfunction : set_data_items


//-----------------------PERFORM_ACTION------------------------------

function void HIGH_ERROR_state::perform_action(ref apb_slave_access_item current_rsp);
   rsp_item_to_be_sent = apb_slave_access_item::type_id::create("rsp_item_to_be_sent");
   rsp_item_to_be_sent.randomize();
   set_data_items();
   current_rsp.copy(rsp_item_to_be_sent);
endfunction : perform_action

//-----------------------DETERMINE_AND_CHANGE_TO_NEXT_STATE------------------------------

function bit[1:0] HIGH_ERROR_state::determine_and_change_to_next_state;
   next_state = param_enums::HIGH_OKAY;
   return next_state;
endfunction : determine_and_change_to_next_state
    

//-----------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------
   //Standard UVM object functions

//-----------------------NEW------------------------------

function HIGH_ERROR_state::new(string name = "HIGH_ERROR_state");
   super.new(name);
endfunction

//-----------------------DO_COPY------------------------------
 
function void HIGH_ERROR_state::do_copy(uvm_object rhs);
//
endfunction : do_copy

function string HIGH_ERROR_state::convert2string();
   string s;
   $sformat(s, "%s\n", super.convert2string());
   $sformat(s, "%s\n HIGH_ERROR_state", s);
   return s;
endfunction: convert2string

function void HIGH_ERROR_state::do_print(uvm_printer printer);
   printer.m_string = convert2string();
endfunction : do_print

function void HIGH_ERROR_state::do_record(uvm_recorder recorder);
//
endfunction: do_record
