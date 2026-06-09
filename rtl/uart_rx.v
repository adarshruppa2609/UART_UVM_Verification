module uart_rx #(
    parameter DATA_WIDTH = 8  
)(
    input clk, 
    input rst, 
    input baud_tick,    
    input rx_serial,    
    output reg data_valid,   
    output reg [DATA_WIDTH-1:0] data_out 
);

    // State encoding instead of typedef enum
    localparam IDLE       = 3'b000,
               START_BIT  = 3'b001,
               DATA_BITS  = 3'b010,
               PARITY_BIT = 3'b011,
               STOP_BIT   = 3'b100;

    reg [2:0] state, next_state;

    reg [DATA_WIDTH-1:0] data_reg; 
    reg [3:0] bit_counter;    
    reg parity_received, parity_calculated; 
    reg rx_sample; 

    // Sample input only on baud tick
    always @(posedge clk) begin
        if (baud_tick)
            rx_sample <= rx_serial;
    end

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
            IDLE: if (rx_serial == 0) begin
                       $display("RX START DETECTED TIME=%0t", $time);
                       next_state = START_BIT; 
                  end
            START_BIT: next_state = DATA_BITS; 
            DATA_BITS: if (bit_counter == DATA_WIDTH - 1) next_state = PARITY_BIT; 
            PARITY_BIT: next_state = STOP_BIT; 
            STOP_BIT:   next_state = IDLE; 
        endcase
    end

    // Data handling + outputs
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            data_valid        <= 0; 
            data_out          <= 0; 
            bit_counter       <= 0; 
            parity_calculated <= 0; 
            parity_received   <= 0; 
        end else if (baud_tick) begin
            data_valid <= 0; // default

            case (state)
                START_BIT: begin 
                    data_valid   <= 0; 
                    bit_counter  <= 0; 
                end

                DATA_BITS: begin 
                    $display("RX BIT[%0d]=%b TIME=%0t", bit_counter,rx_sample,$time);
                    data_reg[bit_counter] <= rx_sample; 
                    bit_counter <= bit_counter + 1; 
                end

                PARITY_BIT: begin 
                    $display("RX PARITY=%b TIME=%0t", rx_sample, $time);
                    parity_received <= rx_sample; 
                end

                STOP_BIT: begin 
                    $display("STOP=%b PAR_RX=%b PAR_CALC=%b DATA=%h TIME=%0t",
             rx_sample,
             parity_received,
             ^data_reg,
             data_reg,
             $time);
                    if (rx_sample == 1) begin // Stop bit check
                        parity_calculated = ^data_reg; 
                        if (parity_received == parity_calculated) begin 
                            data_out   <= data_reg; 
                            data_valid <= 1; 
                            
                            $display("RX DATA=%h TIME=%0t", data_reg,$time);
                        end 
                        // else: parity error (ignored in pure Verilog-2001, since $error not supported)
                    end 
                    // else: stop bit error (ignored for Icarus compatibility)
                    bit_counter <= 0; 
                end
            endcase
        end
    end

endmodule
