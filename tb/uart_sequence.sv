class uart_sequence extends uvm_sequence #(uart_transaction);

  `uvm_object_utils(uart_sequence)

  function new(string name = "uart_sequence");
    super.new(name);
  endfunction

  task body();

    uart_transaction req;

    repeat (10) begin

      req = uart_transaction::type_id::create("req");

      start_item(req);

      assert(req.randomize());

      `uvm_info("SEQ",
                $sformatf("Generated Data = 0x%0h", req.data),
                UVM_LOW)

      finish_item(req);

    end

  endtask

endclass