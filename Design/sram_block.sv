import npu_pkg::*;

module sram_block (
    input  logic                       clk,
    input  logic                       write_enable,
    input  logic [SRAM_ADDR_WIDTH-1:0] addr,
    input  logic [SRAM_DATA_WIDTH-1:0] din,
    output logic [SRAM_DATA_WIDTH-1:0] dout
);

logic [SRAM_DATA_WIDTH-1:0] mem [0:(1<<SRAM_ADDR_WIDTH)-1];

always_ff @(posedge clk) begin
    if (write_enable) begin
        mem[addr] <= din;
    end
    dout <= mem[addr];
end
    
endmodule