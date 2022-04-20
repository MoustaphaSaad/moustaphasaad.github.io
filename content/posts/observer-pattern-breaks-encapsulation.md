---
title: "Observer Pattern Pitfalls"
date: 2022-04-20T20:07:46+02:00
draft: false
description: "Why does observer pattern break encapsulation"
tags: ["general-programming", "design-patterns", "OOP"]
---

Observer pattern is one of the most popular "design patterns". It's also one of the most mis-used patterns out there.

I've seen a lot of observer patterns implementations and nearly all of them break encapsulation which is the most important principle in OOP.

Let's outline the most basic implementation of observer pattern given a toy problem of a `FooBar` with `foo` and `bar` properties and a report generator which observes this `FooBar` thing and regenerates the report whenever it's changed.

You'll usually find two interfaces, Observer and Observable defined in these terms
```Cpp
class Observer {
public:
	virtual ~Observer() = default;

	virtual void update(Event* event) = 0;
};

class Observable {
public:
	virtual ~Observable() = default;

	void addObserver(Observer* observer);
	void removeObserver(Observer* observer);
	void notify(Event* event);
}
```

The report generator simply implements the observer interface
```Cpp
class ReportGenerator: public Observer {
public:

	void update(Event* event) override
	{
		auto fooBar = event->getFooBar();
		auto ratio = fooBar->getFoo() / fooBar->getBar();
		log("foo to bar ratio is ", ratio);
	}
}
```

The `FooBar` implementation is equally simple
```Cpp
class FooBar: public Observable {
public:

	void setFoo(int foo)
	{
		if (mFoo == foo)
			return;
		mFoo = foo;
		notify(new Event{this});
	}

	void setBar(int bar)
	{
		if (mBar == bar)
			return;
		mBar = bar;
		notify(new Event{this});
	}
}
```

And viola you have a very basic observer pattern going. Everything looks good until you realize that you have broken the most important OOP rule, Encapsulation.

Encapsulation is all about grouping object's state/variables privately inside of it in a way which only allows the object itself to access it. This makes your only way to interact with such object is through its public interface/functions and regarding those encapsulation mandates that each public function should move said object from a valid state to a valid state, It's simply illegal for a public function to move an object to invalid state.

Given the above definition of encapsulation you can see why said implementation breaks it when you examine the code below

```Cpp
auto fooBar = new FooBar;
fooBar->setFoo(5); // observers are notified here
fooBar->setBar(3); // observers are notified here
```
You can see the problem that what i meant to do is to change both foo and bar but given the popular eager implementation of observer pattern, it gets notified twice and in one of them the observer observes our object in an intermediate, and potentially invalid state.

You can always fight with your team mates about what kind of API do you want to have, some people will argue that if you want change both foo and bar together then you should have a `setFooBar(foo, bar)` function which changes both values at once, I've seen and was part in such fights and it wasn't fun and it was always broken in subtle ways.

The other problem with the eager implementation is performance, because if you change foo 5 times you'll notify the observers 5 times and recalculate and override the value 5 times.
```Cpp
for (some complex loop)
	fooBar->setFoo(newFooValue); // each time this call is executed observers gets notified
```

So How can you fix these issues? usually the most effective and simple fix is to not notify the observers right away and simply cache the notification until the "function" is finished, usually this is done with the help of an event loop and you notify the observers when the control flow gets back to the event loop, the most famous implementation of this technique is of course Qt's QObject signal and slot system.

There's another solution but this is harder and I've seen a lot of people fail to do (for various reasons) is to stop sending fine grained notifications to observers, usually you're not really interested in a simple integer change like foo or bar you're concerned about some larger operation which will change foo or bar, so make your notification bigger and ban notifications for small objects, basically notifications should be only sent from entire systems only.

In conclusion, Make sure your never ever break encapsulation because I've seen/worked-on code bases where encapsulation was broken and it wasn't fun to work on and bug fixes were as ridiculous as changing order of setter function calls.
```Cpp
// broken code
fooBar->setFoo(1);
fooBar->setBar(2);
// fixed code
fooBar->setBar(2);
fooBar->setFoo(1);
```
I don't know about you but in my humble opinion this is bananas.