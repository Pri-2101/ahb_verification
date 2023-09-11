
import uvm_pkg::*;
`include "uvm_macros.svh"
import apb_slave_agent_pkg::*;

virtual class slave_base_state extends uvm_object;
   `uvm_object_utils(slave_base_state);

   protected rand apb_slave_access_item rsp_item_to_be_sent;
   protected bit[1:0] next_state;

   protected apb_slave_setup_item prev_req_item;
   protected apb_slave_access_item prev_rsp_item;

//   protected apb_slave_setup_item benched;

//-----------------------------------------------------------------------------------
   //User Functions
      
   extern function void save_prev_req_item(apb_slave_setup_item prev_req);
   extern function void save_prev_rsp_item(apb_slave_access_item prev_rsp);

   pure virtual function void set_data_items;
   pure virtual function bit[1:0] determine_and_change_to_next_state();
   pure virtual function void perform_action(ref apb_slave_access_item current_rsp);

//-----------------------------------------------------------------------------------
   //standard UVM object functions   

   extern function new(string name = "slave_base_state");
   extern function void do_copy(uvm_object rhs);
   extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
   extern function string convert2string();
   extern function void do_print(uvm_printer printer);
   extern function void do_record(uvm_recorder recorder);
endclass : slave_base_state


//-----------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------
//User Functions
function void slave_base_state::save_prev_req_item(apb_slave_setup_item prev_req);
   prev_req_item.copy(prev_req);
endfunction : save_prev_req_item

function void slave_base_state::save_prev_rsp_item(apb_slave_access_item prev_rsp);
   prev_rsp_item.copy(prev_rsp);
endfunction: save_prev_rsp_item


//-----------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------
//Standard UVM Object Functions

function slave_base_state::new(string name = "slave_base_state");
   super.new(name);
   next_state = param_enums::HIGH_OKAY;
   rsp_item_to_be_sent = new;
   prev_req_item = new;
   prev_rsp_item = new;
endfunction

function void slave_base_state::do_copy(uvm_object rhs);
   slave_base_state rhs_;
   if(!$cast(rhs_, rhs)) begin
     `uvm_fatal("do_copy","Cannot cast rhs state object into slave_base_state");
   end
   super.do_copy(rhs);
endfunction: do_copy

function bit slave_base_state::do_compare(uvm_object rhs, uvm_comparer comparer);
   slave_base_state rhs_;
   if(!$cast(rhs_, rhs)) begin
       `uvm_error("do_compare_error", "Could not cast the rhs object");
   end
   return super.compare(rhs) 
        && (this.rsp_item_to_be_sent.compare(rhs_.rsp_item_to_be_sent))
        && (this.next_state == rhs_.next_state);
endfunction: do_compare

function string slave_base_state::convert2string();
   string s;
   $sformat(s, "%s\n", super.convert2string());
   //$sformat(s, "%s\n Previous REQ item is %s\n Previous RSP item is %s", s, prev_req_item.convert2string(), prev_rsp_item.convert2string()); 
   return s;
endfunction: convert2string

function void slave_base_state::do_print(uvm_printer printer);
    printer.m_string = convert2string();
endfunction : do_print

function void slave_base_state::do_record(uvm_recorder recorder);
    super.do_record(recorder);
   `uvm_record_field("next_state", next_state);
endfunction: do_record