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

    req = apb_slave_setup_item::type_id::create("req");
    rsp = apb_slave_access_item::type_id::create("rsp");

    forever begin
      @(posedge HCLK);
      if(HSEL[apb_index])
        begin
          req.HADDR = HADDR;
          req.HWRITE = HWRITE;
          req.HBURST = HBURST;
          req.HTRANS = HTRANS;
          req.HSIZE = HSIZE;
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


//      RESET_VALID: assert property( @(posedge HCLK) SIGNAL_VALID(HRESETn));
//      HSEL_VALID: assert property( @(posedge HCLK) SIGNAL_VALID(HSEL));
//      HADDR_VALID: assert property( @(posedge HCLK) CONTROL_SIGNAL_VALID(HADDR));
//      HWRITE_VALID: assert property( @(posedge HCLK) CONTROL_SIGNAL_VALID(HWRITE));
      
//      HWDATA_VALID: assert property( @(posedge HCLK) HWDATA_SIGNAL_VALID);
      //HREADY_VALID: assert property( @(posedge HCLK) HENABLE_SIGNAL_VALID(HREADY));
      //HSLVERR_VALID: assert property( @(posedge HCLK) HENABLE_SIGNAL_VALID(HSLVERR));
      //HRDATA_VALID: assert property( @(posedge HCLK) HRDATA_SIGNAL_VALID);
      //HENABLE_VALID: assert property( @(posedge HCLK) CONTROL_SIGNAL_VALID(HENABLE));
      //assert property(BurstTransferNumberCheck(beats));
      //assert property( BurstTransferNumberCheckSeq(beats));

      ASSERT_ExtendedCycleWriteSignalConstant : assert property(@(posedge HCLK) ExtendedCycleWriteSignalConstant);
      COVER_ExtendedCycleWriteSignalConstant : cover property(@(posedge HCLK) ExtendedCycleWriteSignalConstant);

      ASSERT_TransferCompleteReadDataValidity : assert property(@(posedge HCLK) TransferCompleteReadDataValidity(param_enums::datawidth));
      COVER_TransferCompleteReadDataValidity : cover property(@(posedge HCLK) TransferCompleteReadDataValidity(param_enums::datawidth));      

      ASSERT_IDLETransferNoOKAYResp : assert property(@(posedge HCLK) IDLETransferNoOKAYResp);
      COVER_IDLETransferNoOKAYResp : cover property(@(posedge HCLK) IDLETransferNoOKAYResp);

      ASSERT_BUSYTransferNoOKAYResp : assert property(@(posedge HCLK) BUSYTransferNoOKAYResp);
      COVER_BUSYTransferNoOKAYResp : cover property(@(posedge HCLK) BUSYTransferNoOKAYResp);

      //assert property(@(posedge HCLK) DefBurstBUSYTermination(beats)); probably should be an immediate assertion
      ASSERT_BurstAddrChangeBUSY : assert property(@(posedge HCLK) BurstAddrChangeBUSY(param_enums::datawidth));
      COVER_BurstAddrChangeBUSY : cover property(@(posedge HCLK) BurstAddrChangeBUSY(param_enums::datawidth));

      ASSERT_BurstOneKBOverflow : assert property(@(posedge HCLK) BurstOneKBOverflow);
      COVER_BurstOneKBOverflow : cover property(@(posedge HCLK) BurstOneKBOverflow);

      //assert property(@(posedge HCLK) IncrBurstTermination(beats));

      ASSERT_FixedBurstTermination : assert property(@(posedge HCLK) FixedBurstTermination);
      COVER_FixedBurstTermination : cover property(@(posedge HCLK) FixedBurstTermination);

      ASSERT_SingleBurstTermination : assert property(@(posedge HCLK) SingleBurstTermination);
      COVER_SingleBurstTermination : cover property(@(posedge HCLK) SingleBurstTermination);

      //assert property(@(posedge HCLK) LockedTransferNoIDLETerm);
      ASSERT_WSCR1 : assert property(@(posedge HCLK) WSCR1);
      COVER_WSCR1 : cover property(@(posedge HCLK) WSCR1);

      ASSERT_WSCR2 : assert property(@(posedge HCLK) WSCR2);
      COVER_WSCR2 : cover property(@(posedge HCLK) WSCR2);

      ASSERT_WSCR3 : assert property(@(posedge HCLK) WSCR3);
      COVER_WSCR3 : cover property(@(posedge HCLK) WSCR3);

//      ASSERT_WSCR5 : assert property(@(posedge HCLK) WSCR5);
//      COVER_WSCR5 : cover property(@(posedge HCLK) WSCR5);
 
//      ASSERT_WSCR6 : assert property(@(posedge HCLK) WSCR6);
//      COVER_WSCR6 : cover property(@(posedge HCLK) WSCR6);

      ASSERT_WSCR4 : assert property(@(posedge HCLK) WSCR4);
      COVER_WSCR4 : cover property(@(posedge HCLK) WSCR4);

//      ASSERT_WSCR8 : assert property(@(posedge HCLK) WSCR8(param_enums::datawidth));
//      COVER_WSCR8 : cover property(@(posedge HCLK) WSCR8(param_enums::datawidth));

//      ASSERT_WSCR9 : assert property(@(posedge HCLK) WSCR9(param_enums::datawidth));
//      COVER_WSCR9 : cover property(@(posedge HCLK) WSCR9(param_enums::datawidth));


endinterface: apb_slave_monitor_bfm



