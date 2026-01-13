# Background Removal Setup

**Note: This directory is no longer used. Background removal now uses ImageMagick instead of Python.**

## Current Implementation

The system now uses ImageMagick for background removal (no Python required).

### Installation

1. **Windows**: Download and install ImageMagick from https://imagemagick.org/script/download.php
2. **macOS**: `brew install imagemagick`
3. **Linux**: `sudo apt-get install imagemagick` (Ubuntu/Debian) or `sudo yum install ImageMagick` (CentOS/RHEL)

### How It Works

When a partner logo is uploaded in the admin section, the system automatically:
1. Saves the uploaded image temporarily
2. Uses ImageMagick to remove white/light backgrounds
3. Replaces the original image with the background-removed version (saved as PNG)
4. Stores the processed image

### Troubleshooting

If background removal fails:
- Check that ImageMagick is installed: `magick -version` or `convert -version`
- Check the application logs for error messages
- The system will automatically use the original image if background removal fails
- SVG files are skipped (they don't need background removal)

