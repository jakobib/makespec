########################################################################
# makespec Makefile - licensed under GPL 3.0 by Jakob Voss             #
#                                                                      #
# Current version: https://$(GIT)hub.com/jakobib/makespec              #
# Documentation:   http://jakobib.$(GIT)hub.com/makespec               #
#                                                                      #
# Requires at least GNU Make >= 3.81, Pandoc, Perl, and sed.           #
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
include $(MAKESPEC)/version.make
ifneq ($(wildcard $(MAKESPEC)/local.make),)
	include $(MAKESPEC)/local.make
endif

########################################################################

VARS=-V GITHUB=$(GITHUB) -V VERSION=$(VERSION) 

ifneq ($(LANGUAGE),)
	VARS += -V lang=$(LANGUAGE)
endif

ifneq ($(findstring owl,$(FORMATS)),)
	VARS += -V RDFXML_URL=$(NAME).owl
endif

########################################################################

COMBINED = $(NAME).tmp

RESULTFILES  = $(NAME).html
RESULTFILES += $(foreach f,$(FORMATS),$(NAME).$(f))

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
	@echo LANGUAGE='$(LANGUAGE)'
	@echo ABSTRACT_FROM='$(ABSTRACT_FROM)'
	@echo ABSTRACT='$(ABSTRACT)'
	@echo MAKESPEC='$(MAKESPEC)'
	@echo NAME='$(NAME)'
	@echo GITHUB='$(GITHUB)'
	@echo SOURCE='$(SOURCE)'
	@echo VERSION='$(VERSION)'
	@echo FORMATS='$(FORMATS)'
	@echo RESULTFILES='$(RESULTFILES)'
	@if [ "$(FORMATS)" ] ; then \
		for f in html $(FORMATS); do \
			echo "$$f"; \
		done \
	fi
	@echo VARS='$(VARS)'

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
		GITHUB '$(GITHUB)' \
		GIT_CHANGES: changes.tmp \
		< $(SOURCE) | $(MAKESPEC)/include.pl >> $@
	@rm -f changes.tmp

# TODO: More variables (?)
$(NAME).tmp.ttl: sources
	@$(MAKESPEC)/CodeBlocks $(TTLFORMAT) $(SOURCE) > $@
	@$(MAKESPEC)/CodeBlocks $(TTLFORMAT) $(SOURCE) | \
		$(MAKESPEC)/replace-vars.pl \
			GIT_REVISION_DATE '$(REVDATE)' \
	        VERSION '$(VERSION)' \
	    > $@

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
	@rm *.tmp
	@$(GIT) checkout gh-pages || ( $(GIT) checkout --orphan gh-pages && git rm -rf . )
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

clean: clean-tex
	@rm -f $(NAME)-*.* *.tmp *.log *.aux *.out *.toc

clean-tex:
	@rm -f *.out *.log *.aux *.bbl *.blg *.dvi *.toc

purge: clean
	@rm -f $(RESULTFILES)

.PHONY: info clean purge default status push pull reset-website
