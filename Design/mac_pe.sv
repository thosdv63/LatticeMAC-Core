import npu_pkg::*;

module mac_pe (
    input  logic                        clk,
    input  logic                        rst_n,
    input  logic                        clr_acc,
    input  logic signed [DATA_WIDTH-1:0] in_a,
    input  logic signed [DATA_WIDTH-1:0] in_b,
    output logic signed [DATA_WIDTH-1:0] out_a,
    output logic signed [DATA_WIDTH-1:0] out_b,
    output logic signed [ACC_WIDTH-1:0]  acc    
);

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out_a <= '0;
        out_b <= '0;
        acc   <= '0;
    end else if (clr_acc) begin
        out_a <= '0;
        out_b <= '0;
        acc   <= '0;
    end else begin
        out_a <= in_a;
        out_b <= in_b;
        acc   <= acc + (in_a * in_b);
    end
end
    
endmodule