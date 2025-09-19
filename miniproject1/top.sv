`include "miniproject1.sv"

// Mini Project 1 Top-Level Module

module top(
    input logic     clk, 
    output logic    RGB_R, 
    output logic    RGB_G, 
    output logic    RGB_B
);

    logic red, green, blue;

    cycler u0(
        .clk    (clk), 
        .red    (red), 
        .green  (green), 
        .blue   (blue)
    );

    // inverting red, green and blue logic
    // because the hardware implementation is
    // active low
    assign RGB_R = ~red;
    assign RGB_G = ~green;
    assign RGB_B = ~blue;

endmodule
