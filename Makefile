# See https://tech.davis-hansson.com/p/make/ for a write-up of these settings

# Use bash and set strict execution mode
SHELL:=bash
.SHELLFLAGS := -eu -o pipefail -c

MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

# Targets

default: build

build:
	bundle exec jekyll build

serve:
	bundle exec jekyll serve

watch:
	bundle exec jekyll serve -l



