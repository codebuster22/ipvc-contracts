// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";


contract Warriors is ERC721 {

    // tokenId => warriorGene
    // warriorGene - {1 digit fixed prefix}{3 digits generation id}{72 digits for attributes}
    // Gene - total 76 digits
    mapping( uint256 => uint256 ) internal warriors;
    mapping( uint256 => bool ) public isGeneUsed;
    uint256 public warriorCounter;


    event WarriorGenerated(address indexed owner, uint256 indexed warriorId);

    /**
     * @dev constructor
     */
    constructor () ERC721("Warriors","WRT") {}

    /**
      * @dev generateWarrior
      * @param _gene warrior gene for the token
      * @param _owner address of owner who requested to generate warrior
      */
    function _generateWarrior(uint256 _gene, address _owner) internal {
        uint256 tokenId = warriorCounter;
        warriorCounter++;
        warriors[tokenId] = _gene;
        isGeneUsed[_gene] = true;
        _beforeWarriorMint();
        _mint(_owner, tokenId);
        emit WarriorGenerated(_owner, tokenId);
    }

    /**
     * @dev get warrior's gene
     * @param _warriorId id of warrior token
     */
    function getWarrior(uint256 _warriorId) public view returns(uint256 warrior) {
        warrior = warriors[_warriorId];
        require(
            warrior != 0,
            "Warriors: warrior does not exist"
        );
    }

    /**
      * @dev sequence of code to run, before warrior mint. It is marked virtual so that it can be overriden
      */
    function _beforeWarriorMint() internal virtual { }
}