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
    uint256 public warriorCounter;

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
    }

    /**
      * @dev generateWarrior
      * @param _gene warrior gene for the token
      * @param _owner address of owner who requested to generate warrior
      */
    function generateWarrior(uint256 _gene, address _owner) external onlyController {
        require(
            _gene != 0,
            "Warriors: no warrior without gene"
        );
        require(
            _owner != address(0),
            "Warriors: no warrior can be assigned to zero address"
        );
        uint256 tokenId = warriorCounter;
        warriorCounter++;
        warriors[tokenId] = _gene;
        _mint(_owner, tokenId);
        emit WarriorGenerated(_owner, tokenId);
    }

    /**
     * @dev update controller address
     * @param _newController controller address who is allowed to call write functions
     */
    function updateController(address _newController) public onlyController {
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
}