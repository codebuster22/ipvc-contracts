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

    /**
     * @dev constructor to set inital value.
     */
    constructor () {
        controller = msg.sender;
        totalGeneAttributes = 5;
        geneModulus = 10**(5*2);
    }

    /**
     * @dev generate warrior gene
     * @param _metadata unique metadata using which the warrior attributes are generated
     */
    function geneGenerator(bytes32 _metadata) public view returns(uint256 gene){
        gene = uint256(_metadata);
        gene = gene % geneModulus;
    }

    /**
     * @dev set new total warrior gene attributes
     * @param _newTotalGeneAttributes total number of attributes a warrior should have
     */
    function setTotalGeneAttributes(uint8 _newTotalGeneAttributes) public onlyController{
        require(
            _newTotalGeneAttributes > totalGeneAttributes,
            "WarriorGeneGenerator: cannot decrease gene attributes"
        );
        totalGeneAttributes = _newTotalGeneAttributes;
        geneModulus = 10 ** (totalGeneAttributes*2);
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