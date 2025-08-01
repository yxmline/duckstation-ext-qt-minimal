# Include the basic version config file to get results of regular version checking.
include("${CMAKE_CURRENT_LIST_DIR}/Qt6QTuioTouchPluginConfigVersionImpl.cmake")

set(__qt_disable_package_version_check FALSE)

# Allow to opt out of the version check.
if(QT_NO_PACKAGE_VERSION_CHECK)
    set(__qt_disable_package_version_check TRUE)
endif()



if((NOT PACKAGE_VERSION_COMPATIBLE) OR PACKAGE_VERSION_UNSUITABLE)
    set(__qt_package_version_incompatible TRUE)
else()
    set(__qt_package_version_incompatible FALSE)
endif()

if(__qt_disable_package_version_check)
    # Warn if version check is disabled regardless if it's a Qt repo build or user project build.
    # Allow to opt out of warning.
    if(__qt_package_version_incompatible AND NOT QT_NO_PACKAGE_VERSION_INCOMPATIBLE_WARNING)
        message(WARNING
            "Package ${PACKAGE_FIND_NAME} with version ${PACKAGE_VERSION} was accepted as "
            "compatible because QT_NO_PACKAGE_VERSION_CHECK was set to TRUE. There is no guarantee "
            "the build will succeed. You can silence this warning by passing "
            "-DQT_NO_PACKAGE_VERSION_INCOMPATIBLE_WARNING=TRUE")
    endif()

    # Mark version as compatible. This is how we disable the version check.
    set(PACKAGE_VERSION_COMPATIBLE TRUE)
    unset(PACKAGE_VERSION_UNSUITABLE)

# If QT_REPO_MODULE_VERSION is set, that means we are building a Qt repo. Show message that one can
# disable the check if they need to.
elseif(QT_REPO_MODULE_VERSION AND __qt_package_version_incompatible)
    if(PACKAGE_FIND_VERSION_RANGE)
        set(__qt_package_version_message_prefix "Version range ${PACKAGE_FIND_VERSION_RANGE}")
    else()
        set(__qt_package_version_message_prefix "Version ${PACKAGE_FIND_VERSION}")
    endif()

    message(WARNING
        "${__qt_package_version_message_prefix} of package ${PACKAGE_FIND_NAME} was requested but "
        "an incompatible version was found: ${PACKAGE_VERSION}. You can pass "
        "-DQT_NO_PACKAGE_VERSION_CHECK=TRUE to disable the version check and force the "
        "incompatible version to be used. There is no guarantee the build will succeed. "
        "Use at your own risk. "
        "You can silence this warning by passing -DQT_NO_PACKAGE_VERSION_INCOMPATIBLE_WARNING=TRUE")
endif()

unset(__qt_disable_package_version_check)
unset(__qt_disable_package_version_check_due_to_developer_build)
unset(__qt_package_version_message_prefix)
unset(__qt_package_version_incompatible)
