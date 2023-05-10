import uvm_pkg::*;
import apb_slave_agent_pkg::*;
`include "uvm_macros.svh"


class apb_slave_agent extends uvm_agent;
  `uvm_component_utils(apb_slave_agent)
  apb_slave_agent_config slave_agent_cfg;

  uvm_analysis_port #(apb_slave_setup_item) setup_ap;
  apb_slave_monitor   slave_monitor;
  apb_slave_sequencer slave_sequencer;
  apb_slave_driver    slave_driver;
 // item_listener listener;

  extern function new(string name = "apb_slave_agent", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);

endclass: apb_slave_agent


function apb_slave_agent::new(string name = "apb_slave_agent", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void apb_slave_agent::build_phase(uvm_phase phase);
  slave_agent_cfg = apb_slave_agent_config::get_config(this);
  slave_monitor = apb_slave_monitor::type_id::create("slave_monitor", this);
  if(slave_agent_cfg.active == UVM_ACTIVE) begin
    slave_driver = apb_slave_driver::type_id::create("slave_driver", this);
    slave_sequencer = apb_slave_sequencer::type_id::create("slave_sequencer", this);
  end
  //listener = item_listener::type_id::create("item_listener", this);
endfunction: build_phase

function void apb_slave_agent::connect_phase(uvm_phase phase);
  setup_ap = slave_monitor.req_ap;
  //ap.connect(listener.analysis_export);
  if(slave_agent_cfg.active == UVM_ACTIVE) begin
    slave_driver.seq_item_port.connect(slave_sequencer.seq_item_export);
  end
endfunction: connect_phase
