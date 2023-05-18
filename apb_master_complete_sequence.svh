import uvm_pkg::*;
`include "uvm_macros.svh"
import apb_master_agent_pkg::*;

class apb_master_complete_sequence extends uvm_sequence #(apb_master_setup_item, apb_master_access_item);
   `uvm_object_utils(apb_master_complete_sequence)

   protocol_state_controller state_controller;
   
   extern function new(string name = "apb_master_complete_sequence");
   extern task body;
endclass : apb_master_complete_sequence

function apb_master_complete_sequence::new(string name = "apb_master_complete_sequence");
   super.new(name);
   state_controller = protocol_state_controller::type_id::create("state_controller");
endfunction

task apb_master_complete_sequence::body;
   apb_master_agent_config master_agent_cfg = apb_master_agent_config::get_config(m_sequencer);
   apb_master_setup_item req;
   apb_master_access_item rsp;
   uvm_sequence_item item;
   int i = 0;
   forever begin
      i++;
      req = apb_master_setup_item::type_id::create("req");
      //rsp = apb_master_access_item::type_id::create("rsp");

      start_item(req);
      state_controller.perform_action(req);
      finish_item(req);
      //`uvm_info("Master_REQ_ITEM_SENT_TO_SLAVE", $sformatf("ITEM_%0d details are %s", i, req.convert2string()), UVM_LOW);
      
      //start_item(rsp);
      //finish_item(rsp);
      get_response(rsp);
      //$cast(rsp, item);
      //`uvm_info("Master_RSP_ITEM_RCVD_FROM_SLAVE", $sformatf("ITEM_%0d details are %s", i, rsp.convert2string()), UVM_LOW);

      state_controller.save_prev_req_item(req);
      state_controller.save_prev_rsp_item(rsp);
      `uvm_info("CURRENT STATE", $sformatf("\nThe current state is %s", state_controller.convert2string()), UVM_LOW);
      state_controller.determine_and_change_to_next_state();

   end // forever begin
   
endtask : body



