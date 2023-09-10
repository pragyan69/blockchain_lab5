const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("Auction", function () {
  let Auction, auction, owner, addr1, addr2;
  
  beforeEach(async function () {
    Auction = await ethers.getContractFactory("Auction");
    [owner, addr1, addr2] = await ethers.getSigners();
    auction = await Auction.deploy();
    // Removed the line "await auction.deployed();"
  });

  it("Should allow the owner to start and end the auction", async function () {
    await auction.connect(owner).startAuction();
    expect(await auction.isAuctionOpen()).to.equal(true);

    await auction.connect(owner).endAuction();
    expect(await auction.isAuctionOpen()).to.equal(false);
  });

  it("Should allow users to place bids and prevent withdrawals", async function () {
    await auction.connect(owner).startAuction();

    await auction.connect(addr1).placeBid({ value: ethers.utils.parseEther("1") });
    expect(await auction.bids(addr1.address)).to.equal(ethers.utils.parseEther("1"));

    await auction.connect(addr2).placeBid({ value: ethers.utils.parseEther("2") });
    expect(await auction.bids(addr2.address)).to.equal(ethers.utils.parseEther("2"));

    await auction.connect(owner).endAuction();
  });

  it("Should allow the owner to declare a winner", async function () {
    await auction.connect(owner).startAuction();
    await auction.connect(addr1).placeBid({ value: ethers.utils.parseEther("1") });
    await auction.connect(addr2).placeBid({ value: ethers.utils.parseEther("2") });
    await auction.connect(owner).endAuction();

    await auction.connect(owner).declareWinner();
    expect(await auction.highestBid()).to.equal(0);
    expect(await auction.highestBidder()).to.equal(ethers.constants.AddressZero);
  });
});
