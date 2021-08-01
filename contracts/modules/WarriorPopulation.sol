// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "../Warriors.sol";

contract WarriorPopulation is Warriors{

    // constants
    uint256 public constant PRECISION = 10**18;
    uint256 public constant GROWTH_PRECISION = 100;

    // only 27 million warriors can be minted;
    uint256 public maxPopulation = 27000000;
    // theoretically 100 thousand warriors can be minted per generation;
    uint256 public maxPopulationPerGen = 100000;
    // maximum population for current generation, calculated using logistics equation
    uint256 public currentGenerationMaxPopulation = 14020;
    // total warrior minted - total warrior minted for this current generation
    uint256 public populationUntilLastGeneration;
    // population growth rate
    uint256 public growthRate = 391;

    /**
     * @dev calculate next generation population
     */
     function _calculateNextGenPopulation() internal view returns(uint256 nextGenPopulation){
        uint256 currentPopPercent = (currentGenerationMaxPopulation * PRECISION) / maxPopulationPerGen;
        uint256 totalPrecision = PRECISION * GROWTH_PRECISION;
        uint256 nextPopPercent = ( growthRate * currentPopPercent * (10**18 - currentPopPercent) ) / totalPrecision;
        nextGenPopulation = (nextPopPercent * maxPopulationPerGen) / PRECISION;
     }
}