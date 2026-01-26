`timescale 1ns/1ps

module gpio_ip_tb;

    // -----------------------------
    // Testbench signals
    // -----------------------------
    reg         clk;
    reg         rst_n;
    reg         wr_en;
    reg         rd_en;
    reg  [7:0]  addr;
    reg  [31:0] wdata;
    wire [31:0] rdata;
    reg  [31:0] gpio_in;
    wire [31:0] gpio_out;

    // -----------------------------
    // DUT instantiation
    // -----------------------------
    gpio_ip dut (
        .clk     (clk),
        .rst_n   (rst_n),
        .wr_en   (wr_en),
        .rd_en   (rd_en),
        .addr    (addr),
        .wdata   (wdata),
        .rdata   (rdata),
        .gpio_in (gpio_in),
        .gpio_out(gpio_out)
    );

    // -----------------------------
    // Clock generation (10 ns)
    // -----------------------------
    always #5 clk = ~clk;

    // -----------------------------
    // Test sequence
    // -----------------------------
    initial begin
        // Initialize
        clk     = 0;
        rst_n   = 0;
        wr_en   = 0;
        rd_en   = 0;
        addr    = 8'h00;
        wdata   = 32'h0;
        gpio_in = 32'hA5A5_A5A5;

        // Apply reset
        #20;
        rst_n = 1;

        // -----------------------------
        // Write DIR register (0x04)
        // Set lower 8 pins as output
        // -----------------------------
        #10;
        wr_en = 1;
        addr  = 8'h04;
        wdata = 32'h0000_00FF;
        #10;
        wr_en = 0;

        // -----------------------------
        // Write DATA register (0x00)
        // -----------------------------
        #10;
        wr_en = 1;
        addr  = 8'h00;
        wdata = 32'h0000_00AA;
        #10;
        wr_en = 0;

        // -----------------------------
        // Read DATA register
        // -----------------------------
        #10;
        rd_en = 1;
        addr  = 8'h00;
        #10;
        rd_en = 0;

        // -----------------------------
        // Read DIR register
        // -----------------------------
        #10;
        rd_en = 1;
        addr  = 8'h04;
        #10;
        rd_en = 0;

        // -----------------------------
        // Read GPIO input register
        // -----------------------------
        #10;
        rd_en = 1;
        addr  = 8'h08;
        #10;
        rd_en = 0;

        // Finish simulation
        #20;
        $finish;
    end

endmodule
