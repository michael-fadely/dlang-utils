module util.filesystem;

import std.string : toStringz;

ulong getFreeSpace(in string dir)
{
	version (Windows)
	{
		import core.sys.windows.windows : ULARGE_INTEGER,
		                                  GetDiskFreeSpaceExA;

		ULARGE_INTEGER space;

		if (!GetDiskFreeSpaceExA(dir.toStringz(), &space, null, null))
		{
			return 0;
		}

		return space.QuadPart;
	}
	else version (Posix)
	{
		import core.sys.posix.sys.statvfs : statvfs_t,
		                                    statvfs;

		statvfs_t space;

		if (statvfs(dir.toStringz(), &space) != 0)
		{
			return 0;
		}

		return space.f_bsize * space.f_bfree;
	}
	else
	{
		static assert(false, "Not implemented on this platform.");
	}
}

ulong getCapacity(in string dir)
{
	version (Windows)
	{
		import core.sys.windows.windows : ULARGE_INTEGER,
		                                  GetDiskFreeSpaceExA;

		ULARGE_INTEGER space;

		if (!GetDiskFreeSpaceExA(dir.toStringz(), null, &space, null))
		{
			return 0;
		}

		return space.QuadPart;
	}
	else version (Posix)
	{
		import core.sys.posix.sys.statvfs : statvfs_t,
		                                    statvfs;

		statvfs_t space;

		if (statvfs(dir.toStringz(), &space) != 0)
		{
			return 0;
		}

		return space.f_blocks * space.f_frsize;
	}
	else
	{
		static assert(false, "Not implemented on this platform.");
	}
}

size_t getDirSize(in string path)
{
	import std.file : dirEntries, SpanMode;

	size_t result;

	foreach (entry; dirEntries(path, SpanMode.breadth))
	{
		if (entry.isFile)
		{
			result += entry.size;
		}
	}

	return result;
}
