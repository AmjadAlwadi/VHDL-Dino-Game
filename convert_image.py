from PIL import Image

def convert_and_scale_image(input_file, output_file):
  """
  Converts an image to RGB values of range 0-15 and scales it to 640x480 resolution.

  Args:
      input_file (str): Path to the input image file.
      output_file (str): Path to save the converted and scaled image.
  """
  try:
    # Open the image
    img = Image.open(input_file)

    # Resize the image to 640x480 using LANCZOS filter
    resized_img = img.resize((640, 480), Image.LANCZOS)  # Use LANCZOS for smoother scaling

    # Convert to RGB mode if not already
    if img.mode != 'RGB':
      resized_img = resized_img.convert('RGB')

    # Convert pixel values to 0-15 range
    def convert_pixel(pixel):
      return int(round(pixel * 15 / 255)) # Scale and round to nearest integer

    converted_img = resized_img.point(convert_pixel)

    # Save the converted and scaled image
    converted_img.save(output_file)

  except FileNotFoundError:
    print(f"Error: Input file '{input_file}' not found.")
  except Exception as e:
    print(f"An error occurred: {e}")
    
    
    
   

def convert_to_text(input_file, output_file):
  """
  Converts an image to a text file containing string representations of RGB values.

  Args:
      input_file (str): Path to the input image file.
      output_file (str): Path to save the text file.
  """
  try:
    # Open the image
    img = Image.open(input_file)

    # Open the text file for writing
    with open(output_file, 'w') as f:
      for y in range(img.height):
        for x in range(img.width):
          # Get pixel RGB values
          pixel = img.getpixel((x, y))
          
          # Convert each value to a string with separator (e.g., comma)
          f.write(f"game_over_image({x},{y}).r <= std_logic_vector(to_unsigned({pixel[0]},4));\ngame_over_image({x},{y}).g <= std_logic_vector(to_unsigned({pixel[1]},4));\ngame_over_image({x},{y}).b <= std_logic_vector(to_unsigned({pixel[2]},4));\n")

  except FileNotFoundError:
    print(f"Error: Input file '{input_file}' not found.")
  except Exception as e:
    print(f"An error occurred: {e}")


    

# Example usage
input_file = "game_over.jpg"  # Replace with your image path
output_file = "converted_game_over.png"
convert_and_scale_image(input_file, output_file)
print(f"Image converted and scaled successfully! Saved as: {output_file}")



# Example usage
input_file = "converted_game_over.png"
output_file = "image_data.txt"
convert_to_text(input_file, output_file)
print(f"Image data converted and saved to text file: {output_file}")





