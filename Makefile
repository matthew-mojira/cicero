# Compiler and flags
CC = gcc
CFLAGS = -Wall -g

# Directories
SRCDIR = src
INCDIR = include
OBJDIR = obj

# Files
TARGET = program  # Output program name
SRCFILES = $(SRCDIR)/main.c $(SRCDIR)/parser/sexp.c
OBJFILES = $(OBJDIR)/main.o $(OBJDIR)/sexp.o

# Include directories
INCLUDES = -I$(INCDIR)

# Targets

all: $(TARGET)

$(TARGET): $(OBJFILES)
	$(CC) $(OBJFILES) -o $(TARGET)

$(OBJDIR)/main.o: $(SRCDIR)/main.c
	@mkdir -p $(OBJDIR)  # Create obj directory if it doesn't exist
	$(CC) $(CFLAGS) $(INCLUDES) -c $(SRCDIR)/main.c -o $(OBJDIR)/main.o

$(OBJDIR)/sexp.o: $(SRCDIR)/parser/sexp.c $(INCDIR)/sexp.h
	@mkdir -p $(OBJDIR)  # Create obj directory if it doesn't exist
	$(CC) $(CFLAGS) $(INCLUDES) -c $(SRCDIR)/parser/sexp.c -o $(OBJDIR)/sexp.o

clean:
	rm -rf $(OBJDIR) $(TARGET)

.PHONY: all clean

