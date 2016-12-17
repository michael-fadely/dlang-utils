module util.modifiable;

import std.string;
import std.traits;

enum Modifier;

struct Modifiable(_T)
{
	_T wrapped;
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
