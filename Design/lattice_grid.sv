import npu_pkg::*;

module lattice_grid (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        clr_acc,
    input  vec_in_t     a_in,
    input  vec_in_t     b_in,
    output matrix_acc_t c_out
);

logic signed [DATA_WIDTH-1:0] a_wire [N][N+1];
logic signed [DATA_WIDTH-1:0] b_wire [N+1][N];

genvar i, j;
generate
    for (i = 0; i < N; i++) begin : g_input_assign
        assign a_wire[i][0] = a_in[i];
        assign b_wire[0][i] = b_in[i];
    end

    for (i = 0; i < N; i++) begin : g_row
        for (j = 0; j < N; j++) begin : g_col
            mac_pe pe_inst (
                .clk     (clk),
                .rst_n   (rst_n),
                .clr_acc (clr_acc),
                .in_a    (a_wire[i][j]),
                .in_b    (b_wire[i][j]),
                .out_a   (a_wire[i][j+1]),
                .out_b   (b_wire[i+1][j]),
                .acc     (c_out[i][j])
            );
        end
    end
endgenerate
    
endmodule