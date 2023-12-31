/*++
Copyright (c) 2006 Microsoft Corporation

Module Name:

    debug.cpp

Abstract:

    Basic debugging support.

Author:

    Leonardo de Moura (leonardo) 2006-09-11.

Revision History:

--*/
#include<cstdio>
#ifndef _WINDOWS
#include<unistd.h>
#endif
#include<iostream>
#include "util/mutex.h"
#include "util/str_hashtable.h"
#include "util/z3_exception.h"
#include "util/z3_version.h"

static atomic<bool> g_enable_assertions(true);

void enable_assertions(bool f) {
    g_enable_assertions = f;
}

bool assertions_enabled() {
    return g_enable_assertions;
}

void notify_assertion_violation(const char * fileName, int line, const char * condition) {
    std::cerr << "ASSERTION VIOLATION\n"
                 "File: " << fileName << "\n"
                 "Line: " << line << '\n'
              << condition << '\n';
#ifndef Z3DEBUG
    std::cerr << Z3_FULL_VERSION "\n"
                 "Please file an issue with this message and more detail about how you encountered it at https://github.com/Z3Prover/z3/issues/new\n";
#endif
}

static str_hashtable* g_enabled_debug_tags = nullptr;

static void init_debug_table() {
    if (!g_enabled_debug_tags) {
        g_enabled_debug_tags = alloc(str_hashtable);
    }
}

void finalize_debug() {
    dealloc(g_enabled_debug_tags);
    g_enabled_debug_tags = nullptr;
}

void enable_debug(const char * tag) {
    init_debug_table();
    g_enabled_debug_tags->insert(tag);
}

void disable_debug(const char * tag) {
    init_debug_table();
    g_enabled_debug_tags->erase(tag);
}

bool is_debug_enabled(const char * tag) {
    init_debug_table();
    return g_enabled_debug_tags->contains(tag);
}

#if !defined(_WINDOWS) && !defined(NO_Z3_DEBUGGER)
void invoke_gdb() {
    std::string buffer;
    int * x = nullptr;
    for (;;) {
        std::cerr << "(C)ontinue, (A)bort, (S)top, (T)hrow exception, Invoke (G)DB\n";
        char result;
        bool ok = bool(std::cin >> result);
        if (!ok) exit(ERR_INTERNAL_FATAL); // happens if std::cin is eof or unattached.
        switch(result) {
        case 'C':
        case 'c':
            return;
        case 'A':
        case 'a':
            exit(1);
        case 'S':
        case 's':
            // force seg fault...
            *x = 0;
            return;
        case 't':
        case 'T':
            throw default_exception("assertion violation");
        case 'G':
        case 'g':
            buffer = "gdb -nw /proc/" + std::to_string(getpid()) + "/exe " + std::to_string(getpid());
            std::cerr << "invoking GDB...\n";
            if (system(buffer.c_str()) == 0) {
                std::cerr << "continuing the execution...\n";
            }
            else {
                std::cerr << "error starting GDB...\n";
                // forcing seg fault.
                int * x = nullptr;
                *x = 0;
            }
            return;
        default:
            std::cerr << "INVALID COMMAND\n";
        }
    }
}
#endif
