class uart_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(uart_scoreboard)

  uvm_analysis_imp #(uart_transaction, uart_scoreboard)
      analysis_export;

  bit [7:0] expected_q[$];

  function new(string name="uart_scoreboard",
               uvm_component parent);
    super.new(name,parent);

    analysis_export =
      new("analysis_export", this);
  endfunction

  function void write(uart_transaction tr);

    bit [7:0] exp_data;

    if(expected_q.size() == 0) begin
      `uvm_error("SB",
        "No expected data available!")
      return;
    end

    exp_data = expected_q.pop_front();

    if(exp_data == tr.data)
      `uvm_info("SB",
        $sformatf("PASS Expected=0x%0h Actual=0x%0h",
                  exp_data, tr.data),
        UVM_LOW)
    else
      `uvm_error("SB",
        $sformatf("FAIL Expected=0x%0h Actual=0x%0h",
                  exp_data, tr.data))

  endfunction

endclass