import uvm_pkg::*;
import apb_master_agent_pkg::*;
`include "uvm_macros.svh"
//`include "apb_master_seq_item.svh"
//`include "apb_master_agent_config.svh"

class apb_master_monitor extends uvm_monitor;
    `uvm_component_utils(apb_master_monitor);

    virtual apb_master_monitor_bfm master_monitor_bfm;

    apb_master_agent_config master_agent_cfg;

    uvm_analysis_port #(apb_master_setup_item) master_req_ap;
    uvm_analysis_port #(apb_master_access_item) master_rsp_ap;

    extern function new(string name = "apb_master_monitor", uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern function void report_phase(uvm_phase);

    extern function void notify_access(apb_master_access_item item);
    extern function void notify_setup(apb_master_setup_item item);
endclass : apb_master_monitor

function apb_master_monitor::new(string name = "apb_master_monitor", uvm_component parent = null);
    super.new(name, parent);
endfunction

function void apb_master_monitor::build_phase(uvm_phase phase);
    master_req_ap = new("setup_ap", this); //direct instantiation and it is literally attached to the monitor, so the monitor is its parent (not inheritance wise), understand?
    master_rsp_ap = new("access_ap", this);
    master_agent_cfg = apb_master_agent_config::get_config(null);
    master_monitor_bfm = master_agent_cfg.master_monitor_bfm;
    master_monitor_bfm.proxy = this;
endfunction : build_phase

task apb_master_monitor::run_phase(uvm_phase phase);
    master_monitor_bfm.run();
endtask

function void apb_master_monitor::report_phase(uvm_phase phase);
    //
endfunction

function void apb_master_monitor::notify_setup(apb_master_setup_item item);
    master_req_ap.write(item);
endfunction : notify_setup

function void apb_master_monitor::notify_access(apb_master_access_item item);
    master_rsp_ap.write(item);
endfunction : notify_access
