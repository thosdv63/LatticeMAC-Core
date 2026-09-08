import npu_pkg::*;

module relu_activation (
    input  logic        clk,
    input  logic        rst_n,
    input  matrix_acc_t data_in,
    output matrix_acc_t data_out
);

genvar i, j;
generate
    for (i = 0; i < N; i++) begin : g_relu_row
        for (j = 0; j < N; j++) begin : g_relu_col
            always_ff @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    data_out[i][j] <= '0;
                end else begin
                    data_out[i][j] <= (data_in[i][j][ACC_WIDTH-1] == 1'b1) ? '0 : data_in[i][j];
                end
            end
        end
    end
endgenerate
    
endmodule
