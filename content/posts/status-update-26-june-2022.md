---
title: "Status Update, 26 June 2022"
date: 2022-06-26T23:54:54+02:00
draft: false
tags: ["updates"]
---

Hello, this was a slow week with some maintaince work across my different pet projects.

This week in mn (my std library replacement) I fixed bug in memory arena checkpoints and fixed a false positive in the fast memory leak detector.

In renoir (graphics abstraction layer) I discovered that D3D11 timers implementations doesn't work on my AMD laptop, so I fixed timer's `D3D11Query`s.

In sabre (shader programming language compiler) I discovered a bug in release mode where type formatting function doesn't return in all code paths. I also ran address sanitizer on unittests and I found no issues. I also fixed compute shader's images and buffers auto binding points assignment because in metal images and textures share the same binding points, and the same happens to buffers and uniforms.

In taha (my rendering engine), I managed to made the SSAO blur to use compute shader instead of pixel shader which simplified the usage on the C++ and simplified the blur shader itself. While working on that task I noticed that making read only images read write makes the blur pass take 0.8-1.0ms instead of 0.2ms when the correct access permission is used. I also did a bit of maintenance work and removed the old rendering API.

That's it for this week.
Thanks for reading.