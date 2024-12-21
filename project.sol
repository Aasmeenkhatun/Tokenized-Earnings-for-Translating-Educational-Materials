// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LearnToEarn {
    string public platformName = "Learn-to-Earn Streaming Platform";
    address public owner;
    
    struct User {
        address userAddress;
        uint256 balance;
        bool isTranslator;
    }

    struct Content {
        uint256 id;
        string title;
        address uploader;
        uint256 reward;
        bool isTranslated;
    }

    mapping(address => User) public users;
    mapping(uint256 => Content) public contents;

    uint256 public nextContentId;
    
    event ContentUploaded(uint256 contentId, string title, uint256 reward);
    event TranslationCompleted(uint256 contentId, address translator);
    event RewardClaimed(address user, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier onlyTranslator() {
        require(users[msg.sender].isTranslator, "Only a translator can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function registerUser(bool isTranslator) public {
        users[msg.sender] = User({
            userAddress: msg.sender,
            balance: 0,
            isTranslator: isTranslator
        });
    }

    function uploadContent(string memory title, uint256 reward) public payable {
        require(msg.value == reward, "Reward must be equal to the sent Ether");

        contents[nextContentId] = Content({
            id: nextContentId,
            title: title,
            uploader: msg.sender,
            reward: reward,
            isTranslated: false
        });

        emit ContentUploaded(nextContentId, title, reward);
        nextContentId++;
    }

    function completeTranslation(uint256 contentId) public onlyTranslator {
        Content storage content = contents[contentId];
        require(!content.isTranslated, "Content has already been translated");

        content.isTranslated = true;
        users[msg.sender].balance += content.reward;

        emit TranslationCompleted(contentId, msg.sender);
    }

    function claimReward() public {
        uint256 reward = users[msg.sender].balance;
        require(reward > 0, "No reward available to claim");

        users[msg.sender].balance = 0;
        payable(msg.sender).transfer(reward);

        emit RewardClaimed(msg.sender, reward);
    }

    function getUserBalance(address user) public view returns (uint256) {
        return users[user].balance;
    }

    function getContentDetails(uint256 contentId) public view returns (string memory, address, uint256, bool) {
        Content memory content = contents[contentId];
        return (content.title, content.uploader, content.reward, content.isTranslated);
    }
} 
