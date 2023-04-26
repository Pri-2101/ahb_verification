
typedef enum bit[1:0] {IDLE = 2'b00, BUSY = 2'b01, NONSEQ = 2'b10, SEQ = 2'b11} HTRANS_enum;

typedef enum bit[2:0] {SINGLE = 3'b000, INCR = 3'b001, WRAP4 = 3'b010, INCR4 = 3'b011, WRAP8 = 3'b100, INCR8 = 3'b101, WRAP16 = 3'b110, INCR16 = 3'b111} HBURST_enum;

typedef enum bit {WAITED, ACTIVE} State_enum;

typedef enum bit[2:0] {BYTE = 3'b000, HALF_WORD = 3'b001, WORD = 3'b010, DOUBLE_WORD = 3'b011, FOUR_WORD_LINE = 3'b100, EIGHT_WORD_LINE = 3'b101, FIVE_TWELVE = 3'b110, TEN_TWENTY_FOUR = 3'b111} HSIZE_enum;

typedef enum bit {OKAY = 1'b0, ERROR = 1'b1} HRESP_enum;

typedef enum bit {HIGH = 1'b1, LOW = 1'b0} HREADY_enum;

typedef enum int {datawidth = 32} line_width_enum;


HREADY_enum hready_enum;
HRESP_enum hresp_enums;	     
HTRANS_enum htrans_enums;
HBURST_enum hburst_enums;
State_enum state_enums;
HSIZE_enum hsize_enums;
line_width_enum width_enums;
