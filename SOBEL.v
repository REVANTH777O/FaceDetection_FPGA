module sobel(
    input  [7:0] p00, p01, p02,
    input  [7:0] p10, p11, p12,
    input  [7:0] p20, p21, p22,
    output wire [7:0] edge_out
);

    // Intermediate wires for horizontal (Gx) and vertical (Gy) gradients
    wire signed [11:0] gx, gy;
    wire [11:0] abs_gx, abs_gy;
    wire [12:0] sum;

    // Extend inputs to signed values for correct arithmetic
    wire signed [10:0] s00 = p00; wire signed [10:0] s01 = p01; wire signed [10:0] s02 = p02;
    wire signed [10:0] s10 = p10;                               wire signed [10:0] s12 = p12;
    wire signed [10:0] s20 = p20; wire signed [10:0] s21 = p21; wire signed [10:0] s22 = p22;

    // Gx Sobel Kernel: [-1 0 +1; -2 0 +2; -1 0 +1]
    assign gx = -s00 + s02 - (s10 << 1) + (s12 << 1) - s20 + s22;

    // Gy Sobel Kernel: [-1 -2 -1; 0 0 0; +1 +2 +1]
    assign gy = -s00 - (s01 << 1) - s02 + s20 + (s21 << 1) + s22;

    // Calculate absolute values
    assign abs_gx = (gx < 0) ? -gx : gx;
    assign abs_gy = (gy < 0) ? -gy : gy;

    // Sum the absolute values for the final magnitude
    assign sum  = abs_gx + abs_gy;

    // Clamp the result to 8 bits (0-255)
    assign edge_out = (sum > 255) ? 8'hFF : sum[7:0];

endmodule