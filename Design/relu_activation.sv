import npu_pkg::*;

module relu_activation (
    input  matrix_acc_t data_in,
    output matrix_acc_t data_out
);

genvar i, j;
generate
    for (i = 0; i < N; i++) begin : g_relu_row
        for (j = 0; j < N; j++) begin : g_relu_col
            // relu function
            assign data_out[i][j] = (data_in[i][j][ACC_WIDTH-1] == 1'b1) ? '0 : data_in[i][j];
        end
    end
endgenerate
    
endmodule