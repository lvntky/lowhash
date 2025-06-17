# Makefile for lowhash - A high-performance hashing library
# Copyright (c) 2025 - Licensed under MIT License

# ==============================================================================
# Configuration
# ==============================================================================

# Library information
LIBNAME = lowhash
VERSION = 1.0.0
SOVERSION = 1

# Library targets
STATIC_LIB = lib$(LIBNAME).a
SHARED_LIB = lib$(LIBNAME).so.$(VERSION)
SHARED_LIB_SONAME = lib$(LIBNAME).so.$(SOVERSION)
SHARED_LIB_LINK = lib$(LIBNAME).so

# Directory structure
SRCDIR = src
INCLUDEDIR = include
OBJDIR = obj
TESTDIR = tests
DOCDIR = docs
DISTDIR = dist

# Installation directories (can be overridden)
PREFIX ?= /usr/local
EXEC_PREFIX ?= $(PREFIX)
LIBDIR ?= $(EXEC_PREFIX)/lib
INCLUDEDIR_INSTALL ?= $(PREFIX)/include
PKGCONFIGDIR ?= $(LIBDIR)/pkgconfig
MANDIR ?= $(PREFIX)/share/man/man3

# Compiler and tools
CC ?= gcc
AR ?= ar
RANLIB ?= ranlib
STRIP ?= strip
INSTALL ?= install
PKG_CONFIG ?= pkg-config

# Compiler flags
CFLAGS_BASE = -Wall -Wextra -Wstrict-prototypes -Wmissing-prototypes \
              -Wpointer-arith -Wcast-align -Wwrite-strings \
              -Wcast-qual -Wswitch-default -Wunreachable-code \
              -Winit-self -Wmissing-field-initializers \
              -Wno-unknown-pragmas -Wstrict-aliasing=3 -Wtrampolines \
              -Wlogical-op -Wmissing-declarations -Wredundant-decls \
              -Wmissing-include-dirs -Wswitch-enum -Wswitch-default \
              -Winvalid-pch -Wredundant-decls -Wformat=2 \
              -Wmissing-format-attribute -Wformat-nonliteral

CFLAGS_RELEASE = $(CFLAGS_BASE) -O3 -DNDEBUG -ffunction-sections -fdata-sections
CFLAGS_DEBUG = $(CFLAGS_BASE) -O0 -g3 -DDEBUG -fsanitize=address -fsanitize=undefined
CFLAGS_PROFILE = $(CFLAGS_BASE) -O2 -g -pg -DPROFILE

# Position Independent Code for shared libraries
CFLAGS_PIC = -fPIC

# Include paths
CPPFLAGS = -I$(INCLUDEDIR)

# Linker flags
LDFLAGS_SHARED = -shared -Wl,-soname,$(SHARED_LIB_SONAME)
LDFLAGS_RELEASE = -Wl,--gc-sections -Wl,--strip-all
LDFLAGS_DEBUG = -fsanitize=address -fsanitize=undefined

# Build type (can be: release, debug, profile)
BUILD_TYPE ?= release

# Set flags based on build type
ifeq ($(BUILD_TYPE),debug)
    CFLAGS = $(CFLAGS_DEBUG)
    LDFLAGS = $(LDFLAGS_DEBUG)
    OBJDIR := $(OBJDIR)/debug
else ifeq ($(BUILD_TYPE),profile)
    CFLAGS = $(CFLAGS_PROFILE)
    OBJDIR := $(OBJDIR)/profile
else
    CFLAGS = $(CFLAGS_RELEASE)
    LDFLAGS = $(LDFLAGS_RELEASE)
    OBJDIR := $(OBJDIR)/release
endif

# ==============================================================================
# Source and object files
# ==============================================================================

