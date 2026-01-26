`timescale 1ns/1ps

module soc_top_tb;

    // --------------------------------
    // Testbench signals
    // --------------------------------
    reg         clk;
    reg         rst_n;

    reg  [31:0] bus_addr;
    reg  [31:0] bus_wdata;
    reg         bus_wr_en;
    reg         bus_rd_en;
    wire [31:0] bus_rdata;

    reg  [31:0] gpio_in;
    wire [31:0] gpio_out;

    // --------------------------------
    // DUT instantiation
    // --------------------------------
    soc_top dut (
        .clk        (clk),
        .rst_n      (rst_n),
        .bus_addr   (bus_addr),
        .bus_wdata  (bus_wdata),
        .bus_wr_en  (bus_wr_en),
        .bus_rd_en  (bus_rd_en),
        .bus_rdata  (bus_rdata),
        .gpio_in    (gpio_in),
        .gpio_out   (gpio_out)
    );

    // --------------------------------
    // Clock generation (10 ns)
    // --------------------------------
    always #5 clk = ~clk;

    // --------------------------------
    // Bus write task
    // --------------------------------
    task bus_write;
        input [31:0] addr;
        input [31:0] data;
        begin
            @(posedge clk);
            bus_addr  <= addr;
            bus_wdata <= data;
            bus_wr_en <= 1'b1;
            bus_rd_en <= 1'b0;
            @(posedge clk);
            bus_wr_en <= 1'b0;
        end
    endtask

    // --------------------------------
    // Bus read task
    // --------------------------------
    task bus_read;
        input [31:0] addr;
        begin
            @(posedge clk);
            bus_addr  <= addr;
            bus_rd_en <= 1'b1;
            bus_wr_en <= 1'b0;
            @(posedge clk);
            bus_rd_en <= 1'b0;
        end
    endtask

    // --------------------------------
    // Test sequence
    // --------------------------------
    initial begin
        // Initialize
        clk        = 0;
        rst_n      = 0;
        bus_addr  = 32'b0;
        bus_wdata = 32'b0;
        bus_wr_en = 0;
        bus_rd_en = 0;
        gpio_in   = 32'h1234_5678;

        // Reset
        #20;
        rst_n = 1;

        // --------------------------------
        // Write GPIO DIR register
        // Base: 0x4000_0000 + 0x04
        // --------------------------------
        bus_write(32'h4000_0004, 32'h0000_00FF);

        // --------------------------------
        // Write GPIO DATA register
        // Base: 0x4000_0000 + 0x00
        // --------------------------------
        bus_write(32'h4000_0000, 32'h0000_00AA);

        // --------------------------------
        // Read GPIO DATA register
        // --------------------------------
        bus_read(32'h4000_0000);

        // --------------------------------
        // Read GPIO DIR register
        // --------------------------------
        bus_read(32'h4000_0004);

        // --------------------------------
        // Read GPIO INPUT register
        // --------------------------------
        bus_read(32'h4000_0008);

        // --------------------------------
        // End simulation
        // --------------------------------
        #50;
        $finish;
    end

endmodule
