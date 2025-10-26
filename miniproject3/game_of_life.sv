module game_of_life;

    logic current_grid [0:7][0:7]; // 8x8 grid of bools
    logic next_grid [0:7][0:7];
    logic [2:0] neighbor_count;

    initial begin    
    // initialize grid to have 0s
    for (int i=0; i<8; i++)
        for (int j=0; j<8; j++)
            current_grid[i][j] = 0;
    // put pattern into initial grid
    current_grid[2][3] = 1'b1;
    current_grid[2][4] = 1'b1;
    current_grid[2][5] = 1'b1;
    current_grid[3][5] = 1'b1;
    current_grid[4][3] = 1'b1;
    current_grid[4][4] = 1'b1;
    current_grid[4][5] = 1'b1;
    neighbor_count = 0;

    // print initial grid
    $display("\nInitial Grid:");
    for (int i=0; i<8; i++) begin
        for (int j=0; j<8; j++)
            $write("%0d ", current_grid[i][j]);
        $write("\n");
    end
    end

    initial begin
    int num_steps = 5;
    for (int step = 0; step < num_steps; step++) begin
        #1000000; // wait before next step (this is broken)
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
                if (current_grid[i][j] == 1) begin
                    next_grid[i][j] = (neighbor_count == 2 || neighbor_count == 3);
                end
                else next_grid[i][j] = (neighbor_count == 3);

                neighbor_count = 0;
            end
        end

        // print next grid
        $display("\nNext Grid:");
        for (int i=0; i<8; i++) begin
            for (int j=0; j<8; j++)
                $write("%0d ", next_grid[i][j]);
            $write("\n");
        end

        // Move the new grid into the current grid
        for (int i=0; i<8; i++)
            for (int j=0; j<8; j++)
                current_grid[i][j] = next_grid[i][j];
    end
    $finish;
    end

endmodule

// iverilog -g2012 -o game_of_life.vvp game_of_life.sv
// vvp game_of_life.vvp