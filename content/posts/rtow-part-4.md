---
title: "Ray Tracing in One Weekend - First Sphere"
date: 2022-10-25T21:24:47+02:00
draft: false
description: "Tracing the first solid sphere"
tags: ["general-programming", "ray-tracing", "math", "odin", "golang", "c++"]
---

Series index is [here](../rtow-part-0)

Today we are going to trace our first sphere ever, It won't be pretty but we will work on its looks later.

![result image](/img/rtow-part-4-sphere.png)

## C++

This time the code is nearly identical in all languages because it's a simple function evaluating a simple equation of the sphere.

```cpp
bool hit_sphere(const point3& center, double radius, const ray& r)
{
	auto a = dot(r.direction(), r.direction());
	auto oc = r.origin() - center;
	auto b = 2 * dot(r.direction(), oc);
	auto c = dot(oc, oc) - radius * radius;

	auto discriminant = b * b - 4*a*c;
	return discriminant > 0;
}
```

Time: 253.1 ms ±   8.3 ms

## Golang

Golang's lack of operator overloading makes the code look a bit more clumsy than C++ but it's not a deal breaker at least for me.

```golang
func hitSphere(center Point3, radius float64, r Ray) bool {
	a := r.Dir.Dot(r.Dir)
	oc := r.Orig.Sub(center)
	b := 2 * oc.Dot(r.Dir)
	c := oc.Dot(oc) - radius * radius
	discriminant := b * b - 4 * a * c
	return discriminant > 0
}
```

Time: 596.3 ms ±   8.8 ms

## Odin

Odin's array programming shines here and makes the code nearly identical to C++ without using operator overloads

```odin
hit_sphere :: proc(center: Point3, radius: f64, r: Ray) -> bool {
	a := linalg.dot(r.Dir, r.Dir)
	oc := r.Orig - center
	b := 2 * linalg.dot(oc, r.Dir)
	c := linalg.dot(oc, oc) - radius * radius
	discriminant := b * b - 4 * a * c
	return discriminant > 0
}
```

Time: 587.3 ms ±   5.8 ms

## Conclusion

Looks like Odin's bet on array programming paid out, but I don't really mind golang's methods they might seem clumsy but I can handle it.