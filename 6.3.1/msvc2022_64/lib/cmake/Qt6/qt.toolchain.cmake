set(__qt_toolchain_used_variables
    QT_CHAINLOAD_TOOLCHAIN_FILE
    QT_TOOLCHAIN_INCLUDE_FILE
    QT_TOOLCHAIN_RELOCATABLE_CMAKE_DIR
    QT_TOOLCHAIN_RELOCATABLE_PREFIX
    QT_HOST_PATH
    QT_HOST_PATH_CMAKE_DIR
    QT_REQUIRE_HOST_PATH_CHECK
    QT_ADDITIONAL_PACKAGES_PREFIX_PATH
    QT_ADDITIONAL_HOST_PACKAGES_PREFIX_PATH
)


# Make cache variables used by this toolchain file available to the
# try_compile command that operates on sources files.
list(APPEND CMAKE_TRY_COMPILE_PLATFORM_VARIABLES ${__qt_toolchain_used_variables})
list(REMOVE_DUPLICATES CMAKE_TRY_COMPILE_PLATFORM_VARIABLES)

# Turn the environment variables that are created at the end of this
# file into proper variables. This is needed for try_compile calls
# that operate on whole projects.
if($ENV{_QT_TOOLCHAIN_VARS_INITIALIZED})
    foreach(var ${__qt_toolchain_used_variables})
        set(${var} "$ENV{_QT_TOOLCHAIN_${var}}")
    endforeach()
endif()





    set(__qt_initial_c_compiler "C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Tools/MSVC/14.32.31326/bin/Hostx64/x64/cl.exe")
    set(__qt_initial_cxx_compiler "C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Tools/MSVC/14.32.31326/bin/Hostx64/x64/cl.exe")
    if(NOT DEFINED CMAKE_C_COMPILER AND EXISTS "${__qt_initial_c_compiler}")
        set(CMAKE_C_COMPILER "${__qt_initial_c_compiler}" CACHE STRING "")
    endif()
    if(NOT DEFINED CMAKE_CXX_COMPILER AND EXISTS "${__qt_initial_cxx_compiler}")
        set(CMAKE_CXX_COMPILER "${__qt_initial_cxx_compiler}" CACHE STRING "")
    endif()

if(NOT "${QT_CHAINLOAD_TOOLCHAIN_FILE}" STREQUAL "")
    set(__qt_chainload_toolchain_file "${QT_CHAINLOAD_TOOLCHAIN_FILE}")
endif()
if(__qt_chainload_toolchain_file)
    get_filename_component(__qt_chainload_toolchain_file_real_path
                          "${__qt_chainload_toolchain_file}" REALPATH)
    if(__qt_chainload_toolchain_file_real_path STREQUAL CMAKE_CURRENT_LIST_FILE)
        message(FATAL_ERROR
                "Woah, the Qt toolchain file tried to include itself recusively! '${__qt_chainload_toolchain_file}' "
                "Make sure to remove qtbase/CMakeCache.txt and reconfigure qtbase with 'cmake' "
                "rather than 'qt-cmake', and then you can reconfigure your own project."
        )
    elseif(NOT EXISTS "${__qt_chainload_toolchain_file_real_path}")
        message(WARNING "The toolchain file to be chainloaded "
            "'${__qt_chainload_toolchain_file}' does not exist.")
    else()
        include("${__qt_chainload_toolchain_file}")
        set(__qt_chainload_toolchain_file_included TRUE)
    endif()
    unset(__qt_chainload_toolchain_file)
endif()



# Compute dynamically the Qt installation prefix from the location of this file. This allows
# the usage of the toolchain file when the Qt installation is relocated.
get_filename_component(QT_TOOLCHAIN_RELOCATABLE_INSTALL_PREFIX
                       ${CMAKE_CURRENT_LIST_DIR}/../../../
                       ABSOLUTE)

# Compute the path to the installed Qt lib/cmake folder.
# We assume that the Qt toolchain location is inside the CMake Qt6 package, and thus the directory
# one level higher is what we're looking for.
get_filename_component(QT_TOOLCHAIN_RELOCATABLE_CMAKE_DIR "${CMAKE_CURRENT_LIST_DIR}/.." ABSOLUTE)

# REROOT_PATH_ISSUE_MARKER
# There's a subdirectory check in cmake's cmFindCommon::RerootPaths() function, that doesn't handle
# the case of CMAKE_PREFIX_PATH == CMAKE_FIND_ROOT_PATH for a particular pair of entries.
# Instead of collapsing the search prefix (which is the case when one is a subdir of the other),
# it concatenates them creating an invalid path. Workaround it by setting the root path to the
# Qt install prefix, and the prefix path to the lib/cmake subdir.
list(PREPEND CMAKE_PREFIX_PATH "${QT_TOOLCHAIN_RELOCATABLE_CMAKE_DIR}")
list(PREPEND CMAKE_FIND_ROOT_PATH "${QT_TOOLCHAIN_RELOCATABLE_INSTALL_PREFIX}")

