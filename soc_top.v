module soc_top (
    input  wire        clk,          // system clock
    input  wire        rst_n,        // active-low reset

    // Simple memory-mapped bus signals
    input  wire [31:0] bus_addr,
    input  wire [31:0] bus_wdata,
    input  wire        bus_wr_en,
    input  wire        bus_rd_en,
    output wire [31:0] bus_rdata,

    // GPIO pins
    input  wire [31:0] gpio_in,
    output wire [31:0] gpio_out
);

    // -----------------------------
    // Internal wires
    // -----------------------------
    wire [31:0] gpio_rdata;   // Data read from GPIO
    wire        gpio_sel;     // GPIO select from address decoding

    // -----------------------------
    // Address decoding
    // -----------------------------
    // GPIO base address = 0x4000_0000
    localparam GPIO_BASE = 32'h4000_0000;

    assign gpio_sel = (bus_addr >= GPIO_BASE) &&
                      (bus_addr <  GPIO_BASE + 32'h0000_000C); // 3 registers

    // -----------------------------
    // GPIO IP instantiation
    // -----------------------------
    gpio_ip u_gpio (
        .clk     (clk),
        .rst_n   (rst_n),
        .wr_en  (bus_wr_en & gpio_sel),
        .rd_en  (bus_rd_en & gpio_sel),
        .addr   (bus_addr[7:0]),     // lower 8 bits for register offset
        .wdata  (bus_wdata),
        .rdata  (gpio_rdata),
        .gpio_in(gpio_in),
        .gpio_out(gpio_out)
    );

    // -----------------------------
    // Bus read data mux
    // -----------------------------
    assign bus_rdata = gpio_sel ? gpio_rdata : 32'b0;

endmodule
