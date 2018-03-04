# dlang-utils
Some common things I use in my D projects.

# Module Overview
## util.array
when `std.algorithm.searching` just won't do the job

## util.modifiable
Contains a template structure `Modifiable!YourType` that raises a flag when the value of members marked with the `@Modifier` attribute in your structure have changed. The field `bool modified;` indicates the modified state of your structure. This can be useful, for example, to determine when to serialize a structure to disk.

## util.sizesuffix
### `sizeSuffix`
Takes an input "size" in bytes and returns a size-suffix string. e.g `sizeSuffix(1024)` returns the string `1.00 KB`.

## util.string
### `wildToRegex`
Converts your typical wildcard pattern string (containing `*` for any-character match, and `?` for single-character match) into a regular expression.

### `match`
Checks for a wildcard match in the target by converting the pattern to a regular expression using `wildToRegex`, and then running `std.regex.matchAll` on the target.

### `argsToArray` (needs renaming)
Converts a string into an array of strings split by space, except where escape characters are concerned.

For example, this string:

`` `This is my string "with \"substring\"" and\ escape\ characters` ``

becomes this array:

`` [ `This`, `is`, `my`, `string`, `with "substring"`, `and escape characters` ]``
