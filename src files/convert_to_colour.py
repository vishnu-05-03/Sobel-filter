## Code to read input.hex file and convert into an image

import numpy as np
from PIL import Image
from IPython.display import display

# Step 1: Read the .hex file
hex_file_path = "input.hex"
img_file_path = "input_image.png"
with open(hex_file_path, "r") as file:
    hex_lines = file.readlines()

# Step 2: Parse the hex values and store them in an image array
width, height = 32, 32
rgb_image = np.zeros((height, width, 3), dtype=np.uint8)

for row in range(height):
    for col in range(width):
        # Read Red, Green, and Blue values separately from the hex file
        red_value = int(hex_lines[row * width + col].strip(), 16)
        green_value = int(hex_lines[(height * width) + (row * width) + col].strip(), 16)
        blue_value = int(hex_lines[(2 * height * width) + (row * width) + col].strip(), 16)

        rgb_image[row, col, 0] = red_value   # Red channel
        rgb_image[row, col, 1] = green_value # Green channel
        rgb_image[row, col, 2] = blue_value  # Blue channel

# Step 3: Create a PIL Image and display it in Google Colab
image = Image.fromarray(rgb_image)
display(image)

image.save(img_file_path)  # Save the image to a file
image.show()  # Display the image (opens the default image viewer)