# basic makefile for D language - made by darkstalker
DCC = dmd
DFLAGS = -w
LIBS = -L-lgtkd-3 -L-ldl
INCLUDE = -I/usr/include/d/gtkd-3/
SOURCES = . GBAUtils IO Structures
DFILES = $(foreach dir,$(SOURCES),$(wildcard $(dir)/*.d))
OBJ = $(addprefix build/, $(DFILES:.d=.o))
OUT = $(shell basename `pwd`)

.PHONY: all debug release profile clean

all: debug

debug:   DFLAGS += -g -debug
release: DFLAGS += -O -release -inline -noboundscheck
profile: DFLAGS += -g -O -profile

debug release profile: $(OUT)

$(OUT): $(OBJ)
	$(DCC) $(DFLAGS) -of$@ $(OBJ) $(INCLUDE) $(LIBS)
	strip $@

clean:
	@echo $(DFILES)
	rm -f *~ $(OBJ) $(OUT) trace.{def,log}

%.o: 
	$(DCC) $(DFLAGS) $(INCLUDE) $(LIBS) -of$@ -c $(subst .o,.d,$(subst build/,,$@))
