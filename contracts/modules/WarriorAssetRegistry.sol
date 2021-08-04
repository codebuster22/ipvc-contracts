// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "hardhat/console.sol";

contract WarriorAssetRegistry{

    // assetId = {n-digits generation}{2-digits layer id}{2-digits asset id}
    event AssetRegistered(uint256 indexed assetId, bytes32 indexed assetCid);
    event AssetForLayerRegistered(uint256 indexed layerId, uint256 generation);

    function registerAsset(uint256 layerId, bytes32[] memory assetCids, uint256 generation) public virtual {
        uint256 baseId = (generation*10000)+(layerId*100);
        for(uint i; i < assetCids.length; i++){
            emit AssetRegistered((baseId + i), assetCids[i]);
        }
        emit AssetForLayerRegistered(layerId, generation);
    }

}