// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

contract WarriorAssetRegistry {

    bool internal _areAssetsRegistered;
    event AssetsRegistered(uint256 generation, uint256 totalLayers, bytes32 assetCid);

    function _registerAssets(uint256 _currentGeneration, uint256 _totalLayers, bytes32 _assetsCid) internal {
        require(
            _totalLayers != 0,
            "WarriorAssetRegistry: cannot have zero layers"
        );
        require(
            _assetsCid != bytes32(0),
            "WarriorAssetRegistry: cannot have CID zero"
        );
        _areAssetsRegistered = true;
        emit AssetsRegistered(_currentGeneration, _totalLayers, _assetsCid);
    }

}