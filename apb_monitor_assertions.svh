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
   HTRANS[1:0] == 2'b01 |-> ($stable(HWDATA, @(posedge HCLK)) && $stable(HADDR, @(posedge HCLK)) && $stable(HRDATA, @(posedge HCLK)))[*0:$] ##1 (HTRANS[1:0] !== 2'b01); //Does IDLE condition have to b included here? Check.
endproperty; // ExtendedCycleWriteSignalConstant


//The read data should be valid when transfer is complete
property TransferCompleteReadDataValidity(datawidth);
   !HWRITE |-> ##[1:16] !$isunknown(HRDATA[datawidth:0]);
endproperty; // TransferCompleteReadDataValidity


//Slave does not give OKAY resp for IDLE transfer by master
property IDLETransferNoOKAYResp;
   HTRANS[1:0] == 2'b00 |-> ##1 !HRESP;
endproperty; // IDLETransferNoOKAYResp


//Slave does not give OKAY resp for BUSY transfer by master
property BUSYTransferNoOKAYResp;
   HTRANS[1:0] == 2'b01 |-> ##1 !HRESP;
endproperty; // BUSYTransferNoOKAYResp


//Master terminates an definite burst transfer with BUSY
//Checks for BurstTransferStartType, BurstTransferContinueType
property DefBurstBUSYTermination(beats);
   HBURST[2:0] >= 3'b010 |-> ##[1:16](HTRANS[1:0] == 2'b10) ##1 (HTRANS[1:0] == 2'b11)[->beats-2] ##1 (HTRANS[1:0] == 2'b01);
endproperty; // DefBurstBUSYTermination

//Much more difficult than anticipated
/*
property BurstAddrCalcWrong;

endproperty; // BurstAddrCalcWrong
*/

//implem - not (address changes during a BUSY transfer by the master)
property BurstAddrChangeBUSY(datawidth);
   HTRANS[1:0] == 2'b01 && HBURST[2:0] >= 3'b010 |-> !$stable(HADDR[datawidth:0], @(posedge HCLK) );
endproperty; // BurstAddrChangeBUSY


//imple - Masters must not attempt to start an incrementing burst that crosses the 1KB address boundary
property BurstOneKBOverflow; 
   HBURST[2:0] >= 3'b010 |-> !((HSIZE[2:0] * HBURST[2:0]) < 5'b11100);
endproperty; // BurstOneKBOverflow


// implem - not (non-INCR burst transfer terminated with BUSY transfer)
//the following behaviour is the one enclosed in the brackets above
property NonIncrBurstWrongTermination(beats);
   HBURST[0] !== 1'b1 |-> ##[1:16](HTRANS[1:0] == 2'b10) ##1 (HTRANS[1:0] == 2'b11)[=beats-2] ##1 (HTRANS[1:0] == 2'b01);
endproperty; // NonIncrBurstWrongTermination

sequence NonIncrBurstWrongTerminationSeq(beats);
    (HTRANS[1:0] == 2'b10) ##1 (HTRANS[1:0] == 2'b11)[=beats-2] ##1 (HTRANS[1:0] == 2'b01);
endsequence; // NonIncrBurstWrongTermination


