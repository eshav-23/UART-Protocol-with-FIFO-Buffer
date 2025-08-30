//-----------------------------------------------------------------------------------------------------------
// Testbench for uart_fifo : 8 writes then 8 reads
`timescale 1ns/1ns

module tb_uart_fifo ();

  // Parameters
  localparam DATA_SIZE  = 8;
  localparam SIZE_FIFO  = 8;

  // Testbench signals
  reg                         clk;
  reg                         reset_n;
  reg                         s_tick;
  reg  [DATA_SIZE-1:0]        w_data;
  reg                         wr;
  reg                         rd;
  wire [DATA_SIZE-1:0]        r_data;
  wire                        full;
  wire                        empty;

  // DUT instantiation
  uart_fifo #(
    .DATA_SIZE (DATA_SIZE),
    .SIZE_FIFO (SIZE_FIFO)
  ) dut (
    .clk      (clk),
    .s_tick   (s_tick),
    .reset_n  (reset_n),
    .w_data   (w_data),
    .wr       (wr),
    .rd       (rd),
    .r_data   (r_data),
    .full     (full),
    .empty    (empty)
  );

  // Clock generation (20 ns period = 50 MHz)
  always #10 clk = ~clk;

  // For this test, keep s_tick always HIGH
  always @(posedge clk or negedge reset_n) begin
    if (!reset_n)
      s_tick <= 0;
    else
      s_tick <= 1'b1;
  end

  // Monitor
  initial begin
    $monitor("Time=%0t | wr=%b rd=%b w_data=%h r_data=%h full=%b empty=%b",
             $time, wr, rd, w_data, r_data, full, empty);
  end

  // Stimulus
  initial begin
    clk = 0;
    reset_n = 1;
    wr = 0;
    rd = 0;
    w_data = 0;
    s_tick = 0;

    // Apply reset
    @(negedge clk);
    reset_n = 0;
    @(negedge clk);
    reset_n = 1;

    // ------------------------
    // Write exactly 8 values
    // ------------------------
    wr = 1; rd = 0;

    @(negedge clk); w_data = 8'h6C;
    @(negedge clk); w_data = 8'hAF;
    @(negedge clk); w_data = 8'h64;
    @(negedge clk); w_data = 8'h24;
    @(negedge clk); w_data = 8'h81;
    @(negedge clk); w_data = 8'h09;
    @(negedge clk); w_data = 8'h63;
    @(negedge clk); w_data = 8'h0A;

    @(negedge clk);
    wr = 0; // stop writing after 8 pushes

    // Check FULL flag
    @(posedge clk);
    $display(">>> After 8 writes: full=%0d empty=%0d", full, empty);

    // ------------------------
    // Read exactly 8 values
    // ------------------------
    rd = 1; wr = 0;
    repeat (8) @(negedge clk);
    rd = 0;

    // Check EMPTY flag
    @(posedge clk);
    $display(">>> After 8 reads: full=%0d empty=%0d", full, empty);

    $finish;
  end

endmodule
