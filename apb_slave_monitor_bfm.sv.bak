import uvm_pkg::*;
import apb_slave_agent_pkg::*;
`include "uvm_macros.svh"



interface apb_slave_monitor_bfm (input HCLK,
                                 input HRESETn,
                                 input[31:0] HADDR,
                                 input[31:0] HRDATA,
                                 input[31:0] HWDATA,
                                 input[31:0] HSEL,
                                 input[1:0] HTRANS,
                                 input[2:0] HBURST,
                                 input HRESP,
                                 input HREADY,
                                 input[2:0] HSIZE,
                                 input HWRITE);
                                 //input HREADYOUT);
//This part of the code is synthesisable, in that the connections above will be synthesised where ultimately we will have open pins in the hardware that need to be then read and sent to the computer for the testbench analysis
//All the code below is the hybrid part, HVL part that will not get synthesised completely
  `include "apb_monitor_assertions.svh"
  int apb_index = 0;
  apb_slave_monitor proxy; //proxy to the tb monitor is stored in here, obviously not synthesisable

  function void set_apb_index(int index);
    apb_index = index;
  endfunction : set_apb_index

  task run();
    uvm_sequence_item item, cloned_item;
    apb_slave_setup_item req, cloned_req;
    apb_slave_access_item rsp, cloned_rsp;

    req = apb_slave_setup_item::type_id::create("setup_phase");
    rsp = apb_slave_access_item::type_id::create("access_phase");

    forever begin
      @(posedge HCLK);
      if(HSEL[apb_index])
        begin
          req.HADDR = HADDR;
          req.HWRITE = HWRITE;
          if(HWRITE) req.HWDATA = HWDATA;
          $cast(cloned_req, req.clone()); //sending a clone of req rather than create a new req seq_item in the loop here and then reading values into it.
          proxy.notify_setup(cloned_req);
        end
      if(HREADY && HSEL[apb_index])
        begin
          //rsp.HWRITE = HWRITE;
          //rsp.slv_err = PSLVERR;
          if(!HWRITE) rsp.HRDATA = HRDATA;
          $cast(cloned_rsp, rsp.clone());
          proxy.notify_access(cloned_rsp);
        end
    end // forever begin
  endtask: run

  task wait_for_reset();
    wait (HRESETn);
  endtask : wait_for_reset


      RESET_VALID: assert property( @(posedge HCLK) SIGNAL_VALID(HRESETn));
      HSEL_VALID: assert property( @(posedge HCLK) SIGNAL_VALID(HSEL));
      HADDR_VALID: assert property( @(posedge HCLK) CONTROL_SIGNAL_VALID(HADDR));
      HWRITE_VALID: assert property( @(posedge HCLK) CONTROL_SIGNAL_VALID(HWRITE));
      //HENABLE_VALID: assert property( @(posedge HCLK) CONTROL_SIGNAL_VALID(HENABLE));
      HWDATA_VALID: assert property( @(posedge HCLK) HWDATA_SIGNAL_VALID);
      //HREADY_VALID: assert property( @(posedge HCLK) HENABLE_SIGNAL_VALID(HREADY));
      //HSLVERR_VALID: assert property( @(posedge HCLK) HENABLE_SIGNAL_VALID(HSLVERR));
      //HRDATA_VALID: assert property( @(posedge HCLK) HRDATA_SIGNAL_VALID);
  
      //assert property(BurstTransferNumberCheck(beats));
      //assert property( BurstTransferNumberCheckSeq(beats));

      assert property(@(posedge HCLK) ExtendedCycleWriteSignalConstant);
      assert property(@(posedge HCLK) TransferCompleteReadDataValidity(param_enums::datawidth));
      assert property(@(posedge HCLK) IDLETransferNoOKAYResp);
      assert property(@(posedge HCLK) BUSYTransferNoOKAYResp);
      //assert property(@(posedge HCLK) DefBurstBUSYTermination(beats)); probably should be an immediate assertion
      assert property(@(posedge HCLK) BurstAddrChangeBUSY(param_enums::datawidth));
      assert property(@(posedge HCLK) BurstOneKBOverflow);
      //assert property(@(posedge HCLK) NonIncrBurstWrongTermination(beats));
      //assert property(@(posedge HCLK) NonIncrBurstWrongTerminationSeq(beats));
      //assert property(@(posedge HCLK) FixedBurstWrongTermination(beats));
      //assert property(@(posedge HCLK) FixedBurstWrongTerminationSeq(beats));
      assert property(@(posedge HCLK) SingleBurstWrongTermination);
      //assert property(@(posedge HCLK) LockedTransferNoIDLETerm);
      assert property(@(posedge HCLK) WSCR1);
      assert property(@(posedge HCLK) WSCR2);
      assert property(@(posedge HCLK) WSCR3);
      assert property(@(posedge HCLK) WSCR4);
      assert property(@(posedge HCLK) WSCR5);
      assert property(@(posedge HCLK) WSCR6);
      assert property(@(posedge HCLK) WSCR7(param_enums::datawidth));
      assert property(@(posedge HCLK) WSCR8(param_enums::datawidth));
      assert property(@(posedge HCLK) WSCR9(param_enums::datawidth));


endinterface: apb_slave_monitor_bfm



