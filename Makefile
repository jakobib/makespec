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
include $(MAKESPEC)/formats.make

########################################################################

VARS=-V GITHUB=$(GITHUB) 

########################################################################

COMBINED = $(NAME).tmp

RESULTFILES  = $(NAME).html
RESULTFILES += $(foreach f,$(FORMATS),$(NAME).$(f))

VERSION=$(shell git describe --abbrev=0 --tags | sed '/^[^v]/d; s/^v//' | head -1)

########################################################################

info:
	@echo TITLE='$(TITLE)'
	@echo AUTHOR='$(AUTHOR)'
	@echo DATE='$(DATE)'
	@echo VERSION='$(VERSION)'
	@echo ABSTRACT_FROM='$(ABSTRACT_FROM)'
	@echo ABSTRACT='$(ABSTRACT)'
	@echo MAKESPEC='$(MAKESPEC)'
	@echo NAME='$(NAME)'
	@echo GITHUB='$(GITHUB)'
	@echo SOURCE='$(SOURCE)'
	@echo FORMATS='$(FORMATS)'
	@echo RESULTFILES='$(RESULTFILES)'
	@echo REVHASH='$(REVHASH)'
	@echo REVSHRT='$(REVSHRT)'
	@echo REVDATE='$(REVDATE)'
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
	@$(GIT) log -n $(REVISIONS) --pretty=format:'$(LOGFORMAT)' --follow $(SOURCE) >> changes.tmp
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

# TODO: make this a Makefile variable
status:
	@$(GIT) diff-index --quiet HEAD $(SOURCE) || echo "Current $(SOURCE) not checked in, so this is a DRAFT!"

$(NAME)-tmp.ttl: sources
	@$(MAKESPEC)/CodeBlocks $(TTLFORMAT) $(SOURCE) > $@

$(NAME).ttl: $(NAME)-tmp.ttl
	@$(RAPPER) --guess $< -o turtle > $@
	
$(NAME).owl: $(NAME)-tmp.ttl
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

.PHONY: info clean purge default status
