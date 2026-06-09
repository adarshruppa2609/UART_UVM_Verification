module uart_tx #(
    parameter DATA_WIDTH = 8
)(
    input clk,
    input rst,
    input baud_tick,      
    input data_ready,    
    input [DATA_WIDTH-1:0] data_in,
    output reg tx_serial      
);

   
    localparam IDLE       = 3'b000,
               START_BIT  = 3'b001,
               DATA_BITS  = 3'b010,
               PARITY_BIT = 3'b011,
               STOP_BIT   = 3'b100;

    reg [2:0] state, next_state; 
    reg [DATA_WIDTH-1:0] data_reg; 
    reg [3:0] bit_counter;    
    reg parity; 

    // State register
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else if (baud_tick)
            state <= next_state;
    end

    // Next state logic
    always @(*) begin
        next_state = state;
        case (state)
            IDLE:      if (data_ready) next_state = START_BIT;
            START_BIT: next_state = DATA_BITS;
            DATA_BITS: if (bit_counter == DATA_WIDTH - 1) 
                           next_state = PARITY_BIT;
            PARITY_BIT: next_state = STOP_BIT;
            STOP_BIT:   next_state = IDLE;
        endcase
    end

    // Output + data handling
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx_serial   <= 1'b1; 
            bit_counter <= 0; 
            data_reg    <= 0; 
            parity      <= 0; 
        end else if (baud_tick) begin
            case (state)
                IDLE: tx_serial <= 1'b1; 

                START_BIT: begin
                    $display("TX START TIME=%0t", $time);
                    tx_serial   <= 1'b0;  
                    data_reg    <= data_in; 
                    parity      <= ^data_in;   // XOR all bits for parity
                    bit_counter <= 0;     
                end

                DATA_BITS: begin
                    tx_serial   <= data_reg[bit_counter];  
                    bit_counter <= bit_counter + 1;       
                end

                PARITY_BIT: tx_serial <= parity; 

                STOP_BIT: tx_serial <= 1'b1; 
            endcase
        end
    end

endmodule
