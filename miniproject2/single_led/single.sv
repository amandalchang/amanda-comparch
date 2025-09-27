// Fade

module fade #(
    parameter INC_DEC_INTERVAL = 120000,     // CLK frequency is 12MHz, so 12,000 cycles is 1ms
    parameter INC_DEC_MAX = 200,            // Transition to next state after 200 increments / decrements, which is 0.2s
    parameter PWM_INTERVAL = 1200,          // CLK frequency is 12MHz, so 1,200 cycles is 100us
    parameter INC_DEC_VAL = PWM_INTERVAL / INC_DEC_MAX // Amount you need to inc PWM by so it reaches max brightness in INC_DEC_MAX steps
)(
    input logic clk, 
    output logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value,
    output logic red,
    output logic blue,
    output logic green
);

    // Define state variable values
    localparam [1:0] PWM_INC = 2'b00;
    localparam [1:0] PWM_HOLD = 2'b01;
    localparam [1:0] PWM_DEC = 2'b10;
    localparam [1:0] PWM_OFF = 2'b11;
    

    // Declare state variables
    logic [1:0] current_state = PWM_INC;
    logic debug = 1'b0;
    logic first_cycle = 1'b1;

    logic next_red, next_green, next_blue;

    // Declare variables for timing state transitions
    logic [$clog2(INC_DEC_INTERVAL) - 1:0] count = 0;
    logic [$clog2(INC_DEC_MAX) - 1:0] inc_dec_count = 0;
    logic time_to_inc_dec = 1'b0;
    logic time_to_transition = 1'b0;

    initial begin
        pwm_value = 0;
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
        red <= next_red;
        green <= next_green;
        blue <= next_blue;
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
                pwm_value <= pwm_value + INC_DEC_VAL;
            end
            PWM_HOLD:
                pwm_value <= 1200;
            PWM_DEC: begin
                pwm_value <= pwm_value - INC_DEC_VAL;
            end

            PWM_OFF: 
                pwm_value <= 0;
                
            
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