//not (Fixed burst transfer not ending with SEQ transfer)
//the following behaviour is the one enclosed in the brackets above
property FixedBurstWrongTermination(beats);
   (@(posedge HCLK) ##0 HBURST[2:0] >= 3'b010) |-> ##[1:16](HTRANS[1:0] == 2'b10) ##1 (HTRANS[1:0] == 2'b11)[=beats-2] ##1 (HTRANS[1:0] == 2'b11);
endproperty; // FixedBurstWrongTermination

sequence FixedBurstWrongTerminationSeq(beats);
   (HTRANS[1:0] == 2'b10) ##1 (HTRANS[1:0] == 2'b11)[=beats-2] ##1 (HTRANS[1:0] == 2'b11);
endsequence; // FixedBurstWrongTermination



//not (BUSY transfer after a SINGLE burst)
//The master is not permitted to perform a BUSY transfer immediately after a SINGLE burst. SINGLE bursts must be followed by an IDLE transfer or a NONSEQ transfer.
property SingleBurstWrongTermination;
   HBURST[2:0] == param_enums::SINGLE |-> ##[1:$] (HTRANS[1:0] !== param_enums::IDLE && HTRANS[1:0] !== param_enums::NONSEQ);
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

//not (if in waited state and then once **HTRANS** changes from IDLE to NONSEQ, NONSEQ signal not held  till HREADY HIGH)
//CONSIDER TEST CLOCK
property WSCR1;
   HREADY == param_enums::WAITED ##0 HTRANS[1:0] == param_enums::IDLE |-> ##[0:$] (HTRANS[1:0] == param_enums::NONSEQ) ##[0:$] !$stable(HTRANS[1:0], @(posedge HCLK)) ##0 (HREADY == param_enums::ACTIVE);
endproperty; // WSCR1


//not (if in waited state, master changes **HTRANS** from one to another but not IDLE to NONSEQ)
//the following should not happen
property WSCR2;
   HREADY == param_enums::WAITED |-> ##[0:$] ( HTRANS[1:0] !== param_enums::IDLE) ##[0:$] (HTRANS[1:0] !== param_enums::NONSEQ);
endproperty; // WSCR2


//not (if in waited state, and in fixed length burst, then master changes **HTRANS** from one to another but not BUSY to SEQ)
//the following should not happen
property WSCR3;
   HREADY == param_enums::WAITED |-> ##[0:$]  (HTRANS[1:0] !== param_enums::BUSY) ##[0:$] (HTRANS[1:0] !== param_enums::SEQ);
endproperty; // WSCR3


//not (if in waited state, and in fixed length burst, then if master changes **HTRANS** from BUSY to SEQ, but not held till HREADY HIGH)
//the following should not happen
property WSCR4;
   HREADY == param_enums::WAITED |-> ##[0:$] (HTRANS[1:0] == param_enums::BUSY) ##[0:$] (HTRANS[1:0] == param_enums::SEQ) ##[0:$] !$stable(HTRANS[1:0], @(posedge HCLK)) ##[0:$] (HREADY == param_enums::ACTIVE);
endproperty; // WSCR4


//not (if in waited state, and in undefined length burst, master can change **HTRANS** from on to another but not from BUSY to any other)
property WSCR5;
  HREADY == param_enums::WAITED |-> ##0 (HBURST[2:0] == param_enums::INCR) ##[0:$] (HTRANS[1:0] !== param_enums::BUSY) ##[0:$] (!$stable(HTRANS[1:0], @(posedge HCLK)));
endproperty; // WSCR5


//not (if in waited state, and in undefined length burst, master changes **HTRANS** from  BUSY to anther, but not when HREADY is LOW) // this probably should be implemented to other changes previously mentioned too.
//the following should not happen
property WSCR6;
   HREADY == param_enums::WAITED |-> ##0 (HBURST[2:0] == param_enums::INCR) ##[0:$] (HTRANS[1:0] == param_enums::BUSY) ##[0:$] (!$stable(HTRANS[1:0], @(posedge HCLK)) ##0 HREADY == param_enums::ACTIVE);
endproperty; // WSCR6


//not (if in waited state, the master changes address during **HTRANS** not in IDLE)
//the following should not happen
property WSCR7(datawidth);
   HREADY == param_enums::WAITED |-> ##[0:$] (!$stable(HADDR[datawidth:0], @(posedge HCLK)) ##0 (HTRANS[1:0] !== param_enums::IDLE));
endproperty; // WSCR7


//not (if in waited state, the master changes from **HTRANS** IDLE to NONSEQ, and changes the address during NONSEQ by not holding it till HREADY is high in the next clock edge)
property WSCR8(datawidth);
   HREADY == param_enums::WAITED |-> ##[0:$] (HTRANS[1:0] == param_enums::IDLE) ##[0:$] (HTRANS[1:0] == param_enums::NONSEQ) ##[0:$] (!$stable(HADDR[datawidth:0], @(posedge HCLK)) ##0 (HTRANS[1:0] == param_enums::NONSEQ) ##[0:$] !$stable(HADDR[datawidth:0], @(posedge HCLK))) ##[0:$] (HREADY == param_enums::ACTIVE);
endproperty; // WSCR8


//not (if in waited state there is ERROR response from the slave, master changes address not when **HTRANS** is in IDLE)
property WSCR9(datawidth);
   HREADY == param_enums::WAITED |-> ##[0:$] HRESP ##[0:$] (!$stable(HADDR[datawidth:0], @(posedge HCLK)) ##0 (HTRANS[1:0] !== param_enums::IDLE));
endproperty; // WSCR9


//--------------------------------------------------------------------------------------------------------------//


//not (not constant throughout a burst transfer) //they have the same timings as the address bus.
/*
 property ProtSigNotConstant;
   @(posedge HCLK) |-> ##0 (HBURST >= INCR) ##0 
*/
