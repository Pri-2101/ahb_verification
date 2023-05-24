
import uvm_pkg::*;
`include "uvm_macros.svh"
import apb_slave_agent_pkg::*;

class apb_slave_complete_sequence extends uvm_sequence #(apb_slave_access_item, apb_slave_setup_item);
   `uvm_object_utils(apb_slave_complete_sequence)

   slave_protocol_state_controller state_controller;
   
   extern function new(string name = "apb_slave_complete_sequence");
   extern task body;
endclass : apb_slave_complete_sequence

function apb_slave_complete_sequence::new(string name = "apb_slave_complete_sequence");
   super.new(name);
   state_controller = slave_protocol_state_controller::type_id::create("state_controller");
endfunction

task apb_slave_complete_sequence::body;
   apb_slave_agent_config master_agent_cfg = apb_slave_agent_config::get_config(m_sequencer);
   apb_slave_setup_item req;
   apb_slave_access_item rsp;
   uvm_sequence_item item;
   int i = 0;
   forever begin
      i++;
      //req = apb_slave_setup_item::type_id::create("req");
      rsp = apb_slave_access_item::type_id::create("rsp");

      start_item(rsp);
      state_controller.perform_action(rsp);
      finish_item(rsp);
      `uvm_info("Slave_RSP_ITEM_SENT_TO_MASTER", $sformatf("ITEM_%0d details are %s", i, rsp.convert2string()), UVM_LOW);

      get_response(req);
      //`uvm_info("Slave_REQ_ITEM_RCVD_FROM_MASTER", $sformatf("ITEM_%0d details are %s", i, req.convert2string()), UVM_LOW);
      
      state_controller.save_prev_req_item(req);
      state_controller.save_prev_rsp_item(rsp);
      //`uvm_info("CURRENT STATE", $sformatf("\nThe state is %s", state_controller.convert2string()), UVM_LOW);
      state_controller.determine_and_change_to_next_state();

   end // forever begin
   
endtask : body


