BUNDLE?=	bundle

DB_DIR=		db
CSS_DIR=	$(CURDIR)/public/css

export RACK_ENV?=	development
export DB_URI=		sqlite://$(DB_DIR)/$(RACK_ENV).sqlite3

STYLESHEETS=	# defined
STYLESHEETS+=	default.scss

stylesheet_targets=	$(foreach stylesheet,$(STYLESHEETS),$(CSS_DIR)/$(subst .scss,.css,$(stylesheet)))

.PHONY: help
help:
	@echo Available targets:
	@echo - server
	@echo - migrations
	@echo - bundle-install
	@echo - stylesheets

.PHONY: server
server: bundle-install migrations $(stylesheet_targets)
	$(BUNDLE) exec puma

.PHONY: bundle-install
bundle-install:
	$(BUNDLE) install --path ./vendor

.PHONY: migrations
migrations: | $(DB_DIR)
	$(BUNDLE) exec sequel -E -m ./migrations $(DB_URI)

.PHONY: stylesheets
stylesheets:  $(stylesheet_targets)

$(CSS_DIR)/%.css: stylesheets/%.scss | $(CSS_DIR)
	$(BUNDLE) exec sass $< $@

######### ######### #########

$(DB_DIR):
	mkdir -p $@

$(CSS_DIR):
	mkdir -p $@
