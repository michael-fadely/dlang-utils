module util.sizesuffix;

import std.math;
import std.string : format;

private static const string[] suffixes = [ "bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB" ];

@safe string sizeSuffix(size_t value)
{
	if (value < 0)
	{
		return "-" ~ sizeSuffix(-value);
	} 

	if (value < 1024)
	{
		return format("%u %s", value, suffixes[0]);
	}

	int i;
	real dValue = cast(real)value;
	while (floor(dValue / cast(real)1024) >= 1)
	{
		dValue /= cast(real)1024;
		i++;
	}

	return format("%0.2f%s", dValue, suffixes[i]);
}
