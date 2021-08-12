// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./Warriors.sol";

contract WarriorNFTAuction is IERC721Receiver {
    
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
    event IncreaseCurrentBid(address bidder, uint256 bidAmount);

    modifier warriorOwner(uint _tokenId) {
        address warriorOwner = warrior.ownerOf(_tokenId);
        require(msg.sender == warriorOwner, "The message sender is not the owner of the Warrior");
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

        Auction memory _auction = Auction({
            seller: msg.sender,
            basePrice: _price,
            endTime: _biddingTime.add(block.timestamp),
            highestBid: 0,
            highestBidder: address(0),
            auctionComplete: false
        });

        tokenIdToAuction[_tokenId] = _auction;
    }

    function bid(uint256 _tokenId) public payable {
        Auction storage _auction = tokenIdToAuction[_tokenId];

        require(_auction.seller != msg.sender,"The message sender is the seller!");
        require(msg.value >= _auction.basePrice,"Base price exceeds the limit!");
        require(block.timestamp <= _auction.endTime,"Auction already ended!");
        require(msg.value >= _auction.highestBid,"Invalid bid!");

        _auction.highestBidder = msg.sender;
        _auction.highestBid = msg.value;
        returnsPending[_tokenId][_auction.highestBidder] = msg.value;
        emit TopBidIncreased(msg.sender, msg.value);
    }


    function balance() public view returns (uint256) {
        uint256 amount = address(this).balance;
        return amount;
    }

    function withdraw(uint256 _tokenId) public returns (bool) {
        Auction memory _auction = tokenIdToAuction[_tokenId];

        require(msg.sender != _auction.highestBidder,"You're the highest bidder!");

        uint256 bidAmount = returnsPending[_tokenId][msg.sender];
        if (bidAmount > 0) {
            // if (!payable(_auction.highestBidder).send(bidAmount)) {
            //     returnsPending[_tokenId][msg.sender] = bidAmount;
            //     return false;
            // }
         payable(msg.sender).transfer(bidAmount);
         
        }
        return true;
    }

    function increaseCurrentBid(uint256 _tokenId) public payable {
        Auction storage _auction = tokenIdToAuction[_tokenId];

        require(returnsPending[_tokenId][msg.sender] != 0,"Value cannot be zero!");
        require(_auction.highestBidder != msg.sender,"You're the highest bidder!");
        require(returnsPending[_tokenId][msg.sender].add(msg.value) >= _auction.highestBid,"Value is lesser than highest bid!");

        _auction.highestBidder = msg.sender;
        uint256 newBidAmount = returnsPending[_tokenId][ _auction.highestBidder].add(msg.value);

        _auction.highestBid = newBidAmount;
        returnsPending[_tokenId][_auction.highestBidder] += msg.value;

        emit TopBidIncreased(msg.sender, newBidAmount);
    }

    function closeAuction(uint256 _tokenId) public {
        Auction storage _auction = tokenIdToAuction[_tokenId];

        //   require(block.timestamp >= _auction.endTime);

        require(!_auction.auctionComplete,"Auction ended!");

        _auction.auctionComplete = true;

        uint256 amount = _auction.highestBid;
        uint256 percent = 10;
        uint256 transactionFee = amount.mul(percent).div(100);

        uint256 amountToSeller = _auction.highestBid.sub(transactionFee);
        uint256 amountToThirdParty = transactionFee;

        payable(_auction.seller).transfer(amountToSeller);
        payable(address(0xdD870fA1b7C4700F2BD7f44238821C26f7392148)).transfer(
            amountToThirdParty
        );

        warrior.safeTransferFrom(address(this), _auction.highestBidder, _tokenId);

        emit AuctionResult(_auction.highestBidder, _auction.highestBid);
    }

    function cancelAuction(uint256 _tokenId) public warriorOwner(_tokenId) returns (bool)  {
        Auction memory _auction = tokenIdToAuction[_tokenId];

        require(_auction.seller == msg.sender,"You're not the seller!");

        delete tokenIdToAuction[_tokenId];

        warrior.safeTransferFrom(address(this), _auction.seller, _tokenId);

        return true;
    }

    function getNftContractAddress() public view returns(address) {
        return address(_warrior);        
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
