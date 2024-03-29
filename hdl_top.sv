module hdl_top;
    logic HCLK;
    logic HRESETn;
    wire[31:0] HADDR;
    wire[2:0] HBURST;
    wire[2:0] HSIZE;
    wire[1:0] HTRANS;
    wire[31:0] HWDATA;
    wire HWRITE;
    wire[31:0] HRDATA;
    wire HREADY;
    wire HRESP;
    wire [31:0]HSEL;

    apb_master_monitor_bfm master_monitor_bfm(.HCLK(HCLK), .HRESETn(HRESETn), .HADDR(HADDR), .HBURST(HBURST), .HSIZE(HSIZE),
        .HTRANS(HTRANS), .HWDATA(HWDATA), .HWRITE(HWRITE), .HRDATA(HRDATA), .HREADY(HREADY), .HRESP(HRESP));

    apb_master_driver_bfm master_driver_bfm(.HCLK(HCLK), .HRESETn(HRESETn), .HADDR(HADDR), .HBURST(HBURST), .HSIZE(HSIZE),
        .HTRANS(HTRANS), .HWDATA(HWDATA), .HWRITE(HWRITE), .HRDATA(HRDATA), .HREADY(HREADY), .HRESP(HRESP));

    apb_slave_monitor_bfm slave_monitor_bfm(.HCLK(HCLK), .HRESETn(HRESETn), .HADDR(HADDR), .HRDATA(HRDATA), .HWDATA(HWDATA), 
        .HSEL(HSEL), .HWRITE(HWRITE), .HREADY(HREADY), .HBURST(HBURST), .HTRANS(HTRANS), .HSIZE(HSIZE), .HRESP(HRESP));

    apb_slave_driver_bfm slave_driver_bfm(.HCLK(HCLK), .HRESETn(HRESETn), .HADDR(HADDR), .HRDATA(HRDATA), .HWDATA(HWDATA),
        .HSEL(HSEL), .HWRITE(HWRITE), .HRESP(HRESP), .HREADY(HREADY), .HREADYOUT(HREADY), .HBURST(HBURST), .HSIZE(HSIZE), .HTRANS(HTRANS));

    initial begin
        import uvm_pkg::uvm_config_db;
        uvm_config_db #(virtual apb_slave_monitor_bfm)::set(null, "uvm_test_top", "apb_slave_monitor_bfm", slave_monitor_bfm);
        uvm_config_db #(virtual apb_master_monitor_bfm)::set(null, "uvm_test_top", "apb_master_monitor_bfm", master_monitor_bfm);
        uvm_config_db #(virtual apb_slave_driver_bfm)::set(null, "uvm_test_top", "apb_slave_driver_bfm", slave_driver_bfm);
        uvm_config_db #(virtual apb_master_driver_bfm)::set(null, "uvm_test_top", "apb_master_driver_bfm", master_driver_bfm);
    end

    assign HSEL[31:1] = 0;
    assign HSEL[0] = 1;
    //assign HRESETn = 1;


    initial begin
        HCLK = 0;
        forever begin
    	    #10ns HCLK = ~HCLK;
  	end
    end

endmodule : hdl_top
