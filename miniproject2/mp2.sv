// Fade

module fade #(
    parameter INC_DEC_INTERVAL = 20000,     // CLK frequency is 12MHz, so 20000 cycles is 10/6 of a ms
    parameter INC_DEC_MAX = 100,            // Transition to next state after 100 increments / decrements, which is 1/6s
    parameter PWM_INTERVAL = 1200,          // CLK frequency is 12MHz, so 1,200 cycles is 100us
    parameter INC_DEC_VAL = PWM_INTERVAL / INC_DEC_MAX // Amount you need to inc PWM by so it reaches max brightness in INC_DEC_MAX steps
)(
    input logic clk, 
    output logic [$clog2(PWM_INTERVAL) - 1:0] red_pwm_value,
    output logic [$clog2(PWM_INTERVAL) - 1:0] green_pwm_value,
    output logic [$clog2(PWM_INTERVAL) - 1:0] blue_pwm_value
);

    // State variables; defined by starting color
    localparam [2:0] RED = 3'b000;
    localparam [2:0] YELLOW = 3'b001;
    localparam [2:0] GREEN = 3'b010;
    localparam [2:0] CYAN = 3'b011;
    localparam [2:0] BLUE = 3'b100;
    localparam [2:0] PURPLE = 3'b101;
    

    // Declare state variables
    logic [2:0] current_state = RED;

    // Declare variables for timing state transitions
    logic [$clog2(INC_DEC_INTERVAL) - 1:0] count = 0;
    logic [$clog2(INC_DEC_MAX) - 1:0] inc_dec_count = 0;
    logic time_to_inc_dec = 1'b0;
    logic time_to_transition = 1'b0;

    initial begin
        red_pwm_value = PWM_INTERVAL;
        green_pwm_value = 0;
        blue_pwm_value = 0;
    end

    always_ff @(posedge time_to_transition) begin
        if (current_state != PURPLE) begin
            current_state <= current_state + 1;
        end else begin
            current_state <= RED;
        end
    end

    // Implement counter for incrementing / decrementing PWM value
    always_ff @(posedge clk) begin
        if (count == INC_DEC_INTERVAL - 1) begin
            count <= 0;
            time_to_inc_dec <= 1'b1;
        end
        else begin
            count <= count + 1;
            time_to_inc_dec <= 1'b0;
        end
    end

    // Increment / Decrement PWM value as appropriate given current state
    always_ff @(posedge time_to_inc_dec) begin
        case (current_state)
            RED: begin
                // 0 to 60 degrees
                red_pwm_value <= PWM_INTERVAL;
                green_pwm_value <= green_pwm_value + INC_DEC_VAL;
                blue_pwm_value <= 0;
            end
            YELLOW: begin
                // 60 to 120 degrees
                red_pwm_value <= red_pwm_value - INC_DEC_VAL;
                green_pwm_value <= PWM_INTERVAL; 
            end
            GREEN: begin
                // 120 to 180 degrees
                red_pwm_value <= 0;
                green_pwm_value <= PWM_INTERVAL;
                blue_pwm_value <= blue_pwm_value + INC_DEC_VAL;
            end
            CYAN: begin
                // 180 to 240 degrees
                green_pwm_value <= green_pwm_value - INC_DEC_VAL;
                blue_pwm_value <= PWM_INTERVAL;
            end
            BLUE: begin
                // 240 to 300 degrees
                red_pwm_value <= red_pwm_value + INC_DEC_VAL;
                green_pwm_value <= 0;
            end
            PURPLE: begin
                // 300 to 360 degrees
                red_pwm_value <= PWM_INTERVAL;
                blue_pwm_value <= blue_pwm_value - INC_DEC_VAL;
            end
        endcase
    end

    // Implement counter for timing state transitions
    always_ff @(posedge time_to_inc_dec) begin
        if (inc_dec_count == INC_DEC_MAX - 1) begin
            inc_dec_count <= 0;
            time_to_transition <= 1'b1;
        end
        else begin
            inc_dec_count <= inc_dec_count + 1;
            time_to_transition <= 1'b0;
        end
    end

endmodule
