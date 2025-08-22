# Flashbots Rbuilder on Fusaka Devnet ⚡

A simple setup for running **Rbuilder**, **Reth** (execution client), and **Lighthouse** (consensus client) on the **fusaka-devnet-3** network. Not intended for production use.

> **Source**: Most configuration code is derived from the [ethpandaops/fusaka-devnets](https://github.com/ethpandaops/fusaka-devnets) repository.

## 📋 Prerequisites

Before starting, ensure you have the following tools installed:

- **OpenSSL** — For generating cryptographic keys
- **cast** — Part of [Foundry](https://getfoundry.sh/introduction/installation/) toolkit
- **jq** — Command-line JSON processor
- **Docker** — For running containerized services
- **Make** — For executing setup commands

## 🚀 Quick Start

### Initial Setup

Run the automated setup command:

```bash
make setup
```

This command performs three operations:

#### 1. Generate JWT Secret for reth

Creates a secure JWT secret for reth:
```bash
openssl rand -hex 32 > ./config/reth/jwt.secret
```

#### 2. Create New Wallet

Generates a fresh 24-word mnemonic wallet:
```bash
cast wallet new-mnemonic --words 24 --json > ./config/rbuilder/wallet.json
```

#### 3. Configure Private Key

Automatically inserts the wallet's private key into the environment configuration:
```bash
sed -i "s|^COINBASE_SECRET_KEY=.*|COINBASE_SECRET_KEY=$(jq -r '.accounts[0].private_key' ./config/rbuilder/wallet.json | sed 's/^0x//')|" ./config/rbuilder/rbuilder.env
```

> ⚠️ Always generate a fresh wallet for production use. Never use the demo wallet included in the repository.

### Fund Your Wallet

Retrieve your newly generated wallet address:

```bash
make address
```

Fund your wallet using the [Fusaka Devnet-3 Faucet](https://faucet.fusaka-devnet-3.ethpandaops.io/).

### Launch the Node

Start all services:

```bash
make run
```

Monitor synchronization progress:

```bash
make check-sync
```

## 📊 Monitoring & Logs

View real-time logs for each component:

| Component      | Command                |
|----------------|------------------------|
| **Reth**       | `make reth-logs`       |
| **Lighthouse** | `make lighthouse-logs` |
| **Rbuilder**   | `make rbuilder-logs`   |

## ⚙️ Configuration

### Rbuilder Settings

Customize Rbuilder parameters by editing:

```bash
./config/rbuilder/rbuilder.toml
```

Refer to the [Rbuilder documentation](https://github.com/bharath-123/rbuilder/blob/fusaka-devnet-3/docs/CONFIG.md) for detailed configuration options.

### Network Endpoints

| Service                 | Endpoint                                                                                                   |
|-------------------------|------------------------------------------------------------------------------------------------------------|
| **Block Explorer**      | [explorer.fusaka-devnet-3.ethpandaops.io](https://explorer.fusaka-devnet-3.ethpandaops.io/)                |
| **Faucet**              | [faucet.fusaka-devnet-3.ethpandaops.io](https://faucet.fusaka-devnet-3.ethpandaops.io/)                    |
| **RPC Endpoint**        | [rpc.fusaka-devnet-3.ethpandaops.io](https://rpc.fusaka-devnet-3.ethpandaops.io/)                          |
| **MEV-Boost Relay API** | [mev-relay-1.fusaka-devnet-3.ethpandaops.io:9062](http://mev-relay-1.fusaka-devnet-3.ethpandaops.io:9062/) |
| **MEV-Boost Relay UI**  | [mev-relay-1.fusaka-devnet-3.ethpandaops.io:9060](http://mev-relay-1.fusaka-devnet-3.ethpandaops.io:9060/) |

## 🧹 Clean

Remove all data:

```bash
make clean
```

> **Note**: This action is irreversible and will delete all blockchain data.

## Gotchas

The default configuration uses a Rbuilder Docker image from a personal registry. If you prefer to build your own image instead:

```bash
# Clone the fusaka-compatible rbuilder fork
git clone https://github.com/bharath-123/rbuilder
cd rbuilder

git checkout fusaka-devnet-3
docker build -t rbuilder:local .
```

Then update the [docker compose](docker-compose.yaml) configuration to use `rbuilder:local` instead of the registry image.