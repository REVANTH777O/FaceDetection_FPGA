from PIL import Image
import numpy as np

# Load any image and convert to grayscale 64x64
img = Image.open("face.png").convert("L").resize((64, 64))
data = np.array(img)

# Flatten to 1D
flat = data.flatten()

# Save as hex file for Verilog
with open("image.hex", "w") as f:
    for val in flat:
        f.write("{:02x}\n".format(val))
print("Image saved as image.hex")
