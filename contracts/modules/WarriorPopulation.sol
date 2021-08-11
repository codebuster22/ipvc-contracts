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
    uint256 public currentGenerationMaxPopulation;
    // total warrior minted - total warrior minted for this current generation
    uint256 public populationUntilLastGeneration;
    // population growth rate
    uint256 public growthRate = 391;   // 3.91

    constructor (uint256 _initialMaxPopulation, uint256 _maxPopulation) Warriors() {
       currentGenerationMaxPopulation = _initialMaxPopulation;
       maxPopulation = _maxPopulation;
    }

    /**
     * @dev    checks if total maximum reached
     * @return true if all warriors generated else false
     */
    function isMaxReached() internal view returns(bool) {
       return populationUntilLastGeneration < maxPopulation;
    }

    /**
     * @dev    calculate next generation population
     * @return next generation population
     */
   function _calculateNextGenPopulation() internal view returns(uint256 nextGenPopulation){
      uint256 currentPopPercent = (currentGenerationMaxPopulation * PRECISION) / maxPopulationPerGen;
      uint256 totalPrecision = PRECISION * GROWTH_PRECISION;
      uint256 nextPopPercent = ( growthRate * currentPopPercent * (10**18 - currentPopPercent) ) / totalPrecision;
      nextGenPopulation = (nextPopPercent * maxPopulationPerGen) / PRECISION;
   }

   /**
     * @dev    to follow standard of ERC721
     * @return maximum population of warriors.
     */
   function totalSupply() external view returns(uint256){
      return maxPopulation;
   }
}