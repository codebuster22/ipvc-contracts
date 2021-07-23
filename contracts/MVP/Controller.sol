// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

// import "../interface/MVP/IWarriors.sol";
// import "../interface/MVP/IWarriorGeneGenerator.sol";
import "./Warriors.sol";
import "./WarriorGeneGenerator.sol";
import "../utils/SignatureHelper.sol";


contract Controller is SignatureHelper {


    string constant public ipvc_version = "0.1.0-beta";

    address public origin;                      // address from which the call to generateWarrior can be accepted
    address public admin;                       // address of admin
    address public warriorsContract;            // address ERC721 Warriors contract
    address public warriorGeneGeneratorContract;// address of WarriorGeneGenerator contract

    uint8 public isInitialized;                 // status of Controller contract, 1 - initialized, 0 - not initialized

    modifier onlyAdmin {
        require(
            msg.sender == admin,
            "Controller: only admin functionality"
        );
        _;
    }

    modifier onlyOrigin(
        address _from,
        bytes memory _metadata,
        bytes memory _signature
    ) {
        bytes32 messageHash = generateHash(address(this), _from, _metadata);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        require(
            recoverSigner(ethSignedMessageHash, _signature) == origin,
            "Controller: invalid origin"
        )
    }

    constructor () {
        admin = msg.sender;
    }

    function initialize(
        address _origin,
        address _warriorsContract,
        address _warriorGeneGeneratorContract
    ) public onlyAdmin() {
        require(
            _origin != address(0) 
            && 
            _warriorsContract != address(0) 
            && 
            _warriorGeneGeneratorContract != address(0),
            "Controller: zero address not allowed"
        );
        origin = _origin;
        warriorsContract = _warriorsContract;
        warriorGeneGeneratorContract = _warriorGeneGeneratorContract;
        isInitialized = 1;
    }

    function generateWarrior(
        address _owner,
        uint256 _gene,
        bytes memory _metadata,
        bytes memory _originSignature
    ) public onlyOrigin(_owner, _metadata, _originSignature) {
        Warriors(warriorsContract).generateWarrior(gene, _owner);
    }

    function generateHash(
        address _to,
        address _from,
        bytes memory _metadata
    ) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(_to,_from, _metadata, "generateWarrior()"));
    }
}