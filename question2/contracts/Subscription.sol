// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Subscription {
    struct Creator {
        bool exists;
        uint256 subscriptionFee;
        address[] subscribers;
    }

    mapping(address => Creator) public creators;
    mapping(address => mapping(address => uint256)) public subscriptions;

    event Subscribed(address indexed user, address indexed creator);
    event Unsubscribed(address indexed user, address indexed creator);
    event FeesCollected(address indexed creator, uint256 amount);
    
    function createProfile(uint256 _subscriptionFee) public {
        require(!creators[msg.sender].exists, "Profile already exists.");
        
        Creator memory newCreator = Creator({
            exists: true,
            subscriptionFee: _subscriptionFee,
            subscribers: new address[](0)
        });
        
        creators[msg.sender] = newCreator;
    }

    function subscribe(address creatorAddress) public payable {
        require(creators[creatorAddress].exists, "Creator does not exist.");
        require(msg.value == creators[creatorAddress].subscriptionFee, "Incorrect subscription fee.");
        require(subscriptions[msg.sender][creatorAddress] == 0, "Already subscribed.");

        subscriptions[msg.sender][creatorAddress] = block.timestamp + 30 days;
        creators[creatorAddress].subscribers.push(msg.sender);

        emit Subscribed(msg.sender, creatorAddress);
    }

    function unsubscribe(address creatorAddress) public {
        require(subscriptions[msg.sender][creatorAddress] > 0, "Not subscribed.");

        subscriptions[msg.sender][creatorAddress] = 0;

        emit Unsubscribed(msg.sender, creatorAddress);
    }

    function collectFees() public {
        require(creators[msg.sender].exists, "Creator does not exist.");
        
        uint256 totalAmount = 0;

        for(uint i = 0; i < creators[msg.sender].subscribers.length; i++) {
            address subscriber = creators[msg.sender].subscribers[i];
            if(subscriptions[subscriber][msg.sender] > 0 && subscriptions[subscriber][msg.sender] < block.timestamp) {
                totalAmount += creators[msg.sender].subscriptionFee;
                subscriptions[subscriber][msg.sender] += 30 days;
            }
        }

        payable(msg.sender).transfer(totalAmount);
        emit FeesCollected(msg.sender, totalAmount);
    }
}
