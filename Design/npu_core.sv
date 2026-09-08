import npu_pkg::*;

module npu_core (
    input  logic                       clk,
    input  logic                       rst_n,
    input  logic                       start,
    input  logic                       we_a,
    input  logic                       we_b,
    input  logic [SRAM_ADDR_WIDTH-1:0] ext_addr,
    input  logic [SRAM_DATA_WIDTH-1:0] ext_din_a,
    input  logic [SRAM_DATA_WIDTH-1:0] ext_din_b,
    output logic                       done_out,
    output matrix_acc_t                data_out
);

    logic [SRAM_ADDR_WIDTH-1:0] ctrl_sram_addr;
    logic [SRAM_ADDR_WIDTH-1:0] final_sram_addr;
    logic                       clr_acc;

    logic [SRAM_DATA_WIDTH-1:0] sram_dout_a;
    logic [SRAM_DATA_WIDTH-1:0] sram_dout_b;

    vec_in_t skew_dout_a;
    vec_in_t skew_dout_b;

    matrix_acc_t grid_c_out;

    assign final_sram_addr = (we_a || we_b) ? ext_addr : ctrl_sram_addr;

    npu_controller controller_inst (
        .clk       (clk),
        .rst_n     (rst_n),
        .start     (start),
        .sram_addr (ctrl_sram_addr),
        .clr_acc   (clr_acc),
        .done_out  (done_out)
    );

    sram_block sram_a_inst (
        .clk          (clk),
        .write_enable (we_a),
        .addr         (final_sram_addr),
        .din          (ext_din_a),
        .dout         (sram_dout_a)
    );

    sram_block sram_b_inst (
        .clk          (clk),
        .write_enable (we_b),
        .addr         (final_sram_addr),
        .din          (ext_din_b),
        .dout         (sram_dout_b)
    );

    skew_buffer skew_a_inst (
        .clk     (clk),
        .rst_n   (rst_n),
        .clr_acc (clr_acc),
        .din     (vec_in_t'(sram_dout_a)),
        .dout    (skew_dout_a)
    );

    skew_buffer skew_b_inst (
        .clk     (clk),
        .rst_n   (rst_n),
        .clr_acc (clr_acc),
        .din     (vec_in_t'(sram_dout_b)),
        .dout    (skew_dout_b)
    );

    lattice_grid grid_inst (
        .clk     (clk),
        .rst_n   (rst_n),
        .clr_acc (clr_acc),
        .a_in    (skew_dout_a),
        .b_in    (skew_dout_b),
        .c_out   (grid_c_out)
    );

    relu_activation relu_inst (
        .clk      (clk),
        .rst_n    (rst_n),
        .data_in  (grid_c_out),
        .data_out (data_out)
    );

endmodule
