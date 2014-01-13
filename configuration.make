########################################################################
# Initialize configuration variables                                   #
########################################################################

ifeq ($(NAME),)
	NAME = $(shell basename $(CURDIR))
endif

ifeq ($(ABSTRACT)$(ABSTRACT_FROM),)
	ifneq ($(wildcard abstract.md),)
		ABSTRACT_FROM = abstract.md
	endif
endif

# note that ABSTRACT will never contain newlines!
ifeq ($(ABSTRACT),)
	ifneq ($(ABSTRACT_FROM),)
		ABSTRACT := $(shell cat "$(ABSTRACT_FROM)")
	endif
endif

ifeq ($(SOURCE),)
	SOURCE = $(NAME).md
endif

REVHASH = $(shell $(GIT) log -1 --format="%H"  2>/dev/null)
REVDATE = $(shell $(GIT) log -1 --format="%ad" --date=short 2>/dev/null)
REVTIME = $(shell $(GIT) log -1 --format="%ad" --date=iso 2>/dev/null)
REVSHRT = $(shell $(GIT) log -1 --format="%h"  2>/dev/null)

ifeq ($(DATE),)
	DATE = $(REVDATE)
endif

ifeq ($(REVISIONS),)
	REVISIONS = 5
endif

ifneq ($(GITHUB),)
	REVLINK       = $(GITHUB)commit/$(REVHASH)
	GIT_ATOM_FEED = $(GITHUB)commits/master.atom
    LOGFORMAT     = * [`%ci`]($(NAME)-%h.html): [%s]($(GITHUB)commit/%H)
else
    LOGFORMAT     = * [`%ci`]($(NAME)-%h.html): %s
endif

