// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;


contract Authorized{
    address public admin;                       // address of admin

    modifier onlyAdmin {
        require(
            msg.sender == admin,
            "Authorized: only admin functionality"
        );
        _;
    }

    /**
     * @dev constructor
     */
    constructor () {
        admin = msg.sender;
    }
}