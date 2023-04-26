
import uvm_pkg::*;
import apb_master_agent_pkg::*;
`include "uvm_macros.svh"


class apb_master_driver extends uvm_driver #(uvm_sequence_item, uvm_sequence_item);
    `uvm_component_utils(apb_master_driver);

    // Handle to the BFM
    virtual apb_master_driver_bfm master_driver_bfm;

    //Data members
    apb_master_agent_config master_agent_cfg;

    //Methods
    extern function void build_phase(uvm_phase phase);
    extern function new(string name = "apb_master_driver", uvm_component parent = null);
    extern task run_phase(uvm_phase phase);

endclass : apb_master_driver

function apb_master_driver::new(string name = "apb_master_driver", uvm_component parent = null);
    super.new(name, parent);
endfunction

function void apb_master_driver::build_phase(uvm_phase phase);
    master_agent_cfg = apb_master_agent_config::get_config(null);
    master_driver_bfm = master_agent_cfg.master_driver_bfm;
endfunction : build_phase

task apb_master_driver::run_phase(uvm_phase phase);
    uvm_sequence_item item;
    apb_master_access_item rsp;
    apb_master_setup_item req;

    //master_driver_bfm.reset();
    //##1 master_driver_bfm.no_reset();
    forever begin
        //Setup Phase
        seq_item_port.get_next_item(item);
        assert ($cast(req, item));
        master_driver_bfm.setup_phase(req);
        seq_item_port.item_done();

        //Access Phase
        seq_item_port.get_next_item(item);
        assert ($cast(rsp, item));
        master_driver_bfm.access_phase(rsp);
        seq_item_port.item_done();
    end
endtask : run_phase




