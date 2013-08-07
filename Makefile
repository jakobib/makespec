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

TEX_VARS=-V documentclass=scrreprt -V "mainfont=DejaVu Serif"

########################################################################

COMBINED = $(NAME).tmp

RESULTFILES  = $(NAME).html
RESULTFILES += $(foreach f,$(FORMATS),$(NAME).$(f))

########################################################################


info:
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
		GIT_CHANGES: changes.tmp \
		< $(SOURCE) | $(MAKESPEC)/include.pl >> $@
	@rm -f changes.tmp

status:
	@$(GIT) diff-index --quiet HEAD $(SOURCE) || echo "Current $(SOURCE) not checked in, so this is a DRAFT!"

$(NAME).html: $(COMBINED) $(HTML_TEMPLATE) status
	@echo "Creating $@..."
	@$(PANDOC) --smart -s -N --template=$(HTML_TEMPLATE) --toc -f markdown -t html5 $(VARS) $(COMBINED) \
		| perl -p -e 's!(http://[^<]+)\.</p>!<a href="$$1"><code class="url">$$1</code></a>.</p>!g' \
		| perl -p -e 's!(<h2(.+)span>\s*([^<]+)</a></h2>)!<a id="$$3"></a>$$1!g' \
		| sed 's!<td style="text-align: center;">!<td>!' > $@

$(NAME).tex:
	@$(PANDOC) --smart -s -N --template=$(TEX_TEMPLATE) --toc -f markdown -o $@ $(COMBINED) $(VARS) $(TEX_VARS)
#		$(BIBARGS) $(BIBLATEX)

$(NAME).pdf: $(COMBINED) $(TEX_TEMPLATE) status
	@echo "Creating $@..."
	@$(PANDOC) --smart -s -N --template=$(TEX_TEMPLATE) --latex-engine=xelatex --toc -f markdown -o $@ $(COMBINED) $(VARS) $(TEX_VARS)

# --bibliography=$(REFERENCES) 

$(NAME).epub: $(COMBINED) $(EPUB_CSS)
	$(PANDOC) --epub-stylesheet $(EPUB_CSS) -N -S --template $(HTML_TEMPLATE) --toc $(COMBINED) -o $@

$(NAME).rtf: $(COMBINED)
	@$(PANDOC) --smart -s -N --toc $(COMBINED) -o $@

$(NAME).odt: $(COMBINED)
	@$(PANDOC) --smart -s -N --toc $(COMBINED) -o $@

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

clean:
	@rm -f $(NAME)-*.* *.tmp

purge: clean
	@rm -f $(RESULTFILES)

.PHONY: info clean purge default status
