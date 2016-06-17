#based on https://gist.github.com/postmodern/3224049

NAME=radiosh
VERSION=0.0.1

DIRS=lib bin sbin share
INSTALL_DIRS=`find $(DIRS) -type d ! 2>/dev/null`
INSTALL_FILES=`find $(DIRS) -type f ! -name "*~" 2>/dev/null`

INSTALL_ETC_DIR=`find etc -type d ! 2>/dev/null`
INSTALL_ETC_FILES=`find etc -type f ! -name "*~" 2>/dev/null`

DOC_FILES=`find . -maxdepth 1 -type f -regextype sed -regex '.*[\.md|\.txt]$$' 2>/dev/null`

PREFIX?=/usr/local
ETC_PREFIX?=$(PREFIX)

DOC_DIR=$(PREFIX)/share/doc/$(NAME)

install:
	for dir in $(INSTALL_DIRS); do mkdir -p $(PREFIX)/$$dir; done
	for file in $(INSTALL_FILES); do \
		sed 's?^ETC_PREFIX=\".\"$$?ETC_PREFIX=\"$(ETC_PREFIX)\"?' $$file > $(PREFIX)/$$file; \
		chmod --reference=$$file $(PREFIX)/$$file; \
	done

	for dir in $(INSTALL_ETC_DIRS); do mkdir -p $(PREFIX)/$$dir; done
	for file in $(INSTALL_ETC_FILES); do cp $$file $(ETC_PREFIX)/$$file; done

	mkdir -p $(DOC_DIR)
	for doc in $(DOC_FILES); do cp $$doc $(DOC_DIR)/$$doc; done

uninstall:
	for file in $(INSTALL_FILES); do rm -f $(PREFIX)/$$file; done
	for file in $(INSTALL_ETC_FILES); do rm -f $(PREFIX)/$$file; done
	rm -rf $(DOC_DIR)

.PHONY: install uninstall