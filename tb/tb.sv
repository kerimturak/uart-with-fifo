`timescale 1ns / 1ps
module tb;

  // Parameters
  localparam CLK_PERIOD = 10; // 100 MHz clock
  localparam BAUD_DIV = 16'h0010; // Baud divisor for simulation
  localparam DATA_WIDTH = 8;

  // Signals
  logic clk;
  logic rst_n;
  logic tx_we;
  logic tx_en;
  logic [DATA_WIDTH-1:0] din;
  logic full;
  logic empty;
  logic tx_bit;

  // Instantiate the DUT (Device Under Test)
  uart_tx dut (
    .clk_i(clk),
    .rst_ni(rst_n),
    .baud_div_i(BAUD_DIV),
    .tx_we_i(tx_we),
    .tx_en_i(tx_en),
    .din_i(din),
    .full_o(full),
    .empty_o(empty),
    .tx_bit_o(tx_bit)
  );

  logic [15:0] baud_counter;      // Clock tick counter until baud_div is achieved
  logic        baud_clk;          // Baud clock tick indicator

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      baud_clk     <= 1'b0;
      baud_counter <= 16'd0;
    end else begin

      if (tx_en) begin
        if (baud_counter == BAUD_DIV - 1) begin
          baud_counter <= 16'd0;
          baud_clk     <= 1'b1;
        end else begin
          baud_counter <= baud_counter + 1;
          baud_clk     <= 1'b0;
        end
      end else begin
        baud_clk <= 1'b0;
      end

    end
  end

  // Clock generation
  initial begin
    clk = 0;
    forever #(CLK_PERIOD / 2) clk = ~clk;
  end

  // Reset logic
  initial begin
    rst_n = 0;
    #50;
    rst_n = 1;
  end

  // Testbench variables
  logic [DATA_WIDTH-1:0] test_data [0:15]; // Test data array
  integer i;

  // Initialize test data
  initial begin
    for (i = 0; i < 16; i++) begin
      test_data[i] = i;
    end
  end

  // Self-checking logic
  initial begin
    tx_we = 0;
    tx_en = 0;
    din = 0;

    // Wait for reset release
    @(posedge rst_n);

    // Test case: Write data into FIFO and transmit
    for (i = 0; i < 16; i++) begin
      @(posedge clk);
      if (!full) begin
        tx_we = 1;
        din = test_data[i];
      end
      @(posedge clk);
      tx_we = 0;
    end

    // Enable transmission
    @(posedge clk);
    tx_en = 1;

     // Test complete
    $stop;
  end

endmodule
