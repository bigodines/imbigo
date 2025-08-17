---
title: My challenges with AI assisted coding
date: 2025-08-15T16:16:34-07:00
draft: false
description: Reflections on assisted AI coding
tags:
  - ai
categories:
  - category
author: Matheus Mendes
---
I’m very bullish on AI code assistants. It’s actually the second biggest reason I stepped down from being a director and went back to IC life.  I’ll write more about that decision another time, but today I want to share how I’m using AI day-to-day—and, maybe more importantly, when it doesn’t quite fit.


My toolkit is pretty simple: VSCode, GitHub Copilot, Claude Sonnet, and occasionally KiloCode.


The hardest part of working with AI so far has been the waiting. When I’m in “agentic” mode—fire off a big prompt and wait—it kills my flow. If I don’t get an answer in five seconds, my brain is already somewhere else, usually for twice as long as the model took to respond. Because of that, I’ve built my routine around minimizing that problem:


- I almost never just throw a task at an agent and let it run wild (the only exception: it helped me spin up this website).

- I use agents as a sounding board for architecture debates, and they’re surprisingly good at turning requirements into Mermaid diagrams.

- When I’m diving into legacy code, AI assistants are great for orienting me and pointing out where to start.

- I usually write the first version of the code myself, then lean on AI to spot bugs—or at least clean up syntax and typing errors along the way.

- Once the code works, I always use AI to generate tests. Every single time. At that point I’m basically reviewing test code, which has actually helped me catch real implementation mistakes. (Sometimes hilariously, with tests like test_blah_returns_none_when_id_is_empty()—when what I really wanted was an exception.) Yes, it also spits out plenty of garbage mocks and useless assertions, but the time savings are still massive.

- 	I re-review everything top to bottom, usually deleting the flood of obvious comments (“This function returns X”).

- On PRs, I tag the Copilot bot. Its reviews are mostly fluff, but the little snippet summaries it generates are surprisingly valuable.


Lately, I’ve also been experimenting with:

- 	Auto-generating documentation—it’s not perfect, but decent enough to save time.

- 	Cataloging my best prompts for different use cases (architecture, tests, repo-specific conventions, ideation, documentation).

- 	Spinning up separate agents for each language I use regularly: Go, Python (Flask), and React.

At the end of the day, I don’t think of AI as a replacement for writing code—I still do the core work myself. But it’s like having an endlessly available junior engineer and an architecture debate partner rolled into one. It saves me from the drudge work, helps me move faster, and sometimes even pushes me to rethink my assumptions.


The tech still pulls me out of flow more often than I’d like, but the upside is undeniable. That’s why I’m doubling down on IC work right now: I want to be hands-on while this stuff evolves, because I’m convinced AI will reshape how we write and reason about software.


For me, AI isn’t about the hype cycles or the big “end of software engineering” headlines. It’s about whether it helps me get into flow faster, cut down on tedious work, and catch mistakes earlier. Sometimes it does, sometimes it doesn’t. That gap—between potential and reality—is exactly what keeps me experimenting.
