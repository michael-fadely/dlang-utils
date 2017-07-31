module util.modifiable;

import std.string;
import std.traits;

/// Modifier attribute.
/// structure members with this attribute will raise
/// the `Modifiable.modified` flag upon change.
enum Modifier;

/**
	A wrapper structure that raises a flag when the value of members marked with the `@Modifier`
	attribute in your structure have changed. The field `bool modified;` indicates the modified
	state of your structure.

	This can be useful, for example, to determine when to serialize a structure to disk.

	Params:
		_T = Your structure type.
*/
struct Modifiable(_T)
{
	/// Wrapped data of type `_T`.
	_T wrapped;
	/// Indicates the modified state of any of the members of `_T`.
	bool modified;

	@property auto opDispatch(string name)()
	{
		return mixin("wrapped." ~ name);
	}

	@property auto opDispatch(string name, T)(T value)
	{
		version (unittest) pragma(msg, "wrapping: " ~ name);

		static if (hasUDA!(mixin("_T." ~ name), Modifier))
		{
			mixin(format(
					`if (!modified && wrapped.%s != value)
					{
						modified = true;
					}`, name));
		}

		mixin(`return wrapped.` ~ name ~ ` = value;`);
	}

	auto opDispatch(string name, Args...)(Args args)
	{
		version (unittest) pragma(msg, "wrapping: " ~ name);

		static if (args.length)
		{
			static if (is(ReturnType!(mixin("_T." ~ name)) == void))
			{
				mixin(`wrapped.` ~ name ~ `(args);`);
			}
			else
			{
				mixin(`return wrapped.` ~ name ~ `(args);`);
			}
		}
		else
		{
			static if (is(ReturnType!(mixin("_T." ~ name)) == void))
			{
				mixin(`wrapped.` ~ name ~ `;`);
			}
			else
			{
				mixin(`return wrapped.` ~ name ~ `;`);
			}
		}
	}
}
///
unittest
{
	import std.algorithm : remove;

	struct Test
	{
		@Modifier
		{
			int a, b;
			string[string] map;
			string[] strings;
		}

		int c;
		int _d;
		@property @Modifier
		{
			auto d() { return _d; }
			void d(int value) { _d = value; }
		}
		int func(int one, int two, int three) { return one + two + three; }
		void c_modifier() { c = 1; }
	}

	Modifiable!Test test;
	assert(!test.modified);

	test.map["hi"] = "hello";
	assert(!test.modified);
	test.map = [ "a": "b" ];
	assert(test.modified);
	test.modified = false;

	test.strings = [ "hi", "this", "is", "a", "test", "hi" ];
	assert(test.modified);
	test.modified = false;

	test.strings = test.strings.remove!(x => x == "hi");
	assert(test.modified);
	test.modified = false;

	test.a = 0;
	assert(!test.modified);

	test.b = 0;
	assert(!test.modified);

	test.c = 0;
	assert(!test.modified);

	test.c = 1;
	assert(!test.modified);

	test.a = 1;
	assert(test.modified);
	test.b = 1;
	assert(test.modified);

	test.modified = false;

	test.d = 1000;
	const d = test.d;
	assert(d == 1000 && test.modified);
	assert(test.func(1, 2, 3) == 6);
	test.c_modifier();
}
