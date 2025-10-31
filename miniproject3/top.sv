// `include "memory.sv"
`include "ws2812b.sv"
`include "controller.sv"
`include "game_of_life.sv"

// led_matrix top level module

module top(
    input logic     clk, 
    input logic     SW, 
    input logic     BOOT, 
    output logic    _48b, 
    output logic    _45a, 
    output logic    RGB_R 
);

    logic [7:0] red_data;
    logic [7:0] green_data;
    logic [7:0] blue_data;

    logic [5:0] pixel;
    logic [4:0] frame;
    logic [10:0] address;
    logic [5:0] pixel_count = 6'b0;
    logic [63:0] green_output_array;
    logic [63:0] red_output_array;
    logic [63:0] blue_output_array;

    logic [23:0] shift_reg = 24'd0;
    logic debug;
    logic load_sreg;
    logic transmit_pixel;
    logic shift;
    logic ws2812b_out;
    logic time_to_calc_frame;
    logic [4:0] slow_down_count;
    logic [63:0] test_array = {3'b111, 61'b0};

    assign address = { frame, pixel };

    // Instance the green game of life
    game_of_life #(
        .INIT_FILE          ("initial/greeninit.txt")
    ) u1 (
        .clk                (clk),
        .time_to_calc_frame (time_to_calc_frame),
        .output_array       (green_output_array)      
    );

    // Instance the red game of life
    game_of_life #(
        .INIT_FILE          ("initial/redinit.txt")
    ) u2 (
        .clk                (clk),
        .time_to_calc_frame (time_to_calc_frame),
        .output_array       (red_output_array)
    );

    // Instance the blue game of life
    game_of_life #(
        .INIT_FILE          ("initial/blueinit.txt")
    ) u3 (
        .clk                (clk),
        .time_to_calc_frame (time_to_calc_frame),
        .output_array       (blue_output_array)
    );

    // Instance the WS2812B output driver
    ws2812b u4 (
        .clk            (clk), 
        .serial_in      (shift_reg[23]), 
        .transmit       (transmit_pixel), 
        .ws2812b_out    (ws2812b_out), 
        .shift          (shift)
    );

    // Instance the controller
    controller u5 (
        .clk            (clk), 
        .load_sreg      (load_sreg), 
        .transmit_pixel (transmit_pixel), 
        .pixel          (pixel), 
        .frame          (frame)
    );


    always_ff @(posedge clk) begin
        if (load_sreg) begin // if it's time to load one pixel
            green_data = green_output_array[pixel_count] ? 8'b10010000 : 8'hFF;
            blue_data = blue_output_array[pixel_count] ? 8'b10010000 : 8'hFF;
            red_data = red_output_array[pixel_count] ? 8'b10010000 : 8'hFF;
            pixel_count = pixel_count + 1; // add one to pixel count
            unique case ({ SW, BOOT })
                2'b00:
                    shift_reg <= { green_data, 16'd0 };
                2'b01:
                    shift_reg <= { 8'd0, red_data, 8'd0 };
                2'b10:
                    shift_reg <= { 16'd0, blue_data };
                2'b11:
                    shift_reg <= { green_data, red_data, blue_data };
            endcase
            if (pixel_count == 0) begin // if pixel count is 65 or 0
                time_to_calc_frame = 1'b1; // full frame has been shifted in
                debug = ~debug;
            end
            else time_to_calc_frame = 1'b0; // otherwise it's not time to calculate the state/keep old state
        end
        else if (shift) begin
            shift_reg <= { shift_reg[22:0], 1'b0 };
        end
    end

    assign RGB_R = ~debug; // helps me visualize frame rate
    assign _48b = ws2812b_out;
    assign _45a = ~ws2812b_out;

endmodule
