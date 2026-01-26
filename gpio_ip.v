module gpio_ip (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        wr_en,
    input  wire        rd_en,
    input  wire [3:0]  addr,
    input  wire [31:0] wr_data,
    output reg  [31:0] rd_data,
    input  wire [31:0] gpio_in,
    output reg  [31:0] gpio_out,
    output reg  [31:0] gpio_dir
);

    reg [31:0] data_reg;
    reg [31:0] dir_reg;

    // Write logic
    always @(posedge clk) begin
        if (!rst_n) begin
            data_reg <= 32'b0;
            dir_reg  <= 32'b0;
        end else if (wr_en) begin
            case (addr)
                4'h0: data_reg <= wr_data;
                4'h4: dir_reg  <= wr_data;
                default: ;
            endcase
        end
    end

    // Read logic
    always @(*) begin
        if (rd_en) begin
            case (addr)
                4'h0: rd_data = data_reg;
                4'h4: rd_data = dir_reg;
                4'h8: rd_data = gpio_in;
                default: rd_data = 32'b0;
            endcase
        end else begin
            rd_data = 32'b0;
        end
    end

    // GPIO control
    always @(*) begin
        gpio_out = data_reg & dir_reg;
        gpio_dir = dir_reg;
    end

endmodule
