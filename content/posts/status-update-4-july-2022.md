---
title: "Status Update, 4 July 2022"
date: 2022-07-05T00:21:25+02:00
draft: false
tags: ["updates"]
---

Hello, this was an even slower week :D. I only worked on taha and renoir this week.

In renoir news. I started working on making the compute example work on Metal backend. The compute example is a simple compute shader to increment 100 numbers in a GPU buffer. During that I found out that Metal's compute dispatch function needs the threads per thread-group count unlike OpenGL or DirectX which you can specify that size/count in the shader itself. `[numthreads(10, 1, 1)]` in HLSL, and `layout (local_size_x = 10) in;` in GLSL. This means that compute dispatch function in renoir sadly will need to be revisited.

In taha news. I improved the engine resource usage by using const values in tags feature and now you can bind whatever engine resource you want to any shader variable you want using tags. Here's how SSAO blur shader refers to its input and output textures
```golang
@image
@resource { name = taha.TEXTURE_DEFERRED_SSAO }
var deferred_ssao: Texture2D<float>;

@image
@resource { name = taha.TEXTURE_DEFERRED_SSAO_BLURRED }
var deferred_ssao_blurred: RWTexture2D<float>;
```
Note that `@resource` tag which is used to guide the engine automatic binding code. This should allow the user the flexibilty to use any type he wants, in this case I only need read access to ssao texture so I use `Texture2D` but I need read write access to ssao blurred texture so I use `RWTexture2D`.

That's it for this week.
Thanks for reading.