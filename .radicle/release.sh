#!/usr/bin/env bash
# cargo install radicle-artifact --locked
set -euxo pipefail

REV=56f9a87218597df213174b448bcd750133e97015
TAG=v2.0.2
WASM=./release/tansu_v2.0.2.wasm
WASM_IPFS=ipfs://QmXqnfboZRjNmT6vVUhQri6MZepaXUn6AVWiH2CaKJ8DWh
ATT=./release/tansu-attestation_v2.0.2.json
ATT_IPFS=ipfs://QmVTNGMAWtLhCAdTBfrsehCmytYSoYswM57PxdZy9KvBXR
SBOM=./release/sbom.spdx_v2.0.2.json
SBOM_IPFS=ipfs://QmS5JaG4S8TwYmq8rUr7TG81PJUV2sTW5rtYk9cTB8SnxZ

W_CID=$(rad-artifact cid $WASM)
rad-artifact add $WASM --revision $REV --name wasm-${TAG}
rad-artifact location add $WASM_IPFS --revision $REV --cid $W_CID

A_CID=$(rad-artifact cid $ATT)
rad-artifact add $ATT --revision $REV --name attestation-provenance-${TAG}
rad-artifact location add $ATT_IPFS --revision $REV --cid $A_CID

S_CID=$(rad-artifact cid $SBOM)
rad-artifact add $SBOM --revision $REV --name sbom-spdx-${TAG}
rad-artifact location add $SBOM_IPFS --revision $REV --cid $S_CID

rad-artifact show --pretty $REV
