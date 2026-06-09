interface uart_if;

  logic clk;
  logic rst;

  logic data_ready;
  logic [7:0] data_in;

  logic tx_serial;

  logic data_valid;
  logic [7:0] data_out;

endinterface