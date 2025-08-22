.PHONY: setup run stop restart clean address check-block check-block-global check-sync reth-logs lighthouse-logs rbuilder-logs

JWT_SECRET := ./config/reth/jwt.secret
WALLET_JSON := ./config/rbuilder/wallet.json
ENV_FILE := ./config/rbuilder/rbuilder.env
RPC_LOCAL := http://localhost:8545
RPC_GLOBAL := https://rpc.fusaka-devnet-3.ethpandaops.io

setup:
	@openssl rand -hex 32 > $(JWT_SECRET)
	@cast wallet new-mnemonic --words 24 --json > $(WALLET_JSON)
	@sed -i "s|^COINBASE_SECRET_KEY=.*|COINBASE_SECRET_KEY=$$(jq -r '.accounts[0].private_key' $(WALLET_JSON) | sed 's/^0x//')|" $(ENV_FILE)
	@echo "⚡ Setup complete! ⚡"

run:
	@docker compose up -d

stop:
	@docker compose down

reth-logs:
	@docker compose logs -f reth 

lighthouse-logs:
	@docker compose logs -f lighthouse

rbuilder-logs:
	@docker compose logs -f rbuilder

restart: stop run

clean:
	@rm -rf data/lighthouse/*
	@rm -rf data/reth/*

address:
	@jq -r '.accounts[0].address' $(WALLET_JSON)

define rpc_call
	@curl -sX POST $(1) \
		-H "Content-Type: application/json" \
		-d '{"jsonrpc":"2.0","method":"$(2)","params":[],"id":1}' | jq
endef

check-block:
	$(call rpc_call,$(RPC_LOCAL),eth_blockNumber)

check-block-global:
	$(call rpc_call,$(RPC_GLOBAL),eth_blockNumber)

check-sync:
	$(call rpc_call,$(RPC_LOCAL),eth_syncing)