SRCS = $(wildcard $(SRCDIR)/*.c)
HEADERS = $(wildcard $(INCLUDEDIR)/*.h) $(wildcard $(INCLUDEDIR)/$(LIBNAME)/*.h)
OBJS_STATIC = $(patsubst $(SRCDIR)/%.c,$(OBJDIR)/static/%.o,$(SRCS))
OBJS_SHARED = $(patsubst $(SRCDIR)/%.c,$(OBJDIR)/shared/%.o,$(SRCS))

# Test files
TEST_SRCS = $(wildcard $(TESTDIR)/*.c)
TEST_BINS = $(patsubst $(TESTDIR)/%.c,$(OBJDIR)/tests/%,$(TEST_SRCS))

# ==============================================================================
# Default target
# ==============================================================================

.DEFAULT_GOAL := all

# ==============================================================================
# Phony targets
# ==============================================================================

.PHONY: all static shared clean install uninstall test check \
        install-static install-shared install-headers install-pkgconfig \
        uninstall-static uninstall-shared uninstall-headers uninstall-pkgconfig \
        dist distclean help debug release profile \
        format lint valgrind benchmark

# ==============================================================================
# Main targets
# ==============================================================================

all: static shared

static: $(STATIC_LIB)

shared: $(SHARED_LIB)

debug:
	$(MAKE) BUILD_TYPE=debug all

release:
	$(MAKE) BUILD_TYPE=release all

profile:
	$(MAKE) BUILD_TYPE=profile all

# ==============================================================================
# Library building
# ==============================================================================

$(STATIC_LIB): $(OBJS_STATIC)
	@echo "Creating static library: $@"
	@$(AR) rcs $@ $^
	@$(RANLIB) $@
	@echo "Static library created successfully"

$(SHARED_LIB): $(OBJS_SHARED)
	@echo "Creating shared library: $@"
	@$(CC) $(LDFLAGS_SHARED) $(LDFLAGS) -o $@ $^
	@ln -sf $(SHARED_LIB) $(SHARED_LIB_SONAME)
	@ln -sf $(SHARED_LIB_SONAME) $(SHARED_LIB_LINK)
	@echo "Shared library created successfully"

# Static object files
$(OBJDIR)/static/%.o: $(SRCDIR)/%.c $(HEADERS) | $(OBJDIR)/static
	@echo "Compiling (static): $<"
	@$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

# Shared object files (with PIC)
$(OBJDIR)/shared/%.o: $(SRCDIR)/%.c $(HEADERS) | $(OBJDIR)/shared
	@echo "Compiling (shared): $<"
	@$(CC) $(CPPFLAGS) $(CFLAGS) $(CFLAGS_PIC) -c $< -o $@

# ==============================================================================
# Directory creation
# ==============================================================================

$(OBJDIR)/static:
	@mkdir -p $@

$(OBJDIR)/shared:
	@mkdir -p $@

$(OBJDIR)/tests:
	@mkdir -p $@

$(DISTDIR):
	@mkdir -p $@

# ==============================================================================
# Testing
# ==============================================================================

test: $(TEST_BINS)
	@echo "Running tests..."
	@for test in $(TEST_BINS); do \
		echo "Running $$test"; \
		$$test || exit 1; \
	done
	@echo "All tests passed!"

check: test

$(OBJDIR)/tests/%: $(TESTDIR)/%.c $(STATIC_LIB) | $(OBJDIR)/tests
	@echo "Building test: $@"
	@$(CC) $(CPPFLAGS) $(CFLAGS) $< -L. -l$(LIBNAME) -o $@

# ==============================================================================
# Installation
# ==============================================================================

install: install-static install-shared install-headers install-pkgconfig
	@echo "Installation completed successfully"

install-static: $(STATIC_LIB)
	@echo "Installing static library..."
	@$(INSTALL) -d $(DESTDIR)$(LIBDIR)
	@$(INSTALL) -m 644 $(STATIC_LIB) $(DESTDIR)$(LIBDIR)/

install-shared: $(SHARED_LIB)
	@echo "Installing shared library..."
	@$(INSTALL) -d $(DESTDIR)$(LIBDIR)
	@$(INSTALL) -m 755 $(SHARED_LIB) $(DESTDIR)$(LIBDIR)/
	@ln -sf $(SHARED_LIB) $(DESTDIR)$(LIBDIR)/$(SHARED_LIB_SONAME)
	@ln -sf $(SHARED_LIB_SONAME) $(DESTDIR)$(LIBDIR)/$(SHARED_LIB_LINK)
	@ldconfig -n $(DESTDIR)$(LIBDIR) 2>/dev/null || true

install-headers:
	@echo "Installing headers..."
	@$(INSTALL) -d $(DESTDIR)$(INCLUDEDIR_INSTALL)/$(LIBNAME)
	@for header in $(HEADERS); do \
		$(INSTALL) -m 644 $$header $(DESTDIR)$(INCLUDEDIR_INSTALL)/$(LIBNAME)/ || exit 1; \
	done

install-pkgconfig: $(LIBNAME).pc
	@echo "Installing pkg-config file..."
	@$(INSTALL) -d $(DESTDIR)$(PKGCONFIGDIR)
	@$(INSTALL) -m 644 $(LIBNAME).pc $(DESTDIR)$(PKGCONFIGDIR)/

# ==============================================================================
# Uninstallation
# ==============================================================================

uninstall: uninstall-static uninstall-shared uninstall-headers uninstall-pkgconfig
	@echo "Uninstallation completed"

uninstall-static:
	@echo "Removing static library..."
	@rm -f $(DESTDIR)$(LIBDIR)/$(STATIC_LIB)

uninstall-shared:
	@echo "Removing shared library..."
	@rm -f $(DESTDIR)$(LIBDIR)/$(SHARED_LIB)
	@rm -f $(DESTDIR)$(LIBDIR)/$(SHARED_LIB_SONAME)
	@rm -f $(DESTDIR)$(LIBDIR)/$(SHARED_LIB_LINK)

uninstall-headers:
	@echo "Removing headers..."
	@rm -rf $(DESTDIR)$(INCLUDEDIR_INSTALL)/$(LIBNAME)

uninstall-pkgconfig:
	@echo "Removing pkg-config file..."
	@rm -f $(DESTDIR)$(PKGCONFIGDIR)/$(LIBNAME).pc

# ==============================================================================
# Maintenance and utilities
# ==============================================================================

clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(OBJDIR) $(STATIC_LIB) $(SHARED_LIB)* $(LIBNAME).pc
	@echo "Clean completed"

distclean: clean
	@echo "Deep cleaning..."
	@rm -rf $(DISTDIR) *.log *.tmp *~ core.*
	@find . -name "*.orig" -delete 2>/dev/null || true
	@find . -name "*.rej" -delete 2>/dev/null || true

# Generate pkg-config file
$(LIBNAME).pc:
	@echo "Generating pkg-config file..."
	@echo "prefix=$(PREFIX)" > $@
	@echo "exec_prefix=$(EXEC_PREFIX)" >> $@
	@echo "libdir=$(LIBDIR)" >> $@
	@echo "includedir=$(INCLUDEDIR_INSTALL)" >> $@
	@echo "" >> $@
	@echo "Name: $(LIBNAME)" >> $@
	@echo "Description: High-performance hashing library" >> $@
	@echo "Version: $(VERSION)" >> $@
	@echo "Libs: -L\$${libdir} -l$(LIBNAME)" >> $@
	@echo "Cflags: -I\$${includedir}/$(LIBNAME)" >> $@

# Distribution package
dist: $(DISTDIR)
	@echo "Creating distribution package..."
	@tar -czf $(DISTDIR)/$(LIBNAME)-$(VERSION).tar.gz \
		--exclude='.git*' --exclude='$(OBJDIR)' --exclude='$(DISTDIR)' \
		--exclude='*.o' --exclude='*.a' --exclude='*.so*' \
		--transform 's,^,$(LIBNAME)-$(VERSION)/,' \
		*
	@echo "Distribution package created: $(DISTDIR)/$(LIBNAME)-$(VERSION).tar.gz"

# Code formatting (requires clang-format)
format:
	@if command -v clang-format >/dev/null 2>&1; then \
		echo "Formatting source code..."; \
		find $(SRCDIR) $(INCLUDEDIR) $(TESTDIR) -name "*.c" -o -name "*.h" | \
		xargs clang-format -i; \
		echo "Code formatting completed"; \
	else \
		echo "clang-format not found. Please install it for code formatting."; \
	fi

# Static analysis (requires cppcheck)
lint:
	@if command -v cppcheck >/dev/null 2>&1; then \
		echo "Running static analysis..."; \
		cppcheck --enable=all --inconclusive --std=c99 \
		-I$(INCLUDEDIR) $(SRCDIR); \
	else \
		echo "cppcheck not found. Please install it for static analysis."; \
	fi

# Memory leak detection (requires valgrind)
valgrind: $(TEST_BINS)
	@if command -v valgrind >/dev/null 2>&1; then \
		echo "Running memory leak detection..."; \
		for test in $(TEST_BINS); do \
			echo "Checking $$test with valgrind"; \
			valgrind --leak-check=full --error-exitcode=1 $$test || exit 1; \
		done; \
	else \
		echo "valgrind not found. Please install it for memory leak detection."; \
	fi

# Performance benchmarking
benchmark: $(STATIC_LIB)
	@echo "Running benchmarks..."
	@if [ -f $(TESTDIR)/benchmark.c ]; then \
		$(CC) $(CPPFLAGS) $(CFLAGS) $(TESTDIR)/benchmark.c -L. -l$(LIBNAME) -o $(OBJDIR)/benchmark; \
		./$(OBJDIR)/benchmark; \
	else \
		echo "No benchmark.c found in $(TESTDIR)"; \
	fi

# ==============================================================================
# Help
# ==============================================================================

help:
	@echo "Available targets:"
	@echo "  all          - Build both static and shared libraries (default)"
	@echo "  static       - Build static library only"
	@echo "  shared       - Build shared library only"
	@echo "  debug        - Build with debug flags"
	@echo "  release      - Build with release flags"
	@echo "  profile      - Build with profiling flags"
	@echo "  test         - Build and run tests"
	@echo "  check        - Alias for test"
	@echo "  install      - Install library, headers, and pkg-config"
	@echo "  uninstall    - Remove installed files"
	@echo "  clean        - Remove build artifacts"
	@echo "  distclean    - Deep clean including temporary files"
	@echo "  dist         - Create distribution package"
	@echo "  format       - Format source code (requires clang-format)"
	@echo "  lint         - Run static analysis (requires cppcheck)"
	@echo "  valgrind     - Run memory leak detection (requires valgrind)"
	@echo "  benchmark    - Run performance benchmarks"
	@echo "  help         - Show this help message"
	@echo ""
	@echo "Variables:"
	@echo "  PREFIX       - Installation prefix (default: /usr/local)"
	@echo "  BUILD_TYPE   - Build type: release, debug, profile (default: release)"
	@echo "  CC           - C compiler (default: gcc)"
	@echo "  CFLAGS       - Additional compiler flags"
	@echo "  LDFLAGS      - Additional linker flags"

# ==============================================================================
# Dependencies
# ==============================================================================

# Automatic dependency generation
-include $(OBJS_STATIC:.o=.d)
-include $(OBJS_SHARED:.o=.d)

# Generate dependency files
$(OBJDIR)/static/%.d: $(SRCDIR)/%.c | $(OBJDIR)/static
	@$(CC) $(CPPFLAGS) -MM -MT $(@:.d=.o) $< > $@

$(OBJDIR)/shared/%.d: $(SRCDIR)/%.c | $(OBJDIR)/shared
	@$(CC) $(CPPFLAGS) -MM -MT $(@:.d=.o) $< > $@
