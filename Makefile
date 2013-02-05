
PROJECT = GifMan.xcodeproj
PRODUCTS_DIR = Build/Release

BUNDLE_TARGET = GifMan SIMBL Bundle
STYLE_TARGET = GifMan Chat Style

STYLE_INSTALL_DIR = ~/Library/Application\ Support/Skype/ChatStyles
SIMBLE_INSTALL_DIR = ~/Library/Application\\\ Support/SIMBL
BUNDLE_INSTALL_DIR = $(SIMBLE_INSTALL_DIR)/Plugins

LAUNCH_AGENT_INSTALL_DIR = ~/Library/LaunchAgents
LAUNCH_AGENT_PLIST_FILE = com.tomarnfeld.gifman.plist

#
# GifMan Makefile
#

all: clean bundle style

#
# Build Targets
#

bundle:
	@echo "`tput setaf 2`Bilding SIMBL bundle`tput sgr0`"
	@xcodebuild -project "$(PROJECT)" -target "$(BUNDLE_TARGET)"

style:
	@echo "`tput setaf 2`Building skype style`tput sgr0`"
	@xcodebuild -project "$(PROJECT)" -target "$(STYLE_TARGET)"

simbl:
	@if [[ `ps ax | grep "SIMBL Agent" | grep -v "grep" | wc -l | awk '{print $1}'` -lt 1 ]]; \
	then \
		echo "`tput setaf 2`Installing SIMBL`tput sgr0`"; \
		mkdir -p $(SIMBLE_INSTALL_DIR); \
		cp -r SIMBLAgent.app $(SIMBLE_INSTALL_DIR)/SIMBLAgent.app; \
		cat launch-agent.plist | sed 's|SIMBL_APP_PLACEHOLDER|$(SIMBLE_INSTALL_DIR)/SIMBLAgent|g' > $(LAUNCH_AGENT_INSTALL_DIR)/$(LAUNCH_AGENT_PLIST_FILE); \
		launchctl load $(LAUNCH_AGENT_INSTALL_DIR)/$(LAUNCH_AGENT_PLIST_FILE); \
	else \
		echo "`tput setaf 2`Reloading SIMBL`tput sgr0`"; \
		launchctl unload $(LAUNCH_AGENT_INSTALL_DIR)/$(LAUNCH_AGENT_PLIST_FILE); \
		launchctl load $(LAUNCH_AGENT_INSTALL_DIR)/$(LAUNCH_AGENT_PLIST_FILE); \
	fi

#
# Clean Targets
#

clean:
	@echo "`tput setaf 2`Cleaning Build/ directory`tput sgr0`"
	@rm -rf Build

clean-bundle:
	@echo "`tput setaf 2`Cleaning GifMan.bundle`tput sgr0`"
	@rm -rf $(PRODUCTS_DIR)/GifMan.bundle
	@rm -rf $(PRODUCTS_DIR)/GifMan.bundle.dSYM

clean-style:
	@echo "`tput setaf 2`Cleaning GifMan.SkypeChatStyle`tput sgr0`"
	@rm -rf $(PRODUCTS_DIR)/GifMan.SkypeChatStyle

#
# Install Targets
#

install: install-bundle install-style

install-bundle: simbl bundle
	@echo "`tput setaf 2`Installing $(PRODUCTS_DIR)/GifMan.bundle to $(BUNDLE_INSTALL_DIR)/GifMan.bundle`tput sgr0`"
	@mkdir -p $(BUNDLE_INSTALL_DIR)
	@rm -rf $(BUNDLE_INSTALL_DIR)/GifMan.bundle
	@cp -r $(PRODUCTS_DIR)/GifMan.bundle $(BUNDLE_INSTALL_DIR)/GifMan.bundle

install-style: style
	@echo "`tput setaf 2`Installing $(PRODUCTS_DIR)/GifMan.SkypeChatStyle to $(STYLE_INSTALL_DIR)/GifMan.SkypeChatStyle`tput sgr0`"
	@mkdir -p $(STYLE_INSTALL_DIR)
	@rm -rf $(STYLE_INSTALL_DIR)/GifMan.SkypeChatStyle
	@cp -r $(PRODUCTS_DIR)/GifMan.SkypeChatStyle $(STYLE_INSTALL_DIR)/GifMan.SkypeChatStyle
