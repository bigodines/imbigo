# Obsidian to Hugo Integration Guide

This guide will help you set up a seamless workflow between your Obsidian vault and your Hugo website.

## Overview

With this setup, you can:
- Write blog posts and project documentation in Obsidian
- Use Obsidian's powerful features (wikilinks, templates, graph view, etc.)
- Automatically sync content to your Hugo site
- Maintain a single source of truth for your content

## Setup Instructions

### 1. Configure Your Obsidian Vault

1. **Update the sync script paths:**
   - Open `sync-obsidian.sh` in your Hugo project
   - Update `OBSIDIAN_VAULT_PATH` to point to your Obsidian vault
   - The default is `$HOME/Documents/ObsidianVault` - change this to your actual path

2. **Create the required folders in your Obsidian vault:**
   ```
   Your Obsidian Vault/
   ├── Hugo Blog/          # Your blog posts go here
   ├── Hugo Projects/      # Your project documentation goes here
   ├── attachments/        # Images and other media
   └── templates/          # Obsidian templates (optional)
   ```

### 2. Install Obsidian Templates (Optional but Recommended)

1. **Enable the Templates plugin in Obsidian:**
   - Go to Settings → Core plugins
   - Enable "Templates"
   - Set template folder to `templates/`

2. **Copy the provided templates:**
   - Copy `obsidian-templates/blog-post-template.md` to your Obsidian `templates/` folder
   - Copy `obsidian-templates/project-template.md` to your Obsidian `templates/` folder

### 3. Configure Obsidian Settings (Recommended)

1. **Set up daily notes and templates:**
   - Settings → Core plugins → Templates
   - Template folder location: `templates`

2. **Configure attachment handling:**
   - Settings → Files & Links
   - Default location for new attachments: `attachments/`
   - Automatically update internal links: Enable

## Workflow

### Writing Blog Posts

1. **Create a new post:**
   - In Obsidian, go to the `Hugo Blog` folder
   - Create a new note or use the blog template
   - Use the filename format: `my-post-title.md`

2. **Use the frontmatter template:**
   ```yaml
   ---
   title: "Your Post Title"
   date: 2025-05-24T10:00:00Z
   draft: false
   description: "Brief description"
   tags: ["web-development", "hugo"]
   categories: ["Technology"]
   author: "Matheus Mendes"
   ---
   ```

3. **Write your content:**
   - Use standard Markdown
   - Use Obsidian wikilinks: `[[Other Note]]`
   - Reference images: `![[image.png]]`

### Writing Project Documentation

1. **Create a new project:**
   - In Obsidian, go to the `Hugo Projects` folder
   - Create a new note or use the project template
   - Use a descriptive filename: `my-awesome-project.md`

2. **Use the project frontmatter:**
   ```yaml
   ---
   title: "Project Name"
   date: 2025-05-24T10:00:00Z
   draft: false
   type: "project"
   description: "What your project does"
   technologies: ["React", "Node.js", "MongoDB"]
   github: "https://github.com/user/repo"
   demo: "https://demo-url.com"
   status: "Active"
   featured: true
   weight: 1
   ---
   ```

### Syncing to Hugo

1. **Run the sync script:**
   ```bash
   cd /Users/matheus.mendes/dev/imbigo
   ./sync-obsidian.sh
   ```

2. **What the script does:**
   - Copies new/updated files from Obsidian to Hugo
   - Converts Obsidian wikilinks to markdown links
   - Processes image references
   - Only syncs files that have been modified

3. **View your changes:**
   ```bash
   hugo server
   ```
   Visit `http://localhost:1314` to see your site

## Advanced Features

### Automatic Syncing (Optional)

You can set up automatic syncing using a file watcher or cron job:

1. **Using fswatch (macOS):**
   ```bash
   # Install fswatch
   brew install fswatch
   
   # Watch for changes and auto-sync
   fswatch -o ~/Documents/ObsidianVault/Hugo\ Blog ~/Documents/ObsidianVault/Hugo\ Projects | while read; do
       cd /Users/matheus.mendes/dev/imbigo && ./sync-obsidian.sh
   done
   ```

2. **Using a cron job:**
   ```bash
   # Edit crontab
   crontab -e
   
   # Add this line to sync every 5 minutes
   */5 * * * * cd /Users/matheus.mendes/dev/imbigo && ./sync-obsidian.sh
   ```

### Image Handling

1. **In Obsidian:**
   - Drag and drop images into your notes
   - They'll be saved to the `attachments/` folder
   - Reference them with `![[image.png]]`

2. **The sync script will:**
   - Copy images to your Hugo static folder
   - Convert Obsidian image syntax to Hugo format

### Custom Conversions

The sync script can be customized to handle:
- Different link formats
- Custom frontmatter processing
- File organization rules
- Custom image processing

## Tips for Better Workflow

1. **Use descriptive filenames:** They become your URL slugs
2. **Organize with folders:** Use subfolders in your Hugo Blog folder
3. **Use tags consistently:** They help with site organization
4. **Preview before publishing:** Use `draft: true` while writing
5. **Backup your vault:** Your Obsidian vault is now your content source

## Troubleshooting

### Common Issues

1. **Sync script can't find Obsidian vault:**
   - Check the `OBSIDIAN_VAULT_PATH` in `sync-obsidian.sh`
   - Make sure the path exists and is readable

2. **Images not showing:**
   - Check that images are in the `attachments/` folder
   - Verify the image references in your markdown

3. **Wikilinks not converting:**
   - Make sure the target page exists
   - Check that the link syntax is correct: `[[Page Name]]`

4. **Frontmatter errors:**
   - Ensure YAML is properly formatted
   - Check for missing quotes around values with special characters

### Getting Help

- Check the Hugo documentation: https://gohugo.io/documentation/
- Obsidian help: https://help.obsidian.md/
- Open an issue if you find bugs in the sync script

## Next Steps

1. Set up your Obsidian vault with the folder structure
2. Copy the templates to your Obsidian templates folder
3. Write your first blog post or project documentation
4. Run the sync script and preview your site
5. Set up automatic syncing if desired
6. Deploy your site to production
