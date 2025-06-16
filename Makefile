# Makefile for building and installing a static C library of lowhash

LIBNAME = lowhash.a

INCLUDEDIR = include
SRCDIR = src
OBJDIR = obj

# Installation directories (can be overridden)
PREFIX ?= /usr/localp
INSTALL_LIBDIR = $(PREFIX)/lib
INSTALL_INCLUDEDIR = $(PREFIX)/include/lowhash

CC = gcc
CFLAGS = -Wall -Wextra -O2 -fPIC -I$(INCLUDEDIR)

SRCS = $(wildcard $(SRCDIR)/*.c)

# Map src/foo.c -> obj/foo.o
OBJS = $(patsubst $(SRCDIR)/%.c,$(OBJDIR)/%.o,$(SRCS))

.PHONY: all clean install uninstall

all: $(LIBNAME)

$(LIBNAME): $(OBJS)
	ar rcs $@ $^

# Compile .c files to .o files in obj/ directory
$(OBJDIR)/%.o: $(SRCDIR)/%.c | $(OBJDIR)
	$(CC) $(CFLAGS) -c $< -o $@

# Create obj directory if it doesn't exist
$(OBJDIR):
	mkdir -p $(OBJDIR)

clean:
	rm -rf $(OBJDIR) $(LIBNAME)

install: all
	@echo "Installing library to $(INSTALL_LIBDIR)"
	mkdir -p $(INSTALL_LIBDIR)
	cp $(LIBNAME) $(INSTALL_LIBDIR)
	@echo "Installing headers to $(INSTALL_INCLUDEDIR)"
	mkdir -p $(INSTALL_INCLUDEDIR)
	cp $(INCLUDEDIR)/*.h $(INSTALL_INCLUDEDIR)

uninstall:
	@echo "Removing library from $(INSTALL_LIBDIR)"
	rm -f $(INSTALL_LIBDIR)/$(LIBNAME)
	@echo "Removing headers from $(INSTALL_INCLUDEDIR)"
	rm -f $(INSTALL_INCLUDEDIR)/*.h
