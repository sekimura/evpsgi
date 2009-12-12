/* -*- Mode: C; tab-width: 4; c-basic-offset: 4; indent-tabs-mode: nil -*- */

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <sys/types.h>
#include <stdbool.h>

/**
 * Globally accessible settings as derived from the commandline.
 */
struct settings {
    char *file;
    char *alias;
    u_short port;
    char *inter;
    char *server_name;
    bool alias_is_root;
};
extern struct settings settings;

