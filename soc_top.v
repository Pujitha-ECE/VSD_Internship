module soc_top (
    input  wire        clk,
    input  wire        rst_n,

    // Simple SoC bus interface
    input  wire        bus_wr_en,
    input  wire        bus_rd_en,
    input  wire [31:0] bus_addr,
    input  wire [31:0] bus_wdata,
    output reg  [31:0] bus_rdata,

    // External GPIO pins
    input  wire [31:0] gpio_in,
    output wire [31:0] gpio_out
);

    // --------------------------------
    // Address decoding
    // GPIO base address: 0x4000_0000
    // --------------------------------
    wire gpio_sel;
    assign gpio_sel = (bus_addr[31:12] == 20'h40000);

    // GPIO internal wires
    wire [31:0] gpio_rdata;
    wire [31:0] gpio_dir;

    // --------------------------------
    // GPIO IP instantiation
    // --------------------------------
    gpio_ip u_gpio (
        .clk      (clk),
        .rst_n    (rst_n),
        .wr_en    (bus_wr_en & gpio_sel),
        .rd_en    (bus_rd_en & gpio_sel),
        .addr     (bus_addr[3:0]),
        .wr_data  (bus_wdata),
        .rd_data  (gpio_rdata),
        .gpio_in  (gpio_in),
        .gpio_out (gpio_out),
        .gpio_dir (gpio_dir)
    );

    // --------------------------------
    // Read data mux
    // --------------------------------
    always @(*) begin
        if (gpio_sel && bus_rd_en)
            bus_rdata = gpio_rdata;
        else
            bus_rdata = 32'b0;
    end

endmodule
