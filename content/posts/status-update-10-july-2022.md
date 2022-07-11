---
title: "Status Update, 10 July 2022"
date: 2022-07-12T00:23:43+02:00
draft: false
tags: ["updates"]
---

Hello, this week I started to ramp up the work.

In renoir news. I finished the compute work and this led to compute dispatch API change but as a bonus I got `example-compute` working on metal backend as well as the buffer read back.

In taha new. I started using the renoir compute API. I did the SSAO blur and SSAO pass itself in compute shaders. the SSAO part was pretty straightforward to do but I noticed a big speedup in compute compared to pixel shader.

In pixel shader the SSAO pass consumed 4ms but when I moved it to compute it went down to 0.002ms which is a huge speedup even though I didn't investigate it but I'll take it given that the compute shader is just a simple translation of the pixel shader.

That's it for this week.
Thanks for reading