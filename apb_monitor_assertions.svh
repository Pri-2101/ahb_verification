/*
//SOME BASIC TEXT MACROS ARE BEING DEFINED HERE
//Transfer Types
`define IDLE 2'b00;
`define BUSY 2'b01;
`define NONSEQ 2'b10;
`define SEQ 2'b11;

//Burst Operation Mode
`define SINGLE 3'b000;
`define INCR 3'b001;
`define WRAP4 3'b010;
`define INCR4 3'b011;
`define WRAP8 3'b100;
`define INCR8 3'b101;
`define WRAP16 3'b110;
`define INCR16 3'b111;


//States
`define WAITED 1'b0;
`define ACTIVE 1'b1;
*/

//--------------------------------------------------------------------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------//

property SIGNAL_VALID(signal);
   !$isunknown(signal);
endproperty; // SIGNAL_VALID

property CONTROL_SIGNAL_VALID(signal);
   $onehot(HSEL) |-> !$isunknown(signal);
endproperty; // CONTROL_SIGNAL_VALID

// Check that write data is in a known state if a write
property HWDATA_SIGNAL_VALID;
  $onehot(HSEL) && HWRITE |-> !$isunknown(HWDATA);
endproperty; // HWDATA_SIGNAL_VALID

//-----------------------------------------------------------------------------------------------------------//
//Checking if the number of beats do not exceed the number specified
property BurstTransferNumberCheck(beats);
   //fixed length burst transfers should always end with a SEQ transfer
   HBURST[2:0] >= 3'b010 |=> ##[0:16](HTRANS[1:0] == 2'b10) ##1 (HTRANS[1:0] == 2'b11)[->beats-1];
endproperty; // BurstTransferNumberCheck

sequence BurstTransferNumberCheckSeq(beats);
   (HTRANS[1:0] == 2'b10) ##1 (HTRANS[1:0] == 2'b11)[->beats-1];
endsequence; // BurstTransferNumberCheckSeq


//Write operations require data to be stable throughout the extended cycles
property ExtendedCycleWriteSignalConstant;
   HTRANS[1:0] == param_enums::BUSY |-> ##1 ($stable(HWDATA, @(posedge HCLK)) && $stable(HADDR, @(posedge HCLK)))[*0:$] ##1 (HTRANS[1:0] !== param_enums::BUSY); //Does IDLE condition have to b included here? Check.
endproperty; // ExtendedCycleWriteSignalConstant


//The read data should be valid when transfer is complete
property TransferCompleteReadDataValidity(datawidth);
   !HWRITE |-> ##[1:16] !$isunknown(HRDATA[datawidth-1:0]);
endproperty; // TransferCompleteReadDataValidity


//Slave does not give OKAY resp for IDLE transfer by master
property IDLETransferNoOKAYResp;
   HTRANS == param_enums::IDLE |-> ##[1:16] (HRESP == param_enums::OKAY && HREADY == param_enums::HIGH);
endproperty; // IDLETransferNoOKAYResp


//Slave does not give OKAY resp for BUSY transfer by master
property BUSYTransferNoOKAYResp;
   HTRANS == param_enums::BUSY |-> ##[1:16] (HRESP == param_enums::OKAY && HREADY == param_enums::HIGH);
endproperty; // BUSYTransferNoOKAYResp


//Master terminates an definite burst transfer with BUSY
//Checks for BurstTransferStartType, BurstTransferContinueType
property DefBurstBUSYTermination(beats);
   HBURST >= 3'b010 |-> ##[1:16](HTRANS[1:0] == 2'b10) ##1 (HTRANS == 2'b11)[->beats-2] ##1 (HTRANS[1:0] == 2'b01);
endproperty; // DefBurstBUSYTermination

//Much more difficult than anticipated
/*
property BurstAddrCalcWrong;

endproperty; // BurstAddrCalcWrong
*/

//implem - not (address changes during a BUSY transfer by the master)
property BurstAddrChangeBUSY(datawidth);
   !$stable(HTRANS) ##0 HTRANS == param_enums::BUSY ##0 ((HBURST !== param_enums::SINGLE) && (HBURST !== param_enums::INCR)) |-> ##1 $stable(HADDR)[*0:$] ##1 (HTRANS !== param_enums::BUSY);
endproperty; // BurstAddrChangeBUSY


