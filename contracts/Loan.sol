pragma solidity ^0.5.0;

import "./Ownable.sol";
import "./LoanUtil.sol";

contract Loan is Ownable {
    bytes32 public id;
    address public borrower;
    uint256 public loanAmount;
    uint256 public ownedAmount;
    uint public lenderCount;
    uint public creationTime = now;
    uint public fullyFundedTime;

    enum Status { Requesting, Funding, Funded, FundWithdrawn, Repaid, Defaulted, Refunded, Cancelled, Disabled }

    struct Lender {
        address payable account;
        uint256 lendingAmount;
        uint256 repaidAmount;
    }

    Status public status;
    mapping(address => Lender) internal lenders;
    mapping(uint => address) internal lenderAddr;

    event Requesting(bytes32 loanId, address borrower, address owner);
    event Funding(bytes32 loanId, address lender, uint256 amount);
    event Funded(bytes32 loanId, uint256 amount);
    event FundWithdrawn(bytes32 loanId, uint256 amount);
    event Repaid(bytes32 loadId, uint256 amount);
    event Defaulted(bytes32 loanId, uint256 defaultedAmt, uint256 loanAmt);
    event Refunded(bytes32 loanId, address lender, uint256 amount);
    event Disabled(bytes32 loanId);
    
    modifier isFunding { require(status == Status.Funding, "Required Status: Funding"); _; }
    modifier isFunded { require(status == Status.Funded, "Required Status: Funded"); _; }
    modifier isWithdrawn { require(status == Status.FundWithdrawn, "Required Status: Withdraw"); _; }
    modifier isRepaid { require(status == Status.Repaid, "Required Status: Repaid"); _; }
    modifier isDefaulted { require(status == Status.Defaulted, "Required Status: Defaulted"); _; }
    modifier isRefunded { require(status == Status.Refunded, "Required Status: Refunded"); _; }
    modifier isCancelled { require(status == Status.Cancelled, "Required Status: Cancelled"); _; }

    constructor() internal {}
    
    function fundIt() public payable returns(bool);

    function refund() public payable returns(bool);
    
    function withdrawFund() public payable returns(bool);

    function paybackFund(uint256 amount) public payable returns(bool);
    
    function defaultLoan() public returns(bool);
    
    function cancelLoan() public returns(bool);
    
    function disable() public returns(bool);
    
    /// Internal functions
    
    function onlyAfter(uint _time) internal view returns(bool) { 
        return now >= _time; 
    }

    /// Public functions

    function getLenderInfo(address addr) public view returns(address, uint256) {
        Lender memory l = lenders[addr];
        return (l.account, l.lendingAmount);
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

}