module baud_gen #(
    parameter CLK_FREQ = 10000,   
    parameter BAUD_RATE = 1000    
) (
    input  clk,
    input  rst,
    output reg baud_tick
);

   
    localparam integer BITS_PER_BAUD = CLK_FREQ / BAUD_RATE;

   
    reg [15:0] counter;  

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter   <= 0;
            baud_tick <= 0;
        end else begin
            if (counter == BITS_PER_BAUD - 1) begin
                counter   <= 0;
                baud_tick <= 1;
            end else begin
                counter   <= counter + 1;
                baud_tick <= 0;
            end
        end
    end
endmodule