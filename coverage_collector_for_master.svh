//Insert code in the environment for instantiating the coverage collector only when requierec.
import uvm_pkg::*;
`include "uvm_macros.svh"
import env_pkg::*;
import apb_slave_agent_pkg::apb_slave_setup_item;

class coverage_collector_for_master extends uvm_subscriber #(apb_slave_setup_item);
   `uvm_component_utils(coverage_collector_for_master)

   apb_slave_setup_item rcvd_txn;

   //define covergroups here
    covergroup HTRANS_covergroup;
       coverpoint rcvd_txn.HTRANS {
          bins IDLE_bin = {param_enums::IDLE};
	  bins BUSY_bin = {param_enums::BUSY};
	  bins NONSEQ_bin = {param_enums::NONSEQ};
	  bins SEQ_bin = {param_enums::SEQ};
       }
    endgroup // HTRANS_cover

    covergroup HBURST_covergroup;
       coverpoint rcvd_txn.HBURST {
	  bins SINGLE_bin = {int'(param_enums::SINGLE)};
 	  bins INCR_bin = {int'(param_enums::INCR)};
 	  bins WRAP4_bin = {int'(param_enums::WRAP4)};
 	  bins INCR4_bin = {int'(param_enums::INCR4)};
 	  bins WRAP8_bin = {int'(param_enums::WRAP8)};
 	  bins INCR8_bin = {int'(param_enums::INCR8)};
 	  bins WRAP16_bin = {int'(param_enums::WRAP16)};
 	  bins INCR16_bin = {int'(param_enums::INCR16)};
       }				  
    endgroup // HBURST_cover
    
    covergroup HSIZE_covergroup;
        coverpoint rcvd_txn.HSIZE {
	   bins BYTE_bin = {int'(param_enums::BYTE)};
	   bins HALF_WORD_bin = {int'(param_enums::HALF_WORD)};
	   bins WORD_bin = {int'(param_enums::WORD)};
	   bins DOUBLE_WORD_bin = {int'(param_enums::DOUBLE_WORD)};
	   bins FOUR_WORD_LINE_bin = {int'(param_enums::FOUR_WORD_LINE)};
	   bins EIGHT_WORD_LINE_bin = {int'(param_enums::EIGHT_WORD_LINE)};
	   bins FIVE_TWELVE_bin = {int'(param_enums::FIVE_TWELVE)};
	   bins TEN_TWENTY_FOUR_bin = {int'(param_enums::TEN_TWENTY_FOUR)};
        }				   
    endgroup // HSIZE_covergroup

   covergroup HADDR_covergroup;
      coverpoint rcvd_txn.HADDR {
	    bins HADDR_bins[10] = {[0:32'hFFFF_FFFF]};
      }
      //since the end of test is not determined by coverage in this case, we do not have to worry about the the exponentially massive set of possibilities for a 32 bit number
   endgroup // HADDR_covergroup

   covergroup HWDATA_covergroup;
      coverpoint rcvd_txn.HWDATA {
            bins HWDATA_bins[10] = {[0:32'hFFFF_FFFF]};
      }
   endgroup // HWDATA_covergroup
   
   covergroup HWRITE_covergroup;
      coverpoint rcvd_txn.HWRITE;
   endgroup // HWRITE_covergroup
   
      
   extern function void write(T t);
   extern function new(string name = "coverage_collector_for_master", uvm_component parent = null);
    
endclass : coverage_collector_for_master


function coverage_collector_for_master::new(string name = "coverage_collector_for_master", uvm_component parent = null);
   super.new(name, parent);
   //rcvd_txn = new();

   //instantiating the covergroup variables here
   HTRANS_covergroup = new;
   HBURST_covergroup = new;
   HSIZE_covergroup  = new;
   HADDR_covergroup = new;
   HWDATA_covergroup = new;
   HWRITE_covergroup = new;
endfunction : new

function void coverage_collector_for_master::write(T t);
   if(!$cast(rcvd_txn, t)) begin
        `uvm_error("cast_error", "Could not cast RHS object into apb_slave_seq_item type");
   end

   $cast(rcvd_txn,t);

   HTRANS_covergroup.sample();
    //`uvm_info("COVERAGE_COLLECTOR_INFO", $sformatf("\n%s \n", rcvd_txn.convert2string()), UVM_LOW);
   HBURST_covergroup.sample();
   HSIZE_covergroup.sample();
   HADDR_covergroup.sample();
   HWDATA_covergroup.sample();
   HWRITE_covergroup.sample();
endfunction : write
