`timescale 1ns/1ps

module tb_soc_top;

    // -----------------------------
    // Clock & Reset
    // -----------------------------
    reg clk;
    reg rst_n;

    // -----------------------------
    // Simple Bus Signals
    // -----------------------------
    reg         bus_wr_en;
    reg         bus_rd_en;
    reg [31:0]  bus_addr;
    reg [31:0]  bus_wdata;
    wire [31:0] bus_rdata;

    // -----------------------------
    // GPIO
    // -----------------------------
    reg  [31:0] gpio_in;
    wire [31:0] gpio_out;

    // -----------------------------
    // DUT
    // -----------------------------
    soc_top dut (
        .clk        (clk),
        .rst_n      (rst_n),
        .bus_wr_en  (bus_wr_en),
        .bus_rd_en  (bus_rd_en),
        .bus_addr   (bus_addr),
        .bus_wdata  (bus_wdata),
        .bus_rdata  (bus_rdata),
        .gpio_in    (gpio_in),
        .gpio_out   (gpio_out)
    );

    // -----------------------------
    // CLOCK: 100 MHz
    // -----------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk;   // 10ns period
    end

    // -----------------------------
    // TEST SEQUENCE
    // -----------------------------
    initial begin
        // VCD dump
        $dumpfile("soc_gpio.vcd");
        $dumpvars(0, tb_soc_top);

        // -----------------------------
        // INIT
        // -----------------------------
        rst_n      = 0;
        bus_wr_en  = 0;
        bus_rd_en  = 0;
        bus_addr   = 32'd0;
        bus_wdata  = 32'd0;
        gpio_in    = 32'd0;

        $display("=== RESET ASSERTED ===");
        #20;

        rst_n = 1;
        $display("=== RESET RELEASED ===");

        // ---------------------------------------
        // Step 1: Write GPIO DIR register (OUTPUT)
        // Address: 0x4000_0008
        // ---------------------------------------
        @(posedge clk);
        bus_addr   <= 32'h4000_0008;
        bus_wdata  <= 32'hFFFF_FFFF;   // All pins as OUTPUT
        bus_wr_en  <= 1'b1;

        @(posedge clk);
        bus_wr_en <= 1'b0;

        // Extra clock to ensure DIR write is registered
        @(posedge clk);
        $display("GPIO DIR written: %h", 32'hFFFF_FFFF);

        // ---------------------------------------
        // Step 2: Write GPIO DATA register
        // Address: 0x4000_0000
        // ---------------------------------------
        @(posedge clk);
        bus_addr   <= 32'h4000_0000;
        bus_wdata  <= 32'hA5A5_A5A5;
        bus_wr_en  <= 1'b1;

        @(posedge clk);
        bus_wr_en <= 1'b0;
        @(posedge clk);

        $display("GPIO DATA written: %h", 32'hA5A5_A5A5);
        $display("GPIO OUT value: %h", gpio_out);

        // ---------------------------------------
        // Step 3: Read GPIO DATA register
        // ---------------------------------------
        @(posedge clk);
        bus_addr  <= 32'h4000_0000;
        bus_rd_en <= 1'b1;

        @(posedge clk);
        bus_rd_en <= 1'b0;
        @(posedge clk);

        $display("GPIO DATA read: %h", bus_rdata);

        // ---------------------------------------
        // Step 4: Drive GPIO input (optional)
        // ---------------------------------------
        @(posedge clk);
        gpio_in <= 32'h1234_5678;
        $display("GPIO IN driven: %h", gpio_in);

        #50;

        $display("=== SIMULATION DONE ===");
        $finish;
    end

endmodule
