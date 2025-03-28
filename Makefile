# Compiler and flags
CC = gcc
CFLAGS = -Wall -g -O0

# Directories
SRCDIR = src
INCDIR = include
OBJDIR = obj

# Files
TARGET = cicero
SRCFILES = $(SRCDIR)/main.c $(SRCDIR)/expr.c $(SRCDIR)/interp.c $(SRCDIR)/value.c $(SRCDIR)/parser/sexp.c $(SRCDIR)/values/int.c $(SRCDIR)/values/func.c $(SRCDIR)/values/poopcrap.c $(SRCDIR)/values/type.c
OBJFILES = $(OBJDIR)/main.o $(OBJDIR)/sexp.o $(OBJDIR)/expr.o $(OBJDIR)/interp.o $(OBJDIR)/value.o $(OBJDIR)/int.o $(OBJDIR)/func.o $(OBJDIR)/poopcrap.o $(OBJDIR)/type.o

# Include directories
INCLUDES = -I$(INCDIR) -I$(INCDIR)/values

# Targets

all: $(TARGET)

$(TARGET): $(OBJFILES)
	$(CC) $(INCLUDES) $(OBJFILES) -o $(TARGET)

$(OBJDIR)/main.o: $(SRCDIR)/main.c $(SRCDIR)/parser/sexp.c $(SRCDIR)/expr.c $(SRCDIR)/interp.c $(SRCDIR)/value.c
	@mkdir -p $(OBJDIR)  # Create obj directory if it doesn't exist
	$(CC) $(CFLAGS) $(INCLUDES) -c $(SRCDIR)/main.c -o $(OBJDIR)/main.o

$(OBJDIR)/sexp.o: $(SRCDIR)/parser/sexp.c $(INCDIR)/sexp.h
	@mkdir -p $(OBJDIR)  # Create obj directory if it doesn't exist
	$(CC) $(CFLAGS) $(INCLUDES) -c $(SRCDIR)/parser/sexp.c -o $(OBJDIR)/sexp.o

$(OBJDIR)/expr.o: $(SRCDIR)/expr.c $(INCDIR)/expr.h $(INCDIR)/value.h $(INCDIR)/values/int.h
	@mkdir -p $(OBJDIR)  # Create obj directory if it doesn't exist
	$(CC) $(CFLAGS) $(INCLUDES) -c $(SRCDIR)/expr.c -o $(OBJDIR)/expr.o

$(OBJDIR)/interp.o: $(SRCDIR)/interp.c $(INCDIR)/interp.h $(INCDIR)/expr.h $(INCDIR)/values/int.h $(INCDIR)/values/func.h
	@mkdir -p $(OBJDIR)  # Create obj directory if it doesn't exist
	$(CC) $(CFLAGS) $(INCLUDES) -c $(SRCDIR)/interp.c -o $(OBJDIR)/interp.o

$(OBJDIR)/value.o: $(SRCDIR)/value.c $(INCDIR)/value.h $(INCDIR)/values/int.h $(INCDIR)/values/func.h $(INCDIR)/values/poopcrap.h $(INCDIR)/values/type.h
	@mkdir -p $(OBJDIR)  # Create obj directory if it doesn't exist
	$(CC) $(CFLAGS) $(INCLUDES) -c $(SRCDIR)/value.c -o $(OBJDIR)/value.o

$(OBJDIR)/int.o: $(SRCDIR)/values/int.c $(INCDIR)/values/int.h $(INCDIR)/value.h $(INCDIR)/values/type.h $(INCDIR)/values/poopcrap.h 
	@mkdir -p $(OBJDIR)  # Create obj directory if it doesn't exist
	$(CC) $(CFLAGS) $(INCLUDES) -c $(SRCDIR)/values/int.c -o $(OBJDIR)/int.o

$(OBJDIR)/func.o: $(SRCDIR)/values/func.c $(INCDIR)/values/func.h $(INCDIR)/value.h $(INCDIR)/values/type.h $(INCDIR)/values/poopcrap.h
	@mkdir -p $(OBJDIR)  # Create obj directory if it doesn't exist
	$(CC) $(CFLAGS) $(INCLUDES) -c $(SRCDIR)/values/func.c -o $(OBJDIR)/func.o

$(OBJDIR)/poopcrap.o: $(SRCDIR)/values/poopcrap.c $(INCDIR)/values/poopcrap.h $(INCDIR)/value.h $(INCDIR)/values/type.h
	@mkdir -p $(OBJDIR)  # Create obj directory if it doesn't exist
	$(CC) $(CFLAGS) $(INCLUDES) -c $(SRCDIR)/values/poopcrap.c -o $(OBJDIR)/poopcrap.o

$(OBJDIR)/type.o: $(SRCDIR)/values/type.c $(INCDIR)/values/type.h $(INCDIR)/value.h $(INCDIR)/values/poopcrap.h
	@mkdir -p $(OBJDIR)  # Create obj directory if it doesn't exist
	$(CC) $(CFLAGS) $(INCLUDES) -c $(SRCDIR)/values/type.c -o $(OBJDIR)/type.o
clean:
	rm -rf $(OBJDIR) $(TARGET)

.PHONY: all clean

