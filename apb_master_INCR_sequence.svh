import uvm_pkg::*;
import apb_master_agent_pkg::*;
//import param_enums::*;
`include "uvm_macros.svh"
//`include "apb_master_seq_item.svh"
//`include "apb_master_agent_config.svh"

class apb_master_INCR_sequence extends uvm_sequence #(uvm_sequence_item);
    `uvm_object_utils(apb_master_INCR_sequence)

    rand int no_of_transfers;

    extern function new(string name = "apb_master_INCR_sequence");
    extern task body;
    extern constraint no_of_transfers_constraint;

endclass : apb_master_INCR_sequence

function apb_master_INCR_sequence::new(string name = "apb_master_INCR_sequence");
    super.new(name);
endfunction

task apb_master_INCR_sequence::body;
    apb_master_setup_item req;
    apb_master_access_item res;
    apb_master_agent_config master_agent_cfg = apb_master_agent_config::get_config(m_sequencer);
    
    //req.HBURST.rand_mode(0);
    //req.HTRANS.rand_mode(0);

    assert(req.randomize() with {HBURST == INCR; HTRANS == 2'b10;});

    repeat(no_of_transfers - 1) begin
        req = apb_master_setup_item::type_id::create("req");
        rsp = apb_master_access_item::type_id::create("rsp");

        start_item(req);
        //assert(req.randomize() with {} );
	finish_item(req);

    end
endtask

constraint apb_master_INCR_sequence::no_of_transfers_constraint {no_of_transfers <= 250;};
