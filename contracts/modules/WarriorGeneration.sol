// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./WarriorPopulation.sol";
import "./WarriorAssetRegistry.sol";

contract WarriorGeneration is WarriorPopulation, WarriorAssetRegistry{

    // cooldown period before next generation warrior can be minted after the last warrior was minted.
    uint256 public immutable GENERATION_COOLDOWN;
    // current generation id
    uint256 public currentGeneration;
    // block number after which warriors for current generation can only be minted
    uint256 public nextGenerationStartBlock;
    // with the starting contions, it will take might 466 generations to reach 27 million warriors
    // each generation will have random and unique population, thanks to chaos

    modifier populationCheck{
        require(
            isMaxReached(),
            "Warriors: no more warrior can be minted"
        );
        require(
            currentGenerationPopulation() < currentGenerationMaxPopulation,
            "WarriorGeneration: no more warrior can be minted for this generation"
        );
        _;
    }

    /**
     * @dev                         constructor
     * @param _initialMaxPopulation starting generation maximum population
     * @param _maxPopulation        total maximum population of warriors || total supply
     * @param _cooldown             number of blocks required for cooldown
     */
    constructor(uint256 _initialMaxPopulation, uint256 _maxPopulation, uint256 _cooldown) WarriorPopulation(_initialMaxPopulation, _maxPopulation) {
        nextGenerationStartBlock = block.number + 500;
        GENERATION_COOLDOWN = _cooldown;

    }

    /**
      * @dev is warrior generation active
      */
    function isActive() public view returns(bool){
        return (nextGenerationStartBlock <= block.number) && isMaxReached();
    }

    /**
     * @dev current generation warrior population
     */
    function currentGenerationPopulation() public view returns(uint256) {
        return warriorCounter - populationUntilLastGeneration;
    }

    /**
     * @dev              get warrior's generation
     * @param _warriorId id of warrior token
     */
    function getWarriorGeneration(uint256 _warriorId) public view returns(uint256) {
        return (getWarrior(_warriorId)/10**72)%1000;
    }

    /**
      * @dev sequence of code to run, before warrior mint. It is marked virtual so that it can be overriden
      */
    function _beforeWarriorMint() internal virtual override{
        if(currentGenerationPopulation() == currentGenerationMaxPopulation){
            _endCurrentGeneration();
        }
    }

    /**
     * @dev end current generation minting and set values for next generation minting
     */
    function _endCurrentGeneration() internal{
        nextGenerationStartBlock = block.number + GENERATION_COOLDOWN;
        areAssetsRegistered = false;
        populationUntilLastGeneration = warriorCounter;
        currentGenerationMaxPopulation = _getNextGenerationPopulation();
        currentGeneration++;
    }

    /**
      * @dev calculate next generation population
      */
    function _getNextGenerationPopulation() internal view returns(uint256 nexGenPopulation)  {
        nexGenPopulation = _calculateNextGenPopulation();
        if(populationUntilLastGeneration + nexGenPopulation > maxPopulation){
            nexGenPopulation = maxPopulation - populationUntilLastGeneration;
        }
    }
}