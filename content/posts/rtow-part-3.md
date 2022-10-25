---
title: "Ray Tracing in One Weekend - Sky"
date: 2022-10-25T20:55:52+02:00
draft: false
description: "Creating the ray type and using it for the first time"
tags: ["general-programming", "ray-tracing", "math", "odin", "golang", "c++"]
---

Series index is [here](../rtow-part-0)

Today we are going to work on the ray math type and using it for the first time to render the background.

![result image](/img/rtow-part-3-sky.png)

Note: I started using [hyperfine](https://github.com/sharkdp/hyperfine) to benchmark the time on my AMD 4700u laptop

## C++

The C++ implementation is a simple class that wraps the origin point of the ray and the direction.

Even though the author uses classes he puts everything as public so I don't really get the point of using classes at this point.

Time: 251.8 ms ±   2.0 ms

## Golang

Golang implementation was quite straightforward, I chose to make everything public just like the C++ class, and because of Go I didn't have to write boilerplate code

```golang
type Ray struct {
	Orig Point3
	Dir  Vec3
}

func (r Ray) At(t float64) Point3 {
	return r.Orig.Add(r.Dir.Mul(t))
}
```

Time: 591.5 ms ±   9.6 ms

## Odin

Odin implementation was similar to Golang, No boilerplate whatsoever, simple and straight to the point.

```odin
Ray :: struct {
	Orig: Point3,
	Dir:  Vec3,
}

ray_at :: proc(r: Ray, t: f64) -> Point3 {
	return r.Orig + r.Dir * t
}
```

Time: 575.5 ms ±   4.3 ms

## Conclusion

I like how lean Golang and Odin are, they both allow me to focus on the problem at hand unlike C++.

What surprised me a lot was how close Odin and Golang in performance!, maybe this is the case because our workload is dominated with output image IO we are not doing any serious ray tracing so far.

That's all folks.
