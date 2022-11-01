---
title: "Ray Tracing in One Weekend - Antialiasing"
date: 2022-11-02T00:34:42+02:00
draft: false
description: "Sampling many rays per pixel to achieve antialiasing"
tags: ["general-programming", "ray-tracing", "antialiasing", "multi-sampling", "odin", "golang", "c++"]
---

Series index is [here](../rtow-part-6)

Today we will be adding antialiasing which will add a lot of samples per pixel and will increase the ray tracing time significantly but will result in a better image.

You will see that in this chapter the cost of ray tracing will rise a lot and it will dwarf the IO cost, that was the main reason why I didn't pay a lot of attention to the IO cost earlier.

![result image](/img/rtow-part-6-antialiasing.png)

## C++

Nothing to see here we just added 100 sample per pixel just like in the book.

Time: 2.280 s ±  0.031 s

## Golang

Nothing of note here as well we just added the antialiasing loop to sample 100 sample per pixel.

Time: 7.551 s ±  0.110 s

## Odin

Same thing here we just added sampling loop to sample 100 sample per pixel.

Time: 4.572 s ±  0.041 s

## Conclusion

After adding antialiasing we see a big jump in raytracing time, we will not be working on optimizing anything until we finish the book. The thing of note here is that starting with this chapter we can see a difference between Golang and Odin performance this is in line with my expectation when I started the series, C++ will be the fastest, Golang will be the slowest, and Odin will be somewhere in the middle.
