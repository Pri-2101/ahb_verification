import uvm_pkg::*;
`include "uvm_macros.svh"

//--------------------------------------------------------------------------------------------------
//---------------------------------APB_SLAVE_SETUP_ITEM--------------------------------------------
//--------------------------------------------------------------------------------------------------

class apb_slave_setup_item extends uvm_sequence_item;
    `uvm_object_utils(apb_slave_setup_item);
    
    logic[31:0] HADDR;
    logic[2:0] HBURST;
    logic[2:0] HSIZE;
    logic[1:0] HTRANS;
    logic[31:0] HWDATA;
    logic HWRITE;

    extern function new(string name = "apb_slave_setup_item");
    extern function void do_copy(uvm_object rhs);
    extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    extern function string convert2string();
    extern function void do_print(uvm_printer printer);
    extern function void do_record(uvm_recorder recorder);

endclass : apb_slave_setup_item

function apb_slave_setup_item::new(string name = "apb_slave_setup_item");
    super.new(name);
endfunction

function void apb_slave_setup_item::do_copy(uvm_object rhs);
    apb_slave_setup_item rhs_;

    if(!$cast(rhs_, rhs)) begin
        `uvm_fatal("do_copy", "cast of rhs object failed");
    end
    super.copy(rhs);
    this.HADDR = rhs_.HADDR;
    this.HBURST = rhs_.HBURST;
    this.HSIZE = rhs_.HSIZE;
    this.HTRANS = rhs_.HTRANS;
    this.HWDATA = rhs_.HWDATA;
    this.HWRITE = rhs_.HWRITE;

endfunction : do_copy

function bit apb_slave_setup_item::do_compare(uvm_object rhs, uvm_comparer comparer);
    apb_slave_setup_item rhs_;
    if(!$cast(rhs_, rhs)) begin
        `uvm_fatal("do_compare", "cast of rhs object failed");
        return 0;
    end

    return (super.do_compare(rhs, comparer)) &&
        (this.HADDR == rhs_.HADDR) &&
        (this.HBURST == rhs_.HBURST) &&
        (this.HSIZE == rhs_.HSIZE) &&
        (this.HTRANS == rhs_.HTRANS) &&
        (this.HWDATA == rhs_.HWDATA) &&
        (this.HWRITE == rhs_.HWRITE);

endfunction : do_compare

function string apb_slave_setup_item::convert2string();
    string s;
    $sformat(s, "%s\n", super.convert2string());
    $sformat(s, "%s\n HWRITE\t%0b\n HADDR\t%0h\n HBURST\t%0d\n HSIZE\t%0d\n HTRANS\t%0d\n HWDATA\t%0h\n", s, HWRITE, HADDR, HBURST, HSIZE, HTRANS, HWDATA );
    return s;
endfunction : convert2string

function void apb_slave_setup_item::do_print(uvm_printer printer);
    printer.m_string = this.convert2string();
endfunction : do_print

function void apb_slave_setup_item::do_record(uvm_recorder recorder);
   super.do_record(recorder);
    
    `uvm_record_field("HADDR", HADDR);
    `uvm_record_field("HBURST", HBURST);
    `uvm_record_field("HSIZE", HSIZE);
    `uvm_record_field("HTRANS", HTRANS);
    `uvm_record_field("HWDATA", HWDATA);
    `uvm_record_field("HWRITE", HWRITE);
endfunction

//--------------------------------------------------------------------------------------------------
//---------------------------------APB_SLAVE_ACCESS_ITEM--------------------------------------------
//--------------------------------------------------------------------------------------------------
class apb_slave_access_item extends uvm_sequence_item;
    `uvm_object_utils(apb_slave_access_item);

    rand logic[31:0] HRDATA;
    rand logic HREADY;
    rand logic HRESP;
//

//    constraint HSIZE_constraint;
//    constraint HRDATA_subject_to_HWRITE_constraint;

    extern function new(string name = "apb_slave_access_item");
    extern function void do_copy(uvm_object rhs);
    extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    extern function string convert2string();
    extern function void do_print(uvm_printer printer);
    extern function void do_record(uvm_recorder recorder);

endclass : apb_slave_access_item

//constraint apb_slave_access_item::HSIZE_constraint {HSIZE == 3'b011;}
//constraint apb_slave_access_item::HRDATA_subject_to_HWRITE_constraint {solve HWRITE before HRDATA; if(HWRITE) HRDATA == 32'h00000000;}

function apb_slave_access_item::new(string name = "apb_slave_access_item");
    super.new(name);
endfunction : new

function void apb_slave_access_item::do_copy(uvm_object rhs);
    apb_slave_access_item rhs_;
    if(!$cast(rhs_, rhs)) begin
        `uvm_fatal("do_copy", "cast of rhs object failed");
    end

    super.do_copy(rhs);
    this.HRDATA = rhs_.HRDATA;
    this.HREADY = rhs_.HREADY;
    this.HRESP = rhs_.HRESP;
//    this.HWRITE = rhs_.HWRITE;
//    this.HSIZE = rhs_.HSIZE;
endfunction : do_copy

function bit apb_slave_access_item::do_compare(uvm_object rhs, uvm_comparer comparer);
    apb_slave_access_item rhs_;
    if(!$cast(rhs_, rhs)) begin
        `uvm_fatal("do_compare", "cast of rhs object failed");
        return 0;
    end

    return (super.do_compare(rhs, comparer)) &&
        (this.HRDATA == rhs_.HRDATA) &&
        (this.HREADY == rhs_.HREADY) &&
        (this.HRESP == rhs_.HRESP);
//        (this.HWRITE == rhs_.HWRITE) &&
//        (this.HSIZE == rhs_.HSIZE);

endfunction : do_compare

function string apb_slave_access_item::convert2string();
    string s;
    $sformat(s, "%s\n", super.convert2string());
    $sformat(s, "%s\n HRDATA\t%0h\n HRESP\t%0b\n HREADY\t%0b\n", s, HRDATA, HRESP, HREADY);
    return s;
endfunction : convert2string

function void apb_slave_access_item::do_print(uvm_printer printer);
    printer.m_string = this.convert2string();
endfunction : do_print

function void apb_slave_access_item::do_record(uvm_recorder recorder);
   super.do_record(recorder);
    
    `uvm_record_field("HRDATA", HRDATA);
    `uvm_record_field("HREADY", HREADY);
    `uvm_record_field("HRESP", HRESP);
endfunction : do_record












