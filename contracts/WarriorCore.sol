// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./interface/IGeneGenerator.sol";
import "./access/OriginControl.sol";
import "./modules/WarriorGeneration.sol";


contract WarriorCore is OriginControl, WarriorGeneration {

    string public constant version = "0.1.0-beta";

    address public warriorGeneGeneratorContract;// address of WarriorGeneGenerator contract

    bool public isInitialized;                 // status of Controller contract, 1 - initialized, 0 - not initialized
    bytes32 public constant SALT = keccak256("generateWarrior(uint256, address)");

    mapping (bytes32 => bool) public isMetadataUsed;

    /**
     * @dev                         constructor
     * @param _initialMaxPopulation starting generation maximum population
     * @param _maxPopulation        total maximum population of warriors || total supply
     * @param _cooldown             number of blocks required for cooldown
     */
    constructor (
        uint256 _initialMaxPopulation,
        uint256 _maxPopulation,
        uint256 _cooldown
    ) WarriorGeneration(_initialMaxPopulation, _maxPopulation, _cooldown) { }

    /**
     * @dev                                 initialize contract
     * @param _origin                       origin address
     * @param _warriorGeneGeneratorContract warrior gene generator contract address
     */
    function initialize(
        address _origin,
        address _warriorGeneGeneratorContract
    ) public onlyAdmin() {
        require(
            !isInitialized,
            "WarriorCore: already initialized"
        );
        require(
            _origin != address(0) &&
            _warriorGeneGeneratorContract != address(0),
            "WarriorCore: zero address not allowed"
        );
        origin = _origin;
        warriorGeneGeneratorContract = _warriorGeneGeneratorContract;
        isInitialized = true;
    }

    /**
     * @dev                    generate warrior
     * @param _owner           owner address
     * @param _metadata        metadata
     * @param _originSignature signature to verify the transaction was sent from dapp
     */
    function generateWarrior(
        address _owner,
        bytes32 _metadata,
        bytes memory _originSignature
    ) public populationCheck onlyOrigin(_owner, _metadata, _originSignature) {
        require(
            areAssetsRegistered,
            "WarriorCore: assets not yet registered"
        );
        require(
            _metadata != bytes32(0),
            "WarriorCore: cannot mint warrior without attributes"
        );
        require(
            _owner != address(0),
            "WarriorCore: no warrior can be assigned to zero address"
        );
        require(
            !isMetadataUsed[_metadata],
            "WarriorCore: metadata already used"
        );
        require(
            isActive(),
            "WarriorCore: wait for next generation warriors to arrive"
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
        revert("WarriorCore: gene already used");
    }

    /**
     * @dev                     set gene generator contract address
     * @param _newGeneGenerator new gene generator address
     */
    function setGeneGenerator(address _newGeneGenerator) external onlyAdmin{
        require(
            _newGeneGenerator != address(0),
            "WarriorCore: gene generator cannot be zero address"
        );
        warriorGeneGeneratorContract = _newGeneGenerator;
    }

    /**
     * @dev                register assets for a generation
     * @param _totalLayers total layers of warrior
     * @param _assetsCid   asset registry ipfs hash
     */
    function registerAssets(uint256 _totalLayers, bytes32 _assetsCid) public onlyAdmin {
        require(
            block.number < nextGenerationStartBlock,
            "WarriorCore: cannot change asset while sale is active"
        );
        _registerAssets(currentGeneration, _totalLayers, _assetsCid);
    }
}