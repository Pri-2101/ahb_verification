
import uvm_pkg::*;
`include "uvm_macros.svh"
import apb_slave_agent_pkg::*;

class slave_protocol_state_controller extends uvm_object;
   `uvm_object_utils(slave_protocol_state_controller)
    
   slave_base_state _state;
   bit[1:0] current_state;

   apb_slave_setup_item req_item_to_be_sent;
   bit[1:0] next_state;

   //storing the previous state values
   apb_slave_setup_item prev_req_item;
   apb_slave_access_item prev_rsp_item;

//-----------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------
   //User Functions
   
   extern function void change_state(slave_base_state next_state);
   extern function void determine_and_change_to_next_state();
   
   extern function void save_prev_req_item(apb_slave_setup_item prev_req);
   extern function void save_prev_rsp_item(apb_slave_access_item prev_rsp);
   extern function void perform_action(ref apb_slave_access_item current_rsp);

//-----------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------
   //standard UVM object functions   
      
   extern function new(string name = "slave_protocol_state_controller");
   extern function void do_copy(uvm_object rhs);
   extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
   extern function string convert2string();
   extern function void do_print(uvm_printer printer);
   extern function void do_record(uvm_recorder recorder);
endclass : slave_protocol_state_controller

//-----------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------
   //User Functions

function void slave_protocol_state_controller::change_state(slave_base_state next_state);
   $cast(_state,next_state);
endfunction : change_state

function void slave_protocol_state_controller::save_prev_req_item(apb_slave_setup_item prev_req);
   //prev_req_item.copy(prev_req);
   _state.save_prev_req_item(prev_req);
endfunction : save_prev_req_item

function void slave_protocol_state_controller::save_prev_rsp_item(apb_slave_access_item prev_rsp);
   //prev_rsp_item.copy(prev_rsp);
   _state.save_prev_rsp_item(prev_rsp);
endfunction : save_prev_rsp_item

function void slave_protocol_state_controller::perform_action(ref apb_slave_access_item current_rsp);
   _state.perform_action(current_rsp);
endfunction : perform_action

function void slave_protocol_state_controller::determine_and_change_to_next_state();
    HIGH_OKAY_state high_okay_state_h;
    HIGH_ERROR_state high_error_state_h;
    LOW_OKAY_state low_okay_state_h;
    LOW_ERROR_state low_error_state_h;

    next_state = _state.determine_and_change_to_next_state();
   
    if(next_state == param_enums::HIGH_OKAY) begin
        current_state = param_enums::HIGH_OKAY;
        high_okay_state_h = HIGH_OKAY_state::type_id::create("high_okay_state_h");
        _state = high_okay_state_h;
    end

    if(next_state == param_enums::LOW_OKAY) begin
        low_okay_state_h = LOW_OKAY_state::type_id::create("low_okay_state_h");
//        if(current_state == param_enums::BUSY)
//            seq_state_h.copy(BUSY_state'(_state));
//
//        if(current_state == param_enums::NONSEQ)
//            seq_state_h.copy(NONSEQ_state'(_state));
//
//        if(current_state == param_enums::SEQ)
//            seq_state_h.copy(SEQ_state'(_state));

        _state = low_okay_state_h;
        current_state = param_enums::LOW_OKAY;
    end   

    if(next_state == param_enums::LOW_ERROR) begin
        low_error_state_h = LOW_ERROR_state::type_id::create("low_error_state_h");
        _state = low_error_state_h;
        current_state = param_enums::LOW_ERROR;
    end


    if(next_state == param_enums::HIGH_ERROR) begin
        high_error_state_h = HIGH_ERROR_state::type_id::create("low_error_state_h");
        _state = high_error_state_h;
        current_state = param_enums::HIGH_ERROR;
    end
            
endfunction : determine_and_change_to_next_state


//-----------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------

function slave_protocol_state_controller::new(string name = "slave_protocol_state_controller");
    super.new(name);
    current_state = param_enums::HIGH_OKAY;
    next_state = param_enums::HIGH_OKAY;
    _state = HIGH_OKAY_state::type_id::create("init_state");
endfunction

function void slave_protocol_state_controller::do_copy(uvm_object rhs);
   slave_protocol_state_controller rhs_;
   if(!$cast(rhs_, rhs)) begin
      `uvm_fatal("do_copy", "Cannot cast the rhs object properly");
   end
   super.do_copy(rhs);
   _state = rhs_._state;

endfunction : do_copy

function bit slave_protocol_state_controller::do_compare(uvm_object rhs, uvm_comparer comparer);
   slave_protocol_state_controller rhs_;
   if(!$cast(rhs_,rhs)) begin
      `uvm_fatal("do_compare", "Cannot cast the rhs object properly");
   end
   return (super.do_compare(rhs, comparer) && (_state == rhs_._state));
endfunction : do_compare

function string slave_protocol_state_controller::convert2string();
    string s;
    $sformat(s, "%s\n", super.convert2string());
    $sformat(s, "%s\n %s\n", s, _state.convert2string());
    return s;
endfunction : convert2string

function void slave_protocol_state_controller::do_print(uvm_printer printer);
  printer.m_string = convert2string();
endfunction : do_print

function void slave_protocol_state_controller::do_record(uvm_recorder recorder);
   //
endfunction : do_record
