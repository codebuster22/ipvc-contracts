// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./Authorized.sol";
import "../utils/SignatureHelper.sol";

contract OriginControl is Authorized, SignatureHelper{

    address public origin;                      // address from which the call to generateWarrior can be accepted

    function setOrigin(address _newOrigin) external onlyAdmin{
        require(
            _newOrigin != address(0),
            "OriginControl: origin cannot be zero address"
        );
        origin = _newOrigin;
    }

    modifier onlyOrigin(
        address _from,
        bytes32 _metadata,
        bytes memory _signature
    ) {
        bytes32 messageHash = generateHash(address(this), _from, _metadata);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        require(
            recoverSigner(ethSignedMessageHash, _signature) == origin,
            "OriginControl: invalid origin"
        );
        _;
    }

    function generateHash(
        address _to,
        address _from,
        bytes32 _metadata
    ) public pure returns(bytes32) {
        return keccak256(
            abi.encodePacked(
                _to,_from, _metadata, "generateWarrior(address, bytes32, bytes memory)"
            )
        );
    }
}