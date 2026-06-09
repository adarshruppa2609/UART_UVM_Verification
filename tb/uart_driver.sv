class uart_driver extends uvm_driver #(uart_transaction);

  `uvm_component_utils(uart_driver)

  virtual uart_if vif;

  function new(string name = "uart_driver",
               uvm_component parent);
    super.new(name, parent);
  endfunction
  
  uart_scoreboard sb;

  function void build_phase(uvm_phase phase);
  super.build_phase(phase);

  if(!uvm_config_db#(virtual uart_if)::get(
        this, "", "vif", vif))
    `uvm_fatal("DRV",
      "Could not get virtual interface")

  if(!uvm_config_db#(uart_scoreboard)::get(
        this, "", "sb", sb))
    `uvm_fatal("DRV",
      "Could not get scoreboard handle")

  endfunction

  task run_phase(uvm_phase phase);

    uart_transaction req;

    forever begin

      seq_item_port.get_next_item(req);
      
      sb.expected_q.push_back(req.data);

      `uvm_info("DRV",
                $sformatf("Driving Data = 0x%0h", req.data),
                UVM_LOW)

      vif.data_in    = req.data;
      vif.data_ready = 1'b1;

      repeat(15) @(posedge vif.clk);

      vif.data_ready = 1'b0;
      
      wait(vif.data_valid);
      
      @(posedge vif.clk);

      seq_item_port.item_done();

    end

  endtask

endclass