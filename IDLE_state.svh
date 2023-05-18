import uvm_pkg::*;
`include "uvm_macros.svh"
import apb_master_agent_pkg::*;

class IDLE_state extends base_state;
   `uvm_object_utils(IDLE_state);
    
//-----------------------------------------------------------------------------------
   //User Functions   
   extern function void set_data_items;
   extern function bit[1:0] determine_and_change_to_next_state();
   extern function void perform_action(ref apb_master_setup_item current_req);
   
//-----------------------------------------------------------------------------------
   //standard UVM object functions   
   extern function new(string name = "IDLE_state");
   extern function void do_copy(uvm_object rhs);
   extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
   extern function string convert2string();
   extern function void do_print(uvm_printer printer);
   extern function void do_record(uvm_recorder recorder);
endclass : IDLE_state

//-----------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------
// User Functions

function void IDLE_state::set_data_items;
 req_item_to_be_sent.HADDR = 32'h0000_0000;
 req_item_to_be_sent.HTRANS = param_enums::IDLE;
 req_item_to_be_sent.HSIZE = param_enums::WORD;
 req_item_to_be_sent.HWRITE = 1'b0;
 req_item_to_be_sent.HWDATA = 32'h0000_0000;
 req_item_to_be_sent.HBURST = param_enums::SINGLE;
endfunction : set_data_items

//-----------------------DETERMINE_AND_CHANGE_TO_NEXT_STATE---------------------
function bit[1:0] IDLE_state::determine_and_change_to_next_state();
    if((prev_req_item.HTRANS == param_enums::IDLE) && (prev_rsp_item.HREADY == param_enums::HIGH) && (prev_rsp_item.HRESP == param_enums::OKAY)) begin
        std::randomize(next_state) with {next_state inside {param_enums::IDLE, param_enums::NONSEQ};};
        //$display(next_state);
    end
    else begin
        next_state = param_enums::IDLE;
    end

    return next_state;
endfunction : determine_and_change_to_next_state

//-----------------------PERFORM_ACTION------------------------------
function void IDLE_state::perform_action(ref apb_master_setup_item current_req);
    set_data_items();
    current_req.copy(req_item_to_be_sent);
endfunction : perform_action

//-----------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------
   //standard UVM object functions   
  
function IDLE_state::new(string name = "IDLE_state");
   super.new(name);
endfunction

function void IDLE_state::do_copy(uvm_object rhs);
   base_state rhs_;
   if(!$cast(rhs_, rhs)) begin
     `uvm_fatal("do_copy_error","Cannot cast rhs state object into IDLE_state");
   end
   super.do_copy(rhs);
endfunction: do_copy

function bit IDLE_state::do_compare(uvm_object rhs, uvm_comparer comparer);
   return 1;
endfunction: do_compare

function string IDLE_state::convert2string();
    string s;
    $sformat(s, "%s\n", super.convert2string());
    $sformat(s, "IDLE STATE\n %s", s);
    return s;
endfunction: convert2string

function void IDLE_state::do_print(uvm_printer printer);
    printer.m_string = convert2string();
endfunction : do_print

function void IDLE_state::do_record(uvm_recorder recorder);
   //
endfunction: do_record
