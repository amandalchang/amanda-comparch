`include "single.sv"
`include "pwm_original.sv"

// Fade top level module

module top #(
    parameter PWM_INTERVAL = 1200       // CLK frequency is 12MHz, so 1,200 cycles is 100us
)(
    input logic     clk, 
    output logic    LED,
    output logic    RGB_R,
    output logic    RGB_G,
    output logic    RGB_B
);

    logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value;
    logic pwm_out;

    fade #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u1 (
        .clk            (clk), 
        .pwm_value      (pwm_value),
        .red            (red),
        .green          (green),
        .blue           (blue)
    );

    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u2 (
        .clk            (clk), 
        .pwm_value      (pwm_value), 
        .pwm_out        (pwm_out)
    );

    assign LED = ~pwm_out;
    assign RGB_R = ~red;
    assign RGB_G = ~green;
    assign RGB_B = ~blue;

endmodule
