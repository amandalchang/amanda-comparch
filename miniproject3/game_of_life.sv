module game_of_life #(
    parameter INIT_FILE = ""
)(
    input logic time_to_calc_frame,
    output logic [63:0] output_array
);
    logic [0:7] current_grid [0:7]; // partially packed 8x8 grid of bools
    logic [0:7] next_grid [0:7];
    logic [2:0] neighbor_count;

    initial begin

    if (INIT_FILE != "") begin
            $readmemb(INIT_FILE, current_grid);
        end
    end

    // Returns appropriate future pixel state given current number of neighbors
    function logic next_state(
        input [2:0] neighbor_count,
        input current_pixel_alive
    );
        if (current_pixel_alive) begin
            // stay alive if neighbor count is 2 or 3
            next_state = (neighbor_count == 3'd2 || neighbor_count == 3'd3);
        end else begin
            // come alive if neighbor count is 3
            next_state = (neighbor_count == 3'd3);
        end
    endfunction

    always_ff @(posedge time_to_calc_frame) begin
        // Flatten grid and put it in output_array
        for (int i=0; i<8; i++)
            for (int j=0; j<8; j++)
                output_array[63-(i*8 + j)] = current_grid[i][j];

        for (int i=0; i<8; i++) begin
            for (int j=0; j<8; j++) begin
                
                // Neighbor counting
                neighbor_count = 0;
                for (int a = -1; a<2; a++) begin
                    for (int b = -1; b<2; b++) begin
                        if (!(a==0 && b==0)) // don't add the state of the cell itself
                            // added 8 because system verilog thinks -1 % 8 = -1
                            neighbor_count = neighbor_count + current_grid[(i+a+8) % 8][(j+b+8) % 8];
                    end
                end

                next_grid[i][j] = next_state(neighbor_count, current_grid[i][j]);
            end
        end

        // Move the new grid into the current grid
        for (int i=0; i<8; i++)
            for (int j=0; j<8; j++)
                current_grid[i][j] = next_grid[i][j];
    end

endmodule