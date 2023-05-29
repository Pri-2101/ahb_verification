import uvm_pkg::*;
`include "uvm_macros.svh"
import apb_master_agent_pkg::*;

class apb_master_setup_item extends uvm_sequence_item;
    `uvm_object_utils(apb_master_setup_item);
   
    rand logic[31:0] HADDR;
    rand logic[2:0] HBURST;
    rand logic[2:0] HSIZE;
    rand logic[1:0] HTRANS;
    rand logic[31:0] HWDATA;
    rand logic HWRITE;

    //defining constraints for a general apb sequence item
    extern constraint HSIZE_constraint;
//    extern constraint HWDATA_subject_to_HWRITE_constraint;
    
    extern function new(string name = "apb_master_setup_item");
    extern function void do_copy(uvm_object rhs);
    extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    extern function string convert2string();
    extern function void do_print(uvm_printer printer);
    extern function void do_record(uvm_recorder recorder);
endclass : apb_master_setup_item

constraint apb_master_setup_item::HSIZE_constraint {HSIZE inside {param_enums::BYTE, param_enums::HALF_WORD, param_enums::WORD};} //parameterize this according to the data bus width
//constraint apb_master_setup_item::HWDATA_subject_to_HWRITE_constraint {solve HWRITE before HWDATA;}

function apb_master_setup_item::new(string name = "apb_master_setup_item");
    super.new(name);
endfunction

function void apb_master_setup_item::do_copy(uvm_object rhs);
    apb_master_setup_item rhs_;
    if(!$cast(rhs_,rhs)) begin
        `uvm_fatal("do_copy", "cast of rhs object failed");
    end
    super.do_copy(rhs);

    this.HADDR = rhs_.HADDR;
    this.HBURST = rhs_.HBURST;
    this.HSIZE = rhs_.HSIZE;
    this.HTRANS = rhs_.HTRANS;
    this.HWDATA = rhs_.HWDATA;
    this.HWRITE = rhs_.HWRITE;
endfunction : do_copy

function bit apb_master_setup_item::do_compare(uvm_object rhs, uvm_comparer comparer);
      apb_master_setup_item rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_error("do_compare", "cast of rhs object failed")
    return 0;
  end

  return (super.do_compare(rhs, comparer)) && (this.HADDR == rhs_.HADDR) &&
    (this.HBURST == rhs_.HBURST) &&
    (this.HSIZE == rhs_.HSIZE) && 
    (this.HTRANS == rhs_.HTRANS) && 
    (this.HWDATA == rhs_.HWDATA) && 
    (this.HWRITE == rhs_.HWRITE);
endfunction

function string apb_master_setup_item::convert2string();
    string s;
    $sformat(s, "%s\n", super.convert2string());
    $sformat(s, "%s\n HWRITE\t%0b\n HADDR\t%0h\n HBURST\t%0d\n HSIZE\t%0d\n HTRANS\t%0d\n HWDATA\t%0h\n", s, HWRITE, HADDR, HBURST, HSIZE, HTRANS, HWDATA );
    return s;
endfunction

function void apb_master_setup_item::do_print(uvm_printer printer);
    printer.m_string = convert2string();
endfunction : do_print

function void apb_master_setup_item::do_record(uvm_recorder recorder);
    super.do_record(recorder);
    `uvm_record_field("HADDR", HADDR);
    `uvm_record_field("HBURST", HBURST);
    `uvm_record_field("HSIZE", HSIZE);
    `uvm_record_field("HWDATA", HWDATA);
    `uvm_record_field("HWRITE", HWRITE);
endfunction : do_record

//_____________________________________________________________________________________________________________________________________
//_____________________________________________________________________________________________________________________________________


class apb_master_access_item extends uvm_sequence_item;
    `uvm_object_utils(apb_master_access_item);

    logic[31:0] HRDATA;
    logic HREADY;
    logic HRESP;

    extern function new(string name = "apb_master_access_item");
    extern function void do_copy(uvm_object rhs);
    extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    extern function string convert2string();
    extern function void do_print(uvm_printer printer);
    extern function void do_record(uvm_recorder recorder);
endclass: apb_master_access_item

function apb_master_access_item::new(string name= "apb_master_access_item");
    super.new(name);
endfunction

function void apb_master_access_item::do_copy(uvm_object rhs);
    apb_master_access_item rhs_;
    if(!$cast(rhs_,rhs)) begin 
        `uvm_fatal("do_copy", "cast of rhs object failed");
    end

    super.do_copy(rhs);
    this.HRDATA = rhs_.HRDATA;
    this.HREADY = rhs_.HREADY;
    this.HRESP = rhs_.HRESP;
endfunction: do_copy

function bit apb_master_access_item::do_compare(uvm_object rhs, uvm_comparer comparer);
    apb_master_access_item rhs_;

    if(!$cast(rhs_,rhs)) begin
        `uvm_error("do_compare", "cast of rhs object failed");
        return 0;
    end
    return (super.do_compare(rhs, comparer) &&
            (this.HRDATA == rhs_.HRDATA) &&
            (this.HREADY == rhs_.HREADY) &&
            (this.HRESP == rhs_.HRESP));
endfunction: do_compare

function string apb_master_access_item::convert2string();
    string s;
    $sformat(s, "%s\n", super.convert2string());
    $sformat(s, "%s\n HRDATA\t%0h\n HREADY\t%0b\n HRESP\t%0b\n", s, HRDATA, HREADY, HRESP);
    return s;
endfunction : convert2string

function void apb_master_access_item::do_print(uvm_printer printer);
    printer.m_string = convert2string();
endfunction : do_print

function void apb_master_access_item::do_record(uvm_recorder recorder);
    super.do_record(recorder);

    `uvm_record_field("HRDATA", HRDATA);
    `uvm_record_field("HREADY", HREADY);
    `uvm_record_field("HRESP", HRESP);
endfunction : do_record

