#
# This is the top-level Makefile. Nothing interesting happens here; for
# every target we change to src/ first and build it there.
#

all: 	config.mk
	$(MAKE) -C src $@

clobber: config.mk
	$(MAKE) -C src $@
	rm -f config.mk

%: 	config.mk
	$(MAKE) -C src $@


config.mk:
	@echo "Have you run ./configure? ./config.mk is missing"
