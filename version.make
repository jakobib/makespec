########################################################################
# Create VERSION variable from git repository, unless already set      #
########################################################################

# make sure there is a git repository
HAS_REPOSITORY = $(shell $(GIT) rev-parse --git-dir 2>/dev/null)
GIT_WITH_REPO  = $(if $(HAS_REPOSITORY),$(GIT),$(error "Not a git repository - call 'git init'!"))

ifndef VERSION
 
	# get latest version tag (possibly empty) or exit if no git repository
	VERSION := $(shell $(GIT_WITH_REPO) describe --abbrev=0 --tags 2>/dev/null | sed '/^[^v][0-9]/d; s/^v//' | head -1)

	ifneq ($(REVHASH),)
		VERSION_HASH = $(if $(VERSION),$(shell $(GIT) rev-list v${VERSION} | head -1))

		ifneq ($(VERSION_HASH),$(REVHASH))
			ifeq ($(VERSION_HASH),)
				COMMITS_SINCE_VERSION=$(shell $(GIT) rev-list --all | wc -l)
			else
				COMMITS_SINCE_VERSION=$(shell $(GIT) rev-list v$(VERSION).. | wc -l)
			endif
			VERSION := $(VERSION)rev$(COMMITS_SINCE_VERSION)
		endif

		FILES_CHANGED = $(shell $(GIT) status --porcelain 2>/dev/null | sed '/^??/d' )
		ifneq ($(FILES_CHANGED),)
			VERSION := $(VERSION)-dirty
		endif
	else # not commited yet
		VERSION := rev0
	endif

else
	ifeq ($(VERSION),none)
		VERSION := 
	endif
endif

ifneq ($(VERSION),)
	ABOUT_VERSION=" - version $(VERSION)"
endif

