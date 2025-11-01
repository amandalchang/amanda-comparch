`timescale 10ns/10ns
`include "top.sv"

module game_of_life_tb;

    logic clk = 0;
    logic SW = 1'b1;
    logic BOOT = 1'b1;
    logic _48b, _45a;
    int outfile;
    
    top u0 (
        .clk            (clk), 
        .SW             (SW), 
        .BOOT           (BOOT), 
        ._48b           (_48b), 
        ._45a           (_45a)
    );

    initial begin
        outfile = $fopen ("sim_results/outputfile.txt", "w");

        if (outfile) $display("File was opened successfully : %0d", outfile);
        else     $display("File was NOT opened successfully : %0d", outfile);

        $fdisplay(outfile, "%s\t%s\t%s", "Green   ", "Red     ", "Blue");
        $dumpfile("game_of_life.vcd");
        $dumpvars(0, game_of_life_tb);
      #20000000
        $finish;

    end

    always begin
        #4
        clk = ~clk;
    end

    always @(u0.green_output_array or u0.red_output_array or u0.blue_output_array) begin
        for (int i = 63; i > 0; i -= 8) begin
            $fdisplay(outfile, "%b\t%b\t%b", 
                u0.green_output_array[i -: 8], 
                u0.red_output_array[i -: 8], 
                u0.blue_output_array[i -: 8]
            );
        end
        $fdisplay(outfile, "");
    end

    final begin
        $fclose(outfile);
    end

endmodule

