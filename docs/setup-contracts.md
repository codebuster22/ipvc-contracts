# How to setup contracts

## Instantiate contracts

### import artifacts

```js
import ContractArtifact from 'ContractArtifact.json';
```

### instantiate contract

```js
const contract = new ethers.Contract(ContractArtifact.address, ContractArtifacts.abi, provider);
```

### read data from contract

```js
// 'read' is any arbitrary function with modifier view/pure
const data = await contract.read();
```

## Write data to contract

```js
// 'write' is any arbitrary function which modifies state variables.
arguments = ['argument1', 'argument2'...];
await contract.write(...arguments);
```