pragma solidity ^0.8.6;


contract WarriorGeneGenerator{

    address public controller;
    uint8 public totalGeneAttributes;
    uint256 public geneModulus;

    modifier onlyController() {
        require(
            msg.sender == controller,
            "WarriorGeneGenerator: only controller functionality"
        );
        _;
    }

    modifier isInitialized() {
        require(
            totalGeneAttributes != 0,
            "WarriorGeneGenerator: contract uninitialized"
        );
        _;
    }

    constructor () {
        controller = msg.sender;
        totalGeneAttributes = 5;
        geneModulus = 10**(5*2);
    }

    function geneGenerator(bytes32 _metadata) public view returns(uint256 gene){
        gene = uint256(_metadata);
        gene = gene % geneModulus;
    }

    function setTotalGeneAttributes(uint8 _newTotalGeneAttributes) public onlyController{
        require(
            _newTotalGeneAttributes > totalGeneAttributes,
            "WarriorGeneGenerator: cannot decrease gene attributes"
        );
        totalGeneAttributes = _newTotalGeneAttributes;
        geneModulus = 10 ** (totalGeneAttributes*2);
    }

    function setController(address _newController) public onlyController{
        require(
            _newController != address(0),
            "WarriorGeneGenerator: new controller cannot be zero"
        );
        controller = _newController;
    }

}