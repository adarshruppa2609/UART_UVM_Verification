
class uart_transaction extends uvm_sequence_item;

  rand bit [7:0] data;

  `uvm_object_utils(uart_transaction)

  function new(string name="uart_transaction");
    super.new(name);
  endfunction

endclass