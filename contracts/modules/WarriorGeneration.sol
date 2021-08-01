// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./WarriorPopulation.sol";

contract WarriorGeneration is WarriorPopulation{

    // cooldown period before next generation warrior can be minted after the last warrior was minted.
    uint256 public constant GENERATION_COOLDOWN = 22270;
    // current generation id
    uint256 public currentGeneration;
    // block number after which warriors for current generation can only be minted
    uint256 public nextGenerationStartBlock;
    // with the starting contions, it will take 466 generations to reach 27 million warriors
    // last generation 466 is going to have 2189 warriors only
    // each generation will have random and unique population, thanks to chaos
    uint256 public constant lastGeneration = 466;

    constructor() {
        nextGenerationStartBlock = block.number + 500;
    }

    modifier populationCheck{
        require(
            currentGenerationPopulation() < currentGenerationMaxPopulation,
            "Warriors: no more warrior can be minted for this generation"
        );
        _;
    }

    /**
      * @dev is warrior generation active
      */
    function isActive() public view returns(bool){
        return nextGenerationStartBlock <= block.number;
    }

    function currentGenerationPopulation() public view returns(uint256) {
        return warriorCounter - populationUntilLastGeneration;
    }

    function getWarriorGeneration(uint256 _warriorId) public view returns(uint256) {
        return (warriors[_warriorId]/10**72)%1000;
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
        currentGenerationMaxPopulation = _calculateNextGenPopulation();
        populationUntilLastGeneration = warriorCounter;
        currentGeneration++;
    }
}