# Setup ethers.js

## Setup

### Install ethers.js

```bash
npm install --save ethers
```

### Import getEthers into project

```js
import getEthers from 'getEthers.js';
```

### get provider and ethers object

```js
const {provider, ethers} = await getEthers();
```

### get signer

```js
const signer = provider.getSigner();
```

## Common terminology

1. Provider:- A Provider (in ethers) is a class which provides an abstraction for a connection to the Ethereum Network. It provides read-only access to the Blockchain and its status.

2. Signer:- A Signer is a class which (usually) in some way directly or indirectly has access to a private key, which can sign messages and transactions to authorize the network to charge your account ether to perform operations.

3. Contract:- A Contract is an abstraction which represents a connection to a specific contract on the Ethereum Network, so that applications can use it like a normal JavaScript object.