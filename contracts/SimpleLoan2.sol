pragma solidity ^0.5.0;

import "./Ownable.sol";
//import {Loan as LoanUtil} from "./Loan.sol";

contract SimpleLoan2 is Ownable {
    bytes32 public id;
    address public borrower;
    //address public guarantor;
    uint256 public loanAmount;
    uint public lenderCount;
    //uint fee;
    //uint interestRate;
    uint public createdTime = now;
    uint public fullyFundedTime;

    enum Status { Requesting, Funding, Funded, FundWithdrawn, Repaid, Defaulted, Refunded, Cancelled, Disabled }

    struct Lender {
        address payable account;
        uint256 lendingAmount;
        uint256 repaidAmount;
    }

    Status public status;
    mapping(address => Lender) lenders;
    mapping(uint => address) lenderAddr;

    event Requesting(bytes32 loanId, address borrower, address guarantor);
    event Funding(bytes32 loanId, address lender, uint256 amount);
    event Funded(bytes32 loanId, uint256 amount);
    event FundWithdrawn(bytes32 loanId, uint256 amount);
    event Repaid(bytes32 loadId, uint256 amount);
    event Defaulted(bytes32 loanId, uint256 defaultedAmt, uint256 loanAmt);
    event Refunded(bytes32 loanId, address lender, uint256 amount);
    event Disabled(bytes32 loanId);
    
    modifier isFunding() { status == Status.Funding; _; }
    modifier isFunded() { status == Status.Funded; _; }
    modifier isWithdrawn() { status == Status.FundWithdrawn; _; }
    modifier isRepaid() { status == Status.Repaid; _; }
    modifier isDefaulted() { status == Status.Defaulted; _; }
    modifier isRefunded() { status == Status.Refunded; _; }
    modifier isCancelled() { status == Status.Cancelled; _; }
    
    modifier onlyAfter(uint _time) { require(now >= _time, "Tool early to call this function"); _; }
    modifier onlyBorrowerOrOwner() { require(msg.sender == borrower || msg.sender == owner(), "Authorized for borrower or owner only."); _; }
    modifier onlyBorrower() { require(msg.sender == borrower, "Authorized for borrower only."); _; }

    constructor (address _borrower, uint256 _amt) Ownable() public {
        borrower = _borrower;
        //guarantor = _guarantor;
        loanAmount = _amt;
        status = Status.Funding;
        //id = LoanUtil.generateId(borrower, guarantor);
        id = generateId(borrower, owner());
        createdTime = now;
        emit Requesting(id, borrower, owner());
    }
    
    function fundIt() public payable isFunding() 
    {
        require(msg.value <= loanAmount, "Lending amount is more than what requested.");
        require(msg.value <= loanAmount - getBalance(), "Lending amount is more than remaining fund needed.");
        require(lenders[msg.sender].account == address(0), "Existing lender.");
        require(msg.sender != owner(), "Contract broker can't be a lender in the same contract.");
        require(msg.sender != borrower, "Borrower can't be a lender in the same contract.");

        lenders[msg.sender] = Lender({account: msg.sender, lendingAmount: msg.value, repaidAmount: 0});
        lenderAddr[lenderCount] = msg.sender;
        lenderCount++;
        emit Funding(id, msg.sender, msg.value);
        if (getBalance() == loanAmount) {
            status = Status.Funded;
            fullyFundedTime = now;
            emit Funded(id, loanAmount);
        }
        
    }

    function refund() public payable isFunding() onlyOwner()
    {
        for(uint i=0; i<lenderCount; i++) {
            Lender memory lender = lenders[lenderAddr[i]];
            uint256 refundAmt = lender.lendingAmount;
            address refundAddr = lender.account;
            delete lenders[lenderAddr[i]];
            lender.account.transfer(refundAmt);
            emit Refunded(id, refundAddr, refundAmt);
        }
        lenderCount = 0;
        status = Status.Refunded;
    }
    
    function withdrawFund() public payable isFunded() onlyAfter(fullyFundedTime + 1 weeks) onlyBorrower() {
        msg.sender.transfer(getBalance());
        status = Status.FundWithdrawn;
    }
    
    function defaultLoan() public isWithdrawn() onlyAfter(fullyFundedTime + 4 weeks) onlyBorrowerOrOwner() {
        status = Status.Defaulted;
    }
    
    function cancelLoan() public isRefunded() onlyOwner() {
        status = Status.Cancelled;
    }
    
    function disable() public onlyAfter(createdTime + 10 weeks) onlyOwner() {
        require(status == Status.Repaid || status == Status.Defaulted || status == Status.Cancelled, "Can't disable the contract when its status is still valid");
        status = Status.Disabled;
    }
    
    /**
     * Utility functions
    **/
    function getLenderInfo(address addr) public view returns(address, uint256) {
        Lender memory l = lenders[addr];
        return (l.account, l.lendingAmount);
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
    function generateId(address addr1, address addr2) internal view returns(bytes32) {
        uint256 generatedId = uint256(addr1) - uint256(addr2) + now;
        return bytes32(generatedId);
    }

}