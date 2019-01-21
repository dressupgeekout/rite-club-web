BUNDLE?=	bundle
BEXEC?=		$(BUNDLE) exec
PUMA?=		puma
RUBY?=		ruby
SASS?=		sass
SEQUEL?=	sequel

DB_DIR=		db
CSS_DIR=	$(CURDIR)/public/css

export RACK_ENV?=	development
export DB_URI=		sqlite://$(DB_DIR)/$(RACK_ENV).sqlite3

STYLESHEETS=	# defined
STYLESHEETS+=	default.scss

MODELS=		# defined
MODELS+=	exile
MODELS+=	input_method
MODELS+=	rite
MODELS+=	stage
MODELS+=	triumvirate
MODELS+=	user

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
	$(BEXEC) $(PUMA)

.PHONY: memcached-check
memcached-check:
	@pgrep memcached >/dev/null 2>&1 || (echo "error: memcached is not running?" && exit 1)

.PHONY: bundle-install
bundle-install:
ifneq ($(BEXEC),)
	$(BUNDLE) install --path ./vendor
endif

.PHONY: migrations
migrations: | $(DB_DIR)
	$(BEXEC) $(SEQUEL) -E -m ./migrations $(DB_URI)

.PHONY: populate-db
populate-db:
	$(BEXEC) $(RUBY) ./script/populate_db.rb

.PHONY: stylesheets
stylesheets:  $(stylesheet_targets)

$(CSS_DIR)/%.css: stylesheets/%.scss | $(CSS_DIR)
	$(BEXEC) $(SASS) $< $@

.PHONY: db-console
db-console:
	$(BEXEC) $(SEQUEL) $(foreach model,$(MODELS),-r./models/$(model).rb) $(DB_URI)

######### ######### #########

$(DB_DIR):
	mkdir -p $@

$(CSS_DIR):
	mkdir -p $@
