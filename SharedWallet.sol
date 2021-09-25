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

   constructor() {
       owner = msg.sender;
   }
}