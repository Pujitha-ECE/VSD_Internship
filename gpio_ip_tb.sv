// ==================================================
// gpio_ip_tb.sv
// Self-checking testbench for gpio_ip module
// ==================================================

`timescale 1ns/1ps

module gpio_ip_tb;

    // Clock & reset
    reg clk;
    reg rst_n;

    // Write / read interface
    reg wr_en;
    reg rd_en;
    reg [7:0] addr;
    reg [31:0] wdata;
    wire [31:0] rdata;

    // GPIO signals
    reg [31:0] gpio_in;
    wire [31:0] gpio_out;

    // Instantiate the DUT
    gpio_ip dut (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .addr(addr),
        .wdata(wdata),
        .rdata(rdata),
        .gpio_in(gpio_in),
        .gpio_out(gpio_out)
    );

    // Clock generation: 10ns period
    initial clk = 0;
    always #5 clk = ~clk;

    // Task to write register
    task write_reg(input [7:0] a, input [31:0] d);
        begin
            @(posedge clk);
            wr_en = 1;
            addr  = a;
            wdata = d;
            @(posedge clk);
            wr_en = 0;
        end
    endtask

    // Task to read register and check value
    task read_reg(input [7:0] a, input [31:0] expected);
        begin
            @(posedge clk);
            rd_en = 1;
            addr  = a;
            @(posedge clk);
            rd_en = 0;
            if (rdata !== expected)
                $display("ERROR: Read from %h returned %h, expected %h", a, rdata, expected);
            else
                $display("PASS: Read from %h returned %h", a, rdata);
        end
    endtask

    // Test sequence
    initial begin
        // Initialize signals
        rst_n   = 0;
        wr_en   = 0;
        rd_en   = 0;
        addr    = 0;
        wdata   = 0;
        gpio_in = 32'hA5A5A5A5;

        // Apply reset
        @(posedge clk);
        rst_n = 1;

        // Step 1: Write DIR register (lower 16 bits outputs)
        write_reg(8'h04, 32'h0000FFFF);

        // Step 2: Write DATA register
        write_reg(8'h00, 32'h00001234);

        // Step 3: Read back DATA and DIR
        read_reg(8'h00, 32'h00001234);
        read_reg(8'h04, 32'h0000FFFF);

        // Step 4: Read GPIO input register
        read_reg(8'h08, 32'hA5A5A5A5);

        // Step 5: Check GPIO output
        @(posedge clk);
        if (gpio_out !== (32'h00001234 & 32'h0000FFFF))
            $display("ERROR: gpio_out = %h, expected %h", gpio_out, 32'h00001234 & 32'h0000FFFF);
        else
            $display("PASS: gpio_out = %h", gpio_out);

        $display("All tests finished.");
        #10 $finish;
    end

endmodule
