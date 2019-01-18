pragma solidity ^0.5.0;

import "./Ownable.sol";
import "./LoanUtil.sol";

contract Loan is Ownable {
    bytes32 public id;
    address public borrower;
    uint public loanAmount;
    uint public ownedAmount;
    uint public lenderCount;
    uint public creationTime = now;
    uint public fullyFundedTime;

    enum Status { Requesting, Funding, Funded, FundWithdrawn, Repaid, Defaulted, Refunded, Cancelled, Closed }

    struct Lender {
        address payable account;
        uint lendingAmount;
        uint repaidAmount;
    }

    Status public status;
    // use for circuit breaker
    bool public stopped;
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

    function requestLoan(address _borrower, uint _amount) public;

    function depositFund() public payable;

    function refund() public payable;
    
    function withdrawFund() public payable;

    function repayFund() public payable;

    function paybackLender() public payable;
    
    function defaultLoan() public;
    
    function cancelLoan() public;
    
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

}