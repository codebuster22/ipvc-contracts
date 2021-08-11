// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

contract WarriorAssetRegistry {

    bool public areAssetsRegistered;
    event AssetsRegistered(uint256 indexed generation, uint256 totalLayers, bytes32 indexed assetCid);

    /**
     * @dev                      register assets for a generation
     * @param _currentGeneration current generation
     * @param _totalLayers       total layers of warrior
     * @param _assetsCid         asset registry ipfs hash
     */
    function _registerAssets(uint256 _currentGeneration, uint256 _totalLayers, bytes32 _assetsCid) internal {
        require(
            _totalLayers != 0,
            "WarriorAssetRegistry: cannot have zero layers"
        );
        require(
            _assetsCid != bytes32(0),
            "WarriorAssetRegistry: cannot have CID zero"
        );
        areAssetsRegistered = true;
        emit AssetsRegistered(_currentGeneration, _totalLayers, _assetsCid);
    }

}