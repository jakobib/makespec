PANDOC = $(shell which pandoc)
ifeq ($(PANDOC),)
    PANDOC = $(error pandoc is required but not installed)
endif

GIT = $(shell which git)
ifeq ($(GIT),)
    GIT = $(error git is required but not installed)
endif

RAPPER = $(shell which rapper)
ifeq ($(RAPPER),)
    RAPPER = $(error rapper is required but raptor-utils are not installed)
endif
