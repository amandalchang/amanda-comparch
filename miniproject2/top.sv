`include "mp2.sv"
`include "pwm.sv"

// Fade top level module

module top #(
    parameter PWM_INTERVAL = 1200       // CLK frequency is 12MHz, so 1,200 cycles is 100us
)(
    input logic     clk, 
    output logic    RGB_R,
    output logic    RGB_G,
    output logic    RGB_B
);

    logic [$clog2(PWM_INTERVAL) - 1:0] red_pwm_value;
    logic [$clog2(PWM_INTERVAL) - 1:0] green_pwm_value;
    logic [$clog2(PWM_INTERVAL) - 1:0] blue_pwm_value;
    logic red_pwm_out;
    logic green_pwm_out;
    logic blue_pwm_out;

    fade #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u1 (
        .clk            (clk), 
        .red_pwm_value  (red_pwm_value),
        .green_pwm_value(green_pwm_value),
        .blue_pwm_value (blue_pwm_value)
    );

    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u2 (
        .clk            (clk), 
        .red_pwm_value  (red_pwm_value), 
        .green_pwm_value(green_pwm_value),
        .blue_pwm_value (blue_pwm_value),
        .red_pwm_out    (red_pwm_out), 
        .green_pwm_out  (green_pwm_out),
        .blue_pwm_out   (blue_pwm_out)
    );

    assign RGB_R = ~red_pwm_out;
    assign RGB_G = ~green_pwm_out;
    assign RGB_B = ~blue_pwm_out;

endmodule