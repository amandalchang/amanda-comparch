// Mini project 1

module cycler #(
    // CLK freq is 12MHz, so 2,000,000 cycles is 1/6 of a second
    parameter BLINK_INTERVAL = 2000000,     
)(
    input logic     clk, 
    output logic    red, 
    output logic    green,
    output logic    blue
);

    // Define state variable values
    localparam [2:0] RED = 3'b000;
    localparam [2:0] YELLOW = 3'b001;
    localparam [2:0] GREEN = 3'b010;
    localparam [2:0] CYAN = 3'b011;
    localparam [2:0] BLUE = 3'b100;
    localparam [2:0] MAGENTA = 3'b101;

    // Declare state variables
    logic [2:0] current_color = RED;
    logic [$clog2(BLINK_INTERVAL) - 1:0] count = 0;

    // Declare next output variables
    logic next_red, next_green, next_blue;

    // Register the next state of the FSM
    always_ff @(posedge clk) begin
        red <= next_red;
        green <= next_green;
        blue <= next_blue;
        if (count == BLINK_INTERVAL - 1) begin
            count <= 0;
            if (current_color != MAGENTA) begin
                current_color <= current_color + 1;
            end
            else begin
                current_color <= RED;
            end
        end else count <= count + 1;
    end

    // Compute next output values
    always_comb begin
        next_red = 1'b0; // default low
        next_green = 1'b0; // default low
        next_blue = 1'b0; // default low
        case (current_color)
            RED:
                next_red = 1'b1;
            YELLOW: begin
                next_red = 1'b1;
                next_green = 1'b1;
            end
            GREEN:
                next_green = 1'b1;
            CYAN: begin
                next_green = 1'b1;
                next_blue = 1'b1;
            end
            BLUE:
                next_blue = 1'b1;
            MAGENTA: begin
                next_red = 1'b1;
                next_blue = 1'b1;
            end
        endcase
    end

endmodule
