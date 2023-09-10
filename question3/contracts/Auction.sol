// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Auction {
    address public owner;
    bool public isAuctionOpen;

    uint256 public highestBid;
    address public highestBidder;

    mapping(address => uint256) public bids;

    event AuctionStarted();
    event AuctionEnded(address winner, uint256 highestBid);
    event NewBid(address bidder, uint256 amount);

    constructor() {
        owner = msg.sender;
        isAuctionOpen = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier auctionOpen() {
        require(isAuctionOpen, "Auction is not open");
        _;
    }

    modifier auctionClosed() {
        require(!isAuctionOpen, "Auction is open");
        _;
    }

    function startAuction() public onlyOwner {
        isAuctionOpen = true;
        emit AuctionStarted();
    }

    function endAuction() public onlyOwner auctionOpen {
        isAuctionOpen = false;
        emit AuctionEnded(highestBidder, highestBid);
    }

    function placeBid() public payable auctionOpen {
        require(msg.value > highestBid, "Bid must be higher than the current highest bid");

        uint256 refundAmount = bids[msg.sender];
        bids[msg.sender] = msg.value;

        if (highestBidder != address(0)) {
            bids[highestBidder] = highestBid;
        }

        highestBid = msg.value;
        highestBidder = msg.sender;

        if (highestBidder != msg.sender) {
            payable(msg.sender).transfer(refundAmount);
        }

        emit NewBid(msg.sender, msg.value);
    }

    function declareWinner() public onlyOwner auctionClosed {
        require(highestBidder != address(0), "No bids placed");

        // Transfer the item to the highest bidder
        // This is just a stub as the actual logic depends on how the item is represented.
        // For example, you could use ERC721 to transfer a unique token here.

        // Reset auction state
        bids[highestBidder] = 0;
        highestBid = 0;
        highestBidder = address(0);
    }
}
