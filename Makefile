NAME := $(notdir $(CURDIR))
# See: https://github.com/japaric/xargo/issues/209
TARGET := $(shell rustup toolchain list | grep default | cut -f 1 -d ' ' | sed -e 's/^\(stable\|nightly\)-//')
PROFILE := release
FILE := target/$(TARGET)/$(PROFILE)/$(NAME)

NIGHTLY := rustup run nightly

.PHONY: deps
deps:
	cargo install xargo
	cargo install cargo-bloat
	rustup toolchain install nightly
	$(NIGHTLY) rustup component add rust-src

.PHONY: clean
clean:
	rm -rf target

.PHONY: build
build: clean
	$(NIGHTLY) xargo build --$(PROFILE) --target $(TARGET)
	@echo See $(FILE)

.PHONY: bloat
bloat: clean
	$(NIGHTLY) xargo bloat --$(PROFILE) --target $(TARGET)

.PNONY: run
run: clean
	$(NIGHTLY) xargo run --$(PROFILE) --target $(TARGET)
