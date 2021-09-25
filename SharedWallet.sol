pragma solidity ^0.8.7;

contract SharedWallet {
   address owner;

   struct Request {
       address req;
       uint amount;
       uint timestamp;
   }

   struct WithdrawHistory {
       uint amount;
       uint timestamp;
   }

   struct Withdraws {
       uint totalRequests;
       uint activeRequests;
       mapping(uint => WithdrawHistory) withdrawHistory;
   }

   struct Payments {
       address req;
       mapping(address => Withdraws) withdraws;
   }

   struct Wallet {
       uint totalBalance;
       uint numTransactions;
       uint withdrawReqs;
       mapping(uint => Request) requests;
       mapping(uint => Payments) payments;
   }

   mapping(address => Wallet) wallet;

   constructor() {
       owner = msg.sender;
   }

   function depositMoney() public payable {
       require(msg.sender == owner, "You are (not) the owner");
       wallet[owner].totalBalance += msg.value;
       wallet[owner].numTransactions++; 
   }

   function withdrawRequest() public {
       wallet[owner].withdrawReqs++;
       Request memory request = Request(msg.sender, 1 ether, block.timestamp);
       wallet[owner].requests[wallet[owner].withdrawReqs] = request;
   }
}