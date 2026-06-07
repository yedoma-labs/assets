#!/bin/bash

# Creates resized images resized for GitHub README headers
# Optimal size for GitHub: 1280x400 (or 1280x320 for tighter headers)
# Supports: PNG, JPG, WebP

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${SCRIPT_DIR}/resized"
HEADER_WIDTH=1280
HEADER_HEIGHT=400
MOBILE_WIDTH=640

# Note: Images are downscaled to fit within bounds while maintaining aspect ratio
# No cropping is performed

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

usage() {
    cat << EOF
Usage: $0 [OPTIONS] [IMAGE_FILE]

Creates resized image sizes from source images.

OPTIONS:
    -o, --output DIR        Output directory (default: ./resized)
    -w, --width NUM         Header width in pixels (default: 1280)
    -h, --height NUM        Header height in pixels (default: 400)
    --source-dir DIR        Process all images in a directory
    --help                  Show this help message

EXAMPLES:
    # Resize specific image
    $0 banners/banner.png

    # Resize all images in banners directory
    $0 --source-dir banners

    # Custom size
    $0 -w 1600 -h 500 logos/logo.png

GitHub Recommendations:
    - Width: 1280px minimum (max ~1400px depending on viewport)
    - Height: 320-400px for header images
    - Format: PNG or WebP for quality

Note: Images are downscaled to fit within dimensions while maintaining aspect ratio
EOF
    exit 0
}

check_dependencies() {
    if ! command -v convert &> /dev/null && ! command -v magick &> /dev/null; then
        echo -e "${RED}Error: ImageMagick not found${NC}"
        echo "Install with: brew install imagemagick (macOS) or apt-get install imagemagick (Linux)"
        exit 1
    fi
}

# Use magick if available (ImageMagick v7+), fallback to convert
IMAGE_CMD="convert"
if command -v magick &> /dev/null; then
    IMAGE_CMD="magick"
fi

resize_image() {
    local input_file="$1"
    local output_dir="$2"
    local width="$3"
    local height="$4"

    if [[ ! -f "$input_file" ]]; then
        echo -e "${RED}Error: File not found: $input_file${NC}"
        return 1
    fi

    local basename="${input_file%.*}"
    local filename=$(basename "$basename")
    local ext="${input_file##*.}"

    mkdir -p "$output_dir"

    echo "Processing: $input_file"

    # Desktop header size (1280x400) - fit within bounds, maintain aspect ratio
    local output_header="${output_dir}/${filename}-resized.png"
    $IMAGE_CMD "$input_file" \
        -resize "${width}x${height}" \
        -quality 85 \
        "$output_header"
    echo -e "${GREEN}✓${NC} Created: $output_header"

    # WebP version for smaller file size
    local output_webp="${output_dir}/${filename}-resized.webp"
    $IMAGE_CMD "$output_header" \
        -quality 80 \
        "$output_webp"
    echo -e "${GREEN}✓${NC} Created: $output_webp (WebP format)"

    # Mobile size (640x320) - fit within bounds, maintain aspect ratio
    local mobile_height=$((height / 2))
    local output_mobile="${output_dir}/${filename}-resized-mobile.png"
    $IMAGE_CMD "$input_file" \
        -resize "${MOBILE_WIDTH}x${mobile_height}" \
        -quality 85 \
        "$output_mobile"
    echo -e "${GREEN}✓${NC} Created: $output_mobile"

    echo ""
}

main() {
    local source_file=""
    local source_dir=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -o|--output)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            -w|--width)
                HEADER_WIDTH="$2"
                shift 2
                ;;
            -h|--height)
                HEADER_HEIGHT="$2"
                shift 2
                ;;
            --source-dir)
                source_dir="$2"
                shift 2
                ;;
            --help)
                usage
                ;;
            -*)
                echo "Unknown option: $1"
                usage
                ;;
            *)
                source_file="$1"
                shift
                ;;
        esac
    done

    check_dependencies

    if [[ -z "$source_file" && -z "$source_dir" ]]; then
        usage
    fi

    echo "GitHub Image Optimizer"
    echo "====================="
    echo "Output: $OUTPUT_DIR"
    echo "Size: ${HEADER_WIDTH}x${HEADER_HEIGHT}px"
    echo ""

    if [[ -n "$source_dir" ]]; then
        for image in "$source_dir"/*.{png,jpg,jpeg,webp}; do
            [[ -f "$image" ]] && resize_image "$image" "$OUTPUT_DIR" "$HEADER_WIDTH" "$HEADER_HEIGHT"
        done
    else
        resize_image "$source_file" "$OUTPUT_DIR" "$HEADER_WIDTH" "$HEADER_HEIGHT"
    fi

    echo "📊 File sizes:"
    du -h "$OUTPUT_DIR"/* | sort -rh

    echo ""
    echo -e "${GREEN}Done!${NC} Use images from: $OUTPUT_DIR"
    echo ""
    echo "Recommended README usage:"
    echo '  ![Project Header](./resized/banner-resized.png)'
}

main "$@"
