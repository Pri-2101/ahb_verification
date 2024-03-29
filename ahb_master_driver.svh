
import uvm_pkg::*;
import apb_master_agent_pkg::*;
`include "uvm_macros.svh"


class apb_master_driver extends uvm_driver #(apb_master_setup_item, apb_master_access_item);
    `uvm_component_utils(apb_master_driver);

    // Handle to the BFM
    virtual apb_master_driver_bfm master_driver_bfm;

    //Data members
    apb_master_agent_config master_agent_cfg;
   semaphore pipeline_lock_req;
   semaphore pipeline_lock_rsp;
   
   
    //Methods
    extern function void build_phase(uvm_phase phase);
    extern function new(string name = "apb_master_driver", uvm_component parent = null);
    extern task do_pipelined_transfer;
    extern task run_phase(uvm_phase phase);

endclass : apb_master_driver

function apb_master_driver::new(string name = "apb_master_driver", uvm_component parent = null);
    super.new(name, parent);
   pipeline_lock_req = new(1);
   pipeline_lock_rsp = new(1);
   
endfunction

function void apb_master_driver::build_phase(uvm_phase phase);
    master_agent_cfg = apb_master_agent_config::get_config(null);
    master_driver_bfm = master_agent_cfg.master_driver_bfm;
endfunction : build_phase

task apb_master_driver::run_phase(uvm_phase phase);
    //master_driver_bfm.reset();
    //##1 master_driver_bfm.no_reset();
    //converting the driver to a pipelined driver
   //@(posedge master_driver_bfm.HRESETn);
//   @(posedge master_driver_bfm.HCLK);

   fork
      do_pipelined_transfer;
      do_pipelined_transfer;
   join
endtask : run_phase

task apb_master_driver::do_pipelined_transfer;
   uvm_sequence_item item;
   apb_master_access_item rsp;
   apb_master_setup_item req;


   forever begin
      pipeline_lock_req.get();
          seq_item_port.get(req);
	  //if($cast(req, item)) begin
            accept_tr(req, $time);
            void'(begin_tr(req, "apb_master_driver"));
            master_driver_bfm.setup_phase(req);
            pipeline_lock_req.put();
            end_tr(req);
     	  //end
          //else pipeline_lock_req.put();
      

      pipeline_lock_rsp.get();
            rsp = apb_master_access_item::type_id::create("rsp");
	    rsp.set_id_info(req);
	  //if($cast(rsp, item)) begin
	    accept_tr(rsp, $time);
	    void'(begin_tr(rsp, "apb_master_driver"));
	    master_driver_bfm.access_phase(rsp);
            pipeline_lock_rsp.put();
            seq_item_port.put(rsp); // Put the response back so that the sequence can accordingly generate the next item.
            end_tr(rsp);
    	 //end
         //else pipeline_lock_rsp.put();
   end
endtask : do_pipelined_transfer



