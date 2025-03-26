# Compiler and flags
CC = gcc
CFLAGS = -Wall -g

# Directories
SRCDIR = src
INCDIR = include
OBJDIR = obj

# Files
TARGET = cicero
SRCFILES = $(SRCDIR)/main.c $(SRCDIR)/parser/sexp.c $(SRCDIR)/expr.c
OBJFILES = $(OBJDIR)/main.o $(OBJDIR)/sexp.o $(OBJDIR)/expr.o

# Include directories
INCLUDES = -I$(INCDIR)

# Targets

all: $(TARGET)

$(TARGET): $(OBJFILES)
	$(CC) $(INCLUDES) $(OBJFILES) -o $(TARGET)

$(OBJDIR)/main.o: $(SRCDIR)/main.c $(SRCDIR)/parser/sexp.c $(SRCDIR)/expr.c
	@mkdir -p $(OBJDIR)  # Create obj directory if it doesn't exist
	$(CC) $(CFLAGS) $(INCLUDES) -c $(SRCDIR)/main.c -o $(OBJDIR)/main.o

$(OBJDIR)/sexp.o: $(SRCDIR)/parser/sexp.c $(INCDIR)/sexp.h
	@mkdir -p $(OBJDIR)  # Create obj directory if it doesn't exist
	$(CC) $(CFLAGS) $(INCLUDES) -c $(SRCDIR)/parser/sexp.c -o $(OBJDIR)/sexp.o

$(OBJDIR)/expr.o: $(SRCDIR)/expr.c $(INCDIR)/expr.h $(INCDIR)/value.h
	@mkdir -p $(OBJDIR)  # Create obj directory if it doesn't exist
	$(CC) $(CFLAGS) $(INCLUDES) -c $(SRCDIR)/expr.c -o $(OBJDIR)/expr.o

clean:
	rm -rf $(OBJDIR) $(TARGET)

.PHONY: all clean

