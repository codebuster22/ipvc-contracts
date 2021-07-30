// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "../utils/ERC721.sol";


contract Warriors is ERC721 {

    string public constant token_version = "0.1.0-beta";
    address public controller;

    // tokenId => warriorGene
    // warriorGene - {3 digits for country + 10 digits for characteristics}
    // Gene - (3 digits)+(two digits charateristics)x(5 layers) - total 10 digits
    // Total warriors - 200*99*99*99*99*99 = 19,01,98,00,99,800
    mapping( uint256 => uint256 ) private warriors;
    mapping( uint256 => bool ) public isGeneUsed;
    uint256 public warriorCounter;

    mapping( uint256 => uint256 ) public warriorGen;

    uint256 public maxPopulationPerGen = 100000;
    uint256 public currentGenerationMaxPopulation = 14020;
    uint256 public currentGenerationPopulation;
    uint256 public currentGeneration = 0;
    // with the starting contions, it will take 466 generations to reach 27 million warriors
    // last generation 466 is going to have 2189 warriors only
    // each generation will have random and unique population, thanks to chaos
    uint256 public constant lastGeneration = 466;
    uint256 public growthRate = 391;
    bool public isPopulating;

    uint256 public constant PRECISION = 10**18;
    uint256 public constant GROWTH_PRECISION = 100;

    event WarriorGenerated(address indexed owner, uint256 indexed warriorId);

    modifier onlyController {
        require(
            msg.sender == controller,
            "Warriors: Only controller can access this function"
        );
        _;
    }

    /**
     * @dev constructor
     * @param _controller controller address who is allowed to call write functions
     */
    constructor (address _controller) ERC721("Warriors","WRT") {
        require(
            _controller != address(0),
            "Warriors: Controller address cannot be zero address"
        );
        controller = _controller;
        isPopulating = true;
    }

    /**
      * @dev generateWarrior
      * @param _gene warrior gene for the token
      * @param _owner address of owner who requested to generate warrior
      */
    function generateWarrior(uint256 _gene, address _owner) external onlyController {
        require(
            isPopulating,
            "Warriors: wait for next generation warriors"
        );
        require(
            _gene != 0,
            "Warriors: no warrior without gene"
        );
        require(
            _owner != address(0),
            "Warriors: no warrior can be assigned to zero address"
        );
        require(
            isGeneUsed[_gene] == false,
            "Warriors: gene already used"
        );
        uint256 tokenId = warriorCounter;
        warriorCounter++;
        currentGenerationPopulation++;
        warriors[tokenId] = _gene;
        isGeneUsed[_gene] = true;
        if(currentGenerationPopulation == currentGenerationMaxPopulation){
            isPopulating = false;
        }
        _mint(_owner, tokenId);
        emit WarriorGenerated(_owner, tokenId);
    }

    /**
     * @dev update controller address
     * @param _newController controller address who is allowed to call write functions
     */
    function setController(address _newController) public onlyController {
        require(
            _newController!=address(0),
            "Warriors: controller cannot be address zero"
        );
        controller = _newController;
    }

    /**
     * @dev get warrior's gene
     * @param _warriorId id of warrior token
     */
    function getWarrior(uint256 _warriorId) external view returns(uint256 warrior) {
        warrior = warriors[_warriorId];
        require(
            warrior != 0,
            "Warriors: warrior does not exist"
        );
    }



    /**
     * @dev calculate next generation population
     */
     function calculateNextGenPopulation() public view returns(uint256 nextGenPopulation){
        uint256 currentPopPercent = (currentGenerationMaxPopulation * PRECISION) / maxPopulationPerGen;
        uint256 totalPrecision = PRECISION * GROWTH_PRECISION;
        uint256 nextPopPercent = ( growthRate * currentPopPercent * (10**18 - currentPopPercent) ) / totalPrecision;
        nextGenPopulation = (nextPopPercent * maxPopulationPerGen) / PRECISION;
     }

    //  /**
    //  * @dev calculate next generation population
    //  */
    //  function testCalculateNextGenPopulation(uint256 current) public view returns(uint256 nextGenPopulation){
    //     uint256 currentPopPercent = (current * PRECISION) / maxPopulation;
    //     uint256 totalPrecision = PRECISION * GROWTH_PRECISION;
    //     uint256 nextPopPercent = ( growthRate * currentPopPercent * (10**18 - currentPopPercent) ) / totalPrecision;
    //     nextGenPopulation = (nextPopPercent * maxPopulation) / PRECISION;
    //  }
}