// MAIN TESTBENCH

`timescale 1ns/1ps
import npu_pkg::*;

module tb_npu_core;
    logic                       clk;
    logic                       rst_n;
    logic                       start;
    logic                       we_a;
    logic                       we_b;
    logic [SRAM_ADDR_WIDTH-1:0] ext_addr;
    logic [SRAM_DATA_WIDTH-1:0] ext_din_a;
    logic [SRAM_DATA_WIDTH-1:0] ext_din_b;
    logic                       done_out;
    matrix_acc_t                data_out;

    logic signed [DATA_WIDTH-1:0] mat_a [0:(N*N)-1];
    logic signed [DATA_WIDTH-1:0] mat_b [0:(N*N)-1];
    logic signed [ACC_WIDTH-1:0]  expected_relu [0:(N*N)-1];
    logic signed [ACC_WIDTH-1:0]  sum;

    logic [SRAM_DATA_WIDTH-1:0] tmp_din_a;
    logic [SRAM_DATA_WIDTH-1:0] tmp_din_b;

    logic signed [ACC_WIDTH-1:0] data_out_copy [0:(N*N)-1];
    genvar gi, gj;
    generate
        for (gi = 0; gi < N; gi = gi + 1) begin : copy_row
            for (gj = 0; gj < N; gj = gj + 1) begin : copy_col
                always @(*) begin
                    data_out_copy[gi*N + gj] = data_out[gi][gj];
                end
            end
        end
    endgenerate

    npu_core dut (.*);

    always #5 clk = ~clk;

    integer i, j, k;
    integer row, col, addr_idx;

    initial begin
        $dumpfile("npu_sim.vcd");
        $dumpvars(0, tb_npu_core);
        clk       = 0;
        rst_n     = 0;
        start     = 0;
        we_a      = 0;
        we_b      = 0;
        ext_addr  = 0;
        ext_din_a = 0;
        ext_din_b = 0;

        #20 rst_n = 1;
        #10;

        // Filling matrices
        for (i = 0; i < N*N; i = i + 1) begin
            mat_a[i] = (i % 5) - 2;
            mat_b[i] = (i % 4) - 1;
        end

        // Calculating expected output
        for (i = 0; i < N; i = i + 1) begin
            for (j = 0; j < N; j = j + 1) begin
                sum = 0;
                for (k = 0; k < N; k = k + 1) begin
                    sum = sum + (mat_a[i*N + k] * mat_b[k*N + j]);
                end
                expected_relu[i*N + j] = (sum < 0) ? 0 : sum;
            end
        end

        // Reset sram
        $display("SRAM memory is being reset (0-Padding)");
        for (addr_idx = 0; addr_idx < (1<<SRAM_ADDR_WIDTH); addr_idx = addr_idx + 1) begin
            @(posedge clk);
            we_a      <= 1;
            we_b      <= 1;
            ext_addr  <= addr_idx;
            ext_din_a <= '0;
            ext_din_b <= '0;
        end

        // Upload matrices
        $display("Writing data to SRAM for %0dx%0d", N, N);
        for (row = 0; row < N; row = row + 1) begin
            @(posedge clk);
            we_a     <= 1;
            we_b     <= 1;
            ext_addr <= row;
            
            tmp_din_a = '0;
            tmp_din_b = '0;
            
            for (col = 0; col < N; col = col + 1) begin
                tmp_din_a[col*DATA_WIDTH +: DATA_WIDTH] = mat_a[col*N + row]; // Transpose
                tmp_din_b[col*DATA_WIDTH +: DATA_WIDTH] = mat_b[row*N + col]; // Satir
            end
            
            ext_din_a <= tmp_din_a;
            ext_din_b <= tmp_din_b;
        end

        @(posedge clk);
        we_a <= 0;
        we_b <= 0;
        #10;

        $display("Matris Multiplication Started");
        @(posedge clk);
        start <= 1;
        
        @(posedge clk);
        start <= 0;

        wait(done_out == 1);
        $display("Calculation Done");
        #10;

        $display("\nHARDWARE NPU OUTPUT");
        for (i = 0; i < N; i = i + 1) begin
            $write("Satir %2d: ", i);
            for (j = 0; j < N; j = j + 1) begin
                $write("%6d ", data_out_copy[i*N + j]);
            end
            $display("");
        end

        $display("\nEXPECTED OUTPUT");
        for (i = 0; i < N; i = i + 1) begin
            $write("Satir %2d: ", i);
            for (j = 0; j < N; j = j + 1) begin
                $write("%6d ", expected_relu[i*N + j]);
            end
            $display("");
        end

        // Error Scan
        for (i = 0; i < N; i = i + 1) begin
            for (j = 0; j < N; j = j + 1) begin
                if (data_out_copy[i*N + j] !== expected_relu[i*N + j]) begin
                    $display("\nERROR in: [%0d][%0d] -> Found: %0d, Expected: %0d", 
                             i, j, data_out_copy[i*N + j], expected_relu[i*N + j]);
                    $finish;
                end
            end
        end

        $display("\n--------------------------------------------------");
        $display("  SUCCESFULL: %0dx%0d NPU MATRIX PRODUCT AND RELU VERIFIED!", N, N);
        $display("----------------------------------------------------\n");
        $finish;
    end

endmodule