`timescale 1ns / 1ps
module face_preprocess #(
    parameter IMG_WIDTH = 64,
    parameter IMG_HEIGHT = 64
)(
    input clk,
    input reset,
    input start,
    output reg done
);

    // Memories to store the input and final output images
    reg [7:0] img_mem [0:IMG_WIDTH*IMG_HEIGHT-1];
    reg [7:0] out_mem [0:IMG_WIDTH*IMG_HEIGHT-1];

    // State machine definition
    reg [1:0] state;
    localparam IDLE=0, RUN=1, FINISH=2;

    // Loop counters for image pixels
    integer i, j;
    reg [15:0] idx;

    // Registers to hold the 3x3 pixel window for the Sobel filter
    reg [7:0] p00,p01,p02, p10,p11,p12, p20,p21,p22;

    // Wires connecting the pipeline stages
    wire [7:0] sobel_out;
    wire [7:0] threshold_out;

    // Instantiate the Sobel and Threshold modules
    sobel sobel_inst(
        .p00(p00), .p01(p01), .p02(p02),
        .p10(p10), .p11(p11), .p12(p12),
        .p20(p20), .p21(p21), .p22(p22),
        .edge_out(sobel_out)
    );

    threshold threshold_inst(
        .edge_in(sobel_out),
        .pixel_out(threshold_out)
    );

    // FSM and control logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            done <= 1'b0;
            i <= 0; j <= 0;
        end else begin
            case(state)
                IDLE: begin
                    done <= 1'b0;
                    if (start) begin
                        state <= RUN;
                        // Start processing from the first valid pixel (row 1, col 1)
                        i <= 1;
                        j <= 1;
                    end
                end

                RUN: begin
                    // Calculate the current pixel index
                    idx <= i*IMG_WIDTH + j;

                    // Load the 3x3 neighborhood from memory. This is a critical step.
                    p00 <= img_mem[(i-1)*IMG_WIDTH + (j-1)];
                    p01 <= img_mem[(i-1)*IMG_WIDTH + (j)];
                    p02 <= img_mem[(i-1)*IMG_WIDTH + (j+1)];
                    p10 <= img_mem[(i)*IMG_WIDTH   + (j-1)];
                    p11 <= img_mem[(i)*IMG_WIDTH   + (j)];
                    p12 <= img_mem[(i)*IMG_WIDTH   + (j+1)];
                    p20 <= img_mem[(i+1)*IMG_WIDTH + (j-1)];
                    p21 <= img_mem[(i+1)*IMG_WIDTH + (j)];
                    p22 <= img_mem[(i+1)*IMG_WIDTH + (j+1)];

                    // After one clock cycle, the 'p' registers will be stable,
                    // and 'threshold_out' will have the correct result.
                    // So we write the result for the *previous* pixel index.
                    if (i > 1 || j > 1) begin
                         out_mem[ (i*IMG_WIDTH + j) - 1 ] <= threshold_out;
                    end

                    // Move to the next pixel
                    if (j < IMG_WIDTH - 2) begin
                        j <= j + 1;
                    end else begin
                        j <= 1;
                        if (i < IMG_HEIGHT - 2) begin
                            i <= i + 1;
                        end else begin
                           // We have reached the end of the image
                           state <= FINISH;
                        end
                    end
                end

                FINISH: begin
                    // Write the very last pixel's result
                    out_mem[ (IMG_HEIGHT-2)*IMG_WIDTH + (IMG_WIDTH-2) ] <= threshold_out;
                    done <= 1'b1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule