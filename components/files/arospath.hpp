#ifndef COMPONENTS_FILES_AROSPATH_H
#define COMPONENTS_FILES_AROSPATH_H

#if defined(__AROS__)

#include <filesystem>
#include <string>
#include <vector>

/**
 * \namespace Files
 */
namespace Files
{

    /**
     * \struct ArosPath
     *
     * AROS has no per-user home directories; the game is self contained in
     * the drawer it was started from (PROGDIR:).  Paths are returned in the
     * native AROS spelling ("Volume:dir/file"), resolved from locks so that
     * they never end in a bare "Volume:" (which "/" joins would mis-handle).
     */
    struct ArosPath
    {
        explicit ArosPath(const std::string& applicationName);

        /// PROGDIR:config (override with the OPENMW_USER_CONFIG env var)
        std::filesystem::path getUserConfigPath() const;

        /// PROGDIR:userdata (override with the OPENMW_USER_DATA env var)
        std::filesystem::path getUserDataPath() const;

        /// PROGDIR:
        std::filesystem::path getGlobalConfigPath() const;

        /// PROGDIR:
        std::filesystem::path getLocalPath() const;

        /// PROGDIR:data
        std::filesystem::path getGlobalDataPath() const;

        /// T:openmw
        std::filesystem::path getCachePath() const;

        std::vector<std::filesystem::path> getInstallPaths() const;

        std::string mName;
    };

} /* namespace Files */

#endif /* defined(__AROS__) */

#endif /* COMPONENTS_FILES_AROSPATH_H */
