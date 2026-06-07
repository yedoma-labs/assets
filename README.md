# Assets

Central repository for shared assets referenced across yedoma-labs projects.

# GitHub README Image Resizer

Script that creates optimized image sizes for GitHub repository headers in README.md files.

## Features

- **Optimal GitHub dimensions**: 1280×400px (desktop) and 640×200px (mobile)
- **Multiple formats**: PNG and WebP output for flexibility
- **Batch processing**: Resize entire directories at once
- **Smart cropping**: Uses center gravity to maintain important content
- **Quality optimization**: Compressed WebP for smaller file sizes (60KB vs 700KB+)
- **Flexible sizing**: Customize width and height as needed

## Installation

1. Ensure ImageMagick is installed:

```bash
# macOS
brew install imagemagick

# Linux (Ubuntu/Debian)
sudo apt-get install imagemagick

# Linux (Fedora/RHEL)
sudo dnf install ImageMagick
```

2. Make the script executable:

```bash
chmod +x resize-for-github.sh
```

## Usage

### Single Image
```bash
./resize-for-github.sh banners/banner.png
```

### Batch Process Directory
```bash
./resize-for-github.sh --source-dir banners
./resize-for-github.sh --source-dir logos
```

### Custom Dimensions
```bash
./resize-for-github.sh -w 1600 -h 500 banners/banner.png
```

### Specify Output Directory
```bash
./resize-for-github.sh -o ./optimized banners/banner.png
```

### Full Help
```bash
./resize-for-github.sh --help
```

## Output

Creates three files per input image:

| File | Size | Use Case |
|------|------|----------|
| `*-resized.png` | 1280×400px | Desktop README header |
| `*-resized.webp` | 1280×400px | Smaller file size (~8% of PNG) |
| `*-resized-mobile.png` | 640×200px | Mobile/responsive sizes |

## GitHub Integration

### In README.md

```markdown
# Project Name

![Project Header](./resized/banner-resized.png)

Your project description here...
```

### For Picture Element (responsive)

```html
<picture>
  <source media="(max-width: 640px)" srcset="./resized/banner-resized-mobile.png">
  <img src="./resized/banner-resized.png" alt="Project Header">
</picture>
```

### For WebP with fallback

```html
<picture>
  <source srcset="./resized/banner-resized.webp" type="image/webp">
  <img src="./resized/banner-resized.png" alt="Project Header">
</picture>
```

## Recommended Dimensions

| Usage | Width | Height | Aspect Ratio |
|-------|-------|--------|--------------|
| Desktop header | 1280px | 400px | 3.2:1 |
| Mobile header | 640px | 200px | 3.2:1 |
| Square logo | 400px | 400px | 1:1 |

**GitHub best practices:**
- Minimum width: 1280px (max viewport ~1400px)
- Maximum width: 1600px (diminishing returns)
- Header height: 320-500px (balance between visual and scroll)
- File size: <100KB per image

## Example Workflow

```bash
# Process all banners
./resize-for-github.sh --source-dir banners

# Check output
ls -lh resized/

# Update README with new header
# Then commit
git add resized/
git commit -m "chore: add optimized header images"
```

## Performance Tips

1. **Use WebP format** in README when possible (60KB vs 736KB)
2. **Compress PNGs** further with:
   ```bash
   pngquant --quality=80-85 *.png
   optipng -o2 *.png
   ```
3. **Lazy load** images in HTML to improve page performance
4. **Test responsiveness** on mobile (640px viewport)

## Troubleshooting

### ImageMagick not found
```bash
# Install ImageMagick
brew install imagemagick  # macOS
sudo apt-get install imagemagick  # Linux
```

### Permission denied
```bash
chmod +x resize-for-github.sh
```

### File size too large
- Use WebP version instead of PNG
- Reduce quality: add `-quality 75` to script
- Compress further with optimization tools

## License

Free to use and modify for your projects.
