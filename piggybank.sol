//SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

contract PiggyBank {


    receive() external payable {}

    address payable public checking_account;
    address payable public savings_account;
    address payable public locked;
    address public owner = payable(msg.sender);
    uint public lockTime; //enter in days, get results in seconds/milliseconds
    uint LT;

    modifier diffAcc(address payable addr1, address payable addr2) {
        require (addr1 != addr2);
        _;
    }

    constructor (address payable _savings, address payable _locked) payable diffAcc(_savings, _locked) {
        checking_account = payable(msg.sender);
        savings_account = _savings;
        locked = _locked;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
   
   /*modifier constructAdd (address payable _addr1, address payable _addr2, address payable _addr3) {
       require(_addr1 != _addr2);
       require(_addr1 != _addr3);
       require(_addr2 != _addr3);
       _;
   }*/

    event fundsTransferred(string message);
    error insufficientFunds();
    error notYetTime();

    function getBalance(address payable _user) public view returns(uint) {
        return _user.balance;
    }
    

    function sendToSavings(address payable to, uint amount) payable public onlyOwner {
        require(to == savings_account, "You have entered an incorrect address");
        to.transfer(amount);
        emit fundsTransferred("Transfer successful");
    }

    function withdrawToChecking(address payable from, address payable to, uint amount) public onlyOwner diffAcc(from, to){
        require(to == checking_account, "You have entered an incorrect address");
        to.transfer(amount);
        if (from.balance < amount) {
            revert insufficientFunds();
        }
        emit fundsTransferred("Transfer successful");
    }


    function lockFunds(uint _amount, address payable from, address payable to, uint _locktime) payable public diffAcc(from, to) onlyOwner {
        require(to == locked, "You have entered an incorrect address");
        to.transfer(_amount);
        lockTime = _locktime  * 1 days;
        LT = block.timestamp + lockTime;
    }

    function withdrawFromLocked (uint _amount) payable onlyOwner public {
        if(block.timestamp < LT){
            revert notYetTime();
        }
        else {
            sendToSavings(savings_account, _amount);
            emit fundsTransferred("You have successfully transferred your funds to oyur savings account");
        }
    }

    function getContractBalance () external view returns (uint){
        return address(this).balance;
    }

    
}