module tb_top;

  import uvm_pkg::*;
  import uart_pkg::*;
  `include "uvm_macros.svh"

  uart_if vif();

  // DUT Instantiation
  uart_top dut (
    .clk        (vif.clk),
    .rst        (vif.rst),
    .data_ready (vif.data_ready),
    .data_in    (vif.data_in),

    .tx_serial  (vif.tx_serial),

    .data_valid (vif.data_valid),
    .data_out   (vif.data_out)
  );

  // Clock Generation
  initial begin
    vif.clk = 0;
    forever #5 vif.clk = ~vif.clk;
  end

  // Reset Generation
  initial begin
    vif.rst = 1;
    #20;
    vif.rst = 0;
  end

  // UVM Configuration
  initial begin

    uvm_config_db#(virtual uart_if)::set(
      null,
      "*",
      "vif",
      vif
    );

    run_test("uart_test");

  end

endmodule