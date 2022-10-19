---
title: "Ray Tracing in One Weekend - Vec3"
date: 2022-10-19T21:01:39+02:00
draft: false
description: "Vec3 math type"
tags: ["general-programming", "ray-tracing", "math", "odin", "golang", "c++"]
---

Series index is [here](../rtow-part-0)

Today we are going to work on the main math type `Vec3`

## C++

As usual in C++ we end up with a class and some operator overloading to do the math with.

Time: 444ms

## Golang

Golang doesn't have a language support for operator/function overloading so I went with a simple struct and method functions, it's not as fancy as C++'s operator overloading but it gets the job done and it feels uniform and fits with other language decisions.

```golang
type Vec3 struct {
	E [3]float64
}

func (v Vec3) Add(u Vec3) (res Vec3) {
	res.E[0] = v.E[0] + u.E[0]
	res.E[1] = v.E[1] + u.E[1]
	res.E[2] = v.E[2] + u.E[2]
	return
}

func (v Vec3) Dot(u Vec3) float64 {
	return u.E[0] * v.E[0] + u.E[1] * v.E[1] + u.E[2] * v.E[2]
}

func (v Vec3) Cross(u Vec3) (res Vec3) {
	res.E[0] = u.E[1] * v.E[2] - u.E[2] * v.E[1]
	res.E[1] = u.E[2] * v.E[0] - u.E[0] * v.E[2]
	res.E[2] = u.E[0] * v.E[1] - u.E[1] * v.E[0]
	return
}

...
```

Time: 485ms

## Odin

Odin is different than the other 2 languages, Odin has builtin support for vector types so I didn't have to do much actually, it even has shader like swizzling!

Odin also has quaternion and linear algebra functions in the standard library via `import "core:math/linalg"`

```odin
Vec3 :: [3]f64
Color :: distinct Vec3
Point3 :: distinct Vec3

write_color :: proc(out: io.Writer, c: Color) {
	fmt.wprintf(
		out,
		"%v %v %v\n",
		int(255.999 * c[0]),
		int(255.999 * c[1]),
		int(255.999 * c[2]),
	)
}
```

Time: 468ms

## Conclusion

I really like Odin's builtin math types, it feels like writing shader code which is very nice for graphics work loads.

I don't mind Go either it fits the whole language design and so far it didn't cause any signficant performance decrease maybe that's because of Go value semantics.

That's all folks.
