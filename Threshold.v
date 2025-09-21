module threshold(
    input  [7:0] edge_in,
    output wire [7:0] pixel_out
);
    // You can change this parameter to make the filter more or less sensitive
    parameter THRESHOLD_VALUE = 8'd100;

    // If edge magnitude is greater than the threshold, pixel is white (edge)
    // Otherwise, it's black (no edge)
    assign pixel_out = (edge_in > THRESHOLD_VALUE) ? 8'hFF : 8'h00;

endmodule