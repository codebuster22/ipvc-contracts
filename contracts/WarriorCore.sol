// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./interface/IGeneGenerator.sol";
import "./access/OriginControl.sol";
import "./modules/WarriorGeneration.sol";
import "./modules/WarriorAssetRegistry.sol";


contract WarriorCore is OriginControl, WarriorGeneration, WarriorAssetRegistry {

    string public constant version = "0.1.0-beta";

    address public warriorGeneGeneratorContract;// address of WarriorGeneGenerator contract

    bool public isInitialized;                 // status of Controller contract, 1 - initialized, 0 - not initialized
    bytes32 public constant SALT = keccak256("generateWarrior(uint256, address)");

    mapping (bytes32 => bool) public isMetadataUsed;

    constructor (
        uint256 _initialMaxPopulation,
        uint256 _maxPopulation,
        uint256 _cooldown
    ) WarriorGeneration(_initialMaxPopulation, _maxPopulation, _cooldown) { }

    function initialize(
        address _origin,
        address _warriorGeneGeneratorContract
    ) public onlyAdmin() {
        require(
            !isInitialized,
            "Controller: already initialized"
        );
        require(
            _origin != address(0) &&
            _warriorGeneGeneratorContract != address(0),
            "Controller: zero address not allowed"
        );
        origin = _origin;
        warriorGeneGeneratorContract = _warriorGeneGeneratorContract;
        isInitialized = true;
    }

    function generateWarrior(
        address _owner,
        bytes32 _metadata,
        bytes memory _originSignature
    ) public populationCheck onlyOrigin(_owner, _metadata, _originSignature) {
        require(
            _metadata != bytes32(0),
            "Warriors: cannot mint warrior without attributes"
        );
        require(
            _owner != address(0),
            "Warriors: no warrior can be assigned to zero address"
        );
        require(
            !isMetadataUsed[_metadata],
            "WarriorCore: metadata already used"
        );
        require(
            isActive(),
            "Controller: wait for next generation warriors to arrive"
        );
        bytes32 metadata = _metadata;
        isMetadataUsed[_metadata] = true;
        for(uint256 rounds; rounds<2; rounds++) {
            uint256 gene = IGeneGenerator(warriorGeneGeneratorContract).generateGene(currentGeneration, metadata);
            if(!isGeneUsed[gene]){
                _generateWarrior(gene, _owner);
                return;
            }
            metadata = keccak256(abi.encodePacked(SALT, metadata));
        }
        revert("Warriors: gene already used");
    }

    function setGeneGenerator(address _newGeneGenerator) external onlyAdmin{
        require(
            _newGeneGenerator != address(0),
            "Controller: gene generator cannot be zero address"
        );
        warriorGeneGeneratorContract = _newGeneGenerator;
    }

    function registerAsset(uint256 layerId, bytes32[] memory assetCids, uint256 generation) public override onlyAdmin {
        super.registerAsset(layerId, assetCids, generation);
    }
}