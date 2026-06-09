class uart_monitor extends uvm_monitor;

  `uvm_component_utils(uart_monitor)

  virtual uart_if vif;

  uvm_analysis_port #(uart_transaction) ap;

  function new(string name="uart_monitor",
               uvm_component parent);
    super.new(name,parent);

    ap = new("ap",this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(virtual uart_if)::get(this,"","vif",vif))
      `uvm_fatal("MON","Could not get virtual interface")
  endfunction

  task run_phase(uvm_phase phase);

    uart_transaction tr;

    forever begin

      @(posedge vif.data_valid);

        tr = uart_transaction::type_id::create("tr");

        tr.data = vif.data_out;

        `uvm_info("MON",
                  $sformatf("Captured Data = 0x%0h",
                            tr.data),
                  UVM_LOW)

        ap.write(tr);

    end

  endtask

endclass