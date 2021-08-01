// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;


contract WarriorGeneGenerator{

    address public controller;
    uint256 public constant genModulus = 10**72;
    uint256 public constant genStartPosition = 1;
    uint256 public constant attributeStartPosition = 4;
    uint256 public constant GEN_PREFIX = 10**75;

    modifier onlyController() {
        require(
            msg.sender == controller,
            "WarriorGeneGenerator: only controller functionality"
        );
        _;
    }

    /**
     * @dev constructor to set inital value.
     */
    constructor (address _controller) {
        controller = _controller;
    }

    /**
     * @dev generate warrior gene
     * @param _metadata unique metadata using which the warrior attributes are generated
     */
    function geneGenerator(uint256 _currentGen, bytes32 _metadata) public onlyController view returns(uint256 gene){
        gene = uint256(_metadata);
        // gene = {1-digit prefix}{3-digits generation}{72-digits attributes}
        gene = (gene % genModulus)+(_currentGen*genModulus)+GEN_PREFIX;
    }

    /**
     * @dev set new controller
     * @param _newController new controller address
     */
    function setController(address _newController) public onlyController{
        require(
            _newController != address(0),
            "WarriorGeneGenerator: new controller cannot be zero"
        );
        controller = _newController;
    }

}