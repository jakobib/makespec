ifeq ($(words $(MAKEFILE_LIST)),1)
	NAME     = makespec
	SOURCE   = makespec.md
	GITHUB   = https://$(GIT)hub.com/jakobib/makespec/
	TITLE    = Creating specifications with makespec
	AUTHOR   = Jakob Voß
	ABSTRACT_FROM = README.md
endif

ifeq ($(NAME),)
	NAME = $(shell basename $(CURDIR))
endif

ifeq ($(REVISIONS),)
	COMMIT_NUMBER = 5
else 
	COMMIT_NUMBER = $(REVISIONS)
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

REVHASH = $(shell $(GIT) log -1 --format="%H" -- $(SOURCE))
REVDATE = $(shell $(GIT) log -1 --format="%ai" -- $(SOURCE))
REVSHRT = $(shell $(GIT) log -1 --format="%h" -- $(SOURCE))

ifeq ($(DATE),)
	DATE = $(REVDATE)
endif

ifneq ($(GITHUB),)
	REVLINK = $(GITHUB)commit/$(REVHASH)
	GIT_ATOM_FEED = $(GITHUB)commits/master.atom
endif
