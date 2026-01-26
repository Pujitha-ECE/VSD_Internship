`timescale 1ns/1ps

module tb_gpio_ip;

    // Testbench signals
    reg         clk;
    reg         rst_n;
    reg         wr_en;
    reg         rd_en;
    reg [3:0]   addr;
    reg [31:0]  wr_data;
    reg [31:0]  gpio_in;

    wire [31:0] rd_data;
    wire [31:0] gpio_out;
    wire [31:0] gpio_dir;

    // DUT instantiation
    gpio_ip dut (
        .clk      (clk),
        .rst_n    (rst_n),
        .wr_en    (wr_en),
        .rd_en    (rd_en),
        .addr     (addr),
        .wr_data  (wr_data),
        .rd_data  (rd_data),
        .gpio_in  (gpio_in),
        .gpio_out (gpio_out),
        .gpio_dir (gpio_dir)
    );

    // Clock generation (10 ns period)
    always #5 clk = ~clk;

    // -------------------------------
    // WRITE task with debug
    // -------------------------------
    task write_reg(input [3:0] a, input [31:0] d);
    begin
        @(posedge clk);
        wr_en   = 1;
        rd_en   = 0;
        addr    = a;
        wr_data = d;

        @(posedge clk);
        wr_en = 0;

        $display("[%0t ns] WRITE  Addr = 0x%0h  Data = 0x%0h",
                 $time, a, d);
    end
    endtask

    // -------------------------------
    // READ task with debug
    // -------------------------------
    task read_reg(input [3:0] a);
    begin
        @(posedge clk);
        rd_en = 1;
        wr_en = 0;
        addr  = a;

        #1; // allow combinational read to settle
        $display("[%0t ns] READ   Addr = 0x%0h  Data = 0x%0h",
                 $time, a, rd_data);

        @(posedge clk);
        rd_en = 0;
    end
    endtask

    // -------------------------------
    // Main test sequence
    // -------------------------------
    initial begin
        // Initial values
        clk     = 0;
        rst_n   = 0;
        wr_en   = 0;
        rd_en   = 0;
        addr    = 0;
        wr_data = 0;
        gpio_in = 0;

        $display("======================================");
        $display(" GPIO IP TESTBENCH START ");
        $display("======================================");

        // Apply reset
        #20;
        rst_n = 1;
        $display("[%0t ns] Reset deasserted", $time);

        // ----------------------------------
        // Write GPIO direction (all outputs)
        // ----------------------------------
        write_reg(4'h4, 32'hFFFF_FFFF);

        // ----------------------------------
        // Write GPIO data
        // ----------------------------------
        write_reg(4'h0, 32'hA5A5_A5A5);

        // ----------------------------------
        // Read back registers
        // ----------------------------------
        read_reg(4'h0); // DATA
        read_reg(4'h4); // DIR

        // ----------------------------------
        // Drive GPIO inputs and read
        // ----------------------------------
        gpio_in = 32'h1234_5678;
        $display("[%0t ns] GPIO_IN driven = 0x%0h",
                 $time, gpio_in);

        read_reg(4'h8); // GPIO_IN read

        // ----------------------------------
        // Observe outputs
        // ----------------------------------
        #10;
        $display("[%0t ns] GPIO_OUT = 0x%0h",
                 $time, gpio_out);
        $display("[%0t ns] GPIO_DIR = 0x%0h",
                 $time, gpio_dir);

        $display("======================================");
        $display(" GPIO IP TESTBENCH END ");
        $display("======================================");

        #20;
        $finish;
    end

endmodule
