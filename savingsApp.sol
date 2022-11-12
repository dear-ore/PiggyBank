//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract savingsApp {
    //state variables
    receive() external payable{}
    address public owner  = msg.sender;
    uint public lockTime;
    //Create IDs for savings and locked balances. **Users don't have to know??
    bytes2 public savingsID;
    bytes2 public lockID;
    //uint balance = msg.sender.balance;

    //modifier to restict access
    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }

    //mapping to track locked balance and savings balance
    mapping (bytes2 => uint) public savingsBalance;
    mapping (bytes2 => uint) public lockedBalance;

    function createIDs() public {
        require(savingsID == 0, "You already have an ID");
        require(lockID == 0, "You already have an ID");
        savingsID = bytes2(keccak256(abi.encodePacked(msg.sender,block.timestamp)));
        lockID = bytes2(keccak256(abi.encodePacked(block.number, block.difficulty)));
    }

    function save() public payable onlyOwner {
        require(msg.value != 0);
        savingsBalance[savingsID] += msg.value;
    }

    function savebyLock(uint _lockTime) public payable onlyOwner {
        lockedBalance[lockID] += msg.value;
        //_lockTime is in seconds
        lockTime = block.timestamp + _lockTime;
    }

    function withdrawfromlock(uint amount) public payable onlyOwner {
        require(block.timestamp > lockTime, "Your timelock hasn't been reached yet");
        lockedBalance[lockID] -= amount;
        savingsBalance[savingsID] += amount;
    }

}