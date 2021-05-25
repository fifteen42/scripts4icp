#!/bin/sh

dir_name=`pwd`
base=`basename $dir_name`

dfx_version_full=`dfx --version`
dfx_version=${dfx_version_full: 4}

echo "{
    \"canisters\": {
      \"${base}\": {
        \"build\": \"cargo build --target wasm32-unknown-unknown --package  ${base} --release\",
        \"candid\": \"src/${base}/${base}.did\",
        \"wasm\": \"target/wasm32-unknown-unknown/release/${base}.wasm\",
        \"type\": \"custom\"
      },
      \"${base}_assets\": {
        \"dependencies\": [
          \"${base}\"
        ],
        \"frontend\": {
          \"entrypoint\": \"src/${base}_assets/src/index.html\"
        },
        \"source\": [
          \"src/${base}_assets/assets\",
          \"dist/${base}_assets/\"
        ],
        \"type\": \"assets\"
      }
    },
    \"defaults\": {
      \"build\": {
        \"packtool\": \"\"
      }
    },
    \"dfx\": \"${dfx_version}\",
    \"networks\": {
      \"local\": {
        \"bind\": \"127.0.0.1:8000\",
        \"type\": \"ephemeral\"
      }
    },
    \"version\": 1
  }" > dfx.json

echo "[workspace]
members = [
    \"src/${base}\",
]" > Cargo.toml

cd src/${base}

rm -f main.mo

cargo init --lib

echo "service : {
    \"print\": () -> () query;
}" > ${base}.did

mv Cargo.toml Cargo_before.toml

rm -f Cargo.toml

sed -n 1,8p Cargo_before.toml > Cargo.toml

rm -f Cargo_before.toml

echo "[lib]
crate-type = [\"cdylib\"]

[dependencies]
ic-cdk = \"0.2.4\"
ic-cdk-macros = \"0.2.4\"" >> Cargo.toml

cd src

rm -f lib.rs

echo "#[ic_cdk_macros::query]
fn print() {
    ic_cdk::print(\"Hello World\");
}" > lib.rs

