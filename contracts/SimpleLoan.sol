pragma solidity ^0.5.0;

import "./Ownable.sol";
import "./Loan.sol";
import "./LoanUtil.sol";

contract SimpleLoan is Loan {
    
    modifier onlyBorrowerOrOwner { require(msg.sender == borrower || msg.sender == owner(), "Authorized for borrower or owner only."); _; }
    modifier onlyBorrower { require(msg.sender == borrower, "Authorized for borrower only."); _; }
    
    modifier onlyFullyFundedAfterOneWeek { require(onlyAfter(fullyFundedTime + 1 weeks), "Authorized only after 1 week fully funded"); _; }
    modifier onlyFullyFundedAfterTwoWeek { require(onlyAfter(fullyFundedTime + 2 weeks), "Authorized only after 2 weeks fully funded"); _; }
    modifier onlyFullyFundedAfterThreeWeek { require(onlyAfter(fullyFundedTime + 3 weeks), "Authorized only after 3 weeks fully funded"); _; }
    modifier onlyFullyFundedAfterFourWeek { require(onlyAfter(fullyFundedTime + 4 weeks), "Authorized only after 4 weeks fully funded"); _; }

    modifier onlyCreatedAfterTenWeek { require(onlyAfter(creationTime + 10 weeks), "Authorized only after 10 weeks loan requested."); _; }


    constructor (address _borrower, uint256 _amt) public {
        borrower = _borrower;
        loanAmount = _amt;
        status = Status.Funding;
        id = LoanUtil.generateId(borrower, owner());
        creationTime = now;
        emit Requesting(id, borrower, owner());
    }
    
    function fundIt() public payable isFunding returns(bool)
    {
        require(msg.value <= loanAmount, "Lending amount is more the amount requested.");
        require(msg.value <= loanAmount - getBalance(), "Lending amount is more than remaining fund needed.");
        require(lenders[msg.sender].account == address(0), "Existing lender.");
        require(msg.sender != owner(), "Owner can't be a lender in the same contract.");
        require(msg.sender != borrower, "Borrower can't be a lender in the same contract.");

        lenders[msg.sender] = Lender({account: msg.sender, lendingAmount: msg.value, repaidAmount: 0});
        lenderAddr[lenderCount] = msg.sender;
        lenderCount++;
        emit Funding(id, msg.sender, msg.value);

        /// set the status to funded when the fund reach the requested amount.
        if (getBalance() == loanAmount) {
            status = Status.Funded;
            fullyFundedTime = now;
            emit Funded(id, loanAmount);
        }
        return true;
    }

    function refund() public payable isFunding onlyOwner returns(bool)  
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
        return true;
    }
    
    function withdrawFund() public payable isFunded onlyBorrower onlyFullyFundedAfterOneWeek
        returns(bool)
    {
        ownedAmount = getBalance();
        status = Status.FundWithdrawn;
        if(msg.sender.transfer(getBalance()))
        {
            return true;
        }
        return false;
    }

    function paybackFund(uint256 amount) public payable isWithdrawn onlyBorrower 
        returns(bool)
    {
        return false;
    }
    
    function defaultLoan() public isWithdrawn onlyBorrowerOrOwner onlyFullyFundedAfterFourWeek
        returns(bool)
    {
        status = Status.Defaulted;
        return true;
    }
    
    function cancelLoan() public onlyBorrowerOrOwner 
        returns(bool) 
    {
        status = Status.Cancelled;
        return true;
    }
    
    function disable() public onlyOwner returns(bool) 
    {
        require(status == Status.Repaid || status == Status.Defaulted || status == Status.Cancelled, 
            "Disabling contract not allowed when its status is not Repaid, Defaulted, or Cancelled.");
        status = Status.Disabled;
        return true;
    }

}