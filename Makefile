# Makefile for building lowhash as static library

LIBNAME = lowhash.a

INCLUDEDIR = include
SRCDIR = src
LIBDIR = lib

# Installation directories (can be overridden)
PREFIX ?= /usr/local
INSTALL_LIBDIR = $(PREFIX)/lib
INSTALL_INCLUDEDIR = $(PREFIX)/include/lowhash

CC = gcc
CFLAGS = -Wall -Wextra -O2 -fPIC -I$(INCLUDEDIR)

SRCS = $(wildcard $(SRCDIR)/*.c)
OBJS = $(SRCS:.c=.o)

.PHONY: all clean install uninstall

all: $(LIBNAME)

$(LIBNAME): $(OBJS)
	ar rcs $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS) $(LIBNAME)

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
