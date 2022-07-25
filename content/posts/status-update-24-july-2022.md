---
title: "Status Update, 24 July 2022"
date: 2022-07-25T22:34:19+02:00
draft: false
tags: ["updates"]
---

Hello, This week I did a bunch of bug fixes

In `sabre` I started by fixing an issue in compute buffers indexing where we were generating the indexing code multiple times in incorrect places.


Basically we were generating the following code
```golang
func traverse() {
	var index = 0;
	for var d = 0; d < 4; ++d {
		var first_child_index = flat_octree_child_of(index);
		for var i = 0; i < 8; ++i {
			var node = tree.nodes[i + first_child_index];
		}
	}
}
```

As if it was this code. Which is clearly incorrect
```golang
func traverse() {
	var index = 0;
	var node = tree.nodes[i + first_child_index];
	for var d = 0; d < 4; ++d {
		var first_child_index = flat_octree_child_of(index);
		for var i = 0; i < 8; ++i {
			var node = tree.nodes[i + first_child_index];
		}
	}
}
```

I also fixed an issue where we failed to load any values that's larger than 16 byte from a compute buffer.

Then I worked on fixing a bug in HLSL code generation. After making our texture types templated we had the wrong assumption that we'd only get a single level of instantiation when it comes to textures `Texture2D<vec4> (child) -> Texture2D<T> (parent)` but this is not correct because of the way we structured type instantiations to support partial template instantiations. It was a tough bug to diagnose but the fix was fairly simple.

In `taha` I fixed an old bug where the engine was crashing on shutdown because of how engine resources are managed. We simply were double freeing a resource. This was fixed by freeing the resources in the correct order. This was also a simple fix.

That's it for this week.
Thanks for reading.
