module gpio_ip (
    input  wire        clk,
    input  wire        rst_n,

    // Write interface
    input  wire        wr_en,
    input  wire        rd_en,
    input  wire [7:0]  addr,
    input  wire [31:0] wdata,
    output reg  [31:0] rdata,

    // GPIO signals
    input  wire [31:0] gpio_in,
    output wire [31:0] gpio_out
);

    // --------------------------------------------------
    // Internal registers (to be added)
    // --------------------------------------------------

    // --------------------------------------------------
    // Write logic (to be added)
    // --------------------------------------------------

    // --------------------------------------------------
    // Read logic (to be added)
    // --------------------------------------------------

    // --------------------------------------------------
    // GPIO output logic (to be added)
    // --------------------------------------------------

endmodule
