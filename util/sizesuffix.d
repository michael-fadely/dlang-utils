module util.sizesuffix;

import std.math;
import std.format : format;

private static immutable string[] suffixes = [ "B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB" ];

/// Takes an input size in bytes and returns a size-suffix string.
@safe string sizeSuffix(size_t value)
{
	if (value < 0)
	{
		return "-" ~ sizeSuffix(-value);
	} 

	if (value < 1024)
	{
		return format!("%u %s")(value, suffixes[0]);
	}

	int i;
	real dValue = cast(real)value;
	while (floor(dValue / cast(real)1024) >= 1)
	{
		dValue /= cast(real)1024;
		i++;
	}

	return format!("%0.2f%s")(dValue, suffixes[i]);
}
///
unittest
{
	string str;

	str = sizeSuffix(100);
	assert(str == "100 B");

	str = sizeSuffix(1024);
	assert(str == "1.00 KB");

	str = sizeSuffix(1024 * 1024);
	assert(str == "1.00 MB");

	str = sizeSuffix(1024 * 1024 * 1024);
	assert(str == "1.00 GB");

	str = sizeSuffix(7_864_320);
	assert(str == "7.50 GB");
}
