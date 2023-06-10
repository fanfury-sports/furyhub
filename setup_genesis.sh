#!/bin/sh
#set -o errexit -o nounset -o pipefail


PASSWORD="Fury@nsH3adQu@rt3rs"
CHAIN_ID=${CHAIN_ID:-gridiron_4200-1001}
USER=${USER:-tupt}
MONIKER=${MONIKER:-arg001}

rm -rf $HOME/.fury

fury init --chain-id $CHAIN_ID "$MONIKER" --staking-bond-denom "utfury"

yes PASSWORD | fury keys add $USER 2>&1 | tee account.txt

# hardcode the validator account for this instance
yes PASSWORD | fury add-genesis-account $USER "120000020000utfury"

yes PASSWORD | fury add-genesis-account 'blackaa13kkekwjl8g8hx7laveepjqkm8kfa5een4fdxl2' "120000020000utfury"

sed -i -e 's/enabled-unsafe-cors *= *.*/enabled-unsafe-cors = true/g' .fury/config/app.toml
sed -i -e 's/cors_allowed_origins *= *.*/cors_allowed_origins = \[\"*\"\]/g' .fury/config/config.toml
sed -i -e 's/\<laddr\> *= *.*/laddr = \"tcp:\/\/0.0.0.0:26657\"/g' .fury/config/config.toml # replace exactly the string laddr with\< and \>



# submit a genesis validator tx
## Workraround for https://github.com/cosmos/cosmos-sdk/issues/8251
yes PASSWORD | fury gentx adrian 120000020000utfury --chain-id=$CHAIN_ID --amount=120000020000utfury -y

fury collect-gentxs
sed -i -e 's/stake/utfury/g' .fury/config/genesis.json

fury validate-genesis

# cat $PWD/.fury/config/genesis.json | jq .app_state.genutil.gen_txs[0] -c > "$MONIKER"_validators.txt

echo "The genesis initiation process has finished ..."