# Let CMake load our custom platform modules.
# CMake-provided platform modules take precedence.
if(NOT QT_AVOID_CUSTOM_PLATFORM_MODULES)
    list(PREPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/platforms")
endif()

# Handle packages located in QT_ADDITIONAL_PACKAGES_PREFIX_PATH when cross-compiling. Needed for
# Conan.
# We prepend to CMAKE_PREFIX_PATH so that a find_package(Qt6Foo) call works, without having to go
# through the Qt6 umbrella package. The paths must end in lib/cmake to ensure the package is found.
# See REROOT_PATH_ISSUE_MARKER.
# We prepend to CMAKE_FIND_ROOT_PATH, due to the bug mentioned at REROOT_PATH_ISSUE_MARKER.
#
# Note that we don't handle QT_ADDITIONAL_HOST_PACKAGES_PREFIX_PATH here, because we would thwart
# our efforts to not accidentally pick up host packages. For now, we say that
# find_package(Qt6FooTools) is not supported, and people must use find_package(Qt6 COMPONENTS
# FooTools) instead.
set(__qt_toolchain_additional_packages_prefixes "")
if(QT_ADDITIONAL_PACKAGES_PREFIX_PATH)
    list(APPEND __qt_toolchain_additional_packages_prefixes
         ${QT_ADDITIONAL_PACKAGES_PREFIX_PATH})
endif()
if(DEFINED ENV{QT_ADDITIONAL_PACKAGES_PREFIX_PATH}
    AND NOT "$ENV{QT_ADDITIONAL_PACKAGES_PREFIX_PATH}" STREQUAL "")
    set(__qt_env_additional_packages_prefixes $ENV{QT_ADDITIONAL_PACKAGES_PREFIX_PATH})
    if(NOT CMAKE_HOST_WIN32)
        string(REPLACE ":" ";" __qt_env_additional_packages_prefixes
            "${__qt_env_additional_packages_prefixes}")
    endif()
    list(APPEND __qt_toolchain_additional_packages_prefixes
        ${__qt_env_additional_packages_prefixes})
    unset(__qt_env_additional_packages_prefixes)
endif()

if(__qt_toolchain_additional_packages_prefixes)
    set(__qt_toolchain_additional_packages_root_paths "")
    set(__qt_toolchain_additional_packages_prefix_paths "")

    foreach(__qt_additional_path IN LISTS __qt_toolchain_additional_packages_prefixes)
        file(TO_CMAKE_PATH "${__qt_additional_path}" __qt_additional_path)
        get_filename_component(__qt_additional_path "${__qt_additional_path}" ABSOLUTE)
        set(__qt_additional_path_lib_cmake "${__qt_additional_path}")
        if(NOT __qt_additional_path_lib_cmake MATCHES "/lib/cmake$")
            string(APPEND __qt_additional_path_lib_cmake "/lib/cmake")
        endif()

        list(APPEND __qt_toolchain_additional_packages_root_paths
                    "${__qt_additional_path}")
        list(APPEND __qt_toolchain_additional_packages_prefix_paths
                    "${__qt_additional_path_lib_cmake}")
    endforeach()
    list(PREPEND CMAKE_PREFIX_PATH ${__qt_toolchain_additional_packages_prefix_paths})
    list(PREPEND CMAKE_FIND_ROOT_PATH ${__qt_toolchain_additional_packages_root_paths})

    unset(__qt_additional_path)
    unset(__qt_additional_path_lib_cmake)
    unset(__qt_toolchain_additional_packages_root_paths)
    unset(__qt_toolchain_additional_packages_prefix_paths)
endif()
unset(__qt_toolchain_additional_packages_prefixes)

# Allow customization of the toolchain file by placing an additional file next to it.
set(__qt_toolchain_extra_file "${CMAKE_CURRENT_LIST_DIR}/qt.toolchain.extra.cmake")
if(EXISTS "${__qt_toolchain_extra_file}")
    include("${__qt_toolchain_extra_file}")
endif()

# Allow customization of the toolchain file by passing a path to an additional CMake file to be
# included.
if(QT_TOOLCHAIN_INCLUDE_FILE)
    get_filename_component(__qt_toolchain_include_file_real_path
                          "${QT_TOOLCHAIN_INCLUDE_FILE}" REALPATH)
    if(EXISTS "${__qt_toolchain_include_file_real_path}")
        include("${__qt_toolchain_include_file_real_path}")
    else()
        message(WARNING "The passed extra toolchain file to be included does not exist: "
                "${__qt_toolchain_include_file_real_path}")
    endif()
endif()

# Set up QT_HOST_PATH and do sanity checks.
# A host path is required when cross-compiling but optional when doing a native build.
# Requiredness can be overridden via variable.
if(DEFINED QT_REQUIRE_HOST_PATH_CHECK)
    set(__qt_toolchain_host_path_required "${QT_REQUIRE_HOST_PATH_CHECK}")
else()
    set(__qt_toolchain_host_path_required "FALSE")
endif()
set(__qt_toolchain_initial_qt_host_path
    "")
set(__qt_toolchain_initial_qt_host_path_cmake_dir
    "")

# QT_HOST_PATH precedence:
# - cache variable / command line option
# - environment variable
# - initial QT_HOST_PATH when qtbase was configured (and the directory exists)
if(NOT DEFINED QT_HOST_PATH)
    if(DEFINED ENV{QT_HOST_PATH})
        set(QT_HOST_PATH "$ENV{QT_HOST_PATH}" CACHE PATH "")
    else(__qt_toolchain_initial_qt_host_path AND EXISTS "${__qt_toolchain_initial_qt_host_path}")
        set(QT_HOST_PATH "${__qt_toolchain_initial_qt_host_path}" CACHE PATH "")
    endif()
endif()

if(NOT QT_HOST_PATH STREQUAL "")
    get_filename_component(__qt_toolchain_host_path_absolute "${QT_HOST_PATH}" ABSOLUTE)
endif()

if(__qt_toolchain_host_path_required AND
      ("${QT_HOST_PATH}" STREQUAL "" OR NOT EXISTS "${__qt_toolchain_host_path_absolute}"))
    message(FATAL_ERROR
        "To use a cross-compiled Qt, please set the QT_HOST_PATH cache variable to the location "
        "of your host Qt installation.")
endif()

# QT_HOST_PATH_CMAKE_DIR is needed to work around the rerooting issue when looking for host tools
# See REROOT_PATH_ISSUE_MARKER.
# Prefer initially configured path if none was explicitly set.
if(__qt_toolchain_host_path_required AND NOT DEFINED QT_HOST_PATH_CMAKE_DIR)
    if(__qt_toolchain_initial_qt_host_path_cmake_dir
          AND EXISTS "${__qt_toolchain_initial_qt_host_path_cmake_dir}")
        set(QT_HOST_PATH_CMAKE_DIR "${__qt_toolchain_initial_qt_host_path_cmake_dir}" CACHE PATH "")
    else()
        # First try to auto-compute the location instead of requiring to set QT_HOST_PATH_CMAKE_DIR
        # explicitly.
        set(__qt_candidate_host_path_cmake_dir "${QT_HOST_PATH}/lib/cmake")
        if(__qt_candidate_host_path_cmake_dir AND EXISTS "${__qt_candidate_host_path_cmake_dir}")
            set(QT_HOST_PATH_CMAKE_DIR
                "${__qt_candidate_host_path_cmake_dir}" CACHE PATH "")
        endif()
    endif()
endif()

if(NOT QT_HOST_PATH_CMAKE_DIR STREQUAL "")
    get_filename_component(__qt_toolchain_host_path_cmake_dir_absolute
                           "${QT_HOST_PATH_CMAKE_DIR}" ABSOLUTE)
endif()

if(__qt_toolchain_host_path_required AND
      ("${QT_HOST_PATH_CMAKE_DIR}" STREQUAL ""
       OR NOT EXISTS "${__qt_toolchain_host_path_cmake_dir_absolute}"))
    message(FATAL_ERROR
        "To use a cross-compiled Qt, please set the QT_HOST_PATH_CMAKE_DIR cache variable to "
        "the location of your host Qt installation lib/cmake directory.")
endif()

# Store initial build type (if any is specified) to be read by QtBuildInternals.cmake when building
# a Qt repo, standalone tests or a single test.
if(DEFINED CACHE{CMAKE_BUILD_TYPE})
    set(__qt_toolchain_cmake_build_type_before_project_call "${CMAKE_BUILD_TYPE}")
endif()

# Compile tests only see a restricted set of variables.
# All cache variables, this toolchain file uses, must be made available to project-based
# try_compile tests because this toolchain file will be included there too.
if(NOT "$ENV{_QT_TOOLCHAIN_VARS_INITIALIZED}")
    set(ENV{_QT_TOOLCHAIN_VARS_INITIALIZED} ON)
    foreach(var ${__qt_toolchain_used_variables})
        set(ENV{_QT_TOOLCHAIN_${var}} "${${var}}")
    endforeach()
endif()
