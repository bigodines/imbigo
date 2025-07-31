---
title: Imbigo.net
date: 2025-05-24T21:59:05-07:00
draft: false
type: code
description: Vibin some Obsidian + Hugo integration with auto-deploy to a custom domain and free hosting from github
technologies:
  - JavaScript
  - Go
  - Hugo
  - Obsidian
  - AI
github: https://github.com/yourusername/project-name
demo: https://www.imbigo.net
status: Active
featured: true
weight: 1
---

  
I've decided to write a few lines about a really fun project that I've developed with the assistance of Claude Sonnet 4. I wanted to test its reasoning and agentic coding abilities and see what I could get off the ground in a few hours.

My goal was to create a website that I could write and manage from Obisidian and host for free on github. Spoiler alert, you are visiting this website.

I worked with the agent for a few hours on a Sunday evening. I ran  `hugo new site imbigo`, opened VSCode and started with this prompt:

```
"I just started this project using Hugo v0.147.5. In a brand new git repository. My plan is for us to code a personal website/blog for me using Hugo and eventually manage the content from my Obsidian notes. I would like for you to get familiar with the files in this directory and for us to start working on a theme or my future website.\n\nMy website will have three types of pages: a the main page is going to be a blog with my latest articles, I also want an \"about me\" page with a large picture on the right side and some text on the left where I will briefly describe my professional path. I would also like a different page layout for a \"code\"  section where I will showcase open source projects I've built.\n\nIn terms of the style of the website, I am looking for something modern but lightweight. Should we give it a try?"
```

The agent perfectly identified how to work with Hugo; created a simple responsive layout (html, css, js, partials) and created some generic slop content. I was genuinely impressed by how much it got done from that simple prompt and the fact that things worked right out of the box.

I've used ChatGPT to create a "logo" based on the ezines from the late 90s that maybe only 5 of you ever came a cross but I used to contribute quite often on my early days online.  In general, most of the wrestling with the agent happened when trying to align things with css. I will save you from the details but after some back and forth we go to a place where I was happy.

I told the agent I was going to use Obsidian to manage the content and asked the agent to write me a template per page so that the content could render well on the theme it just created for me. Not only Claude create the templates but it also created a script that would allow me to sync my obsidian folder into my website folder. The bash script was fully functional, had a help section and validation. 

Next, I had the agent telling me what to do to host it for free on github and configure my DNS records in godaddy. It built a deployment pipeline as a github action that will build my website everytime I merge code into main.

I was really happy with the result and the last thing I asked was for it to add a google analytics tag to my template.

All in all, I got a fully working website, logo, deployment pipeline, obsidian cms blazing fast and hosted for free. I've only had to pay for Claude and the imbigo.net domain.

I also asked the agent to expport our conversation in json format for those of you who want to take a look or maybe try it on your own.



