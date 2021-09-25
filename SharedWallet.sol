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

    struct Request {
        address payee;
        uint amount;
        uint timestamp;
    }

    struct Balance {
        uint totalBalance;
        uint numTransactions;
        uint withdrawRequests;
        mapping(uint => Withdraw) withdraws;
        mapping(uint => Payment) payments;
        mapping(uint => Request) requests;
    }

    constructor() {
        owner = msg.sender;
    }

    mapping(address => Balance) public wallet;

    function depositMoney(uint _amount) public payable {
        require(msg.sender == owner, "You are not the owner");
        wallet[owner].totalBalance += _amount;
        wallet[owner].numTransactions++;
        Payment memory payment = Payment(_amount, block.timestamp);
        wallet[owner].payments[wallet[owner].numTransactions] = payment;
    }

    function showTotalRequests() public view returns (uint) {
        require(msg.sender == owner, "You are not the owner");
        return wallet[msg.sender].withdrawRequests;
    }

    function showWithdrawRequest(uint _request) public view returns(Request memory) {
        require(msg.sender == owner, "You are not the owner");
        return wallet[owner].requests[_request];
    }

    function requestWithdraw(uint _amount) public {
        Request memory request = Request(msg.sender, _amount, block.timestamp);
        wallet[owner].withdrawRequests++;
        wallet[owner].requests[wallet[owner].withdrawRequests] = request;
    }
}