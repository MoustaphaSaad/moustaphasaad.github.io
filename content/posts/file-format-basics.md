---
title: "File Format Basics"
date: 2022-02-15T23:44:49+02:00
draft: false
description: "Some notes on how to properly write a file format"
tags: ["general-programming", "IO"]
---

In the last couple of days I've needed to write a simple file format for assets in a toy engine of mine, here are some notes I have gathered about writing file formats.

I have binary and text files along these lines that i want to group into a single resources file
- `/font/my_font.ttf`
- `/image/logo.png`
- `/mesh/player.gltf`
- `/shader/vertex.glsl`

First of all we have to answer a set of questions to somewhat narrow the solution space.

### Will we need atomic transactions?
If you answer yes, then your best bet is `SQLite`, you can either use traditional database schemas and create a table for each object type you have, or if you just want a simple way to group multiple files in a single file like I do then you can create a single files table where you store file names and content just like so 

```sqlite
CREATE TABLE files(filename TEXT PRIMARY KEY, content BLOB);
```

In my case the answer is no, I don't need atomic transactions.

### Will we need our format to be human readable?
If you answer yes, then you can either use `JSON`, or `XML`, or `TOML`, or any human readable data encodings. You'll need to encode your binary blobs into a text friendly encoding like `base64` for example. In my experience you rarely need your files to be human readable because most users don't manipulate files by hand anyway.

In my case the answer is no, I don't need my format to be human readable.

### Is there an already existing convention for what we're trying to do?

If you answer yes, then you should probably follow the conventions. For example if we're using this data to communicate with network service, then `JSON` will probably be a better fit.

In my case there are no set conventions and it's an internal format to my toy engine anyway

### Our Solution
Given the answer to the above questions the simplest possible solution is to open a file and write your data into it. We open a binary file. write the file name, file size, and file content.

#### Primitives

First we need to define how to write the primitive types, in my case I chose to work with a single primitive type `uint64_t` (we have a lot of memory and disk space nowadays) we simply define it as an 8 byte unsigned integer written in little endian because most CPUs these days are little endian anyway so this way we can just `fwrite` our `uint64_t` directly in most platforms.

Then we go on and define how to write our composite types, In my case I only have one composite type `string` we simply define it as a count with `uint64_t` type followed by the null terminated file name bytes.

#### Conventions

We only have a single convention, all our offsets are measured from the start of the file, basically they are absolute positions in the file.

#### Structure

Now we can use our primitives to illustrate the structure of your file format.

- Magic number: `uint64_t`
- Version: `uint64_t`
- Header Offset: `uint64_t`
- Blobs: bytes
- Header entries count: `uint64_t`
- Header entries: array of
  - File name: string
  - File offset: `uint64_t`
  - File size: `uint64_t`

##### Magic number

A Magic number is a constant numerical or text value used to identify file formats. It's usually the first thing in the file. It's a nice thing to have in your file format especially when you know that some users/companies fiddle with file extensions. I have seen some programs writing `.dcm` files which are in fact are not `DICOMs`.

##### Version

A File format version. This is one of the most critical things to add to your format. It tracks the structure and representation of your files, and as your file format evolve you increment it and keep the old version code/support if you want backward compatibility. You use the version information to choose which read/write routines will you use with this file, in my case I have a switch statement, a virtual table (inheritance/polymorphism) will also work just as fine here.

```c++
switch (package.version)
{
case VERSION_1:
    if (auto err = _read_table_version_1(stream, package))
        return err;
    break;
default:
    return ERROR_UNSUPPORTED_VERSION;
}
```

##### Header Offset

Tells you where the header starts. We usually put the headers at the end of the file so that appending new data to the file doesn't move too many bytes around. We just read the header into memory, write the data, then rewrite the header after it.

##### Blobs

This is just the binary dump of files' content.

##### Header

Header is an array of files' description. We start with the count of files in this array followed by each file's information.

- File name: a string containing the name we use to refer to this file/blob
- File offset: offset from the start of the file (absolute position) of the file content blob
- File size: the size of this blob in bytes

#### Implementation

We preferred to have the implementation as easy as possible that's why we only have a single primitive type and a single composite type, which simplifies the implementation a lot, because now I only need 2 functions `_write_uint64_t` and `_write_string` which I then use in all the other functions.

File reading is equally simple, we open the file, seek to the header at the end of the file, read it and keep an in memory table for each blob/file, when the user asks to read any blob content we lookup its offset and size from the table using blob/file name, seek to it then read. It couldn't be any simpler.

Another good convention to have is to have your strings null terminated on disk. It's a nice quality of life improvement when working with this format using `C`, also it'll only cost you a single extra `null` byte.

You can stream blob's content by modelling your blob reading interface in a similar manner to disk files

```
Blob* package_blob_open(Package* p, const char* name);
size_t package_blob_read(Blob* blob, void* buffer, size_t buffer_size);
void package_blob_close(Blob* blob);
```

#### Pitfalls

The most famous pitfall in writing file formats is not including a version of the format, make sure you're always versioning all your formats no matter what, if you're using` SQLite` you should version your format, if you're using `JSON` you should version your format, and especially if you're using binary you should version your format.

Always use exact integer types when writing/reading to disk, don't use `size_t`, use `uint32_t` or `uint64_t`.

You should document every version of your format, least your can do is have a `Docs.h` along with your code to describe the format in.

As with any other piece of software you should always test your implementation against the documentation you've written, sadly I've seen many implementations release to production with bugs and they have to live with these bugs forever.
