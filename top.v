`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.08.2025 17:06:59
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns/1ps

module uart_protocol #(
  parameter DATA_SIZE      = 8,
  parameter SIZE_FIFO      = 8,
  parameter SYS_FREQ       = 50000000,
  parameter BAUD_RATE      = 921600,
  parameter SAMPLE         = 32,
  parameter CLOCK          = SYS_FREQ/BAUD_RATE,
  parameter BAUD_DVSR      = SYS_FREQ/(SAMPLE*BAUD_RATE)
)(
  input                       clk,               // Clock
  input                       reset_n,           // Asynchronous reset active low
  input                       rx,                // RX
  output                      tx,                // TX
  output      [2:0]           TX_status_register,
  output      [2:0]           RX_status_register
);

  // ---------------------------------------------------
  // Signal Declarations
  // ---------------------------------------------------
  wire                     s_tick;
  wire [DATA_SIZE-1:0]     tx_data_in;
  wire [DATA_SIZE-1:0]     rx_data_out;
  wire [DATA_SIZE-1:0]     bus_data_in;
  wire [DATA_SIZE-1:0]     bus_data_out;

  wire                     tx_start;
  wire                     tx_done;
  wire                     tx_full;
  wire                     tx_empty;

  wire                     rx_start;
  wire                     rx_done;
  wire                     rx_full;
  wire                     rx_empty;

  reg                      state, next_state;
  reg                      fifo_tx_wr;
  reg                      fifo_rx_rd;

  // ---------------------------------------------------
  // Local Parameters (FSM)
  // ---------------------------------------------------
  localparam IDLE = 1'b0,
             ON   = 1'b1;

  // ---------------------------------------------------
  // Assignments
  // ---------------------------------------------------
  assign tx_start = ~tx_empty; // tx starts when fifo not empty
  assign rx_start = ~rx_full;  // rx starts when fifo not full
  assign bus_data_in = bus_data_out;

  // Status registers
  assign TX_status_register = {tx_done, tx_empty, tx_full};
  assign RX_status_register = {rx_done, rx_empty, rx_full};

  // ---------------------------------------------------
  // FSM State Register
  // ---------------------------------------------------
  always @(posedge clk or negedge reset_n) begin
    if (~reset_n)
      state <= IDLE;
    else if (s_tick)
      state <= next_state;
  end

  // ---------------------------------------------------
  // FSM Next-State Logic
  // ---------------------------------------------------
  always @(*) begin
    fifo_rx_rd = 0;
    fifo_tx_wr = 0;
    next_state = state;

    case(state)
      IDLE: begin
        if (~rx_empty & ~tx_full) begin
          fifo_tx_wr = 1;
          next_state = ON;
        end else begin
          next_state = IDLE;
        end
      end

      ON: begin
        if (rx_empty | tx_full) begin
          next_state = IDLE;
        end else begin
          fifo_rx_rd = 1;
          next_state = ON;
        end
      end
    endcase
  end

  // ---------------------------------------------------
  // Submodules
  // ---------------------------------------------------

  // Sampling Clock
  uart_sampling_tick #(
    .SYS_FREQ  (SYS_FREQ),
    .BAUD_RATE (BAUD_RATE),
    .CLOCK     (CLOCK),
    .SAMPLE    (SAMPLE),
    .BAUD_DVSR (BAUD_DVSR)
  ) uart_sampling_tick_inst (
    .clk     (clk),
    .reset_n (reset_n),
    .s_tick  (s_tick)
  );

  // Transmitter
  uart_tx #(
    .DATA_SIZE (DATA_SIZE)
  ) uart_tx_inst (
    .clk          (clk),
    .s_tick       (s_tick),
    .reset_n      (reset_n),
    .tx_start     (tx_start),
    .data_in      (tx_data_in),
    .tx           (tx),
    .tx_done_tick (tx_done)
  );

  // TX FIFO
  uart_fifo #(
    .DATA_SIZE (DATA_SIZE),
    .SIZE_FIFO (SIZE_FIFO)
  ) uart_fifo_tx (
    .clk     (clk),
    .s_tick  (s_tick),
    .reset_n (reset_n),
    .w_data  (bus_data_in),
    .r_data  (tx_data_in),
    .wr      (fifo_tx_wr),
    .rd      (tx_done),
    .full    (tx_full),
    .empty   (tx_empty)
  );

  // Receiver
  uart_rx #(
    .DATA_SIZE (DATA_SIZE)
  ) uart_rx_inst (
    .clk          (clk),
    .s_tick       (s_tick),
    .reset_n      (reset_n),
    .rx_start     (rx_start),
    .rx           (rx),
    .data_out     (rx_data_out),
    .rx_done_tick (rx_done)
  );

  // RX FIFO
  uart_fifo #(
    .DATA_SIZE (DATA_SIZE),
    .SIZE_FIFO (SIZE_FIFO)
  ) uart_fifo_rx (
    .clk     (clk),
    .s_tick  (s_tick),
    .reset_n (reset_n),
    .w_data  (rx_data_out),
    .r_data  (bus_data_out),
    .wr      (rx_done),
    .rd      (fifo_rx_rd),
    .full    (rx_full),
    .empty   (rx_empty)
  );

endmodule
