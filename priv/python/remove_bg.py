#!/usr/bin/env python3
"""
Background removal script using rembg library.
Usage: python remove_bg.py <input_path> <output_path>
"""
import sys
from rembg import remove
from PIL import Image

def remove_background(input_path, output_path):
    """Remove background from an image and save as PNG."""
    try:
        with open(input_path, 'rb') as input_file:
            input_data = input_file.read()
        
        # Remove background
        output_data = remove(input_data)
        
        # Save output
        with open(output_path, 'wb') as output_file:
            output_file.write(output_data)
        
        return True
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        return False

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python remove_bg.py <input_path> <output_path>", file=sys.stderr)
        sys.exit(1)
    
    input_path = sys.argv[1]
    output_path = sys.argv[2]
    
    success = remove_background(input_path, output_path)
    sys.exit(0 if success else 1)