//imple - Masters must not attempt to start an incrementing burst that crosses the 1KB address boundary
property BurstOneKBOverflow; 
   ((HBURST !== param_enums::SINGLE) && (HBURST !== param_enums::INCR)) |-> ((HSIZE * HBURST) < 5'b11100);
endproperty; // BurstOneKBOverflow


//Refer Section 3.5.1
//property IncrBurstTermination;
//    !$stable(HBURST) ##0 HBURST == param_enums::INCR ##[1:$] HTRANS == param_enums::BUSY |-> ##[1:$] HTRANS == param_enums::NON
//endproperty; // IncrBurstTermination


property FixedBurstTermination;
   !$stable(HBURST) ##0 HBURST >= param_enums::WRAP4 |-> ##[0:$] HTRANS == param_enums::SEQ ##1 !$stable(HBURST);
endproperty; // FixedBurstWrongTermination

property SingleBurstTermination;
   !$stable(HBURST) ##0 HBURST == param_enums::SINGLE |-> ##[1:$] (HTRANS == param_enums::IDLE || HTRANS == param_enums::NONSEQ);
endproperty; // SingleBurstWrongTerminationOne

//not (burst not terminated either by above properties nor by slave error response)
/*
property BurstPreTerminationERROR;
   (@(posedge HCLK) ##0 HBURST[2:0] >= 3'b001) |-> ##[1:16]( !NonIncrBurstWrongTerminationSeq ##0 !FixedBurstWrongTermination) ;
endproperty; // BurstPreTerminationERROR
*/

//not(Locked transfer not terminated with IDLE transfer from master)
/*
property LockedTransferNoIDLETerm;
   (@(posedge HCLK) ##0 HMASTLOCK) |-> ##[1:$] !(HTRANS[1:0] == IDLE);
endproperty; // LockedTransferNoIDLETerm
*/

//--------------------------------------------------------------------------------------------------------------//

//Waited State Changes Restriction
//Here are some changes that are not allowed when the slave or master is in the waited state.
//See Section 3.6.1

property WSCR1;
   (HREADY == param_enums::WAITED) throughout (HTRANS == param_enums::IDLE ##[1:$] (HTRANS == param_enums::NONSEQ)) |-> ##1 (HTRANS == param_enums::NONSEQ)[*0:$] ##0 (HREADY == param_enums::ACTIVE);
endproperty; // WSCR1

property WSCR2;
   HBURST >= param_enums::INCR4 ##0 (HREADY == param_enums::WAITED) |-> (HREADY == param_enums::WAITED) throughout (HTRANS == param_enums::BUSY ##[1:$] HTRANS == param_enums::SEQ) |-> HTRANS == param_enums::SEQ[*0:$] ##1 (HREADY == param_enums::ACTIVE);
endproperty; // WSCR2

property WSCR3;
   HREADY == param_enums::WAITED ##0 (HBURST !== param_enums::SINGLE && HBURST !== param_enums::INCR) ##0 (HTRANS == param_enums::BUSY) ##[1:$] (HTRANS == param_enums::SEQ) |-> ##1 (HTRANS == param_enums::SEQ)[*0:$] ##0 (HREADY == param_enums::ACTIVE);
endproperty; // WSCR3


//Address changes during waited transfers
property WSCR4;
   (HREADY == param_enums::WAITED ##0 HTRANS == param_enums::IDLE) |-> HREADY == param_enums::WAITED throughout $changed(HADDR) |-> ##1 HREADY == param_enums::WAITED throughout (HTRANS == param_enums::NONSEQ ##0 !$changed(HADDR)[*0:$]) ##1 HREADY == param_enums::ACTIVE; 
endproperty; //WSCR4
//not (if in waited state, the master changes from **HTRANS** IDLE to NONSEQ, and changes the address during NONSEQ by not holding it till HREADY is high in the next clock edge)
//property WSCR8(datawidth);
//   HREADY == param_enums::WAITED |-> ##[0:$] (HTRANS[1:0] == param_enums::IDLE) ##[0:$] (HTRANS[1:0] == param_enums::NONSEQ) ##[0:$] (!$stable(HADDR[datawidth:0], @(posedge HCLK)) ##0 (HTRANS[1:0] == param_enums::NONSEQ) ##[0:$] !$stable(HADDR[datawidth:0], @(posedge HCLK))) ##[0:$] (HREADY == param_enums::ACTIVE);
//endproperty; // WSCR8


//not (if in waited state there is ERROR response from the slave, master changes address not when **HTRANS** is in IDLE)
//property WSCR9(datawidth);
//   HREADY == param_enums::WAITED ##[0:$] HRESP == param_enums::ERROR |-> ##[1:2] !$stable(HADDR[datawidth-1:0]);
//endproperty; // WSCR9


//--------------------------------------------------------------------------------------------------------------//


//not (not constant throughout a burst transfer) //they have the same timings as the address bus.
/*
 property ProtSigNotConstant;
   @(posedge HCLK) |-> ##0 (HBURST >= INCR) ##0 
*/
