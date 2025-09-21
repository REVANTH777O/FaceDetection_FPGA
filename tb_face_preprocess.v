`timescale 1ns / 1ps

module tb_face_preprocess();

  reg clk;
  reg reset;
  reg start;
  wire done;

  // Instantiate DUT
  face_preprocess #(
      .IMG_WIDTH(64),
      .IMG_HEIGHT(64)
  ) dut (
      .clk(clk),
      .reset(reset),
      .start(start),
      .done(done)
  );

  // Clock generation (100 MHz -> 10ns period)
  initial begin
    clk = 0;
    forever #5 clk = ~clk;  // toggle every 5ns
  end

  // Initialize memories and start process
  initial begin
    // Reset
    reset = 1;
    start = 0;
    #50;
    reset = 0;
    #20;

    // Load image data into DUT memory
    $display("📂 Loading input image from image.hex ...");
    $readmemh("image.hex", dut.img_mem);

    // Send start signal
    $display("🚀 Start signal sent. Processing begins...");
    start = 1;
    #10;
    start = 0;
  end

  // Stop simulation when 'done' is asserted
  always @(posedge done) begin
    $display("✅ Processing complete. Writing output to out.hex ...");
    $writememh("out.hex", dut.out_mem);  // write processed image
    #50;
    $finish;
  end

endmodule
