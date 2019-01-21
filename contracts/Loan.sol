pragma solidity ^0.5.0;

import "./Ownable.sol";
import "./LoanUtil.sol";

contract Loan is Ownable {
    enum Status { Requesting, Funding, Funded, FundWithdrawn, Repaid, Defaulted, Refunded, Cancelled, Closed }

    struct Lender {
        address payable account;
        uint lendingAmount;
        uint repaidAmount;
    }

    bytes32 _id;
    address _borrower;
    uint _loanAmount;
    uint _ownedAmount;
    uint _lenderCount;
    uint _creationTime = now;
    uint _fullyFundedTime;
    Status internal _status;

    // use for circuit breaker
    bool internal _stopped;
    mapping(address => Lender) internal _lenders;
    mapping(uint => address) internal _lenderAddr;

    /// events for loan status
    event Requesting(bytes32 indexed loanId, address indexed borrower, address owner);
    event Funding(bytes32 indexed loanId, address indexed lender, uint amount);
    event Funded(bytes32 indexed loanId, uint amount);
    event FundWithdrawn(bytes32 indexed loanId, uint amount);
    event Repaid(bytes32 indexed loanId, uint amount);
    event Defaulted(bytes32 indexed loanId, address indexed borrower, uint defaultedAmt, uint loanAmt);
    event Refunded(bytes32 indexed loanId, address indexed lender, uint amount);
    event Cancelled(bytes32 indexed loanId);
    event Stopped(bytes32 indexed loanId);
    event Resumed(bytes32 indexed loanId);
    event Closed(bytes32 indexed loanId);

    /// internal constructor to make abstract contract.
    constructor() internal { }

    /// modifiers to check loan in the required status.
    modifier isFunding { 
        require(_status == Status.Funding, "Required Status: Funding"); 
        _; 
    }
    
    modifier isFunded { 
        require(_status == Status.Funded, "Required Status: Funded"); 
        _; 
    }
    
    modifier isWithdrawn { 
        require(_status == Status.FundWithdrawn, "Required Status: Withdraw"); 
        _; 
    }
    
    modifier isRepaid { 
        require(_status == Status.Repaid, "Required Status: Repaid"); 
        _; 
    }

    modifier isDefaulted { 
        require(_status == Status.Defaulted, "Required Status: Defaulted"); 
        _; 
    }
    
    modifier isRefunded { 
        require(_status == Status.Refunded, "Required Status: Refunded"); 
        _; 
    }
    
    modifier isCancelled { 
        require(_status == Status.Cancelled, "Required Status: Cancelled"); 
        _; 
    }
    
    modifier isNotStopped { 
        require(_stopped != true, "The state of the contract is stopped by the owner, no operations allow at this time."); 
        _; 
    }
    
    /// abtract functions.
    function request(address borrower, uint amount) public;

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

    function stop() public onlyOwner {
        _stopped = true;
        emit Stopped(_id);
    }

    function resume() public onlyOwner {
        _stopped = false;
        emit Resumed(_id);
    }

    // Public property getters
    function id() public view returns(bytes32) {
        return _id;
    }

    function lenderBy(address addr) public view returns(address, uint, uint) {
        if (addr == address(0)) {
            return (address(0), 0, 0);
        } else {
            Lender memory l = _lenders[addr];
            return (l.account, l.lendingAmount, l.repaidAmount);
        }
    }

    function lenderAddressAt(uint idx) public view returns(address) {
        return _lenderAddr[idx];
    }

    function lenderAt(uint idx) public view returns(address, uint, uint) {
        return lenderBy(lenderAddressAt(idx));
    }

    function balance() public view returns(uint256) {
        return address(this).balance;
    }

    function status() public view returns(Status) {
        return _status;
    }

    function loanAmount() public view returns(uint) {
        return _loanAmount;
    }

    function ownedAmount() public view returns(uint) {
        return _ownedAmount;
    }

    function borrower() public view returns(address) {
        return _borrower;
    }

    function lenderCount() public view returns(uint) {
        return _lenderCount;
    }
}