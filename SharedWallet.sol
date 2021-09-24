pragma solidity ^0.8.7;

contract SharedWallet {
    address owner;

    struct Withdraw {
        uint amount;
        uint timestamp;
    }

    struct Payment {
        uint amount;
        uint timestamp;
    }

    struct Balance {
        uint totalBalance;
        uint numPayments;
        mapping(uint => Withdraw) withdraws;
        mapping(uint => Payment) payments;
    }

    constructor() {
        owner = msg.sender;
    }

    mapping(address => Balance) public totalBalance;

    function depositMoney(uint _amount) public payable {
        require(msg.sender == owner, "You are not the owner");
        totalBalance[owner].totalBalance += _amount;
        totalBalance[owner].numPayments++;
        Payment memory payment = Payment(_amount, block.timestamp);
        totalBalance[owner].payments[totalBalance[owner].numPayments] = payment;
    }
}