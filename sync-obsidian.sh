#!/bin/bash

# Obsidian to Hugo Sync Script
# This script syncs content from your Obsidian vault to Hugo

# Configuration - UPDATE THESE PATHS
OBSIDIAN_VAULT_PATH="$HOME/dev/brainv2"  # Change this to your Obsidian vault path
OBSIDIAN_BLOG_FOLDER="Imbigo Blog"                    # Folder name in your Obsidian vault
OBSIDIAN_PROJECTS_FOLDER="Imbigo Projects"            # Projects folder in your Obsidian vault
HUGO_CONTENT_PATH="$(pwd)/content"
HUGO_POSTS_PATH="$HUGO_CONTENT_PATH/posts"
HUGO_PROJECTS_PATH="$HUGO_CONTENT_PATH/code"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Obsidian vault exists
if [[ ! -d "$OBSIDIAN_VAULT_PATH" ]]; then
    print_error "Obsidian vault not found at: $OBSIDIAN_VAULT_PATH"
    print_warning "Please update the OBSIDIAN_VAULT_PATH variable in this script"
    exit 1
fi

# Create Hugo content directories if they don't exist
mkdir -p "$HUGO_POSTS_PATH"
mkdir -p "$HUGO_PROJECTS_PATH"

# Function to process markdown files
process_markdown_file() {
    local source_file="$1"
    local dest_file="$2"
    local file_type="$3"
    
    print_status "Processing $file_type: $(basename "$source_file")"
    
    # Create temporary file for processing
    temp_file=$(mktemp)
    
    # Process the file
    while IFS= read -r line; do
        # Convert Obsidian wikilinks [[Page Name]] to regular markdown links
        # This is a basic conversion - you might need to adjust based on your needs
        line=$(echo "$line" | sed 's/\[\[\([^]]*\)\]\]/[\1](\1)/g')
        
        # Convert Obsidian image links ![[image.png]] to Hugo format
        line=$(echo "$line" | sed 's/!\[\[\([^]]*\)\]\]/![Image](\/img\/\1)/g')
        
        # Fix type field for projects - change "type: project" to "type: code"
        if [[ "$file_type" == "project" ]]; then
            line=$(echo "$line" | sed 's/type: project/type: code/g')
        fi
        
        echo "$line" >> "$temp_file"
    done < "$source_file"
    
    # Copy processed file to destination
    cp "$temp_file" "$dest_file"
    rm "$temp_file"
    
    print_success "Synced: $(basename "$dest_file")"
}

# Sync blog posts
OBSIDIAN_BLOG_PATH="$OBSIDIAN_VAULT_PATH/$OBSIDIAN_BLOG_FOLDER"
if [[ -d "$OBSIDIAN_BLOG_PATH" ]]; then
    print_status "Syncing blog posts from: $OBSIDIAN_BLOG_PATH"

    # Find all markdown files in the blog folder
    find "$OBSIDIAN_BLOG_PATH" -name "*.md" -type f | while read -r file; do
        filename=$(basename "$file")
        dest_file="$HUGO_POSTS_PATH/$filename"

        # Only sync if source is newer than destination or destination doesn't exist
        if [[ ! -f "$dest_file" ]] || [[ "$file" -nt "$dest_file" ]]; then
            process_markdown_file "$file" "$dest_file" "blog post"
        else
            print_status "Skipping $filename (up to date)"
        fi
    done
else
    print_warning "Blog folder not found: $OBSIDIAN_BLOG_PATH"
    print_warning "Create this folder in your Obsidian vault or update the OBSIDIAN_BLOG_FOLDER variable"
fi

# Sync project pages
OBSIDIAN_PROJECTS_PATH_FULL="$OBSIDIAN_VAULT_PATH/$OBSIDIAN_PROJECTS_FOLDER"
if [[ -d "$OBSIDIAN_PROJECTS_PATH_FULL" ]]; then
    print_status "Syncing projects from: $OBSIDIAN_PROJECTS_PATH_FULL"

    # Find all markdown files in the projects folder
    find "$OBSIDIAN_PROJECTS_PATH_FULL" -name "*.md" -type f | while read -r file; do
        filename=$(basename "$file")
        dest_file="$HUGO_PROJECTS_PATH/$filename"

        # Only sync if source is newer than destination or destination doesn't exist
        if [[ ! -f "$dest_file" ]] || [[ "$file" -nt "$dest_file" ]]; then
            process_markdown_file "$file" "$dest_file" "project"
        else
            print_status "Skipping $filename (up to date)"
        fi
    done
else
    print_warning "Projects folder not found: $OBSIDIAN_PROJECTS_PATH_FULL"
    print_warning "Create this folder in your Obsidian vault or update the OBSIDIAN_PROJECTS_FOLDER variable"
fi

# Sync images (if you have them in Obsidian)
OBSIDIAN_IMAGES_PATH="$OBSIDIAN_VAULT_PATH/attachments"
HUGO_IMAGES_PATH="$HUGO_CONTENT_PATH/../themes/imbigo-theme/static/img"

if [[ -d "$OBSIDIAN_IMAGES_PATH" ]]; then
    print_status "Syncing images from: $OBSIDIAN_IMAGES_PATH"

    # Create images directory if it doesn't exist
    mkdir -p "$HUGO_IMAGES_PATH"

    # Copy new or updated images
    find "$OBSIDIAN_IMAGES_PATH" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.gif" -o -name "*.webp" \) | while read -r file; do
        filename=$(basename "$file")
        dest_file="$HUGO_IMAGES_PATH/$filename"

        if [[ ! -f "$dest_file" ]] || [[ "$file" -nt "$dest_file" ]]; then
            cp "$file" "$dest_file"
            print_success "Synced image: $filename"
        fi
    done
fi

print_success "Sync completed!"
print_status "Run 'hugo server' to see your changes locally"
print_status "Run 'hugo' to build for production"
