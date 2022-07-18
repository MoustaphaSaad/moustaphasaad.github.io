---
title: "Status Update, 17 July 2022"
date: 2022-07-18T07:24:25+02:00
draft: false
tags: ["updates"]
---

Hello, This was a busy week.

In `mn` news. I fixed small crash in json parsing code which was crashing if a `nullptr` string was passed to it. And we have another small fix to an assertion in `virtual_free` windows implementation contributed by `3a2l`.

In `sabre` news. I started by updating the reflection information for uniform buffers by providing the aligned and unaligned size of the uniform buffers. Then came the support for instancing work, now sabre supports `@system_instance_id` tag and you can use this `uint` to index into an instancing data uniform buffer.

In `taha` news. I worked a bit on volume rendering. At first I did the usual single pass ray casting where you render a cube and shoot rays from these pixels in pixel shader. It's fine but in case you have a lot of empty space you do a lot of texture lookups and this makes the pixel shader take a lot more time. The more you don't see the more it costs to render.

To optimize the empty space you traverse till you get to the data you can subdivide the volume into a multiple of small cubes instead of a single cube and we just don't draw the empty one's this generated a lot of draw calls so I used instanced rendering which improved the performance of cube rendering and that also improved the performance of volume rendering because now we can skip empty space which means that the less we see the less time we consume in ray casting. That's a lot better.

One corner case that's not handled by the above optimization scheme is if you have a lot of empty space in the middle of your volume. The scheme above only removes empty space at the start of the ray `[empty space, data]` but you have `[data, empty space, data]` you don't get much benefit from that optimization scheme. Maybe I should write a blog post about it one day.

That's it for this week.
Thanks for reading.
