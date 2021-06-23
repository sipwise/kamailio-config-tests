#!/bin/sh
# shellcheck disable=SC2068
lnav -c':filter-out cfgt ' -c':filter-out pv_headers ' -c':filter-out pvapi.c:1245' ${@}
