########################################################################
# makespec Makefile - licensed under GPL 3.0 by Jakob Voss             #
#                                                                      #
# Current version: https://github.com/jakobib/makespec                 #
# Documentation:   http://jakobib.github.com/makespec                  #
#                                                                      #
# Requires GNU Make.                                                   #
########################################################################

DIRNAME  = $(shell basename $(CURDIR))
MAKESPEC = $(wildcard makespec)

ifeq ($(DIRNAME),makespec)
	ifeq ($(MAKESPEC),)
		NAME     = makespec
		GITHUB   = https://github.com/jakobib/makespec/
		SOURCE   = README.md
		MAKESPEC = .
		TITLE    = Creating specifications with makespec
		AUTHOR   = Jakob Voß
	endif
endif

ifeq ($(NAME),)
	NAME = $(DIRNAME)
endif

ifeq ($(REVISIONS),)
	COMMIT_NUMBER = 5
else 
	COMMIT_NUMBER = $(REVISIONS)
endif

########################################################################

ifeq ($(SOURCE),)
	SOURCE = $(NAME).md
endif

REVHASH = $(shell git log -1 --format="%H" -- $(SOURCE))
REVDATE = $(shell git log -1 --format="%ai" -- $(SOURCE))
REVSHRT = $(shell git log -1 --format="%h" -- $(SOURCE))

ifneq ($(GITHUB),)
	REVLINK = $(GITHUB)commit/$(REVHASH)
	GIT_ATOM_FEED = $(GITHUB)commits/master.atom
endif

COMBINED = $(NAME)-tmp.md

RESULTFILES  = $(NAME).html
RESULTFILES += $(foreach f,$(FORMATS),$(NAME).$(f))

HTML_TEMPLATE=$(MAKESPEC)/templates/default.html
VARS=-V GITHUB=$(GITHUB)

########################################################################

info:
	@echo MAKESPEC=$(MAKESPEC)
	@echo NAME=$(NAME)
	@echo GITHUB=$(GITHUB)
	@echo SOURCE=$(SOURCE)
	@echo FORMATS=$(FORMATS)
	@echo RESULTFILES=$(RESULTFILES)
	@echo REVHASH=$(REVHASH)
	@echo REVSHRT=$(REVSHRT)
	@echo REVDATE=$(REVDATE)
	@if [ "$(FORMATS)" ] ; then \
		for f in html $(FORMATS); do \
			echo "$$f"; \
		done \
	fi		

sources: Makefile $(MAKESPEC) $(SOURCE) $(REFERENCES)

new: purge html $(FORMATS)

html: $(NAME).html
pdf:  $(NAME).pdf
ttl:  $(NAME).ttl
owl:  $(NAME).owl

# TODO: REFERENCES and METADATA not supported yet
# TODO: automatically insert "fork me on GitHub" badge

$(COMBINED): sources changes.md
	@rm -f $@
	@if [ '$(TITLE)$(AUTHOR)' ]; then \
		echo "% $(TITLE)" > $@ ; \
		echo "% $(AUTHOR)" >> $@ ; \
		echo "% $(REVDATE)" >> $@ ; \
		echo "" >> $@ ; \
	fi
	@sed 's/GIT_REVISION_DATE/${REVDATE}/' $(SOURCE) \
		| sed 's!GIT_ATOM_FEED!${GIT_ATOM_FEED}!' \
		| sed 's!GIT_REVISION_HASH![${REVSHRT}](${REVLINK})!' \
		| perl -p -e 's!GIT_CHANGES!`cat changes.md`!ge' >> $@

$(NAME).html: $(COMBINED) $(HTML_TEMPLATE)
	@echo "Creating $@..."
	@pandoc -s -N --template=$(HTML_TEMPLATE) --toc -f markdown -t html5 $(VARS) $(COMBINED) \
		| perl -p -e 's!(http://[^<]+)\.</p>!<a href="$$1"><code class="url">$$1</code></a>.</p>!g' \
		| perl -p -e 's!(<h2(.+)span>\s*([^<]+)</a></h2>)!<a id="$$3"></a>$$1!g' \
		| sed 's!<td style="text-align: center;">!<td>!' > $@
	@git diff-index --quiet HEAD $(SOURCE) || echo "Current $(SOURCE) not checked in, so this is a DRAFT!"

# FIXME: the current PDF does not look that nice...
#$(NAME).pdf: sources
#	pandoc -N --bibliography=$(REFERENCES) --toc -f markdown -o $(NAME).pdf $(SOURCE)

$(NAME)-tmp.ttl: sources
	@./$(MAKESPEC)/CodeBlocks $(TTLFORMAT) $(SOURCE) > $@

$(NAME).ttl: $(NAME)-tmp.ttl
	@rapper --guess $< -o turtle > $@
	
$(NAME).owl: $(NAME)-tmp.ttl
	@rapper --guess $< -o rdfxml > $@

changes: changes.md

changes.md: sources
	@echo "" > $@
	@git log -n $(COMMIT_NUMBER) \
	--pretty=format:'* [`%ci`]($(NAME)-%h.html): [%s]($(GITHUB)commit/%H)' $(SOURCE) >> $@
	@echo "" >> $@

revision: $(RESULTFILES)
	@for f in html $(FORMATS); do \
		cp $(NAME).$$f $(NAME)-$(REVSHRT).$$f ; \
	done 

website: sources clean purge revision $(RESULTFILES)
	@echo "new revision to be shown at $(GITHUB)"
	@rm $(RESULTFILES)
	@git checkout gh-pages || git checkout --orphan gh-pages
	@for f in html $(FORMATS); do \
		cp $(NAME)-$(REVSHRT).$$f $(NAME).$$f ; \
	done
	@echo "<!DOCTYPE html><html><head><meta http-equiv='refresh' content='0;url=$(NAME).html'/></head></html>" > index.html
	@git add index.html $(NAME)-$(REVSHRT).html $(RESULTFILES)
	@git commit -m "revision $(REVSHRT)"
	@git checkout master

cleancopy:
	@echo "checking that no local modifcations exist..."
	@git diff-index --quiet HEAD --

clean:
	@rm -f $(NAME)-*.* *.tmp

purge: clean
	@rm -f $(RESULTFILES) changes.md

.PHONY: clean purge html

