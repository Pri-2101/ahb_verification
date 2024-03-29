import uvm_pkg::*;
`include "uvm_macros.svh"
import apb_slave_agent_pkg::*;

class apb_slave_sequencer extends uvm_sequencer #(apb_slave_access_item, apb_slave_setup_item);
  `uvm_component_utils(apb_slave_sequencer)
  extern function new(string name="apb_slave_sequencer", uvm_component parent = null);
endclass: apb_slave_sequencer

function apb_slave_sequencer::new(string name="apb_slave_sequencer", uvm_component parent = null);
  super.new(name, parent);
endfunction
