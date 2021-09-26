pragma solidity ^0.8.7;

import './Owned.sol';

contract SharedWallet is Owned {

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
       uint reqNum;
   }

   struct Wallet {
       uint totalBalance;
       uint numTransactions;
       uint withdrawReqs;
       mapping(uint => Request) requests;
       mapping(uint => Payments) payments;
   }

   mapping(address => Wallet) public wallet;
   mapping(address => Withdraws) public withdraws;

   function depositMoney() public payable onlyOwner {
       wallet[owner].totalBalance += msg.value;
       wallet[owner].numTransactions++; 
   }

   function requestWithdraw() public {
       wallet[owner].withdrawReqs++;
       Request memory _request = Request(msg.sender, 1 ether, block.timestamp);
       wallet[owner].requests[wallet[owner].withdrawReqs] = _request;
       withdraws[msg.sender].activeRequests++;
   }

   function acceptWithdraw(uint _index, uint _amount) public onlyOwner {
       address payable _to = payable(wallet[owner].requests[_index].req);

       WithdrawHistory memory _withdrawHistory = WithdrawHistory(_amount * 1 ether, block.timestamp);

       withdraws[_to].totalRequests++;
       withdraws[_to].activeRequests--;
       withdraws[_to].withdrawHistory[withdraws[_to].totalRequests] = _withdrawHistory;
       
       Payments memory _payments = Payments(_to, withdraws[_to].totalRequests);
       
       wallet[owner].totalBalance -= _amount * 1 ether;
       wallet[owner].numTransactions++;
       wallet[owner].withdrawReqs--;
       wallet[owner].payments[wallet[owner].numTransactions] = _payments;
       _to.transfer(_amount * 1 ether);
   }

    // Show functions
   function showActiveRequests(uint _index) onlyOwner public view returns(Request memory) {
       return wallet[owner].requests[_index];
   }
}