//SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
contract PiggyBank {
    
    address public checking_account;
    address public savings_account;
    address public locked;
    uint public lockTime; //enter in days, get results in seconds/milliseconds
    mapping(address => uint) balance;

    modifier diffAcc(address addr1, address addr2) {
        require (addr1 != addr2);
        _;
    }
    /*modifier onlyOwner() {
        require(msg.sender == )
    }*/
   
    constructor (address _checking, address _savings, address _locked) diffAcc(_checking, _savings) {
        checking_account = _checking;
        savings_account = _savings;
        locked = _locked;
    }

    event fundsTransferred(string message);
    error insufficientFunds();
    error notYetTime();

    function getBalance(address _user) public view returns(uint) {
        return balance[_user];
    }
    

    function mint(uint amount, uint cap) public {
        assert(amount < cap);
        balance[checking_account]+= amount;
    }

    function sendToSavings(address from, address to, uint amount) public diffAcc(from, to) {
        from = checking_account;
        to = savings_account;
        balance[from]-= amount;
        balance[to]+= amount;
        if(balance[from] < amount) {
            revert insufficientFunds();
        }
        emit fundsTransferred("Transfer successful");
    }

    function withdrawToChecking(address from, address to, uint amount) public diffAcc(from, to){
        from = savings_account;
        to = checking_account;
        balance[from]-= amount;
        balance[to]+= amount;
        if(balance[from] < amount) {
            revert insufficientFunds();
        }
        emit fundsTransferred("Transfer successful");
    }


    function lockFunds(uint _amount, address from, address to, uint _locktime) public diffAcc(from, to) {
        to = locked;
        balance[locked]+= _amount;
        balance[from]-= _amount;
        lockTime = block.timestamp + (_locktime  * 1 days);
    }

    function withdrawFromLocked (uint _amount, address from, address to ) public diffAcc(from, to) {
        if(block.timestamp < lockTime){
            revert notYetTime();
        }
        else {
            sendToSavings(locked, savings_account, _amount);
            emit fundsTransferred("You have successfully transferred your funds to oyur savings account");
        }
        //interest in gwei/wei
       // uint interest = _interest *
        //use safemath 
    }

    
}