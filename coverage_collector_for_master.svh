//Insert code in the environment for instantiating the coverage collector only when requierec.
import uvm_pkg::*;
`include "uvm_macros.svh"
import apb_slave_agent_pkg::*;

class coverage_collector_for_master extends uvm_subscriber #(uvm_sequence_item);
   `uvm_component_utils(coverage_collector_for_master)

   apb_slave_setup_item rcvd_txn;

   //define covergroups here
    covergroup HTRANS_covergroup;
       coverpoint rcvd_txn.HTRANS {
          bins IDLE_bin = {IDLE};
	  bins BUSY_bin = {BUSY};
	  bins NONSEQ_bin = {NONSEQ};
	  bins SEQ_bin = {SEQ};
       }
    endgroup // HTRANS_cover

    covergroup HBURST_covergroup;
       coverpoint rcvd_txn.HBURST {
	  bins SINGLE_bin = {SINGLE};
 	  bins INCR_bin = {INCR};
 	  bins WRAP4_bin = {WRAP4};
 	  bins INCR4_bin = {INCR4};
 	  bins WRAP8_bin = {WRAP8};
 	  bins INCR8_bin = {INCR8};
 	  bins WRAP16_bin = {WRAP16};
 	  bins INCR16_bin = {INCR16};
       }				  
    endgroup // HBURST_cover
    
    covergroup HSIZE_covergroup;
        coverpoint rcvd_txn.HSIZE {
	   bins BYTE_bin = {BYTE};
	   bins HALF_WORD_bin = {HALF_WORD};
	   bins WORD_bin = {WORD};
	   bins DOUBLE_WORD_bin = {DOUBLE_WORD};
	   bins FOUR_WORD_LINE_bin = {FOUR_WORD_LINE};
	   bins EIGHT_WORD_LINE_bin = {EIGHT_WORD_LINE};
	   bins FIVE_TWELVE_bin = {FIVE_TWELVE};
	   bins TEN_TWENTY_FOUR_bin = {TEN_TWENTY_FOUR};
        }				   
    endgroup // HSIZE_covergroup

   covergroup HADDR_covergroup;
      coverpoint rcvd_txn.HADDR[10];
      //since the end of test is not determined by coverage in this case, we do not have to worry about the the exponentially massive set of possibilities for a 32 bit number
   endgroup // HADDR_covergroup

   covergroup HWDATA_covergroup;
      coverpoint rcvd_txn.HWDATA[10]   ;
   endgroup // HWDATA_covergroup
   
   covergroup HWRITE_covergroup;
      coverpoint rcvd_txn.HWRITE;
   endgroup // HWRITE_covergroup
   
      
   extern function void write(T t);
   extern function new(string name = "coverage_collector_for_master", uvm_component parent = null);
    
endclass : coverage_collector_for_master


function coverage_collector_for_master::new(string name = "coverage_collector_for_master", uvm_component parent = null);
   super.new(name, parent);
   rcvd_txn = new();

   //instantiating the covergroup variables here
   HTRANS_covergroup = new;
   HBURST_covergroup = new;
   HSIZE_covergroup = new;
   HADDR_covergroup = new;
   HWDATA_covergroup = new;
   HWRITE_covergroup = new;
endfunction : new

function void coverage_collector_for_master::write(T t);
   if(!$cast(rcvd_txn, t)) begin
        `uvm_error("cast_error", "Could not cast RHS object into apb_slave_seq_item type");
   end

   rcvd_txn.copy(t);

   HTRANS_covergroup.sample();
   HBURST_covergroup.sample();
   HSIZE_covergroup.sample();
   HADDR_covergroup.sample();
   HWDATA_covergroup.sample();
   HWRITE_covergroup.sample();
endfunction : write
