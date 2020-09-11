#!/usr/bin/env bash
NODEOS_RUNNING=$1

set -m

# CAUTION: Never use these development keys for a production account!
# Doing so will most certainly result in the loss of access to your account, these private keys are publicly known.
SYSTEM_ACCOUNT_PRIVATE_KEY="5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3"
SYSTEM_ACCOUNT_PUBLIC_KEY="EOS6MRyAjQq8ud7hVNYcfnVPJqcVpscN5So8BhtHuGYqET5GDW5CV"

ROOT_DIR="/home/gitpod"
CONTRACTS_DIR="$ROOT_DIR/contracts"
BLOCKCHAIN_DATA_DIR=$ROOT_DIR/eosio/chain/data
BLOCKCHAIN_CONFIG_DIR=$ROOT_DIR/eosio/chain/config
WALLET_DIR="$ROOT_DIR/eosio-wallet"

function post_preactivate {
  curl -X POST http://127.0.0.1:8888/v1/producer/schedule_protocol_feature_activations -d '{"protocol_features_to_activate": ["0ec7e080177b2c02b278d5088611686b49d739925a92d9bfcacd7fc6b74053bd"]}'
}

# $1 account name
# $2 contract directory
# $3 wasm file name
# $4 abi file name
function setcode {
  retry_count="4"

  while [ $retry_count -gt 0 ]; do
    cleos set code $1 $2 -p $1@active
    if [ $? -eq 0 ]; then
      break
    fi

    echo "setcode failed retrying..."
    sleep 1s
    retry_count=$[$retry_count-1]
  done

  if [ $retry_count -eq 0 ]; then
    echo "setcode failed too many times, bailing."
    exit 1
  fi
}

# $1 account name
# $2 contract directory
# $3 abi file name
function setabi {
  retry_count="4"

  while [ $retry_count -gt 0 ]; do
    cleos set abi $1 $2 -p $1@active
    if [ $? -eq 0 ]; then
      break
    fi

    echo "setcode failed retrying..."
    sleep 1s
    retry_count=$[$retry_count-1]
  done

  if [ $retry_count -eq 0 ]; then
    echo "setcode failed too many times, bailing."
    exit 1
  fi
}

# $1 - account name
# $2 - public key
# $3 - private key
function create_account {
  cleos wallet import --private-key $3
  cleos create account eosio $1 $2
}

# Move into the executable directory
cd $ROOT_DIR/
mkdir -p $CONFIG_DIR
mkdir -p $BLOCKCHAIN_DATA_DIR
mkdir -p $BLOCKCHAIN_CONFIG_DIR

if [ -z "$NODEOS_RUNNING" ]; then
  echo "Starting the chain for setup"
  nodeos -e -p eosio \
  --data-dir $BLOCKCHAIN_DATA_DIR \
  --config-dir $BLOCKCHAIN_CONFIG_DIR \
  --http-validate-host=false \
  --plugin eosio::producer_api_plugin \
  --plugin eosio::chain_api_plugin \
  --plugin eosio::http_plugin \
  --http-server-address=0.0.0.0:8888 \
  --access-control-allow-origin=* \
  --contracts-console \
  --max-transaction-time=100000 \
  --verbose-http-errors &
fi

mkdir -p "$CONFIG_DIR"/keys

sleep 1s

echo "Waiting for the chain to finish startup"
until curl localhost:8888/v1/chain/get_info
do
  echo "Still waiting"
  sleep 1s
done

# Sleep for 2s to allow time for 4 blocks to be created so we have blocks to reference when sending transactions
sleep 2s
echo "Creating accounts and deploying contracts"

# preactivate concensus upgrades
post_preactivate

sleep 1s
cleos wallet unlock --password </password
setabi eosio $CONTRACTS_DIR/boot/boot.abi
setcode eosio $CONTRACTS_DIR/boot/boot.wasm
sleep 2s
cleos push action eosio boot "[]" -p eosio@active

sleep 1s
setcode eosio $CONTRACTS_DIR/system/system.wasm
setabi eosio $CONTRACTS_DIR/system/system.abi

# token
sleep 1s
create_account returnvalue $SYSTEM_ACCOUNT_PUBLIC_KEY $SYSTEM_ACCOUNT_PRIVATE_KEY

sleep 1s
cleos set abi returnvalue $CONTRACTS_DIR/action_results/action_results.abi -p returnvalue@active -p eosio@active
cleos set code returnvalue $CONTRACTS_DIR/action_results/action_results.wasm -p returnvalue@active -p eosio@active

cleos push action eosio init "[]" -p eosio@active

echo "All done initializing the blockchain"

if [[ -z $NODEOS_RUNNING ]]; then
  echo "Shut down Nodeos, sleeping for 2 seconds to allow time for at least 4 blocks to be created after deploying contracts"
  sleep 2s
  kill %1
  fg %1
fi
