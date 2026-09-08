// LEGACY TESTBENCH

`timescale 1ns / 1ps

module tb_skew_buffer;

    localparam int N          = 4;
    localparam int DATA_WIDTH = 8;

    logic                     clk;
    logic                     rst_n;
    logic signed [N-1:0][DATA_WIDTH-1:0] din;
    logic signed [N-1:0][DATA_WIDTH-1:0] dout;

    skew_buffer #(
        .N(N),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .din(din),
        .dout(dout)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("tb_skew_buffer.vcd");
        $dumpvars(0, tb_skew_buffer);
    end

    initial begin
        rst_n = 0;
        for (int k = 0; k < N; k++) begin
            din[k] = 8'sd0;
        end

        repeat (2) @(posedge clk);
        #1; // timing
        rst_n = 1;

        din[0] = 8'sd10;
        din[1] = 8'sd20;
        din[2] = 8'sd30;
        din[3] = 8'sd40;

        #1;
        $display("[t = 0 Clock] dout[0]=%0d | dout[1]=%0d | dout[2]=%0d | dout[3]=%0d", 
                 dout[0], dout[1], dout[2], dout[3]);

        @(posedge clk); #1;
        $display("[t = 1 Clock] dout[0]=%0d | dout[1]=%0d | dout[2]=%0d | dout[3]=%0d", 
                 dout[0], dout[1], dout[2], dout[3]);

        @(posedge clk); #1;
        $display("[t = 2 Clock] dout[0]=%0d | dout[1]=%0d | dout[2]=%0d | dout[3]=%0d", 
                 dout[0], dout[1], dout[2], dout[3]);

        @(posedge clk); #1;
        $display("[t = 3 Clock] dout[0]=%0d | dout[1]=%0d | dout[2]=%0d | dout[3]=%0d", 
                 dout[0], dout[1], dout[2], dout[3]);

        for (int k = 0; k < N; k++) begin
            din[k] = 8'sd0;
        end

        repeat (3) @(posedge clk);
        $display("Test completed.");
        $finish;
    end

endmodule