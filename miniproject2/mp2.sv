// Fade

module fade #(
    parameter INC_DEC_INTERVAL = 20000,     // CLK frequency is 12MHz, so 20000 cycles is 10/6 of a ms
    // *** INC_DEC_MAX needs to evenly divide PWM_INTERVAL, or else there will be a brightness offset 
    // where red never reaches 0% duty and blue/green are never at 100% duty. This is because INC_DEC_VAL
    // is an always an integer.
    parameter INC_DEC_MAX = 100,            // Transition to next state after 100 increments / decrements, which is 1/6s
    parameter PWM_INTERVAL = 1200,          // CLK frequency is 12MHz, so 1,200 cycles is 100us
    parameter INC_DEC_VAL = PWM_INTERVAL / INC_DEC_MAX // Amount you need to inc PWM by so it reaches PWM_INTERVAL in INC_DEC_MAX steps
)(
    input logic clk, 
    output logic [$clog2(PWM_INTERVAL) - 1:0] red_pwm_value,
    output logic [$clog2(PWM_INTERVAL) - 1:0] green_pwm_value,
    output logic [$clog2(PWM_INTERVAL) - 1:0] blue_pwm_value
);

    // State variables; naming is defined by starting color
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

    initial begin
        red_pwm_value = PWM_INTERVAL;
        green_pwm_value = 0;
        blue_pwm_value = 0;
    end

    // i put everything into one clock to reduce dependence on fake
    // clocks made by setting flags like time_to_transition in fade
    always_ff @(posedge clk) begin
        if (count == INC_DEC_INTERVAL - 1) begin // if it's time to increment
            case (current_state) // increment based on state
                RED: green_pwm_value <= green_pwm_value + INC_DEC_VAL;
                YELLOW: red_pwm_value <= red_pwm_value - INC_DEC_VAL;
                GREEN: blue_pwm_value <= blue_pwm_value + INC_DEC_VAL;
                CYAN: green_pwm_value <= green_pwm_value - INC_DEC_VAL;
                BLUE: red_pwm_value <= red_pwm_value + INC_DEC_VAL;
                PURPLE: blue_pwm_value <= blue_pwm_value - INC_DEC_VAL;
            endcase

            count <= 0; // restart clock tick counter
            if (inc_dec_count == INC_DEC_MAX - 1) begin // if we've finished incrementing
                if (current_state != PURPLE)
                    current_state <= current_state + 1; // go to next state
                else
                    current_state <= RED; // or go back to the start

                inc_dec_count <= 0; //restart increment counter
            end else begin
                inc_dec_count <= inc_dec_count + 1; // count increment
            end
        end else begin
            count <= count + 1; // count clock tick
        end
    end

endmodule

