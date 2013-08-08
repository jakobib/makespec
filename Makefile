########################################################################
# makespec Makefile - licensed under GPL 3.0 by Jakob Voss             #
#                                                                      #
# Current version: https://$(GIT)hub.com/jakobib/makespec              #
# Documentation:   http://jakobib.$(GIT)hub.com/makespec               #
#                                                                      #
# Requires at least GNU Make >= 3.81, Pandoc, Perl, and sed. 		   #
########################################################################

# path of this file
MAKESPEC = $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

# makespec documents itself by default
ifeq ($(words $(MAKEFILE_LIST)),1)
	NAME     = makespec
	SOURCE   = makespec.md
	GITHUB   = https://github.com/jakobib/makespec/
	TITLE    = Creating specifications with makespec
	AUTHOR   = Jakob Voß
	ABSTRACT_FROM = README.md
endif

# include files
include $(MAKESPEC)/executables.make
include $(MAKESPEC)/configuration.make

########################################################################

# make sure there is a git repository
HAS_REPOSITORY = $(shell $(GIT) rev-parse --git-dir 2>/dev/null)
GIT_WITH_REPO  = $(if $(HAS_REPOSITORY),$(GIT),$(error "Not a git repository - call 'git init'!"))

# get latest version tag (possibly empty) or exit if no git repository
VERSION := $(shell $(GIT_WITH_REPO) describe --always --abbrev=0 --tags 2>/dev/null | sed '/^[^v]/d; s/^v//' | head -1)

ifneq ($(REVHASH),)
	VERSION_HASH = $(if $(VERSION),$(shell $(GIT) rev-list v${VERSION} | head -1))

	ifneq ($(VERSION_HASH),$(REVHASH))
		ifeq ($(VERSION_HASH),)
			COMMITS_SINCE_VERSION=$(shell $(GIT) rev-list --all | wc -l)
		else
			COMMITS_SINCE_VERSION=$(shell $(GIT) rev-list v$(VERSION).. | wc -l)
		endif
		VERSION := "$(VERSION)rev$(COMMITS_SINCE_VERSION)"
	endif

	FILES_CHANGED = $(shell $(GIT) status --porcelain 2>/dev/null | sed '/^??/d' )
	ifneq ($(FILES_CHANGED),)
		VERSION := "$(VERSION)-dirty"
	endif
else # not commited yet
	VERSION := "rev0"
endif

########################################################################

VARS=-V GITHUB=$(GITHUB) 

########################################################################

COMBINED = $(NAME).tmp

RESULTFILES  = $(NAME).html
RESULTFILES += $(foreach f,$(FORMATS),$(NAME).$(f))

########################################################################

include $(MAKESPEC)/formats.make
include $(MAKESPEC)/workflow.make

########################################################################

status:
ifeq ($(REVSHRT),)
	@echo "Not commited yet - version $(VERSION)"
else
	@echo "Last commit $(REVSHRT) at $(REVDATE) - version $(VERSION)"
#	@if [ -n "$(FILES_CHANGED)" ]; then echo "Your repository contains uncommitted changes!"; fi
endif

info: status
	@echo TITLE='$(TITLE)'
	@echo AUTHOR='$(AUTHOR)'
	@echo DATE='$(DATE)'
	@echo ABSTRACT_FROM='$(ABSTRACT_FROM)'
	@echo ABSTRACT='$(ABSTRACT)'
	@echo MAKESPEC='$(MAKESPEC)'
	@echo NAME='$(NAME)'
	@echo GITHUB='$(GITHUB)'
	@echo SOURCE='$(SOURCE)'
	@echo FORMATS='$(FORMATS)'
	@echo RESULTFILES='$(RESULTFILES)'
	@if [ "$(FORMATS)" ] ; then \
		for f in html $(FORMATS); do \
			echo "$$f"; \
		done \
	fi

sources: Makefile $(MAKESPEC) $(SOURCE) $(REFERENCES)

# rebuild all output formats
new: purge html $(FORMATS)

# TODO: REFERENCES and METADATA not supported yet
# TODO: automatically insert "fork me on GitHub" badge
# TODO: replacement vars, such as $(ABSTRACT) may contain nasty characters

$(COMBINED): sources
	@rm -f $@
	@if [ '$(TITLE)$(AUTHOR)' ]; then \
		echo "% $(TITLE)" > $@ ; \
		echo "% $(AUTHOR)" >> $@ ; \
		echo "% $(DATE)" >> $@ ; \
		echo "" >> $@ ; \
	fi
	@echo "" > changes.tmp
ifneq ($(REVSHRT),)
# TODO: follow additional source files?
	@$(GIT) log -n $(REVISIONS) --pretty=format:'$(LOGFORMAT)' --follow $(SOURCE) >> changes.tmp
endif
	@echo "" >> changes.tmp
	@$(MAKESPEC)/replace-vars.pl \
		GIT_REVISION_DATE '$(REVDATE)' \
		GIT_ATOM_FEED	  '$(GIT_ATOM_FEED)' \
		GIT_REVISION_HASH '[${REVSHRT}](${REVLINK})' \
		ABSTRACT '$(ABSTRACT)' \
		VERSION '$(VERSION)' \
		GIT_CHANGES: changes.tmp \
		< $(SOURCE) | $(MAKESPEC)/include.pl >> $@
	@rm -f changes.tmp

$(NAME).tmp.ttl: sources
	@$(MAKESPEC)/CodeBlocks $(TTLFORMAT) $(SOURCE) > $@

$(NAME).ttl: $(NAME).tmp.ttl
	@$(RAPPER) --guess $< -o turtle > $@
	
$(NAME).owl: $(NAME).tmp.ttl
	@$(RAPPER) --guess $< -o rdfxml > $@

revision: $(RESULTFILES)
	@for f in html $(FORMATS); do \
		cp $(NAME).$$f $(NAME)-$(REVSHRT).$$f ; \
	done 

website: sources clean purge revision $(RESULTFILES)
	@echo "new revision to be shown at $(GITHUB)"
	@rm $(RESULTFILES)
	@$(GIT) checkout gh-pages || $(GIT) checkout --orphan gh-pages
	@for f in html $(FORMATS); do \
		cp $(NAME)-$(REVSHRT).$$f $(NAME).$$f ; \
	done
	@echo "<!DOCTYPE html><html><head><meta http-equiv='refresh' content='0;url=$(NAME).html'/></head></html>" > index.html
	@$(GIT) add index.html $(NAME)-$(REVSHRT).html $(RESULTFILES)
	@$(GIT) commit -m "revision $(REVSHRT)"
	@$(GIT) checkout master

cleancopy:
	@echo "checking that no local modifcations exist..."
	@$(GIT) diff-index --quiet HEAD --

all: $(RESULTFILES)

clean:
	@rm -f $(NAME)-*.* *.tmp

purge: clean
	@rm -f $(RESULTFILES)

.PHONY: info clean purge default status push pull
