import uvm_pkg::*;
`include "uvm_macros.svh"

class apb_master_sequencer extends uvm_sequencer #(uvm_sequence_item);
    `uvm_component_utils(apb_master_sequencer);
    extern function new(string name = "apb_master_sequencer", uvm_component parent = null);
endclass : apb_master_sequencer

function apb_master_sequencer::new(string name = "apb_master_sequencer", uvm_component parent = null);
    super.new(name, parent);
endfunction
