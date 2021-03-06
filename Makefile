TOPDIR=.
include Makerules

TARGETS = $(EDIR)/wglreadtest.exe \
          $(EDIR)/wglspheres.exe \
          $(EDIR)/wglinfo.exe \
          $(EDIR)/faker.dll \
          $(EDIR)/vglrun.bat

FOBJS = $(ODIR)/faker.obj \
        $(ODIR)/pbwin.obj \
        $(ODIR)/rrblitter.obj

OBJS = $(FOBJS) \
       $(ODIR)/wglreadtest.obj \
       $(ODIR)/wglspheres.obj

all: util $(TARGETS)

.PHONY: util
util:
	cd $@; $(MAKE); cd ..

clean:
	-$(RM) $(TARGETS) $(OBJS); \
	cd util; $(MAKE) clean; cd ..

HDRS := $(wildcard ../include/*.h) $(wildcard *.h)
$(OBJS): $(HDRS)

$(EDIR)/wglspheres.exe: $(ODIR)/wglspheres.obj
	$(LINK) $(LDFLAGS) $< -out:$@ opengl32.lib glu32.lib user32.lib gdi32.lib

$(EDIR)/wglinfo.exe: $(ODIR)/wglinfo.obj
	$(LINK) $(LDFLAGS) $< -out:$@ opengl32.lib glu32.lib user32.lib gdi32.lib

$(EDIR)/wglreadtest.exe: $(ODIR)/wglreadtest.obj
	$(LINK) $(LDFLAGS) $< -out:$@ opengl32.lib glu32.lib user32.lib gdi32.lib

$(EDIR)/faker.dll: $(FOBJS)
	$(LINK) $(LDFLAGS) -dll $(FOBJS) -out:$@ detours.lib detoured.lib \
		opengl32.lib rrutil.lib $(FBXLIB)

$(EDIR)/vglrun.bat: vglrun.bat
	cp $< $@

WBLDDIR = $(TOPDIR)\\$(platform)$(subplatform)

ifeq ($(DEBUG), yes)
WBLDDIR := $(WBLDDIR)\\dbg
endif

DETOURSDIR=$$%systemdrive%\\Program Files\\Microsoft Research\\Detours Express 2.1

dist: all
	$(RM) $(WBLDDIR)\$(APPNAME)-Server.exe
	makensis //DAPPNAME=$(APPNAME)-Server //DVERSION=$(VERSION) \
		//DBUILD=$(BUILD) //DBLDDIR=$(WBLDDIR) //DDETOURSDIR="$(DETOURSDIR)" winfaker.nsi || \
	makensis /DAPPNAME=$(APPNAME)-Server /DVERSION=$(VERSION) \
		/DBUILD=$(BUILD) /DBLDDIR=$(WBLDDIR) /DDETOURSDIR="$(DETOURSDIR)" winfaker.nsi  # Cygwin doesn't like the //
