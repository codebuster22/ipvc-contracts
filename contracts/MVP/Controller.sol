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

    bool public isInitialized;                 // status of Controller contract, 1 - initialized, 0 - not initialized
    bytes32 public constant SALT = keccak256("generateWarrior(uint256, address)");

    mapping (bytes32 => bool) public isMetadataUsed;

    modifier onlyAdmin {
        require(
            msg.sender == admin,
            "Controller: only admin functionality"
        );
        _;
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
            "Controller: invalid origin"
        );
        _;
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
            !isInitialized,
            "Controller: already initialized"
        );
        require(
            _origin != address(0) &&
            _warriorsContract != address(0) &&
            _warriorGeneGeneratorContract != address(0),
            "Controller: zero address not allowed"
        );
        origin = _origin;
        warriorsContract = _warriorsContract;
        warriorGeneGeneratorContract = _warriorGeneGeneratorContract;
        isInitialized = true;
    }

    function generateWarrior(
        address _owner,
        bytes32 _metadata,
        bytes memory _originSignature
    ) public onlyOrigin(_owner, _metadata, _originSignature) {
        require(
            isMetadataUsed[_metadata],
            "Controller: metadata already used"
        );
        require(
            Warriors(warriorsContract).isPopulating(),
            "Controller: wait for next generation warriors"
        );
        uint256 currentGen = Warriors(warriorsContract).currentGeneration();
        bytes32 metadata = _metadata;
        for(uint256 rounds; rounds<2; rounds++) {
            uint256 gene = WarriorGeneGenerator(warriorGeneGeneratorContract).geneGenerator(currentGen, metadata);
            if(!Warriors(warriorsContract).isGeneUsed(gene)){
                Warriors(warriorsContract).generateWarrior(gene, _owner);
                return;
            }
            metadata = keccak256(abi.encodePacked(SALT, metadata));
        }
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

    function setNewController(address _newController) external onlyAdmin{
        require(
            _newController != address(0),
            "Controller: new controller cannot be zero"
        );
        WarriorGeneGenerator(warriorGeneGeneratorContract).setController(_newController);
        Warriors(warriorsContract).setController(_newController);
    }

    function setOrigin(address _newOrigin) external onlyAdmin{
        require(
            _newOrigin != address(0),
            "Controller: origin cannot be zero address"
        );
        origin = _newOrigin;
    }

    function setGeneGenerator(address _newGeneGenerator) external onlyAdmin{
        require(
            _newGeneGenerator != address(0),
            "Controller: gene generator cannot be zero address"
        );
        warriorGeneGeneratorContract = _newGeneGenerator;
    }
}