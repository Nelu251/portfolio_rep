#!/bin/bash

# Portfolio Image Resizer Script
# This script resizes all images in the portfolio to improve performance

echo "🖼️  Portfolio Image Resizer"
echo "=========================="

# Create backup directory
BACKUP_DIR="public/images_backup_$(date +%Y%m%d_%H%M%S)"
echo "📁 Creating backup in: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# Function to resize images
resize_images() {
    local dir="$1"
    local max_width="$2"
    local quality="$3"
    
    echo "📂 Processing directory: $dir"
    
    # Find all JPG files
    find "$dir" -name "*.jpg" -o -name "*.jpeg" | while read -r file; do
        # Get file info
        filename=$(basename "$file")
        dirname=$(dirname "$file")
        
        # Create backup
        backup_file="$BACKUP_DIR/${dirname#public/}/$filename"
        mkdir -p "$(dirname "$backup_file")"
        cp "$file" "$backup_file"
        
        # Get original dimensions
        original_size=$(sips -g pixelWidth -g pixelHeight "$file" | grep -E "(pixelWidth|pixelHeight)" | awk '{print $2}' | tr '\n' 'x' | sed 's/x$//')
        original_width=$(echo "$original_size" | cut -d'x' -f1)
        
        # Only resize if image is larger than max_width
        if [ "$original_width" -gt "$max_width" ]; then
            echo "  🔄 Resizing: $filename ($original_size -> max width $max_width)"
            
            # Resize image
            sips -Z "$max_width" --setProperty formatOptions "$quality" "$file" > /dev/null 2>&1
            
            # Get new dimensions
            new_size=$(sips -g pixelWidth -g pixelHeight "$file" | grep -E "(pixelWidth|pixelHeight)" | awk '{print $2}' | tr '\n' 'x' | sed 's/x$//')
            echo "  ✅ Resized: $filename ($original_size -> $new_size)"
        else
            echo "  ⏭️  Skipping: $filename (already $original_size, smaller than $max_width)"
        fi
    done
}

# Resize images with different settings
echo ""
echo "🎯 Resizing images for different use cases..."

# Gallery images (larger, high quality)
echo ""
echo "📸 Gallery Images (max width: 1200px, quality: 85%)"
resize_images "public/branding" 1200 85
resize_images "public/logo" 1200 85
resize_images "public/packaging" 1200 85
resize_images "public/social-media" 1200 85

# Create optimized versions for thumbnails
echo ""
echo "🖼️  Creating thumbnail versions (max width: 400px, quality: 80%)"
THUMBNAIL_DIR="public/thumbnails"
mkdir -p "$THUMBNAIL_DIR"

# Function to create thumbnails
create_thumbnails() {
    local source_dir="$1"
    local category=$(basename "$source_dir")
    
    echo "📂 Creating thumbnails for: $category"
    mkdir -p "$THUMBNAIL_DIR/$category"
    
    find "$source_dir" -name "*.jpg" -o -name "*.jpeg" | while read -r file; do
        filename=$(basename "$file")
        thumbnail_file="$THUMBNAIL_DIR/$category/$filename"
        
        # Create thumbnail
        sips -Z 400 --setProperty formatOptions 80 "$file" --out "$thumbnail_file" > /dev/null 2>&1
        
        echo "  📷 Created thumbnail: $filename"
    done
}

create_thumbnails "public/branding"
create_thumbnails "public/logo" 
create_thumbnails "public/packaging"
create_thumbnails "public/social-media"

# Calculate space savings
echo ""
echo "📊 Space Savings Report"
echo "======================="

# Calculate original size
original_size=$(du -sh "$BACKUP_DIR" | cut -f1)
echo "📁 Original images size: $original_size"

# Calculate new size
new_size=$(du -sh public | cut -f1)
echo "📁 New images size: $new_size"

echo ""
echo "✅ Image resizing complete!"
echo "📁 Original images backed up to: $BACKUP_DIR"
echo "🖼️  Thumbnails created in: $THUMBNAIL_DIR"
echo ""
echo "💡 Next steps:"
echo "   1. Test the performance improvements"
echo "   2. If satisfied, you can delete the backup folder"
echo "   3. Consider updating your components to use thumbnails for previews"
