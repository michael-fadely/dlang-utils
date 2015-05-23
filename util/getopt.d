module util.getopt;

public import std.getopt;

import std.array : Appender, empty;
import std.stdio : stdout;

string optionAsString(in Option option)
{
	Appender!string result;

	if (!option.optShort.empty)
	{
		result.put(option.optShort);
		if (!option.optLong.empty)
		{
			result.put(", ");
			result.put(option.optLong);
		}
	}
	else if (!option.optLong.empty)
	{
		result.put(option.optLong);
	}

	return result.data;
}

void printOptions(in Option[] options)
{
	size_t max_len;
	Appender!(string[]) option_strings;

	foreach (option; options)
	{
		auto str = option.optionAsString();
		if (str.length > max_len)
			max_len = str.length;
		option_strings.put(str);
	}

	++max_len;

	foreach (i, option; options)
	{
		stdout.writefln("%-*s %s", max_len, option_strings.data[i], option.help);
	}
}
