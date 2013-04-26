# Introduction

**makespace** is a git repository containing a Makefile and templates to create
specifications written in [Pandoc Markdown]. The Makefile also supports
generating and updating [GitHub pages](http://pages.github.com/) to publish the
specification.

Feel free to reuse, [comment](https://github.com/jakobib/makespec/issues),
fork, and modify! The current version can be found at
<https://github.com/jakobib/makespec>.

# Usage

## Synopsis

Create a git repository to host your specification

    mkdir yourspec && cd yourspec
    git init

Include makespec as git submodule

    git submodule add https://github.com/jakobib/makespec.git

Create a short `Makefile` with basic metadata and settings

    NAME=yourspec
    GITHUB=http://github.com/youraccount/yourspec/
    FORMATS=
    REVISIONS=
    
    include makespec/Makefile

Write the specification in Markdown syntax, for instance with vim editor

    vim facyspec.md

Create a HTML version

    make html

Commit to your repository

    git add Makefile yourspec.md
    git commit -m "created a fancy specification"

Create a `gh-pages` branch with the HTML version

    make website

To fully clone a repository that makes use of makespec:

    git clone git@github.com:youraccount/yourspec.git
    git checkout -b gh-pages origin/gh-pages && git checkout master
    git submodule update --init

## Configuration

NAME
  : Required short name. Should not contain spaces and similar nasty characters.

SOURCE
  : Source file in Pandoc Markdown syntax, set to `NAME.md` by default.

GITHUB
  : Github repository to link to in revision history.

REVISIONS
  : Number of revisions to show in the revision history (GIT-CHANGES).

FORMATS
  : If your specification contains a RDF ontology written in Turtle syntax, 
    set `FORMATS=ttl owl`. More formats may be supported in the future.

TITLE
  : Title, unless already specified in the source file.

AUTHOR
  : List of authors, unless already specified in the source file.

## Variables

The following character strings (if you replace minus-signs with underscore)
are automatically replaced.

GIT-REVISION-DATE
  : timestamp of the latest commit.

GIT-REVISION-HASH
  : Short revision hash of the latest commit.

GIT-CHANGES
  : Revision history. Length can be set with `REVISIONS`.

GIT-ATOM-FEED
  : URL of an Atom feed with revisions at GitHub.

## Requirements

* GNU Make
* [Pandoc](http://johnmacfarlane.net/pandoc/) version >= 1.9
* [Rapper](http://librdf.org/raptor/rapper.html) from Raptor RDF library
  (only if writing an RDF ontology)

# Examples

The following specifications make use of makespec:

* [Simple Service Status Ontology (SSSO)](https://github.com/gbv/ssso)
* [Document Service Ontology (DSO)](https://github.com/gbv/dso)
* [Document Availability Information API (DAIA)](https://github.com/gbv/daiaspec)
* [Patrons Account Information API (PAIA)](https://github.com/gbv/paia)
* ...

Last but not least, the documentation of makespec is also created with makespec.
[This document](https://github.com/jakobib/makespec/blob/master/README.md) was
last modified at GIT_REVISION_DATE with hash GIT_REVISION_HASH.

[Pandoc Markdown]: http://johnmacfarlane.net/pandoc/demo/example9/pandocs-markdown.html

# Revision history

Also available as [Atom feed](GIT_ATOM_FEED).

GIT_CHANGES

