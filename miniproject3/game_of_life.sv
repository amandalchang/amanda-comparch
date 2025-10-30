module game_of_life #(
    parameter INIT_FILE = ""
)(
    input logic clk,
    input logic time_to_calc_frame,
    output logic [63:0] output_array
);
    logic [0:7] current_grid [0:7]; // partially packed 8x8 grid of bools
    logic [0:7] next_grid [0:7];
    logic [2:0] neighbor_count = 2'b0;

    initial begin

    if (INIT_FILE != "") begin
            $readmemb(INIT_FILE, current_grid);
        end
    end

    always_ff @(posedge time_to_calc_frame) begin
        for (int i=0; i<8; i++) begin
            for (int j=0; j<8; j++) begin
                // Neighbor counting
                for (int a = -1; a<2; a++) begin
                    for (int b = -1; b<2; b++) begin
                        if (!(a==0 && b==0)) // don't add the state of the cell itself
                            // added 8 because system verilog thinks -1 % 8 = -1
                            neighbor_count = neighbor_count + current_grid[(i+a+8) % 8][(j+b+8) % 8];
                    end
                end

                // Create new grid based on number of neighbors
                if (current_grid[i][j] == 1) begin // if the current pixel is currently alive
                    // if the neighbor count is 2 or 3 then it should stay alive
                    // otherwise it dies
                    next_grid[i][j] = (neighbor_count == 2 || neighbor_count == 3);
                end
                // if the current pixel is dead & the neighbor count is 3, then alive
                else next_grid[i][j] = (neighbor_count == 3); 

                neighbor_count = 0;
            end
        end

        // Flatten next grid and put it in output_array
        for (int i=0; i<8; i++)
            for (int j=0; j<8; j++)
                output_array[i*8 + j] = next_grid[i][j];

        // Move the new grid into the current grid
        for (int i=0; i<8; i++)
            for (int j=0; j<8; j++)
                current_grid[i][j] = next_grid[i][j];
    end

endmodule