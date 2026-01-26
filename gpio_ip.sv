// ==================================================
// GPIO IP RTL Module
// Provides register storage, write/readback logic
// and drives GPIO outputs according to direction.
// ==================================================

module gpio_ip (
    input  wire        clk,
    input  wire        rst_n,

    // Write / read interface
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
    // Register storage
    // --------------------------------------------------
    reg [31:0] data_reg;   // GPIO output data register
    reg [31:0] dir_reg;    // GPIO direction register

    // --------------------------------------------------
    // Write logic (synchronous)
    // --------------------------------------------------
    always @(posedge clk) begin
        if (!rst_n) begin
            data_reg <= 32'b0;
            dir_reg  <= 32'b0;
        end
        else begin
            if (wr_en) begin
                case (addr)
                    8'h00: data_reg <= wdata; // DATA register
                    8'h04: dir_reg  <= wdata; // DIR register
                    default: begin
                        // No write, hold value
                        data_reg <= data_reg;
                        dir_reg  <= dir_reg;
                    end
                endcase
            end
        end
    end

    // --------------------------------------------------
    // Readback logic (combinational)
    // --------------------------------------------------
    always @(*) begin
        if (rd_en) begin
            case (addr)
                8'h00: rdata = data_reg; // DATA register
                8'h04: rdata = dir_reg;  // DIR register
                8'h08: rdata = gpio_in;  // GPIO input (read-only)
                default: rdata = 32'b0;
            endcase
        end
        else begin
            rdata = 32'b0;
        end
    end

    // --------------------------------------------------
    // GPIO output logic
    // --------------------------------------------------
    assign gpio_out = data_reg & dir_reg;

endmodule
