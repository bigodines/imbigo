---
title: High-performance worker pools with Bigopool
date: 2025-05-29T20:45:55-07:00
draft: false
description: Building High-Performance Concurrent Applications with `bigopool`
tags:
  - bigopool
  - go
categories:
  - code
author: Matheus Mendes
---

Concurrency is one of Go's greatest strengths, but managing goroutines effectively at scale can be challenging. When you have millions of tasks to process, spawning a goroutine for each one can quickly overwhelm your system with excessive memory usage and context switching overhead. This is where worker pools come to the rescue.

A few years ago, I created [bigopool](https://github.com/bigodines/bigopool), a lightweight Go library that implements high-performance worker pools with elegant error and result handling. Today, I have finally decided to write about it.

## The Problem: Too Many Goroutines

Imagine you need to process 1,00,000 images, make API calls to validate 500,000 email addresses, or perform complex calculations on a massive dataset. The naive approach might look like this:

```go
// Don't do this!
for _, item := range hugeSlice {
    go func(item Item) {
        // process item
    }(item)
}
```

While this code will work for small datasets, it becomes problematic at scale:
- **Memory explosion**: Each goroutine consumes ~2KB of stack space. For 1M items, that's 2gb in goroutine allocation alone.

- **CPU thrashing**: Too many goroutines lead to excessive context switching

- **Resource exhaustion**: You might hit system limits on the number of threads

## The Solution: Worker Pools

Worker pools solve this by maintaining a fixed number of worker goroutines that process jobs from a shared queue. This gives you:

- **Controlled resource usage**: Fixed memory footprint regardless of job count
- **Better performance**: Optimal number of workers for your system
- **Backpressure**: Built-in queue management prevents overwhelming your system

## Introducing bigopool

`bigopool` was designed with simplicity and performance in mind. It provides two main abstractions:

1. **Worker Pool**: For processing large numbers of jobs with controlled concurrency
2. **Parallel Execution**: For running a small number of functions concurrently

Let me show you how both work in practice.

## Worker Pool in Action

The worker pool is perfect when you have many similar tasks to process. Here's how it works:

### 1. Define Your Job

First, implement the `Job` interface by defining an `Execute()` method:

```go
type ImageProcessingJob struct {
    ImagePath  string
    OutputPath string
    Quality    int
}

func (j ImageProcessingJob) Execute() (bigopool.Result, error) {
    // Simulate image processing
    time.Sleep(time.Millisecond * 100)
    
    result := map[string]interface{}{
        "input":      j.ImagePath,
        "output":     j.OutputPath,
        "size_kb":    1024,
        "processed":  true,
    }
    
    return result, nil
}
```

### 2. Create and Configure the Dispatcher

```go
// Create a dispatcher with 5 workers and a queue capacity of 100
dispatcher, err := bigopool.NewDispatcher(5, 100)
if err != nil {
    log.Fatal(err)
}

// Start the workers
dispatcher.Run()
```

### 3. Enqueue Jobs and Collect Results

```go
// Add jobs to the queue
imagePaths := []string{"image1.jpg", "image2.jpg", "image3.jpg"}
for _, path := range imagePaths {
    job := ImageProcessingJob{
        ImagePath:  path,
        OutputPath: "processed_" + path,
        Quality:    85,
    }
    dispatcher.Enqueue(job)
}

// Wait for all jobs to complete and collect results
results, errors := dispatcher.Wait()

fmt.Printf("Processed %d images\n", len(results))
if !errors.IsEmpty() {
    fmt.Printf("Encountered %d errors\n", len(errors.All()))
}
```

## Parallel Execution for Quick Tasks

Sometimes you don't need a full worker pool—you just want to run a few functions concurrently. The `Parallel` function is perfect for this:

```go
func FetchUserProfile(userID int) error {
    var user User
    var posts []Post
    var followers []User
    
    // Run multiple API calls in parallel
    errs := bigopool.Parallel(
        func() error {
            var err error
            user, err = api.GetUser(userID)
            return err
        },
        
        func() error {
            var err error
            posts, err = api.GetUserPosts(userID)
            return err
        },
        
        func() error {
            var err error
            followers, err = api.GetUserFollowers(userID)
            return err
        },
    )
    
    if !errs.IsEmpty() {
        return errs.ToError()
    }
    
    // All API calls completed successfully
    fmt.Printf("User: %s, Posts: %d, Followers: %d\n", 
        user.Name, len(posts), len(followers))
    
    return nil
}
```

## (Almost)Real-World Example: Web Scraper

Let's build a practical example—a web scraper that fetches multiple URLs concurrently:

```go
type WebScrapingJob struct {
    URL        string
    Timeout    time.Duration
    UserAgent  string
}

func (j WebScrapingJob) Execute() (bigopool.Result, error) {
    client := &http.Client{Timeout: j.Timeout}
    
    req, err := http.NewRequest("GET", j.URL, nil)
    if err != nil {
        return nil, err
    }
    
    req.Header.Set("User-Agent", j.UserAgent)
    
    resp, err := client.Do(req)
    if err != nil {
        return nil, fmt.Errorf("failed to fetch %s: %w", j.URL, err)
    }
    defer resp.Body.Close()
    
    body, err := ioutil.ReadAll(resp.Body)
    if err != nil {
        return nil, err
    }
    
    return WebScrapingResult{
        URL:        j.URL,
        StatusCode: resp.StatusCode,
        BodySize:   len(body),
        Content:    string(body),
        FetchedAt:  time.Now(),
    }, nil
}

type WebScrapingResult struct {
    URL        string
    StatusCode int
    BodySize   int
    Content    string
    FetchedAt  time.Time
}

func ScrapeWebsites(urls []string) {
    // Configure for 10 concurrent workers with a buffer queue of 500
    dispatcher, err := bigopool.NewDispatcher(10, 500)
    if err != nil {
        log.Fatal(err)
    }
    
    dispatcher.Run()
    
    // Enqueue all scraping jobs
    for _, url := range urls {
        job := WebScrapingJob{
            URL:       url,
            Timeout:   time.Second * 30,
            UserAgent: "bigopool-scraper/1.0",
        }
        dispatcher.Enqueue(job)
    }
    
    // Wait for completion
    results, errors := dispatcher.Wait()
    
    // Process results
    for _, result := range results {
        if scrapedData, ok := result.(WebScrapingResult); ok {
            fmt.Printf("✓ %s (%d bytes, status: %d)\n", 
                scrapedData.URL, scrapedData.BodySize, scrapedData.StatusCode)
        }
    }
    
    // Handle errors
    for _, err := range errors.All() {
        fmt.Printf("✗ Error: %v\n", err)
    }
}
```

## Performance and Benchmarks

One of the things I'm most proud of about `bigopool` is its performance. The library is designed to minimize allocations and overhead. Here are some benchmark results from a potato MacBook Pro from 2016:

```
Benchmark5Workers1000Queue    2190982    566 ns/op    98 B/op    0 allocs/op
Benchmark10Workers100Queue    2168791    559 ns/op    79 B/op    0 allocs/op
Benchmark20Workers200Queue    2159338    572 ns/op    80 B/op    0 allocs/op
```

These benchmarks show that `bigopool` can process jobs with sub-microsecond latency and minimal memory allocations, making it suitable for high-throughput applications.

## Advanced Features

### Cancelable Parallel Execution

For scenarios where you want to cancel remaining operations if one fails, use `CancelableParallel`:

```go
ctx := context.Background()
errs := bigopool.CancelableParallel(ctx,
    func(ctx context.Context) error {
        return criticalOperation1(ctx)
    },
    func(ctx context.Context) error {
        return criticalOperation2(ctx)
    },
    func(ctx context.Context) error {
        return criticalOperation3(ctx)
    },
)
```

If any operation fails, the context is canceled and remaining operations can detect this and exit early.

### Thread-Safe Error Handling

`bigopool` includes a thread-safe error collection mechanism. The `Errors` interface provides several useful methods:

```go
results, errors := dispatcher.Wait()

// Check if any errors occurred
if !errors.IsEmpty() {
    // Get all errors as a slice
    allErrors := errors.All()
    
    log.Printf("Processing failed with %d errors: %v", 
        len(allErrors), combinedError)
}
```

## Design Philosophy

When building `bigopool`, I focused on several key principles:

1. **Simplicity**: The API should be intuitive and require minimal boilerplate.  Note that the library won't automatically handle failed jobs but will let you know of them.
2. **Performance**: Zero allocations in the hot path where possible
3. **Safety**: Thread-safe by default with proper error handling. 
4. **Flexibility**: Support both worker pool and simple parallel execution patterns

The library intentionally keeps the interface minimal—you implement one method (`Execute()`) and the library handles the rest. 

## When to Use bigopool

I consider `bigopool` a good option for:

- **High-volume job processing**: Image processing, data transformation, API calls, batch processing all your users to build email message content
- **I/O-bound operations**: File processing, database operations, web scraping
- **Batch processing**: ETL jobs, report generation, bulk operations
- **Microservice communication**: Parallel API calls, data aggregation

It might be overkill for:

- **One-off parallel tasks**: Use regular goroutines
- **CPU-bound work with optimal worker count**: Consider `runtime.GOMAXPROCS(0)` workers
- **Real-time streaming**: Consider channels and select statements

## Conclusion

Building `bigopool` taught me a lot about Go's concurrency primitives and the importance of controlling resource usage in high-throughput applications. The library has been used in production systems processing dozens of millions of jobs, and I'm proud of how it balances simplicity with performance.

Try it out in your next project:

```bash
go get -u github.com/bigodines/bigopool
```

For more, visit bigopool's [GitHub](https://github.com/bigodines/bigopool). If you find a bug or have ideas for improvements, contributions are always welcome!

---

*If this library saves you time or helps with your project, I'd love to hear about it. You can find me on LinkedIn [@bigodines](https://linkedin.com/in/bigodines).*
