// LEGACY TESTBENCH

`timescale 1ns / 1ps

module tb_mac_pe;

    logic        clk;
    logic        rst_n;
    logic        clr_acc;
    logic signed [7:0]  in_a;
    logic signed [7:0]  in_b;

    logic signed [7:0]  out_a;
    logic signed [7:0]  out_b;
    logic signed [31:0] acc;

    mac_pe dut (
        .clk(clk),
        .rst_n(rst_n),
        .clr_acc(clr_acc),
        .in_a(in_a),
        .in_b(in_b),
        .out_a(out_a),
        .out_b(out_b),
        .acc(acc)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("tb_mac_pe.vcd");
        $dumpvars(0, tb_mac_pe); // Tüm alt sinyalleri kaydeder
    end

    initial begin
        rst_n   = 0;
        clr_acc = 0;
        in_a    = 8'sd0;
        in_b    = 8'sd0;

        repeat (2) @(posedge clk);
        rst_n   = 1;
        @(posedge clk);

        // acc = 5 * 4 = 20
        clr_acc = 1;
        in_a    = 8'sd5;
        in_b    = 8'sd4;
        @(posedge clk);

        clr_acc = 0;
        in_a    = 8'sd3;
        in_b    = -8'sd2;
        @(posedge clk);

        // acc = 14 + (-10 * 5) = -36
        in_a    = -8'sd10;
        in_b    = 8'sd5;
        @(posedge clk);

        // acc = 12 * 2 = 24
        clr_acc = 1;
        in_a    = 8'sd12;
        in_b    = 8'sd2;
        @(posedge clk);

        clr_acc = 0;
        in_a    = 8'sd0;
        in_b    = 8'sd0;
        repeat (2) @(posedge clk);

        $display("Simulation finished succesfully.");
        $finish;
    end

endmodule