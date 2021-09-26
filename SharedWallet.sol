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
       uint fulfilledReqs;
       uint activeRequests;
       mapping(uint => WithdrawHistory) withdrawHistory;
   }

   struct Payments {
       address req;
       uint reqNum;
   }

   struct Deposit {
       uint amount;
       uint timestamp;
   }

   struct Wallet {
       uint totalBalance;
       uint numTransactions;
       uint numPayments;
       uint numDeposits;
       uint withdrawReqs;
       mapping(uint => Request) requests;
       mapping(uint => Payments) payments;
       mapping(uint => Deposit) deposits;
   }

   mapping(address => Wallet) public wallet;
   mapping(address => Withdraws) public withdraws;

   function depositMoney() public payable onlyOwner {
       require(msg.value > 0, "You must put in Ethereum to successfully deposit");
       Deposit memory _deposit = Deposit(msg.value, block.timestamp);
       wallet[owner].totalBalance += msg.value;
       wallet[owner].numTransactions++;
       wallet[owner].numDeposits++;
       wallet[owner].deposits[wallet[owner].numDeposits] = _deposit;
   }

   function requestWithdraw() public {
       wallet[owner].withdrawReqs++;
       Request memory _request = Request(msg.sender, 1 ether, block.timestamp);
       wallet[owner].requests[wallet[owner].withdrawReqs] = _request;
       withdraws[msg.sender].activeRequests++;
   }

   function acceptWithdraw(uint _index, uint _amount) public onlyOwner {
       assert(wallet[owner].totalBalance >= _amount);
       address payable _to = payable(wallet[owner].requests[_index].req);

       WithdrawHistory memory _withdrawHistory = WithdrawHistory(_amount * 1 ether, block.timestamp);

       withdraws[_to].fulfilledReqs++;
       withdraws[_to].activeRequests--;
       withdraws[_to].withdrawHistory[withdraws[_to].fulfilledReqs] = _withdrawHistory;
       
       Payments memory _payments = Payments(_to, withdraws[_to].fulfilledReqs);
       
       wallet[owner].totalBalance -= _amount * 1 ether;
       wallet[owner].numTransactions++;
       wallet[owner].numPayments++;
       wallet[owner].withdrawReqs--;
       wallet[owner].payments[wallet[owner].numPayments] = _payments;
       _to.transfer(_amount * 1 ether);
   }

   function declineWithdraw(uint _index) public onlyOwner {
       require(_index <= wallet[owner].withdrawReqs, "No active withdraw request at this index");
       assert(wallet[owner].withdrawReqs > 0);
       withdraws[wallet[owner].requests[_index].req].activeRequests--;
       wallet[owner].withdrawReqs--;
   }

    // "Show"  functions
   function showActiveRequests(uint _index) onlyOwner public view returns(Request memory) {
       require(_index <= wallet[owner].withdrawReqs, "There are no active requests.");
       assert(wallet[owner].withdrawReqs > 0);
       return wallet[owner].requests[_index];
   }

   function showWithdrawHistory(address _req, uint _index) onlyOwner public view returns(WithdrawHistory memory) {
       require(_index <= withdraws[_req].fulfilledReqs, "There is no withdraw history");
       assert(withdraws[_req].fulfilledReqs > 0);
       return withdraws[_req].withdrawHistory[_index];
   }

   function showPaymentHistory(uint _index) onlyOwner public view returns(Payments memory) {
       require(_index <= wallet[owner].numPayments, "There is no payment history");
       assert(wallet[owner].numPayments > 0);
       return wallet[owner].payments[_index];
   }

   function showDepositHistory(uint _index) onlyOwner public view returns(Deposit memory) {
       require(_index <= wallet[owner].numDeposits, "There is no deposit history");
       assert(wallet[owner].numDeposits > 0);
       return wallet[owner].deposits[_index];
   }
}