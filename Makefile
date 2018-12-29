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
	@echo - bundle-install
	@echo - migrations
	@echo - populate-db
	@echo - stylesheets
	@echo - db-console

.PHONY: server
server: bundle-install migrations populate-db $(stylesheet_targets)
	$(BUNDLE) exec puma

.PHONY: bundle-install
bundle-install:
	$(BUNDLE) install --path ./vendor

.PHONY: migrations
migrations: | $(DB_DIR)
	$(BUNDLE) exec sequel -E -m ./migrations $(DB_URI)

.PHONY: populate-db
populate-db:
	$(BUNDLE) exec ruby ./script/populate_db.rb

.PHONY: stylesheets
stylesheets:  $(stylesheet_targets)

$(CSS_DIR)/%.css: stylesheets/%.scss | $(CSS_DIR)
	$(BUNDLE) exec sass $< $@

.PHONY: db-console
db-console:
	$(BUNDLE) exec sequel $(DB_URI)

######### ######### #########

$(DB_DIR):
	mkdir -p $@

$(CSS_DIR):
	mkdir -p $@
