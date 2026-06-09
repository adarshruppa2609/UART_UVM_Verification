
class uart_env extends uvm_env;

  `uvm_component_utils(uart_env)

  uart_agent agent;
  uart_scoreboard sb;

  function new(string name="uart_env",
               uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    agent = uart_agent::type_id::create("agent", this);
    sb    = uart_scoreboard::type_id::create("sb", this);
    
    uvm_config_db#(uart_scoreboard)::set(this, "agent.driver","sb",sb);

  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    agent.monitor.ap.connect(sb.analysis_export);

  endfunction

endclass