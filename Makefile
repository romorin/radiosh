#based on https://gist.github.com/postmodern/3224049

# Definition

NAME=radiosh
VERSION=0.0.1

# Configuration

PREFIX?=/usr/local
ETC_PREFIX?=$(PREFIX)

# Valid values are LOCAL | GLOBAL | NONE
BASH_COMPLETION?=GLOBAL

# Variables

ifeq ($(BASH_COMPLETION), LOCAL)
	BASH_COMPLETION_PREFIX=$(HOME)
else ifeq ($(BASH_COMPLETION), GLOBAL)
	BASH_COMPLETION_PREFIX=/etc
else
	BASH_COMPLETION_PREFIX=""
endif

DIRS=lib bin sbin share
INSTALL_DIRS=`find $(DIRS) -type d 2>/dev/null`
INSTALL_FILES=`find $(DIRS) -type f ! -name "*~" 2>/dev/null`

INSTALL_ETC_DIR=$(PREFIX)/etc
INSTALL_ETC_FILES=`find etc -type f ! -name "*~" 2>/dev/null`

COMPLETION_DIR=$(BASH_COMPLETION_PREFIX)/bash_completion.d
COMPLETION_FILES=`find bash_completion.d -type f ! -name "*~" 2>/dev/null`

DOC_DIR=$(PREFIX)/share/doc/$(NAME)
DOC_FILES=`find . -maxdepth 1 -type f -regextype sed -regex '.*[\.md|\.txt]$$' 2>/dev/null`

# todo did not manage to find a way to do the same using a variable and preserve newlines
MESSAGES_LOC="/tmp/radiosh-makefile-output.txt"

install:
	touch $(MESSAGES_LOC)

	for dir in $(INSTALL_DIRS); do mkdir -p $(PREFIX)/$$dir; done
	for file in $(INSTALL_FILES); do \
		sed 's?^ETC_PREFIX=\".\"$$?ETC_PREFIX=\"$(ETC_PREFIX)\"?' $$file > $(PREFIX)/$$file; \
		chmod --reference=$$file $(PREFIX)/$$file; \
	done

	mkdir -p $(INSTALL_ETC_DIR)
	for file in $(INSTALL_ETC_FILES); do cp $$file $(ETC_PREFIX)/$$file; done

	mkdir -p $(DOC_DIR)
	for doc in $(DOC_FILES); do cp $$doc $(DOC_DIR)/$$doc; done

	if [ $(BASH_COMPLETION_PREFIX) != "" ]; then \
		$(eval HAS_COMPLETION="true") \
		mkdir -p $(COMPLETION_DIR) ; \
		for compl in $(COMPLETION_FILES) ; do \
			sed 's?^ETC_PREFIX=\".\"$$?ETC_PREFIX=\"$(ETC_PREFIX)\"?' $$compl > $(BASH_COMPLETION_PREFIX)/$$compl; \
			chmod --reference=$$compl $(BASH_COMPLETION_PREFIX)/$$compl; \
		done ; \
	fi
	if [ $(HAS_COMPLETION)="true" ]; then \
		echo "----------------------------------------------" > $(MESSAGES_LOC) ; \
		echo "" >> $(MESSAGES_LOC) ; \
		if [ $(BASH_COMPLETION) = LOCAL ]; then \
			echo "Please add the following into your ~/.bashrc :" >> $(MESSAGES_LOC) ; \
			\
			for compl in $(COMPLETION_FILES) ; do \
				echo "if [ -f \"$(BASH_COMPLETION_PREFIX)/$$compl\" ] ; then" >> $(MESSAGES_LOC) ; \
				echo "    . $(BASH_COMPLETION_PREFIX)/$$compl" >> $(MESSAGES_LOC) ; \
				echo "fi" >> $(MESSAGES_LOC) ; \
				echo "" >> $(MESSAGES_LOC) ; \
			done ; \
		fi ; \
		echo "Run the following to enable autocompletion on the current shell :" >> $(MESSAGES_LOC) ; \
		\
		for compl in $(COMPLETION_FILES) ; do \
			echo ". $(BASH_COMPLETION_PREFIX)/$$compl" >> $(MESSAGES_LOC) ; \
		done ; \
		echo "" >> $(MESSAGES_LOC) ; \
	fi
	cat $(MESSAGES_LOC) && rm $(MESSAGES_LOC)

uninstall:
	for file in $(INSTALL_FILES); do rm -f $(PREFIX)/$$file; done
	for file in $(INSTALL_ETC_FILES); do rm -f $(ETC_PREFIX)/$$file; done
	for file in $(COMPLETION_FILES); do rm -f $(BASH_COMPLETION_PREFIX)/$$file; done
	rm -rf $(DOC_DIR)

.PHONY: install uninstall
