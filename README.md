# makespec

**makespace** is a git repository containing Makefiles and templates to create
specifications written in [Pandoc Markdown]. The current version can be found
at <https://github.com/jakobib/makespec>. Feel free to 
[comment](https://github.com/jakobib/makespec/issues), reuse, fork, and modify!


    Simple Markdown file ---makespec--->  HTML page
                                          Website
                                          Schema files
                                          ...

## Requirements

* GNU Make
* [Pandoc](http://johnmacfarlane.net/pandoc/) version >= 1.9
* [Rapper](http://librdf.org/raptor/rapper.html) from Raptor RDF library
  (only if writing an RDF ontology)

## Usage

You should manage the specification in a git repository for revision control:

    mkdir yourspec && cd yourspec
    git init

Write the specification in Markdown syntax with an editor of your choice:

    vim facyspec.md
    git add fancyspec.md
    git commit -m "created a fancy specification"

Copy or clone makespec into subdirectory `makespec`. I recommend to use it as git
submodule:

    git submodule add https://github.com/jakobib/makespec.git

Create a minimal Makefile with basic metadata like this:

    NAME=fancyspec
    GITHUB=http://github.com/youraccount/yourspec/
    FORMATS=
    
    include makespec/Makefile

If your specification contains a RDF ontology written in Turtle syntax, set the
"`FORMATS=ttl owl`". To create a nice looking HTML version of your specification
(and RDF files, if selected), just run:

    make

In addition makespec contains experimental support of generating and updating
[GitHub pages](http://pages.github.com/).

Have a look at `makespec/Makefile` for detailed usage. Additional parameters
include:

* REVISIONS - number of revisions to show at `GIT_CHANGES`
* TTLFORMAT - CodeBlock format to extract as RDF/Turtle

## Examples

The following specifications make use of makespec:

* [Simple Service Status Ontology (SSSO)](https://github.com/gbv/ssso)
* [Document Service Ontology (DSO)](https://github.com/gbv/dso)
* [Document Availability Information API (DAIA)](https://github.com/gbv/daiaspec)
* [Patrons Account Information API (PAIA)](https://github.com/gbv/paia)
* ...


[Pandoc Markdown]: http://johnmacfarlane.net/pandoc/demo/example9/pandocs-markdown.html

