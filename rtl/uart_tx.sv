`timescale 1ns / 1ps
module uart_tx
(
    input  logic        clk_i,
    input  logic        rst_ni,
    input  logic [15:0] baud_div_i,
    input  logic        tx_we_i,
    input  logic        tx_en_i,
    input  logic [7:0]  din_i,
    output logic        full_o,
    output logic        empty_o,
    output logic        tx_bit_o
);

  localparam DEPTH = 32;

  logic [7:0]  data;
  logic [9:0]  frame;
  logic [3:0]  bit_counter;
  logic [15:0] baud_counter;
  logic        baud_clk;
  logic        rd_en;

  enum logic [1:0] {
    IDLE,
    LOAD,
    SENDING
  } state, next_state;

  wbit_fifo #(
    .DATA_WIDTH (8),
    .FIFO_DEPTH (DEPTH)
  ) tx_buffer (
    .clk        (clk_i),
    .rst        (!rst_ni),
    .write_en   (tx_we_i),
    .read_en    (rd_en),
    .write_data (din_i),
    .read_data  (data),
    .full       (full_o),
    .empty      (empty_o)
  );

  always_comb begin
    next_state = state;
    case (state)
      IDLE:    if (!empty_o && tx_en_i)  next_state = LOAD;
      LOAD:    next_state = SENDING;
      SENDING: if (bit_counter == 9)     next_state = (!empty_o && tx_en_i) ? LOAD : IDLE;
    endcase
    frame = {1'b1, data, 1'b0};
    tx_bit_o = (state == SENDING) ? frame[bit_counter] : 1'b1;
    rd_en =  (state == LOAD);
  end

  always_ff @(posedge clk_i) begin
    if (!rst_ni) begin
      state <= IDLE;
      baud_clk     <= 1'b0;
      baud_counter <= 16'd0;
      bit_counter  <= 4'd0;
    end else begin
      if (baud_clk || (bit_counter == '0)) state <= next_state;

      if (tx_en_i) begin
        if (baud_counter == baud_div_i - 1) begin
          baud_counter <= 16'd0;
          baud_clk     <= 1'b1;
        end else begin
          baud_counter <= baud_counter + 1;
          baud_clk     <= 1'b0;
        end
      end else begin
        baud_clk <= 1'b0;
      end

      if (baud_clk) begin
        bit_counter <= (state == SENDING && bit_counter != 9) ? bit_counter + 1'b1 : 4'd0;
      end
    end
  end

endmodule
