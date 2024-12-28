# Directories
FRONTEND_DIR := ./frontend
BACKEND_DIR := ./backend
PUBLIC_DIR := ./public

# Commands
ELM_MAKE := elm make
CARGO_BUILD := cargo build
CARGO_RUN := cargo run

# Targets
.PHONY: all frontend backend clean serve

all: frontend backend

frontend:
	cd $(FRONTEND_DIR) && $(ELM_MAKE) src/Main.elm --output=../$(PUBLIC_DIR)/main.js
	cp $(FRONTEND_DIR)/index.html $(PUBLIC_DIR)/
	cp $(FRONTEND_DIR)/src/ports.websocket.js $(PUBLIC_DIR)/

backend:
	$(CARGO_BUILD) --manifest-path=$(BACKEND_DIR)/Cargo.toml

serve: all
	$(CARGO_RUN) --manifest-path=$(BACKEND_DIR)/Cargo.toml

serve_debug: all
	RUST_LOG=info,actix_web=debug $(CARGO_RUN) --manifest-path=$(BACKEND_DIR)/Cargo.toml

clean:
	rm -rf $(PUBLIC_DIR)/*
	rm -rf $(BACKEND_DIR)/target

