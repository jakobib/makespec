########################################################################
# Configure output formats                                             #
########################################################################

# document formats
html:  $(NAME).html # first rule, so this is the default
pdf:   $(NAME).pdf
tex:   $(NAME).tex
epub:  $(NAME).epub
epub3: $(NAME).epub3
rtf:   $(NAME).rtf
odt:   $(NAME).odt
docx:  $(NAME).docx

HTML_TEMPLATE = $(MAKESPEC)/templates/default.html
TEX_TEMPLATE  = $(MAKESPEC)/templates/default.latex
EPUB_CSS      = $(MAKESPEC)/templates/default.epub.css

# schema formats
bnf:  $(NAME).bnf # Backus-Naur (TODO: which variant?)

ttl:  $(NAME).ttl # RDF/Turtle
owl:  $(NAME).owl # RDF/XML

rng:  $(NAME).rng # RELAX NG
xsd:  $(NAME).xsd # XML Schema
dtd:  $(NAME).dtd # DTD
sch:  $(NAME).sch # Schematron

sql:  $(NAME).sql # SQL Schema
