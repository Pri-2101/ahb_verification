import uvm_pkg::*;
import apb_slave_agent_pkg::*;
`include "uvm_macros.svh"

class apb_slave_driver extends uvm_driver #(apb_slave_access_item, apb_slave_setup_item);

  `uvm_component_utils(apb_slave_driver)

  virtual apb_slave_driver_bfm slave_driver_bfm;
  apb_slave_agent_config slave_agent_cfg;

  extern function new(string name = "apb_slave_driver", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);

endclass: apb_slave_driver

function apb_slave_driver::new(string name = "apb_slave_driver", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void apb_slave_driver::build_phase(uvm_phase phase);
  slave_agent_cfg = apb_slave_agent_config::get_config(this);
  slave_driver_bfm = slave_agent_cfg.slave_driver_bfm;
  slave_driver_bfm.set_apb_index(slave_agent_cfg.apb_index);
endfunction: build_phase

task apb_slave_driver::run_phase(uvm_phase phase);
  uvm_sequence_item item;
  apb_slave_setup_item req;
  apb_slave_access_item rsp;
  
  forever begin

    seq_item_port.get_next_item(rsp);
        slave_driver_bfm.access_phase(rsp); 
    seq_item_port.item_done();


    req = apb_slave_setup_item::type_id::create("req");
    req.set_id_info(rsp);
        slave_driver_bfm.setup_phase(req);
    seq_item_port.put(req);
  end

endtask: run_phase
