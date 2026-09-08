package npu_pkg;
    localparam int N               = 16;  // Supported 4, 8, 16, 32 (and maybe 64, 128 ....)
    localparam int DATA_WIDTH      = 8; 
    localparam int ACC_WIDTH       = 32; 
    localparam int SRAM_ADDR_WIDTH = 8;
    localparam int SRAM_DATA_WIDTH = N * DATA_WIDTH;

    // 1D Vector
    typedef logic signed [N-1:0][DATA_WIDTH-1:0] vec_in_t;
    
    // 2D Matrix
    typedef logic signed [N-1:0][N-1:0][ACC_WIDTH-1:0] matrix_acc_t;

    // FSM states
    typedef enum logic [1:0] { 
        IDLE         = 2'b00,
        LOAD_COMPUTE = 2'b01,
        WAIT         = 2'b10,
        DONE         = 2'b11
    } state_t;
endpackage