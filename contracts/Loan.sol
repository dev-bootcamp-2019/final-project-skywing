pragma solidity ^0.5.0;

import "./Ownable.sol";
import "./LoanUtil.sol";

contract Loan is Ownable {
    bytes32 id;
    address borrower;
    uint loanAmount;
    uint ownedAmount;
    uint lenderCount;
    uint creationTime = now;
    uint fullyFundedTime;

    enum Status { Requesting, Funding, Funded, FundWithdrawn, Repaid, Defaulted, Refunded, Cancelled, Closed }

    struct Lender {
        address payable account;
        uint lendingAmount;
        uint repaidAmount;
    }

    Status internal status;
    // use for circuit breaker
    bool internal stopped;
    mapping(address => Lender) internal lenders;
    mapping(uint => address) internal lenderAddr;

    /// events for loan status
    event Requesting(bytes32 indexed loanId, address indexed borrower, address owner);
    event Funding(bytes32 indexed loanId, address indexed lender, uint amount);
    event Funded(bytes32 indexed loanId, uint amount);
    event FundWithdrawn(bytes32 indexed loanId, uint amount);
    event Repaid(bytes32 indexed loadId, uint amount);
    event Defaulted(bytes32 indexed loanId, uint defaultedAmt, uint loanAmt);
    event Refunded(bytes32 indexed loanId, address indexed lender, uint amount);
    event Cancelled(bytes32 indexed loanId);
    event Stopped(bytes32 indexed loanId);
    event Resumed(bytes32 indexed loanId);
    event Closed(bytes32 indexed loanId);

    /// modifiers to check loan in the required status.
    modifier isFunding { require(status == Status.Funding, "Required Status: Funding"); _; }
    modifier isFunded { require(status == Status.Funded, "Required Status: Funded"); _; }
    modifier isWithdrawn { require(status == Status.FundWithdrawn, "Required Status: Withdraw"); _; }
    modifier isRepaid { require(status == Status.Repaid, "Required Status: Repaid"); _; }
    modifier isDefaulted { require(status == Status.Defaulted, "Required Status: Defaulted"); _; }
    modifier isRefunded { require(status == Status.Refunded, "Required Status: Refunded"); _; }
    modifier isCancelled { require(status == Status.Cancelled, "Required Status: Cancelled"); _; }
    modifier isNotStopped { require(stopped != true, "The state of the contract is stopped by the owner, no operations allow at this time."); _; }

    /// internal constructor to make abstract contract.
    constructor() internal {}
    
    /// abtract functions.

    function request(address _borrower, uint _amount) public;

    function depositFund() public payable;

    function refund() public payable;
    
    function withdrawToBorrower() public payable;

    function repay() public payable;

    function withdrawToLenders() public payable;
    
    function toDefault() public;
    
    function cancel() public;
    
    /// Internal functions
    
    function onlyAfter(uint _time) internal view returns(bool) { 
        return now >= _time; 
    }

    /// Public functions

    function stop() public onlyOwner
    {
        stopped = true;
        emit Stopped(id);
    }

    function resume() public onlyOwner
    {
        stopped = false;
        emit Resumed(id);
    }

    function getLenderBy(address addr) public view returns(address, uint, uint) {
        Lender memory l = lenders[addr];
        return (l.account, l.lendingAmount, l.repaidAmount);
    }

    function getLenderAddressAt(uint idx) public view returns(address) {
        return lenderAddr[idx];
    }

    function getLenderAt(uint idx) public view returns(address, uint, uint) {
        return getLenderBy(getLenderAddressAt(idx));
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function getStatus() public view returns(Status) {
        return status;
    }

    function getLoanAmount() public view returns(uint) {
        return loanAmount;
    }

    function getOwnedAmount() public view returns(uint) {
        return ownedAmount;
    }

    function getBorrower() public view returns(address) {
        return borrower;
    }

    function getLenderCount() public view returns(uint) {
        return lenderCount;
    }
}