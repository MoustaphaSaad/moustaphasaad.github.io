---
title: "Interfaces as Data"
date: 2022-02-26T20:57:09+02:00
draft: false
description: "Introducing the case for building interfaces around data instead of code"
tags: ["design", "OOP"]
---

Most of the software engineers I've met put a lot of emphasis on what I call grand design. Every project should have an over-arching plan behind it, and if it doesn't have one then your solution is not "well-designed".

Over the last couple of years I've came to realise that this is not really true, and the most important design principals are really too simple and straight-forward to the degree that it might seem obvious, But sadly most people don't pay attention to them because they are not as flashy as the complex monstrosities which developers usually work with.

One of those important design principals is to construct your interfaces around data instead of code. To illustrate this point we'll inspect some fictional problem that's usually used in this kind of settings. First we'll go through this problem using the traditional OOP (`C++`, `Java`) methods which rely heavily on building the interfaces around code, Then we'll see how this can be simplified by using data interfaces.

## Simplest OOP Solution

Our problem is as simple as it gets. We get data from some source (might be disk, network, database, etc...), Do some processing on the data, Then report the results to user.

```Cpp
class CDataProcessor
{
public:
	void GetData();
	void Process();
	void PrintResult();
private:
	...
};

int main()
{
	CDataProcessor p{};
	p.GetData();
	p.Process();
	p.PrintResult();
}
```

It's not the best of code, Yet it's not the worst either. Most traditional (`C++`, `Java`) OOP Developers will say that this implementation has the following problems:
- `CDataProcessor` has too many responsibilities, We can't reuse the algorithm in other applications.
- The Processing is coupled with data retrieval and result reporting code.

## Single Responsibility Per Class

First we'll put different responsibilities in different classes, which means we'll end up with 3 classes:
- `CFileProvider`: retrieves the data from a file.
- `CDataProcessing`: does the data processing part.
- `CResultReporting`: reports the result to an output file.

Now our classes are easy to understand, maintain, and reuse.

## Going Up The Tower Of Abstractions

What happens if our data is in a database rather than a file? In the last iteration our application is highly coupled with data being in a file. To fix this problem we'll need to abstract the data retrieval code into its own interfaces.

```Cpp
class IDataProvider
{
public:
	void GetData();
protected:
	virtual void GetDataFromImpl() = 0;
};

class CFileProvider: public IDataProvider
{
protected:
	void GetDataFromImpl() override;
};
```

The same design can be used for data processing and result reporting.

```Cpp
class IDataProcessor
{
public:
	void Process();
protected:
	virtual void ProcessImpl() = 0;
};

class CDataProcessing: public IDataProcessor
{
protected:
	void ProcessImpl() override;
};

class IReportResult
{
public:
	void ReportResult();
protected:
	virtual void ReportResultImpl() = 0;
};

class CResultReporting: public IReportResult
{
protected:
	void ReportResultImpl() override;
};
```

Now that we have abstracted all of our operations we can mix and match different classes together so long as they implement our interfaces. This is going to be the best data processing application ever.

## Queue in the Factories

In the last design iteration the creation of our concrete classes was done manually in the main function, We can put that in a factory class so that such logic be isolated. Now we only work with the abstract interfaces in the main function.

The orchestration between all of our classes is also done manually in the main function, We can isolate this into a controller class which uses the factory to construct the instances then it uses them.

```Cpp
class CFactory
{
public:
	auto GetInstances();
};

class CController
{
public:
	void Start()
	{
		CFactory f{};
		auto [provider, processor, reporter] = f.GetInstance();
		provider->GetData();
		processor->Process();
		reporter->ReportResult();
		...
	}
};
```

After all this awesome design refactoring work our application became flexible, we can get the data from different sources (files, network, databases, etc...), we can have many processing algorithms, and we can report to different outputs (console, files, network, etc...).

## Data Interfaces

In data interfaces we put more emphasis on data description/definition. In our new world data are just data they don't have behaviors.

```Cpp
struct Raw_Data
{
	std::vector<Entry> entries;
};

struct Processed_Data
{
	std::vector<Algo_Data> data_about_each_entry;
};
```

Now how will we load such data from disk?, We'll use good old functions.

```Cpp
// loads the data from the given file on disk
Raw_Data load_data_from_disk(std::string_view filename);
// processes the given raw data and outputs the equivalent processed data
Processed_Data process_data_using_algorithm_1(const Raw_Data& raw_data);
// report results to disk file
void report_result_to_disk(const Processed_Data& processed_data, std::string_view filename);
```

Our implementation is simple so far, But what about loading the data from different sources, like a database for example?. We use functions, again.

```Cpp
// extracts the relevant data from the given database connection
Raw_Data load_data_from_database(const Database& db);
// downloads the data from the given URL
Raw_Data load_data_from_network(const Url& url);
```

But how are we going to use such thing in our main function?

```Cpp
int main()
{
	auto raw_data = load_data_from_database(db);
	auto processed_data = process_data_using_algorithm_1(raw_data);
	report_result_to_disk(processed_data, output_file);
}
```

As we can see it doesn't get any simpler than this. Some of you would say "yeah, sure this will work if your data, and processing is trivial, my data is huge and I want to stream it", Don't worry my friend I got you.

## Streaming Huge Data

We use functions, again, you get the theme at this point. But this time we want to save the streaming state between function calls, so we use structs.

```Cpp
struct Streamed_Raw_Data
{
	Raw_Data loaded_raw_data;
	Database* db;
	...;
};

// starts the data streaming from a database
Streamed_Raw_Data start_raw_data_streaming(Database* db, size_t entry_limit);
// advances to the next streaming chunk if one exists
// returns the number of entries loaded in the given streamed raw data instance
size_t load_next_chunk(Streamed_Raw_Data& raw_data);
```

Voila, We can now stream our huge data easily. Note how we just reuse the same data type `Raw_Data` inside of `Streamed_Raw_Data` so that it can work nicely with our processing functions, after all our interface is the data itself so we have to keep it consistent to make our new streaming scheme compatible with our old code.

## Conclusion

Interfaces as code is a very bad idea because it couples a lot of code across different concerns together, This is not healthy for your project for the simple reason that it will slow you down a lot when you eventually need to refactor the code. And No, You'll need to refactor even the most perfect design if only to meet new business goals. The only constant thing in this universe is things change. Anything that doesn't take this simple principal into consideration is flawed.

Once I embraced such principal, It felt liberating, I only need to worry about representing the essential data to my problem and focus on writing the application logic. An Extra benefit I found is that it made my code easier to test, after all my data is the interface so the only thing i need to do is to verify that the output data is correct and I'm good to go. I don't need all the usual "mocking" classes and the complicated testing setups.
