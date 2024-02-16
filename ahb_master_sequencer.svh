import uvm_pkg::*;
`include "uvm_macros.svh"
import apb_master_agent_pkg::*;

class apb_master_sequencer extends uvm_sequencer #(apb_master_setup_item, apb_master_access_item);
    `uvm_component_utils(apb_master_sequencer);
    extern function new(string name = "apb_master_sequencer", uvm_component parent = null);
endclass : apb_master_sequencer

function apb_master_sequencer::new(string name = "apb_master_sequencer", uvm_component parent = null);
    super.new(name, parent);
endfunction
