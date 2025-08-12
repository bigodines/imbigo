---
title: How I built this site no-code
date: 2025-05-24T21:59:05-07:00
draft: false
type: code
description: How I used Claude Sonnet 4 to build a complete Hugo website with Obsidian CMS integration, custom theme, and automated deployment pipeline - in one afternoon, using github's free hosting.
technologies:
  - JavaScript
  - Go
  - Hugo
  - Obsidian
  - GitHub Actions
  - AI
github: https://github.com/bigodines/imbigo
demo: https://www.imbigo.net
status: Active
featured: true
weight: 1
---
## The Challenge: Website in an Evening

I had a Sunday evening free and decided to see how far I could get building a personal website with an AI agent's help. The goal wasn't just to throw together a basic site, but to create something I'd actually want to use - complete with a custom theme, content management, and proper deployment.

Spoiler alert: you're reading this on that very website.

## What I Wanted

My requirements were pretty specific:
- A personal blog/portfolio site using Hugo. This would allow me to host for free as a GitHub page and would make it blazing fast and highly cacheable
- Three different page types: blog posts, an about page, and a place to keep my open source code categorized
- Content management through Obsidian (since I already live in it for notes)
- Something that looks modern but doesn't take forever to load
- Custom domain with automated deployment

I started with `hugo new site imbigo`, opened VSCode, and basically told the AI what I wanted:

```
"I just started this project using Hugo v0.147.5. In a brand new git repository. My plan is for us to code a personal website/blog for me using Hugo and eventually manage the content from my Obsidian notes. I would like for you to get familiar with the files in this directory and for us to start working on a theme for my future website.

My website will have three types of pages: the main page is going to be a blog with my latest articles, I also want an "about me" page with a large picture on the right side and some text on the left where I will briefly describe my professional path. I would also like a different page layout for a "code" section where I will showcase open source projects I've built.

In terms of the style of the website, I am looking for something modern but lightweight. Should we give it a try?"
```

## How It Actually Went

### Getting the Theme Right (1 prompt)

The AI immediately got to work on a custom theme called `imbigo-theme`. I was honestly surprised at how well it understood Hugo's structure right away. It created:

- A complete theme with all the Hugo conventions
- Responsive layouts for all three page types
- Clean HTML with proper Hugo templating
- CSS with flexbox that actually worked on mobile
- Some basic JavaScript for navigation
- Slop placeholder texts

The crazy part? It all worked on the first try. No broken layouts, no debugging - just a working website.

### Setting Up Content (part of initial prompt)

Next was organizing the content structure. The AI set up all the directories properly and created some sample posts to show how each page type would work:

- Blog posts in `/content/posts/`
- Project showcases in `/content/code/`
- Static pages like the about page
- Front matter templates for each type

Nothing groundbreaking here, but it saved me from having to remember Hugo's conventions.

### Logo Tweaking (3 prompts)

I had created a logo using DALL-E  and wanted to use it instead of just text. The AI swapped it in easily, but then came the fun part - getting the sizing right. "The logo is too big," I said. Fixed. "Now it's too small." Fixed again. This back-and-forth actually worked really well. I would have helped if I knew the size and where I wanted from the get go but I didn't so we were brute forcing until it looked good enough.

### The Obsidian Integration (1 prompt)

This is where things got interesting. I explained that I wanted to write everything in Obsidian and have it sync to the website. The AI didn't just help with templates - it built me a complete solution:

- Obsidian templates for each content type with the right Hugo front matter
- A bash script (`sync-obsidian.sh`) that syncs my vault to Hugo's content directory
- Validation to make sure nothing breaks during sync
- A help system because why not

The script actually works great and handles edge cases I didn't even think about.

### Getting It Online (1 prompt)

The last piece was deployment. I explained I wanted free hosting on GitHub with a custom domain, and the AI walked me through setting up:

- A GitHub Actions workflow for automated builds
- GitHub Pages configuration
- DNS setup for my custom domain
- Some Hugo optimizations for production

Now whenever I push to main, the site rebuilds automatically.

## What I Ended Up With

After about 6 main prompts (plus a few small adjustments), I had:

- A custom Hugo theme that actually looks decent
- Three different page layouts that work on mobile
- Obsidian integration with automated syncing
- A deployment pipeline that runs on GitHub Actions
- Custom domain setup (imbigo.net)
- Google Analytics integration
- Documentation and templates for everything

Total prompts: ~6 for major features + 3-4 for tweaks
Total cost: Claude subscription + domain (~$20/year)
Hosting: Free on GitHub Pages
Domain: (I forgot :D)
Time to write a new post: Write in Obsidian, run sync script, done

## Takeaways

A few things that stood out:

1. The AI understood the whole pipeline, not just individual pieces
2. Small iterative changes worked really well
3. It provided good documentation without being asked
4. It followed Hugo conventions I didn't even know existed
5. It anticipated problems I would have run into later

Six prompts for a complete website with CMS and deployment. That's pretty remarkable when you think about it.

If you're thinking about trying AI-assisted development: be specific about what you want and expect to iterate. I'm not here to tell you how to do it or to sell a course on how to build the perfect prompt but I'm here to encourage to give it a honest try. The technology is surprisingly capable right now and only getting better every week.

---


---

*Want to see the full conversation? [Download the complete chat export](/conversation-export-sanitized.json) to see every prompt and response that built this site. The code is all on GitHub too.*

  

