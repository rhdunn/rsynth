PREFIX       = @prefix@
LIB_DIR      = $(PREFIX)/lib/dict

AUTOMAKE_OPTIONS = subdir-objects

localedir = $(datadir)/locale

AM_LDFLAGS  =
AM_CFLAGS = -DDICT_DIR=\"$(LIB_DIR)\" -DDEFAULT_DICT=\"$(DEFAULT_DICT)\"

ACLOCAL_AMFLAGS = -I m4

bin_PROGRAMS =
lib_LTLIBRARIES =
man1_MANS =
pkgdata_DATA =

noinst_bin_PROGRAMS =
noinst_LIBRARIES =

noinst_bindir =

EXTRA_DIST = config.rpath ChangeLog
CLEANFILES =
SUBDIRS =

############################# ChangeLog #######################################

ChangeLog:
	git log > ChangeLog

dist-hook: ChangeLog

.PHONY: ChangeLog

EXTRA_DIST += ChangeLog

############################# applications ####################################

COMMON_SOURCES = \
	opsynth.c \
	elements.c \
	holmes.c \
	trie.c \
	phtoelm.c \
	darray.c \
	say.c \
	phones.c \
	text.c \
	english.c \
	deutsch.c \
	charset.c

bin_PROGRAMS += say
say_SOURCES = ${COMMON_SOURCES} \
	hplay.c \
	l2u.c \
	aufile.c \
	getarg.c \
	Revision.c \
	dict.c \
	saymain.c

#bin_PROGRAMS += mkdictdb
mkdictdb_SOURCES = ${COMMON_SOURCES} \
	mkdictdb.c

bin_PROGRAMS += dlookup
dlookup_SOURCES = ${COMMON_SOURCES} \
	getarg.c \
	dict.c \
	dlookup.c

############################# dictionaries ####################################

#aDict.db : $(ADICT) mkdictdb
#	LANG=en_US mkdictdb $(ADICT) aDict.db
#	touch $@

#bDict.db : $(BDICT) mkdictdb
#	LANG=en_GB mkdictdb $(BDICT) bDict.db
#	touch $@

#install  : $(PROGS) $(DICTS) $(EXTRA_INST)
#	for f in $(DICTS); do \
#	$(INSTALL_DATA) $$f $(LIB_DIR); \
#	done
