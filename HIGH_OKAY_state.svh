import uvm_pkg::*;
`include "uvm_macros.svh"
import apb_slave_agent_pkg::*;

class HIGH_OKAY_state extends slave_base_state;
   `uvm_object_utils(HIGH_OKAY_state);
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
   extern function new(string name = "HIGH_OKAY_state");
   extern function void do_copy(uvm_object rhs);
   //extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
   extern function string convert2string();
   extern function void do_print(uvm_printer printer);
   extern function void do_record(uvm_recorder recorder);
endclass : HIGH_OKAY_state

//-----------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------
   //User Functions

//-----------------------SET_DATA_ITEMS------------------------------

function void HIGH_OKAY_state::set_data_items;
   rsp_item_to_be_sent.HREADY = param_enums::HIGH;
   rsp_item_to_be_sent.HRESP = param_enums::OKAY;
   if(prev_req_item.HWRITE == 1'b1 || prev_req_item.HTRANS ==  param_enums::IDLE || prev_req_item.HWRITE == 1'bx)
       rsp_item_to_be_sent.HRDATA = 32'hzzzz_zzzz;
//   else begin
//       if(reserve.compare(prev_req_item)) begin
//            rsp_item_to_be_sent.HRDATA = reserve.HRDATA;
//       end
//   end
endfunction : set_data_items


//-----------------------PERFORM_ACTION------------------------------

function void HIGH_OKAY_state::perform_action(ref apb_slave_access_item current_rsp);
   rsp_item_to_be_sent = apb_slave_access_item::type_id::create("rsp_item_to_be_sent");
   rsp_item_to_be_sent.randomize();
   set_data_items();
   current_rsp.copy(rsp_item_to_be_sent);
endfunction : perform_action

//-----------------------DETERMINE_AND_CHANGE_TO_NEXT_STATE------------------------------

function bit[1:0] HIGH_OKAY_state::determine_and_change_to_next_state;
//   if(no_of_transfers > 1) begin
//      std::randomize(next_state) with {next_state inside {param_enums::LOW_OKAY, param_enums::LOW_ERROR}; next_state dist {param_enums::}};
//   end
//   else begin
      std::randomize(next_state) with {next_state inside {param_enums::HIGH_OKAY, param_enums::LOW_ERROR, param_enums::LOW_OKAY}; next_state dist {param_enums::HIGH_OKAY := 400, param_enums::LOW_OKAY := 200, param_enums::LOW_ERROR := 80};};
//   end
   return next_state;
endfunction : determine_and_change_to_next_state
    

//-----------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------
   //Standard UVM object functions

//-----------------------NEW------------------------------

function HIGH_OKAY_state::new(string name = "HIGH_OKAY_state");
   super.new(name);
endfunction

//-----------------------DO_COPY------------------------------
 
function void HIGH_OKAY_state::do_copy(uvm_object rhs);
//
endfunction : do_copy

function string HIGH_OKAY_state::convert2string();
   string s;
   $sformat(s, "%s\n", super.convert2string());
   $sformat(s, "%s\n HIGH_OKAY_state", s);
   return s;
endfunction

function void HIGH_OKAY_state::do_print(uvm_printer printer);
   printer.m_string = convert2string();
endfunction : do_print

function void HIGH_OKAY_state::do_record(uvm_recorder recorder);
//
endfunction: do_record
