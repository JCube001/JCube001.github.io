SRC_DIR = src
DEST_DIR = build

.PHONY: all
all: serve

.PHONY: config
config:
	bundle config set --local path vendor/bundle

.PHONY: serve
serve:
	bundle exec jekyll serve --source $(SRC_DIR) --destination $(DEST_DIR) --watch --livereload

.PHONY: production
production:
	JEKYLL_ENV=production bundle exec jekyll build --source $(SRC_DIR) --destination $(DEST_DIR)

.PHONY: clean
clean:
	rm -rf $(DEST_DIR)
