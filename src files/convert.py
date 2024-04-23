import numpy as np
from PIL import Image
import matplotlib.pyplot as plt


# Step 1: Read the .hex file
hex_file_path = "sobel_output.hex"  # Replace with your .hex file path

with open(hex_file_path, "r") as file:
    hex_lines = file.readlines()

# Step 2: Parse the hex values and store them in an array
grayscale_values = [int(line.strip(), 16) for line in hex_lines]

# Step 3: Create a NumPy array from the grayscale values
width, height = 30,30  # Adjust dimensions as needed
grayscale_data = np.array(grayscale_values, dtype=np.uint8).reshape((height, width))

# Step 4: Create a PIL Image from the grayscale data
image = Image.fromarray(grayscale_data, mode="L")

# Step 5: Save or display the image
image.save("sobel_output.png")  # Save the image to a file
image.show()  # Display the image (opens the default image viewer)