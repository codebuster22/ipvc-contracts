// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;


interface IGeneGenerator{
    /**
     * @dev generate warrior gene
     * @param _metadata unique metadata using which the warrior attributes are generated
     */
    function generateGene(uint256 _currentGen, bytes32 _metadata) external pure returns(uint256 gene);
}