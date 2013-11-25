# Introduction

{ABSTRACT}

# Usage

## Setup

Best practice using makedoc is to host your specification in a git repository,
optionally published at [GitHub](http://github.com/). Your repository should
contain at least:

 * The specification as Pandoc Markdown source file (e.g. `myspec.md`)
 * A `Makefile` with basic settings and [configuration], such as:

        NAME=myspec
        GITHUB=https://github.com/myaccount/myspec/

        include makespec/Makefile

 * A subdirectory `makespec` containing makespec. Best practice is inclusion
   as as git submodule. To do so in a new git repository:

        git submodule add https://github.com/jakobib/makespec.git

To clone an existing specification that uses makespace this way:

    git clone --recursive http://github.com/myaccount/myspec.git

If you publish the specification as GitHub pages, you should not forget to also
clone the `gh-pages` branch:

    git checkout -b gh-pages origin/gh-pages && git checkout master

## Workflow

Make sure you have the most recent version

    make pull

Edit the specification source file in Markdown syntax, for instance with vim
editor

    vim myspec.md

Create a HTML version

    make html

Commit to your repository

    git add Makefile myspec.md
    git commit -m "improved my fancy specification"

Create a `gh-pages` branch with the HTML version

    make website

Publish

    make push

## Configuration

[configuration]: #configuration

### Basic metadata

NAME
  : Required short name. Should not contain spaces and similar nasty characters.

SOURCE
  : Source file in Pandoc Markdown syntax, set to `$NAME.md` by default.

GITHUB
  : Github repository to link to in revision history.

TITLE
  : Title, unless already specified in the source file.

AUTHOR
  : List of authors, unless already specified in the source file.

DATE
  : Fixed date of publication. Set to a timestamp of the latest commit
    by default.

VERSION
  : A document version. Set to the current version by inspecting git tags
    by default. Setting `VERSION=none` will omit version numbers.
	
LANGUAGE
  : Document language code (passed to LaTeX or HTML).

ABSTRACT
  : A short abstract (in Markdown syntax) which is used as template 
    variable ABSTRACT.

ABSTRACT_FROM
  : A file to read abstract from if no ABSTRACT was defined. Set to
    `abstract.md` by default.

### Output control

REVISIONS
  : Number of revisions to show in the revision history (GIT_CHANGES).

FORMATS
  : If your specification contains a RDF ontology written in Turtle syntax,
    set `FORMATS=ttl owl`. More formats may be supported in the future.
    Format `html` is always enabled by default.

HTML_TEMPLATE
  : An optional Pandoc template for HTML output

HTML_TEMPLATE
  : An optional CSS file for HTML output

TEX_TEMPLATE
  : An optional Pandoc template for LaTeX and PDF output

## Document variables

The following variables, if enclosed in curly brackets (such as
`{THIS_VARIABLE}`) are automatically replaced before conversion from Markdown
syntax.

GIT_REVISION_DATE
  : timestamp of the latest commit.

GIT_REVISION_HASH
  : Short revision hash of the latest commit.

GIT_CHANGES
  : Revision history. Length can be set with configuration variable `REVISIONS`.

GIT_ATOM_FEED
  : URL of an Atom feed with revisions at GitHub.

ABSTRACT
  : Abstract, if defined with configuration variable `ABSTRACT` or 
    `ABSTRACT_FROM`.

VERSION
  : The current version number (see [versioning](#versioning)).
    
## Template variables

GITHUB
  : As defined in metadata variable GITHUB.

VERSION
  : The current version number (see [versioning](#versioning)).

lang
  : As defined in metadata variable LANGUAGE.

## Plugins

`plugins.md`{.include}

## Requirements

* GNU Make
* Perl >= 5.14.1
* [Pandoc](http://johnmacfarlane.net/pandoc/) version >= 1.9
* [Rapper](http://librdf.org/raptor/rapper.html) from Raptor RDF library
  (only if writing an RDF ontology)

## Versioning

Document versioning is based on git commits and tags. The **`VERSION`**
variable is set to the latest git tag, optionally appended by a revision
counter and the suffix '`-dirty`' for uncommitted changes. Version tags must
start with the small letter '`v`' followed by a digit. For instance if the
latest commit was tagged as '`v1.3`' then the version will be '`1.3`'. If two
commits have been made since this tag, the version will be '`1.3rev2`'. If the
git working copy further contains uncommitted changes, the version will be
'`1.3rev2-dirty`'. Without tags, version number are just based on the number of
commits, starting with '`rev0`' (no commit).

The version number can be used both as [document variable](#document-variables)
(`{‍VERSION}`) and as [template variable](#template-variables)
(`$VERSION$`). The default templates show version numbers in parentheses,
append to the date.

# Implementation

Makespec consists of a set of makefiles and Pandoc templates.

## How documents are build

    $SOURCE --> $NAME.tmp.md --> $NAME.(html|tex|pdf|odt...)

## How schemas are build

Schema output files are extracted from code sections of the source file.  All
schemas are checked for syntax errors.

    $SOURCE --> $(NAME).tmp.ttl --> $(NAME).(tmp|owl)

## Interaction with GitHub or another git remote

`make pull`:
    git pull origin master gh-pages --tags

`make push`:
	git push origin master gh-pages --tags

# Examples

The following specifications make use of makespec:

* [Simple Service Status Ontology (SSSO)](https://github.com/gbv/ssso)
* [Document Service Ontology (DSO)](https://github.com/gbv/dso)
* [Document Availability Information API (DAIA)](https://github.com/gbv/daiaspec)
* [Patrons Account Information API (PAIA)](https://github.com/gbv/paia)
* ...

Last but not least, the documentation of makespec is also created with makespec.

# Extension

The makefile `local.make` can be used for custom settings and extensions in
forks of makespec. Please don't commit this files together with changes to
makespec core files to facilitate merging back changes of your fork into
makespec.

# Revision history

[This document](https://github.com/jakobib/makespec/blob/master/README.md) with
version *{VERSION}* was last modified at *{GIT_REVISION_DATE}* with hash
*{GIT_REVISION_HASH}*.

Also available as [Atom feed]({GIT_ATOM_FEED}).

{GIT_CHANGES}

