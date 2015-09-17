########################################################################
# Define output formats                                                #
########################################################################

# document formats
html:  $(NAME).html # first rule, so this is the default
tex:   $(NAME).tex
pdf:   $(NAME).pdf
epub:  $(NAME).epub
epub3: $(NAME).epub3
rtf:   $(NAME).rtf
odt:   $(NAME).odt
docx:  $(NAME).docx

# schema formats
bnf:  $(NAME).bnf # Backus-Naur (TODO: which variant?)

ttl:  $(NAME).ttl # RDF/Turtle
owl:  $(NAME).owl # RDF/XML

rng:  $(NAME).rng # RELAX NG
xsd:  $(NAME).xsd # XML Schema
dtd:  $(NAME).dtd # DTD
sch:  $(NAME).sch # Schematron

sql:  $(NAME).sql # SQL Schema

########################################################################
# Configure HTML document output format                                #
########################################################################

HTML_ARGS = --smart --standalone --number-sections --section-divs --toc

HTML_TEMPLATE ?= $(MAKESPEC)/templates/default.html
HTML_CSS      ?=
HTML_VARS     ?=

ifneq ($(HTML_TEMPLATE),)
    HTML_ARGS += --template=$(HTML_TEMPLATE) 
endif

ifneq ($(HTML_CSS),)
    HTML_ARGS += --css=$(HTML_CSS) 
endif

$(NAME).html: $(COMBINED) $(HTML_TEMPLATE) status
	@echo "Creating $@..."
	@$(PANDOC) $(HTML_ARGS) -f markdown -t html5 $(VARS) $(HTML_VARS) $(COMBINED) \
		| perl -p -e 's!(http://[^<]+)\.</p>!<a href="$$1"><code class="url">$$1</code></a>.</p>!g' \
		| perl -p -e 's!(<h2(.+)span>\s*([^<]+)</a></h2>)!<a id="$$3"></a>$$1!g' \
		| sed 's!<td style="text-align: center;">!<td>!' > $@

########################################################################
# Configure LaTex and PDF document output formats                      #
########################################################################

TEX_ARGS = --smart --standalone --number-sections --toc --latex-engine=xelatex

TEX_TEMPLATE ?= $(MAKESPEC)/templates/default.latex
TEX_VARS     ?= -V documentclass=scrreprt -V "mainfont=DejaVu Serif"

ifneq ($(TEX_TEMPLATE),)
    TEX_ARGS += --template=$(TEX_TEMPLATE) 
endif

# TODO:	$(BIBARGS) $(BIBLATEX) ...

$(NAME).tex: $(COMBINED) $(TEX_TEMPLATE) status
	@echo "Creating $@..."
	@$(PANDOC) $(TEX_ARGS) -f markdown -o $@ $(VARS) $(TEX_VARS) $(COMBINED)

$(NAME).pdf: $(COMBINED) $(TEX_TEMPLATE) status
	@echo "Creating $@..."
	@$(PANDOC) $(TEX_ARGS) -f markdown -o $@ $(VARS) $(TEX_VARS) $(COMBINED)

########################################################################
# Configure Epub/Epub2 document output formats                         #
########################################################################

EPUB_ARGS = --smart --standalone --number-sections --toc 

EPUB_TEMPLATE ?=
EPUB_CSS      ?= $(MAKESPEC)/templates/default.epub.css
EPUB_VARS     ?=

# TODO: use HTML_TEMPLATE by default?
ifneq ($(EPUB_TEMPLATE),)
    EPUB_ARGS += --template=$(EPUB_TEMPLATE) 
endif

ifneq ($(EPUB_CSS),)
    EPUB_ARGS += --epub-stylesheet=$(EPUB_CSS) 
endif

# TODO:
# --bibliography=$(REFERENCES) 
# --epub-cover-image=
# --epub-embed-font=
# --epub-chapter-level=

$(NAME).epub: $(COMBINED)
	@echo "Creating $@..."
	@$(PANDOC) $(EPUB_ARGS) -f markdown -o $@ $(VARS) $(EPUB_VARS) $(COMBINED)

########################################################################
# Configure additional document output formats                         #
########################################################################

RTF_ARGS = --smart --standalone --number-sections --toc

$(NAME).rtf: $(COMBINED)
	@$(PANDOC) $(RTF_ARGS) -f markdown -o $@ $(COMBINED)

ODT_ARGS = --smart --standalone --number-sections --toc

$(NAME).odt: $(COMBINED)
	@$(PANDOC) $(ODT_ARGS) -f markdown -o $@ $(COMBINED)


