import uvm_pkg::*;
import apb_master_agent_pkg::*;
`include "uvm_macros.svh"

class apb_master_agent extends uvm_agent;
    `uvm_component_utils(apb_master_agent);

    //handle for getting the configuration object from the environment
    apb_master_agent_config master_cfg;

    //making the analysis port of the monitor available outside the agent by creating a handle
    uvm_analysis_port #(apb_master_access_item) ap;

    //creating handles to the sub components
    //object creation via composition being done here
    apb_master_sequencer master_sequencer;
    apb_master_monitor master_monitor;
    apb_master_driver master_driver;
    
    extern function new(string name = "apb_master_agent", uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    //extern function void report_phase(uvm_phase phase);
endclass : apb_master_agent

function apb_master_agent::new(string name = "apb_master_agent", uvm_component parent = null);
    super.new(name, parent);
endfunction

function void apb_master_agent::build_phase(uvm_phase phase);
    master_cfg = apb_master_agent_config::get_config(this);
    master_monitor = apb_master_monitor::type_id::create("master_monitor",this);

    if(master_cfg.active == UVM_ACTIVE) begin
        master_driver = apb_master_driver::type_id::create("master_driver", this);
        master_sequencer = apb_master_sequencer::type_id::create("master_sequencer", this);
    end

endfunction : build_phase

function void apb_master_agent::connect_phase(uvm_phase phase);
    ap = master_monitor.master_rsp_ap;
    //listener here in slave agent
    if(master_cfg.active == UVM_ACTIVE) begin
        master_driver.seq_item_port.connect(master_sequencer.seq_item_export);
    end
endfunction

