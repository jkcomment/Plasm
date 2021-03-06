#!/usr/bin/env bash

set -eux

# Enable warnings about unused extern crates
export RUSTFLAGS=" -W unused-extern-crates"

# Install rustup and the specified rust toolchain.
curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain=$RUST_TOOLCHAIN -y
# Load cargo environment. Specifically, put cargo into PATH.
source ~/.cargo/env

rustup install nightly-2019-05-21
rustup target add wasm32-unknown-unknown --toolchain nightly-2019-05-21
rustup override set nightly

rustc --version
rustup --version
cargo --version

case $TARGET in
	"native")
		sudo apt-get -y update
		sudo apt-get install -y cmake pkg-config libssl-dev

		./scripts/init.sh
		cargo build
		;;

	"wasm")

		# Install prerequisites and build all wasm projects
		cargo install pwasm-utils-cli --bin wasm-prune --force

		cd ./contracts/balances && ./build.sh && cargo test
		cd ./contracts/cash && ./build.sh && cargo test
		cd ../commitment && cargo test
		cd ../deposit && cargo test
		cd ../predicate && cargo test
		;;
esac
