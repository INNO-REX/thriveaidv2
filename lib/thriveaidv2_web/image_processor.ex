defmodule Thriveaidv2Web.ImageProcessor do
  @moduledoc """
  Handles image processing tasks like background removal.
  Uses Mogrify (Elixir wrapper for ImageMagick) for background removal.
  """
  
  @doc """
  Removes the background from an image file using Mogrify/ImageMagick.
  Returns {:ok, output_path} on success, {:error, reason} on failure.
  """
  def remove_background(input_path) when is_binary(input_path) do
    # Check if input file exists
    unless File.exists?(input_path) do
      return_error("Input file not found: #{input_path}")
    end
    
    # Generate output path (always PNG for transparency)
    output_path = input_path
      |> Path.rootname()
      |> Kernel.<>("_nobg.png")
    
    try do
      # Use Mogrify to remove background
      # This makes white/light backgrounds transparent
      # Works best for logos with white/light backgrounds
      Mogrify.open(input_path)
      |> Mogrify.custom("fuzz", "10%")
      |> Mogrify.custom("transparent", "white")
      |> Mogrify.custom("fuzz", "5%")
      |> Mogrify.custom("transparent", "#FFFFFF")
      |> Mogrify.format("png")
      |> Mogrify.save(path: output_path)
      
      if File.exists?(output_path) do
        file_size = File.stat!(output_path).size
        if file_size > 0 do
          {:ok, output_path}
        else
          return_error("Output file is empty")
        end
      else
        return_error("Output file was not created")
      end
    rescue
      error ->
        # Mogrify will raise if ImageMagick is not available
        return_error("ImageMagick not available: #{Exception.message(error)}")
    end
  end
  
  def remove_background(_), do: return_error("Invalid input path")
  
  defp return_error(reason) do
    {:error, reason}
  end
  
  @doc """
  Checks if background removal is available (ImageMagick installed).
  """
  def available? do
    try do
      # Try a simple mogrify operation to check if ImageMagick is available
      # Create a temporary test file
      test_input = Path.join(System.tmp_dir(), "test_bg_check_#{:rand.uniform(10000)}.png")
      test_output = Path.join(System.tmp_dir(), "test_bg_check_out_#{:rand.uniform(10000)}.png")
      
      # Create a minimal 1x1 PNG file for testing
      File.write!(test_input, <<137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137, 0, 0, 0, 10, 73, 68, 65, 84, 120, 156, 99, 0, 1, 0, 0, 5, 0, 1, 13, 10, 45, 180, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130>>)
      
      Mogrify.open(test_input)
      |> Mogrify.format("png")
      |> Mogrify.save(path: test_output)
      
      # Clean up
      File.rm(test_input)
      File.rm(test_output)
      
      true
    rescue
      _ -> false
    end
  end
end

