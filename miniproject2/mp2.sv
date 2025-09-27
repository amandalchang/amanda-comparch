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

    // Define state variable values
    localparam [1:0] PWM_INC = 2'b00;
    localparam [1:0] PWM_HOLD = 2'b01;
    localparam [1:0] PWM_DEC = 2'b10;
    localparam [1:0] PWM_OFF = 2'b11;
    

    // Declare state variables
    logic [1:0] current_state = PWM_INC;
    logic first_cycle = 1'b1;
    logic next_red, next_green, next_blue;

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
        case (current_state)
            PWM_INC: begin
                current_state <= PWM_HOLD;
            end

            PWM_HOLD: begin
                if (first_cycle) begin
                    first_cycle <= 1'b0; // double cycle time
                end else begin
                    current_state <= PWM_DEC;
                    first_cycle <= 1'b1;
                end
            end

            PWM_DEC: begin
                current_state <= PWM_OFF;
            end

            PWM_OFF: begin
                if (first_cycle) begin
                    first_cycle <= 1'b0; // double cycle time
                end else begin
                    current_state <= PWM_INC;
                    first_cycle <= 1'b1;
                end
            end

            default: begin
                // not super necessary, here to reset in case of glitches
                current_state <= PWM_INC;
                first_cycle <= 1'b1;
            end
        endcase
    end

    // Compute the next state of the FSM
    always_comb begin
        next_red = 1'b0;
        next_green = 1'b0;
        next_blue = 1'b0;
        case (current_state)
            PWM_INC: begin
                next_red = 1'b1;
            end
            PWM_HOLD: begin
                next_green = 1'b1;
            end
            PWM_DEC: begin
                next_blue = 1'b1;
            end
        endcase
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
            PWM_INC: begin
                // 0 to 60 degrees
                green_pwm_value <= green_pwm_value + INC_DEC_VAL;
                red_pwm_value <= PWM_INTERVAL;
                blue_pwm_value <= 0;
            end
            PWM_HOLD: begin
                green_pwm_value <= PWM_INTERVAL;
                if (first_cycle) begin
                    // 60 to 120 degrees
                    red_pwm_value <= red_pwm_value - INC_DEC_VAL;
                    blue_pwm_value <= 0;
                end else begin
                    // 120 to 180 degrees
                    red_pwm_value <= 0;
                    blue_pwm_value <= blue_pwm_value + INC_DEC_VAL;
                end
            end
            PWM_DEC: begin
                // 180 to 240 degrees
                green_pwm_value <= green_pwm_value - INC_DEC_VAL;
                red_pwm_value <= 0;
                blue_pwm_value <= PWM_INTERVAL;
            end
            PWM_OFF: begin
                green_pwm_value <= 0;
                if (first_cycle) begin
                    // 240 to 300 degrees
                    red_pwm_value <= red_pwm_value + INC_DEC_VAL;
                    blue_pwm_value <= PWM_INTERVAL;
                end else begin
                    // 300 to 360 degrees
                    red_pwm_value <= PWM_INTERVAL;
                    blue_pwm_value <= blue_pwm_value - INC_DEC_VAL;
                end
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
