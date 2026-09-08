import npu_pkg::*;

module skew_buffer (
    input  logic    clk,
    input  logic    rst_n,
    input  vec_in_t din,
    output vec_in_t dout
);

genvar i;

generate
    for (i = 0; i < N; i++) begin : g_skew
        if (i == 0) begin : g_line0
            assign dout[0] = din[0];
        end else begin : g_line_delay
            logic signed [DATA_WIDTH-1:0] shift_reg [0:i-1];

            always_ff @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    for (int k = 0; k < i; k++) begin
                        shift_reg[k] <= '0;
                    end
                end else begin
                    shift_reg[0] <= din[i];
                    for (int k = 1; k < i; k++) begin
                        shift_reg[k] <= shift_reg[k-1];
                    end
                end
            end 
            
            assign dout[i] = shift_reg[i-1];
        end
    end
endgenerate

endmodule