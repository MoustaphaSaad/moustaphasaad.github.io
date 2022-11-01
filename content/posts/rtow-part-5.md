---
title: "Ray Tracing in One Weekend - Hittable Abstraction"
date: 2022-11-01T23:26:43+02:00
draft: false
description: "Abstracting away a hittable object in 3 different programming languages"
tags: ["general-programming", "ray-tracing", "abstraction", "interfaces", "inheritance, "odin", "golang", "c++"]
---

Series index is [here](../rtow-part-0)

Today we are working on abstracting away what a hittable object is, and we are using that to add another object to our scene, The floor plane.

![result image](/img/rtow-part-5-hittable-abstraction.png)

## C++

In C++ we abstract things by using the inheritance that's why we added an abstract base class called `hittable`

```C++
class hittable
{
public:
	virtual bool hit(const ray& r, double t_min, double t_max, hit_record& rec) const = 0;
};
```

Then we have 2 implementations so far. The first is `sphere` which is pretty much straightforward we simply copied our ray_sphere implementation and wrapped it in a class.

The more interesting one is the `hittable_list` implementation we decided to represent a list of hittable objects using `vector<shared_ptr<hittable>>` and here we are using `shared_ptr` because we want to have a list of "abstract things" or basically an interface so we have to put such implementations on the heap in order to be able to store different implementations in the same vector. This in turn forces us to manage the lifetime of such heap allocation and we do so using a shared_ptr. we could use a unique_ptr instead and it will work but the book itself used `shared_ptr` as it is easier to work with and won't introduce the reader to the concept of move constructors.

```C++
class hittable_list: public hittable {
public:
	hittable_list() {}
	hittable_list(shared_ptr<hittable> object) { add(object); }

	void clear() { objects.clear(); }
	void add(shared_ptr<hittable> object) { return objects.push_back(object); }

	virtual bool hit(const ray& r, double t_min, double t_max, hit_record& rec) const override
	{
		hit_record temp_rec;
		bool hit_anything = false;
		auto closest_so_far = t_max;

		for (const auto& object: objects)
		{
			if (object->hit(r, t_min, closest_so_far, temp_rec))
			{
				hit_anything = true;
				closest_so_far = temp_rec.t;
				rec = temp_rec;
			}
		}

		return hit_anything;
	}

	std::vector<shared_ptr<hittable>> objects;
};
```

Time: 270.4 ms ±   4.3 ms

## Golang

Golang shines here really. the `interface` feature is basically built for this kind of things and being garbage collected eliminated the worry about managing the heap allocations.

```golang
type Hittable interface {
	Hit(r Ray, tMin, tMax float64) (HitRecord, bool)
}
```

Note that we used multiple return values here instead of passing an output parameter by reference and writing into it, this feature is also better in my opinion than C++'s pass by reference style.

The hittable list is simply a typedef of a slice at this point, with a very simple implementation for the `Hit` function
```golang
type HittableList []Hittable

func (list HittableList) Hit(r Ray, tMin, tMax float64) (rec HitRecord, hit bool) {
	hit = false
	closestSoFar := tMax

	for _, v := range list {
		if v_rec, v_hit := v.Hit(r, tMin, closestSoFar); v_hit {
			hit = true
			closestSoFar = v_rec.T
			rec = v_rec
		}
	}

	return
}
```

Time: 707.3 ms ±  14.3 ms

## Odin

Odin is really the odd one out here, it doesn't have smart pointers like C++ nor is it garbage collected like Golang. But in my opinion Odin solution is equally interesting in Odin you basically have to write what Golang's does for you by hand, let's take a look at `Hittable`

```odin
Hittable :: struct {
	using vtable: ^Hittable_VTable,
	data: rawptr,
}
Hittable_VTable :: struct {
	hit: proc(self: Hittable, r: Ray, t_min, t_max: f64) -> (HitRecord, bool),
}
```

As you can see `Hittable` is 2 pointers (just like Golang's interface) one for the data/object/instance and the other for the virtual table (I think golang's calls it witness table) which contains function pointers for the implementation for that object/instance.

This might be a bit manual and tedious but it gives you access to the underlying details of how the abstractions work.

The most unique aspect of Odin approach so far is that abstraction and object storage is completely orthogonal/decoupled this means that I don't need to put/allocate my spheres on the heap in the first place they can live on the stack so long as they are wrapped in a `Hittable` struct instance and they live long enough for their usage I'm okay. So the main difference here is Odin's `HittableList` doesn't have to "own" its members unlike C++ and Golang.

Let's have a look at `HittableList` then
```odin
HittableList :: []Hittable

hittable_list_hit :: proc(self: HittableList, r: Ray, t_min, t_max: f64) -> (rec: HitRecord, hit: bool) {
	hit = false
	closest_so_far := t_max

	for v in self {
		if v_rec, v_hit := v->hit(r, t_min, t_max); v_hit {
			hit = true
			closest_so_far = v_rec.t
			rec = v_rec
		}
	}

	return
}

hittable_list_to_hittable :: proc(self: ^HittableList) -> Hittable {
	return Hittable {
		data = self,
		vtable = &_hittable_list_vtable,
	}
}

_hittable_list_vtable := Hittable_VTable {
	hit = proc(self: Hittable, r: Ray, t_min, t_max: f64) -> (HitRecord, bool) {
		list := (^HittableList)(self.data)
		return hittable_list_hit(list^, r, t_min, t_max)
	},
}
```

Note the `xxxxx_to_hittable` functions they basically are helper functions, they wrap the given object in a `Hittable` struct so that you can use it polymorphically (in an abstract way), and as we have said earlier `Hittable` struct becomes transient and it doesn't live for long or own anything really.

Time: 652.0 ms ±  10.4 ms

## Conclusion
This chapter was very fun to work through because as you can see every language has its own way to work with type polymorphically, I really like the Golang's style and prefer Odin's style over C++ because it decouples objects storage and abstractions.