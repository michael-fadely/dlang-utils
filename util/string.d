module util.string;

import std.algorithm;
import std.array;
import std.regex;
import std.uni : isWhite;

string stripEscape(in string str, char escapeDelim = '\\')
{
	if (!canFind(str, escapeDelim))
		return str;

	Appender!string result;

	foreach (char c; str)
	{
		if (c == escapeDelim)
			continue;

		result.put(c);
	}

	return result.data;
}

// TODO: Rename
string[] ArgsToArray(in string str, bool allowEscape = true, char escapeDelim = '\\')
{
	Appender!(string[]) result;
	bool escape = false;
	bool quote = false;
	size_t start;

	if (str.length < 1)
		return result.data;

	for (size_t i = 0; i <= str.length; i++)
	{
		if (i == str.length)
		{
			if (allowEscape && escape)
				throw new Exception("Orphan escape character at end of string.");
			else if (quote)
				throw new Exception(`Unclosed substring (Expected closing '"', reached end of string).`);
			else
				result.put(stripEscape(str[start .. $], escapeDelim));

			break;
		}

		if (escape)
		{
			escape = false;
			continue;
		}

		char c = str[i];
		
		if (allowEscape && (escape = (c == escapeDelim)) == true)
			continue;
		
		if (!allowEscape || !escape)
		{
			if (c == '\"')
			{
				if ((quote = !quote) == false)
					result.put(stripEscape(str[start .. i], escapeDelim));

				start = i + 1;
			}
			else if (start == i)
			{
				if (isWhite(c))
					++start;
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

const char[] escape = [ '\\', '*', '+', '?', '[', ']', '{', '}', '(', ')', '.', '^', '$' ];
/// Escapes characters used for regular expression.
/// If no characters need escaping, the input string is returned.
string regexEscape(string str)
{
	if (str.all!(x => !escape.canFind(x)))
		return str;

	Appender!string result;
	foreach (c; str)
	{
		if (escape.canFind(c))
			result.put('\\');
		result.put(c);
	}
	return result.data;
}
/// Converts standard wildcard string containing * and/or ? to a regular expression sting.
/// If no conversion is required, the input string is returned.
string wildToRegex(string str)
{
	if (!str.canFind('*') && !str.canFind('?'))
		return str;

	auto result = str.regexEscape();
	result = result.replace(`\*`, `.*`).replace(`\?`, `.{1}`);
	return result;
}
/// Checks for pattern match in target.
bool match(string target, string pattern)
{
	auto regex_str = wildToRegex(pattern);
	if (regex_str == pattern)
		return target == pattern;

	auto r = regex(regex_str);
	auto m = matchAll(target, r);
	return !m.empty;
}
