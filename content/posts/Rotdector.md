---
title: "Fighting Code Rot: How I Built a Tool to Keep Technical Debt in Check"
date: 2025-06-22T15:31:37+08:00
draft: false
description: "Fighting Code Rot: How I Built a Tool to Keep Technical Debt in Check"
tags:
  - rotdetector
  - go
  - opensource
categories:
  - code
author: Matheus Mendes
---
*"This is a temporary fix. I'll come back for it later"* – Famous last words that every developer has uttered at least once.

We've all been there. You're staring down a deadline, your PM is breathing down your neck, and you need to ship something that works. So you write a quick hack, slap a `// TODO: refactor this ugly mess` comment on top, and move on with your life.

But here's the thing about "later" – it has a funny way of never actually arriving.

Six months pass. That "temporary" fix is still lurking in your codebase like an uninvited guest who's overstayed their welcome. The original developer has probably moved teams, taking all the context with them. Now nobody wants to touch that code because, hey, it works, and why fix what ain't broken, right?

This is what we've come to call **code rot** – the slow, inevitable decay that happens when our quick fixes become permanent fixtures.

## Why Our Current Approach Sucks

Let me paint you a picture from my own experience. I've worked with teams where the codebase was littered with TODOs left and right. It's like archaeological layers of good intentions gone bad.

The problem isn't that developers are lazy or don't care. It's that our tools and processes are fundamentally broken:

1. **We're always in crisis mode**: Startups are built around tight deadlines and moonshot experiments
2. **Knowledge evaporates**: People leave, switch teams, or simply forget why they wrote something
3. **TODOs are invisible**: They're scattered everywhere but never surface at the right time
4. **JIRA tickets are too far from the code**: That "upgrade nodejs" ticket will never get prioritized until it is too late.

I've seen TODOs that were literally older than the framework they were commenting on. It's both hilarious and terrifying.

## My Solution: RotDetector

After hitting this wall one too many times, I decided to build something about it. I needed a tool that would:

- Be dead simple to use
- Fast and able to parse large codebases without impacting the build job too much
- Work with whatever language my team was using
- Automatically yell at us when things got stale (aka: break the build)
- Play nice with our existing CI setup

The result was **RotDetector** – a tool that treats code comments like food in your fridge. Give them an expiration date, and get reminded when they've gone bad.

## How It Actually Works

The concept is stupidly simple (which is probably why it works). Instead of writing this:

```javascript
// TODO: refactor this when we have time
if (legacyMode) {
    // ugly hack for backward compatibility
    return processLegacyData(data);
}
```

You write this:

```javascript
// BestBy 06/2025: refactor this when we have time
if (legacyMode) {
    // ugly hack for backward compatibility
    return processLegacyData(data);
}
```

That's it. RotDetector scans your code, finds `BestBy` comments, checks if they're expired, and throws a fit if they are. It handles different date formats and works with Go, JavaScript/TypeScript, Python, and Ruby.

You'll either have to address the issue by the date or change the expiration opening another PR and encouraging a discussion on why the date has been changed.

## Some examples 

Here's how this looks in practice:

### Feature Flags That Actually Get Removed

```go
// BestBy 12/2024: Remove feature flag after Q4 rollout
if featureFlags.EnableNewDashboard {
    return renderNewDashboard(ctx)
}
return renderLegacyDashboard(ctx)
```

I can't tell you how many times I've seen feature flags that outlived the features they were supposed to toggle.

### Workarounds with Exit Strategies

```python
# BestBy 03/2025: Remove when API v2 is stable
def get_user_data(user_id):
    try:
        return api_v2_client.get_user(user_id)
    except APIException:
        # Fallback to v1 API
        return api_v1_client.get_user(user_id)
```

### "Good Enough for Now" Code

```typescript
// BestBy 08/2025: Profile and optimize after first deliverable
export function processItems(items: Item[]): ProcessedItem[] {
    // Quick and dirty implementation for MVP
    return items.map(item => ({
        ...item,
        processed: true,
        timestamp: Date.now()
    }));
}
```

The beauty is that it forces you to think about *when* you'll actually come back to fix things.

## Plugging It Into Your CI

This is where the magic happens. Add RotDetector to your CI pipeline, and suddenly those expired comments become everyone's problem:

```yaml
# GitHub Actions example
- name: Check for rotting code
  run: |
    wget https://github.com/bigodines/rotdetector/releases/download/v1.0.0/rotdetector
    chmod +x rotdetector
    ./rotdetector -dir=. -ci
```

When it finds expired comments, your build fails. No ifs, ands, or buts. You either fix the code, extend the deadline with a good reason, or PRs won't merge.

It's like having a really persistent team member who never forgets and never lets things slide.

## The Psychology Behind It

Here's what I found interesting: just adding expiration dates changes how people think about code. Instead of "I'll fix this someday," it becomes "I'll fix this by March, or I'll have to explain why I can't."

It's the difference between saying "let's grab coffee sometime" and "let's grab coffee next Tuesday at 3 PM." One is a pleasant fiction, the other is a commitment.

Plus, when your build breaks because of an expired comment, you can't just ignore it and hope someone else deals with it. The accountability is built-in.

## Getting Your Hands Dirty

Want to try it out? It's pretty straightforward:

```bash
# Grab the code and build it
git clone git@github.com:bigodines/rotdetector.git
cd rotdetector
make build

# Run it on your project
./bin/rotdetector -dir=/path/to/your/project

# Also check for TODOs while you're at it
./bin/rotdetector -dir=/path/to/your/project -todo

# Make it CI-friendly (no pretty colors)
./bin/rotdetector -dir=/path/to/your/project -ci
```

The tool is fast – I built it in Go with concurrent file processing, so it'll chew through thousands of files in seconds.

## Lessons Learned

After using this thing for a while, here's what I've figured out:

**Don't be overly optimistic with dates.** I learned this the hard way. Setting a deadline you can't meet just leads to build failures and grumpy teammates. It's better to be realistic and extend when needed.

**Context is king!**
```go
// BestBy 03/2025: Remove after customer migration to new API
// Context: Legacy customers still depend on v1 endpoint
// Ticket: PROJ-1234
```

**Different types of debt need different timelines:**
- Feature flags: Plan around your rollout schedule
- Quick fixes: Align with your sprint cycles
- Legacy compatibility: Match your deprecation timeline
- Performance hacks: Tie to when you'll actually have time to optimize

**Make your code reviewers care.** When someone submits a PR with a `BestBy` comment, the reviewer should ask: "Is this date realistic? Do we have a plan?"

## What Actually Happened

I'll be honest – I was skeptical this would work. But after rolling it out across a few projects, the results were better than I expected:

Our codebase stopped accumulating the usual pile of forgotten TODOs. When something was marked for cleanup, it actually got cleaned up (or at least had a documented reason for why it couldn't be).

Most importantly, it shifted the team mindset from "should we fix this?" to "when will we fix this?" That's a small change in wording but a huge change in accountability.

---

RotDetector is open source and living on [GitHub](https://github.com/bigodines/rotdetector). It's a small tool that tackles a big problem – one expired comment at a time.

Next time you're about to write a TODO, try adding a `BestBy` date instead. Your future self will probably curse you for the accountability, but they'll also thank you for the reminder.

*Have you found other ways to keep technical debt under control? I'd love to hear about what's worked (or spectacularly failed) for your team.*
