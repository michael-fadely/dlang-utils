module util.unittests;

version (unittest)
{
	void main()
	{
		import std.stdio;
		stdout.writeln("unittest complete, press enter to exit");
		stdin.readln();
	}

	unittest
	{
		import util.string : ArgsToArray;

		string[] result = ArgsToArray(`This is my string "with \"substring\"" and\ escape\ characters`);
		
		assert(result.length == 6);
		assert(result == ["This", "is", "my", "string", "with \"substring\"", "and escape characters"]);

		result = ArgsToArray(`This\ is\ a\ whole\ string`);
		assert(result.length == 1);
		assert(result == ["This is a whole string"]);
	}

	unittest
	{
		import util.string;

		string a = "Neko?sama@402AF8.*.235237";
		string b = "Neko-sama@402AF8.ECFE3D.3E8072.235237";
		assert(b.match(a));
		assert(b.match(b));

		string no_escape = "this doesn't need escaping";
		assert(no_escape.regexEscape() == no_escape);
	}

	unittest
	{
		import std.algorithm;
		import util.modifiable;

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
		auto d = test.d;
		assert(d == 1000 && test.modified);
		assert(test.func(1, 2, 3) == 6);
		test.c_modifier();
	}
}
