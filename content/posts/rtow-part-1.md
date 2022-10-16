---
title: "Ray Tracing in One Weekend - Disk I/O"
date: 2022-10-16T22:33:49+02:00
draft: false
description: "Outputting the first image"
tags: ["general-programming", "ray-tracing", "IO", "odin", "golang", "c++"]
---

Series index is [here](../rtow-part-0)

Let's start by writing the necessary code to output the following image:

![result image](/img/rtow-part-1-color.png)

## C++

Nothing to see here, I pretty much followed the code.

Time: 463.278ms

## Golang

Working with go using the vscode golang language extension was func, I didn't have to manage any imports at all the
extension did it for me, golang as a language is very fun to work with.

I really liked the untyped constants that can work with any variable type and it does the right thing. I also like that
go doesn't have debug/release builds. As advertised golang does the correct thing out of the box and buffers IO.

``` golang
func main() {
	start := time.Now()
	const image_width = 256
	const image_height = 256

	fmt.Printf("P3\n%v %v\n255\n", image_width, image_height)

	for j := image_height - 1; j >= 0; j-- {
		fmt.Fprintf(os.Stderr, "\rElapsed time: %v, ", time.Since(start))
		fmt.Fprintf(os.Stderr, "Scanlines remaining: %v ", j)
		for i := 0; i < image_width; i++ {
			r := float64(i) / (image_width - 1)
			g := float64(j) / (image_height - 1)
			b := 0.25

			ir := int(255.999 * r)
			ig := int(255.999 * g)
			ib := int(255.999 * b)

			fmt.Printf("%v %v %v\n", ir, ig, ib)
		}
	}

	fmt.Fprintf(os.Stderr, "\nDone.\n")
	fmt.Fprintf(os.Stderr, "Elapsed time: %v\n", time.Since(start))
}
```

Time: 459.9055ms

## Odin

Odin code is quite similar to Go's code, it even has the untyped constants, but Odin is a lower level language than Go
which means out of the box stdout/stderr writes wasn't fast but once I used the builtin `bufio.Writer` it soon became
as fast as Go and C++.

One thing to note here is how we manage the IO streams, just look at this line:
`io.to_writer(bufio.writer_to_stream(&buffered_stdout))`

I had to convert the `bufio.Writer` to `io.Stream` then convert that to `io.Writer` explicitly. I get that Odin doesn't
have interface system like Go and that adding a similar one will most likely require a garbage collector to handle
escaping pointers, but here me out a bit, Can we have a similar thing that only runs in compile time and for function
arguments only.

Most probably gingerbill (Odin designer) already thought this out and found design problems with this style. I don't
mind doing the conversion explicitly, it fits the language design more and it's similar to how I do polymorphic usage
in C.


```odin
main :: proc() {
	start := time.now()

	buffered_stdout: bufio.Writer
	bufio.writer_init(&buffered_stdout, io.to_writer(os.stream_from_handle(os.stdout)))
	defer {
		bufio.writer_flush(&buffered_stdout)
		bufio.writer_destroy(&buffered_stdout)
	}
	stdout := io.to_writer(bufio.writer_to_stream(&buffered_stdout))

	buffered_stderr: bufio.Writer
	bufio.writer_init(&buffered_stderr, io.to_writer(os.stream_from_handle(os.stderr)))
	defer {
		bufio.writer_flush(&buffered_stderr)
		bufio.writer_destroy(&buffered_stderr)
	}
	stderr := io.to_writer(bufio.writer_to_stream(&buffered_stderr))

	image_width :: 256
	image_height :: 256

	fmt.wprintf(stdout, "P3\n%v %v\n255\n", image_width, image_height)

	for j := image_height - 1; j >= 0; j -= 1 {
		fmt.wprintf(stderr, "\rElapsed time: %v ms, ", time.duration_milliseconds(time.since(start)))
		fmt.wprintf(stderr, "Scanlines remaining: %v", j)
		for i in 0..<image_width {
			r := f64(i) / (image_width - 1)
			g := f64(j) / (image_height - 1)
			b := 0.25

			ir := int(255.999 * r)
			ig := int(255.999 * g)
			ib := int(255.999 * b)

			fmt.wprintf(stdout, "%v %v %v\n", ir, ig, ib)
		}
	}

	fmt.wprintf(stderr, "\nDone.\n")
	fmt.wprintf(stderr, "Elapsed time: %v ms\n", time.duration_milliseconds(time.since(start)))
}
```

Time: 476.455ms
