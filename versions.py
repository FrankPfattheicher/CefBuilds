
import os
import re
import subprocess


def get_sha(repo):
    sha = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=repo).decode('ascii').strip()
    return sha


def get_count(repo):
    return get_count_branch(repo, 'HEAD')


def get_count_branch(repo, branch):
    count = subprocess.check_output(['git', 'rev-list', '--count', branch], cwd=repo).decode('ascii').strip()
    return count


def main():

    basefolder = os.path.expanduser("~/code")
    print("base folder = " + basefolder)

    cef_version_file = os.path.join(basefolder, "chromium_git/cef/VERSION")
    if not(os.path.exists(cef_version_file)):
        cef_version_file = os.path.join(basefolder, "chromium_git/cef/VERSION.in")
    chromium_version_file = os.path.join(basefolder, "chromium_git/chromium/src/chrome/VERSION")

    version = open(cef_version_file)
    lines = version.read()
    version.close()

    cef_version = re.search("CEF_MAJOR=([0-9]+)\n", lines).group(1)
    print("CEF major = " + cef_version)

    version = open(chromium_version_file)
    lines = version.read()
    version.close()

    chromium_major = re.search("MAJOR=([0-9]+)\n", lines).group(1)
    chromium_minor = re.search("MINOR=([0-9]+)\n", lines).group(1)
    chromium_build = re.search("BUILD=([0-9]+)\n", lines).group(1)
    chromium_patch = re.search("PATCH=([0-9]+)\n", lines).group(1)
    chromium_version = chromium_major + "." + chromium_minor + "." + chromium_build + "." + chromium_patch
    print("Chromium version = " + chromium_version)

    cef_repo = os.path.join(basefolder, "chromium_git/cef")
    chromium_repo = os.path.join(basefolder, "chromium_git/chromium/src")

    cef_hash = get_sha(cef_repo)
    print("CEF GIT hash = " + cef_hash)
    cef_hash = cef_hash[:7]
    print("CEF GIT short hash = " + cef_hash)
    cef_count = get_count(cef_repo)
    print("CEF GIT count = " + cef_count)

    chromium_hash = get_sha(chromium_repo)
    print("Chromium GIT hash = " + chromium_hash)
    #chromium_count = get_count_branch(chromium_repo, chromium_version)
    #print("Chromium GIT count = " + chromium_count)

    # Version Number Format
    # see https://bitbucket.org/chromiumembedded/cef/wiki/BranchesAndBuilding
    cef_pack = "cef_binary_" + cef_version + "." + str(chromium_build) + "." \
               + cef_count + ".g" + cef_hash + "_linuxarm_client"
    print("cef_pack (old format) = " + cef_pack)

    #cef_pack_new = "cef_binary_" + chromium_major + "." + str(1) + "." + str(13) \
    #               + "+g" + cef_hash + "+chromium-" + chromium_version + "_linuxarm_client"
    #print("cef_pack (new format) = " + cef_pack_new)


if __name__ == '__main__':
    main()

