#include "arospath.hpp"

#if defined(__AROS__)

#include <cstdlib>
#include <string>

#include <dos/dos.h>
#include <proto/dos.h>
#include <proto/exec.h>
#include <exec/memory.h>

namespace
{
    // Paths are kept in their native AROS spelling ("Volume:dir/file"): the
    // AROS C library does not map a POSIX "/Volume/dir" form onto volumes,
    // and std::filesystem happily joins and splits the native form as long
    // as no component is empty ("Volume:" + "/dir" would mean the parent).
    std::filesystem::path nativePath(const std::string& path)
    {
        return path;
    }

    std::filesystem::path lockToPath(BPTR lock)
    {
        char buffer[1024];
        if (lock != BNULL && NameFromLock(lock, buffer, sizeof(buffer)))
            return nativePath(buffer);
        return {};
    }

    std::filesystem::path assignToPath(const char* name, const std::filesystem::path& fallback)
    {
        BPTR lock = Lock(name, SHARED_LOCK);
        if (lock == BNULL)
            return fallback;
        std::filesystem::path result = lockToPath(lock);
        UnLock(lock);
        return result.empty() ? fallback : result;
    }

    const std::filesystem::path& getProgramDir()
    {
        static const std::filesystem::path dir = [] {
            std::filesystem::path result = lockToPath(GetProgramDir());
            if (result.empty())
                result = std::filesystem::current_path();
            return result;
        }();
        return dir;
    }

    std::filesystem::path getEnv(const char* envVariable, const std::filesystem::path& fallback)
    {
        const char* result = std::getenv(envVariable);
        if (result == nullptr || *result == '\0')
            return fallback;
        return nativePath(result);
    }

    // The program directory is the natural home for settings and saves, but
    // on read-only media (the Live CD) nothing can be written there; fall
    // back to T: (the AROS temporary/scratch assign) in that case.
    bool programDirWritable()
    {
        // Ask the volume rather than trying to write: the disk state tells
        // whether the filesystem accepts writes at all (a Live CD does not).
        static const bool writable = [] {
            bool result = false;
            BPTR lock = Lock("PROGDIR:", SHARED_LOCK);
            if (lock == BNULL)
                return false;
            struct InfoData* info = static_cast<struct InfoData*>(
                AllocMem(sizeof(struct InfoData), MEMF_PUBLIC | MEMF_CLEAR));
            if (info != nullptr)
            {
                if (Info(lock, info))
                    result = (info->id_DiskState == ID_VALIDATED);
                FreeMem(info, sizeof(struct InfoData));
            }
            UnLock(lock);
            return result;
        }();
        return writable;
    }

    std::filesystem::path userBase(const char* subdir)
    {
        if (programDirWritable())
            return getProgramDir() / subdir;
        return assignToPath("T:", getProgramDir()) / "OpenMW" / subdir;
    }
}

/**
 * \namespace Files
 */
namespace Files
{

    ArosPath::ArosPath(const std::string& applicationName)
        : mName(applicationName)
    {
    }

    std::filesystem::path ArosPath::getUserConfigPath() const
    {
        return getEnv("OPENMW_USER_CONFIG", userBase("config"));
    }

    std::filesystem::path ArosPath::getUserDataPath() const
    {
        return getEnv("OPENMW_USER_DATA", userBase("userdata"));
    }

    std::filesystem::path ArosPath::getCachePath() const
    {
        return assignToPath("T:", getProgramDir() / "cache") / mName;
    }

    std::filesystem::path ArosPath::getGlobalConfigPath() const
    {
        return getProgramDir();
    }

    std::filesystem::path ArosPath::getLocalPath() const
    {
        return getProgramDir() / "";
    }

    std::filesystem::path ArosPath::getGlobalDataPath() const
    {
        return getProgramDir() / "data";
    }

    std::vector<std::filesystem::path> ArosPath::getInstallPaths() const
    {
        return {};
    }

} /* namespace Files */

#endif /* defined(__AROS__) */
