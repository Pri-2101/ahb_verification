package apb_master_agent_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh";

    `include "param_enums.svh";
    `include "apb_master_seq_item.svh"
    `include "apb_master_agent_config.svh"
    `include "apb_master_driver.svh"
    `include "apb_master_monitor.svh"
    `include "apb_master_sequencer.svh"
    `include "apb_master_agent.svh"
   

    `include "base_state.svh"
    `include "NONSEQ_state.svh"
    `include "IDLE_state.svh"
    typedef class SEQ_state;
    `include "BUSY_state.svh"
    `include "SEQ_state.svh"
    `include "protocol_state_controller.svh"
      

    //`include "apb_master_INCR_sequence.svh"
    //`include "apb_master_single_trans_sequence.svh"

endpackage : apb_master_agent_pkg
