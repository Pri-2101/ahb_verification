import uvm_pkg::*;
`include "uvm_macros.svh"
import apb_master_agent_pkg::*;

class protocol_state_controller extends uvm_object;
   `uvm_object_utils(protocol_state_controller)
    
   base_state _state;
   bit[1:0] current_state;

   apb_master_setup_item req_item_to_be_sent;
   bit[1:0] next_state;

   //storing the previous state values
   apb_master_setup_item prev_req_item;
   apb_master_access_item prev_rsp_item;

//-----------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------
   //User Functions
   
   extern function void change_state(base_state next_state);
   extern function void determine_and_change_to_next_state();
   
   extern function void save_prev_req_item(apb_master_setup_item prev_req);
   extern function void save_prev_rsp_item(apb_master_access_item prev_rsp);
   extern function void perform_action(ref apb_master_setup_item current_req);

//-----------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------
   //standard UVM object functions   
      
   extern function new(string name = "protocol_state_controller");
   extern function void do_copy(uvm_object rhs);
   extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
   extern function string convert2string();
   extern function void do_print(uvm_printer printer);
   extern function void do_record(uvm_recorder recorder);
endclass : protocol_state_controller

//-----------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------
   //User Functions

function void protocol_state_controller::change_state(base_state next_state);
   $cast(_state,next_state);
endfunction : change_state

function void protocol_state_controller::save_prev_req_item(apb_master_setup_item prev_req);
   //prev_req_item.copy(prev_req);
   _state.save_prev_req_item(prev_req);
endfunction : save_prev_req_item

function void protocol_state_controller::save_prev_rsp_item(apb_master_access_item prev_rsp);
   //prev_rsp_item.copy(prev_rsp);
   _state.save_prev_rsp_item(prev_rsp);
endfunction : save_prev_rsp_item

function void protocol_state_controller::perform_action(ref apb_master_setup_item current_req);
   _state.perform_action(current_req);
endfunction : perform_action

function void protocol_state_controller::determine_and_change_to_next_state();
    IDLE_state idle_state_h;
    SEQ_state seq_state_h;
    NONSEQ_state nonseq_state_h;
    BUSY_state busy_state_h;

    next_state = _state.determine_and_change_to_next_state();
   
    if(next_state == param_enums::NONSEQ) begin
        current_state = param_enums::NONSEQ;
        nonseq_state_h = NONSEQ_state::type_id::create("nonseq_state_h");
        _state = nonseq_state_h;
    end

    if(next_state == param_enums::SEQ) begin
        seq_state_h = SEQ_state::type_id::create("seq_state_h");
        if(current_state == param_enums::BUSY)
            seq_state_h.copy(BUSY_state'(_state));

        if(current_state == param_enums::NONSEQ)
            seq_state_h.copy(NONSEQ_state'(_state));

        if(current_state == param_enums::SEQ)
            seq_state_h.copy(SEQ_state'(_state));

        _state = seq_state_h;
        current_state = param_enums::SEQ;
    end   

    if(next_state == param_enums::BUSY) begin
        busy_state_h = BUSY_state::type_id::create("busy_state_h");

        if(current_state == param_enums::BUSY)
            busy_state_h.copy(BUSY_state'(_state));

        if(current_state == param_enums::NONSEQ)
            busy_state_h.copy(NONSEQ_state'(_state));

        if(current_state == param_enums::SEQ)
            busy_state_h.copy(SEQ_state'(_state));
 
        _state = busy_state_h;
        current_state = param_enums::BUSY;
    end
            
endfunction : determine_and_change_to_next_state


//-----------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------

function protocol_state_controller::new(string name = "protocol_state_controller");
    super.new(name);
    current_state = param_enums::IDLE;
    next_state = param_enums::IDLE;
    _state = IDLE_state::type_id::create("init_state");
endfunction

function void protocol_state_controller::do_copy(uvm_object rhs);
   protocol_state_controller rhs_;
   if(!$cast(rhs_, rhs)) begin
      `uvm_fatal("do_copy", "Cannot cast the rhs object properly");
   end
   super.do_copy(rhs);
   _state = rhs_._state;

endfunction : do_copy

function bit protocol_state_controller::do_compare(uvm_object rhs, uvm_comparer comparer);
   protocol_state_controller rhs_;
   if(!$cast(rhs_,rhs)) begin
      `uvm_fatal("do_compare", "Cannot cast the rhs object properly");
   end
   return (super.do_compare(rhs, comparer) && (_state == rhs_._state));
endfunction : do_compare

function string protocol_state_controller::convert2string();
    string s;
    $sformat(s, "%s\n", super.convert2string());
    $sformat(s, "%s\n %s\n", s, _state.convert2string());
    return s;
endfunction : convert2string

function void protocol_state_controller::do_print(uvm_printer printer);
  printer.m_string = convert2string();
endfunction : do_print

function void protocol_state_controller::do_record(uvm_recorder recorder);
   //
endfunction : do_record

