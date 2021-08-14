    // SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./Warriors.sol";
import "./access/Authorized.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";       // for transactionFee calculation

contract WarriorNFTAuction is IERC721Receiver,Authorized {
        using SafeMath for uint256;
    struct Auction {
        address seller;
        uint256 basePrice;
        uint256 endTime;
        address highestBidder;
        uint256 highestBid;
        bool auctionComplete;
    }

    Warriors public warrior;

    mapping(uint256 => Auction) public tokenIdToAuction;
    mapping(uint256 => mapping(address => uint256)) public returnsPending;

    event TopBidIncreased(address bidder, uint256 bidAmount);
    event AuctionResult(address winner, uint256 bidAmount);
   // event IncreaseCurrentBid(address bidder, uint256 bidAmount);

    modifier warriorOwner(uint _tokenId) {
        address warriorsOwner = warrior.ownerOf(_tokenId);
        require(msg.sender == warriorsOwner, "The message sender is not the owner of the Warrior");
        _;
    }

    constructor(address warriors) {
        warrior = Warriors(warriors);
    }

    function createAuction(
        uint256 _tokenId,
        uint256 _price,
        uint256 _biddingTime
    ) public warriorOwner(_tokenId) {
        
        warrior.safeTransferFrom(msg.sender, address(this), _tokenId);

        Auction memory auction = Auction({
            seller: msg.sender,
            basePrice: _price,
            endTime: _biddingTime.add(block.timestamp),
            highestBid: 0,
            highestBidder: address(0),
            auctionComplete: false
        });

        tokenIdToAuction[_tokenId] = auction;
    }

    function bid(uint256 _tokenId) public payable {
        Auction storage auction = tokenIdToAuction[_tokenId];

        require(auction.seller != msg.sender,"The message sender is the seller!");
        require(msg.value >= auction.basePrice,"Base price exceeds the limit!");
        require(block.timestamp <= auction.endTime,"Auction already ended!");
        require(msg.value >= auction.highestBid,"Invalid bid!");

        auction.highestBidder = msg.sender;
        auction.highestBid = msg.value;
        returnsPending[_tokenId][auction.highestBidder] = msg.value;
        emit TopBidIncreased(msg.sender, msg.value);
    }


    function balance() public view returns (uint256) {
        uint256 amount = address(this).balance;
        return amount;
    }

    function withdraw(uint256 _tokenId) public returns (bool) {
        Auction memory auction = tokenIdToAuction[_tokenId];

        require(msg.sender != auction.highestBidder,"You're the highest bidder!");

        uint256 bidAmount = returnsPending[_tokenId][msg.sender];
        if (bidAmount > 0) {
            // if (!payable(auction.highestBidder).send(bidAmount)) {
            //     returnsPending[_tokenId][msg.sender] = bidAmount;
            //     return false;
            // }
         payable(msg.sender).transfer(bidAmount);
         
        }
        return true;
    }
    function closeAuction(uint256 _tokenId) public onlyAdmin{
        Auction storage auction = tokenIdToAuction[_tokenId];

        //   require(block.timestamp >= auction.endTime);

        require(!auction.auctionComplete,"Auction already ended!");

        auction.auctionComplete = true;

        uint256 amount = auction.highestBid;
        uint256 percent = 10;
        uint256 transactionFee = amount.mul(percent).div(100);

        uint256 amountToSeller = auction.highestBid.sub(transactionFee);
        uint256 amountToThirdParty = transactionFee;

        payable(auction.seller).transfer(amountToSeller);
        payable(admin).transfer(amountToThirdParty);

        warrior.safeTransferFrom(address(this), auction.highestBidder, _tokenId);

        emit AuctionResult(auction.highestBidder, auction.highestBid);
    }

    function cancelAuction(uint256 _tokenId) public warriorOwner(_tokenId) returns (bool)  {
        Auction memory auction = tokenIdToAuction[_tokenId];

        require(auction.seller == msg.sender,"You're not the seller!");

        delete tokenIdToAuction[_tokenId];

        warrior.safeTransferFrom(address(this), auction.seller, _tokenId);

        return true;
    }

    function getNftContractAddress() public view returns(address) {
        return address(warrior);        
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
