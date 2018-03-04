module util.string;

import std.algorithm;
import std.array;
import std.conv : to;
import std.regex;
import std.uni : isWhite;

/**
	Strips escape characters from the given string.

	Params:
		str = The string to be stripped.
		escapeDelim = Optional escape delimiter. Defaults to '\'.

	Returns:
		If no escape characters are present, the input string is returned.
		Otherwise, a stripped copy is returned.
*/
@safe string stripEscape(in string str, char escapeDelim = '\\')
{
	if (!canFind(str, escapeDelim))
	{
		return str;
	}

	return to!string(str.filter!(c => c != escapeDelim));
}

// TODO: Rename
@safe string[] argsToArray(in string str, bool allowEscape = true, char escapeDelim = '\\')
{
	Appender!(string[]) result;

	bool escape, quote;
	size_t start;

	if (str.length < 1)
	{
		return result.data;
	}

	for (size_t i; i <= str.length; i++)
	{
		if (i == str.length)
		{
			if (allowEscape && escape)
			{
				throw new Exception("Orphan escape character at end of string.");
			}
			else if (quote)
			{
				throw new Exception(`Unclosed substring (Expected closing '"', reached end of string).`);
			}
			else
			{
				result.put(stripEscape(str[start .. $], escapeDelim));
			}

			break;
		}

		if (escape)
		{
			escape = false;
			continue;
		}

		auto c = str[i];

		if (allowEscape && (escape = (c == escapeDelim)) == true)
		{
			continue;
		}

		if (!allowEscape || !escape)
		{
			if (c == '"')
			{
				if ((quote = !quote) == false)
				{
					result.put(stripEscape(str[start .. i], escapeDelim));
				}

				start = i + 1;
			}
			else if (start == i)
			{
				if (isWhite(c))
				{
					++start;
				}
			}
			else if (!quote && isWhite(c))
			{
				result.put(stripEscape(str[start .. i], escapeDelim));
				start = i + 1;
			}
		}
	}

	return result.data;
}
///
unittest
{
	string[] result = argsToArray(`This is my string "with \"substring\"" and\ escape\ characters`);
	
	assert(result.length == 6);
	assert(result == ["This", "is", "my", "string", "with \"substring\"", "and escape characters"]);

	result = argsToArray(`This\ is\ a\ whole\ string`);
	assert(result.length == 1);
	assert(result == ["This is a whole string"]);
}

/**
	Converts standard wildcard string containing * and/or ? to a regular expression sting.

	Params:
		str = The string to be converted.

	Returns:
		A copy of the input string.
		If no conversion is required, the input string is returned.
*/
@safe string wildToRegex(string str)
{
	if (!str.canFind('*') && !str.canFind('?'))
	{
		return str;
	}

	auto result = to!string(escaper(str));
	result = result.replace(`\*`, `.*`).replace(`\?`, `.{1}`);
	return result;
}

/**
	Checks `target` for the matching wildcard string in `pattern`.

	Params:
		target = The string to search.
		pattern = The wildcard pattern to search for in `target`.

	Returns:
		`true` if a match has been found.
*/
@safe bool match(string target, string pattern)
{
	auto regexString = wildToRegex(pattern);

	if (regexString == pattern)
	{
		return target == pattern;
	}

	auto r = regex(regexString);
	auto m = matchAll(target, r);
	return !m.empty;
}
///
unittest
{
	string a = "Neko?sama@402AF8.*.235237";
	string b = "Neko-sama@402AF8.ECFE3D.3E8072.235237";
	assert(b.match(a));
	assert(b.match(b));
}
