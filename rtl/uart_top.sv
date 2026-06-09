module uart_top(
    input clk,
    input rst,
    input data_ready,
    input [7:0] data_in,

    output tx_serial,
    output data_valid,
    output [7:0] data_out
);

wire baud_tick;

baud_gen baud_inst(
    .clk(clk),
    .rst(rst),
    .baud_tick(baud_tick)
);

uart_tx tx_inst(
    .clk(clk),
    .rst(rst),
    .baud_tick(baud_tick),
    .data_ready(data_ready),
    .data_in(data_in),
    .tx_serial(tx_serial)
);

uart_rx rx_inst(
    .clk(clk),
    .rst(rst),
    .baud_tick(baud_tick),
    .rx_serial(tx_serial),   // loopback
    .data_valid(data_valid),
    .data_out(data_out)
);

endmodule