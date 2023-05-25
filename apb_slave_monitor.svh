import uvm_pkg::*;
import apb_slave_agent_pkg::*;
`include "uvm_macros.svh"

class apb_slave_monitor extends uvm_monitor;

  `uvm_component_utils(apb_slave_monitor);

  virtual apb_slave_monitor_bfm slave_monitor_bfm;
  //Configuration object is being passed in from the above layers in the testbench
  apb_slave_agent_config slave_agent_cfg;

  uvm_analysis_port #(apb_slave_setup_item) req_ap;
  uvm_analysis_port #(apb_slave_access_item) rsp_ap;

  extern function new(string name = "apb_slave_monitor", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern function void report_phase(uvm_phase phase);

  // Proxy Methods:
  extern function void notify_setup(apb_slave_setup_item item);
  extern function void notify_access(apb_slave_access_item item);

endclass: apb_slave_monitor

function apb_slave_monitor::new(string name = "apb_slave_monitor", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void apb_slave_monitor::build_phase(uvm_phase phase);
  req_ap = new("req_ap", this);
  rsp_ap = new("rsp_ap", this);
  slave_agent_cfg = apb_slave_agent_config::get_config(this); //doing some basic error checking
  slave_monitor_bfm = slave_agent_cfg.slave_monitor_bfm; //Getting the BFM from the configuration object
  slave_monitor_bfm.set_apb_index(slave_agent_cfg.apb_index);
  slave_monitor_bfm.proxy = this; // storing the proxy to the tb monitor (i.e. this object) in the bfm viz. actually the INTERFACE
endfunction: build_phase

task apb_slave_monitor::run_phase(uvm_phase phase);
  slave_monitor_bfm.run();
endtask: run_phase

function void apb_slave_monitor::report_phase(uvm_phase phase);
  //
endfunction: report_phase

function void apb_slave_monitor::notify_setup(apb_slave_setup_item item);
  req_ap.write(item);
endfunction : notify_setup

function void apb_slave_monitor::notify_access(apb_slave_access_item item);
  rsp_ap.write(item);
endfunction : notify_access
