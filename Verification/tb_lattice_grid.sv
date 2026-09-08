// LEGACY TESTBENCH, NOT IN USE
`timescale 1ns / 1ps

module tb_lattice_grid;

    localparam int N          = 4;
    localparam int DATA_WIDTH = 8;
    localparam int ACC_WIDTH  = 32;

    logic clk;
    logic rst_n;
    logic clr_acc;

    logic signed [N-1:0][DATA_WIDTH-1:0] din_a;
    logic signed [N-1:0][DATA_WIDTH-1:0] din_b;

    logic signed [N-1:0][DATA_WIDTH-1:0] a_skewed;
    logic signed [N-1:0][DATA_WIDTH-1:0] b_skewed;

    logic signed [N-1:0][N-1:0][ACC_WIDTH-1:0] c_out;


    skew_buffer #(.N(N), .DATA_WIDTH(DATA_WIDTH)) skew_a (
        .clk  (clk),
        .rst_n(rst_n),
        .din  (din_a),
        .dout (a_skewed)
    );

    skew_buffer #(.N(N), .DATA_WIDTH(DATA_WIDTH)) skew_b (
        .clk  (clk),
        .rst_n(rst_n),
        .din  (din_b),
        .dout (b_skewed)
    );

    lattice_grid #(.N(N), .DATA_WIDTH(DATA_WIDTH), .ACC_WIDTH(ACC_WIDTH)) grid (
        .clk    (clk),
        .rst_n  (rst_n),
        .clr_acc(clr_acc),
        .a_in   (a_skewed),
        .b_in   (b_skewed),
        .c_out  (c_out)
    );


    // 100MHz Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        $dumpfile("tb_lattice_grid.vcd");
        $dumpvars(0, tb_lattice_grid);
    end

    initial begin
        rst_n   = 0;
        clr_acc = 0;
        for(int k=0; k<N; k++) begin
            din_a[k] = '0;
            din_b[k] = '0;
        end
        
        repeat(2) @(posedge clk);
        #1; 
        rst_n = 1;
        clr_acc = 1; 
        
        din_a[0] = 8'sd1; din_a[1] = 8'sd2; din_a[2] = 8'sd3; din_a[3] = 8'sd4;
        din_b[0] = 8'sd1; din_b[1] = 8'sd2; din_b[2] = 8'sd3; din_b[3] = 8'sd4;
        
        @(posedge clk);
        #1;
        clr_acc = 0; 
        
        for(int k=0; k<N; k++) begin
            din_a[k] = '0;
            din_b[k] = '0;
        end

        repeat(15) @(posedge clk);
        
        $display("\nCALCULATED C MATRIS :");
        $display("[%4d, %4d, %4d, %4d]", c_out[0][0], c_out[0][1], c_out[0][2], c_out[0][3]);
        $display("[%4d, %4d, %4d, %4d]", c_out[1][0], c_out[1][1], c_out[1][2], c_out[1][3]);
        $display("[%4d, %4d, %4d, %4d]", c_out[2][0], c_out[2][1], c_out[2][2], c_out[2][3]);
        $display("[%4d, %4d, %4d, %4d]", c_out[3][0], c_out[3][1], c_out[3][2], c_out[3][3]);
        $display("------------------------------------\n");
        
        $finish;
    end

endmodule