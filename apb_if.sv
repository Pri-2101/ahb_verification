interface apb_if(
  input PCLK,
  input PRESETn);

  logic[31:0] PADDR;
  logic[31:0] PRDATA;
  logic[31:0] PWDATA;
  logic[15:0] PSEL;
  logic PENABLE;
  logic PWRITE;
  logic PREADY;
  logic PSLVERR;
endinterface: apb_if
