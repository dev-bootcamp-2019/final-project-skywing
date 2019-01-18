pragma solidity ^0.5.0;

import "./Ownable.sol";
import "./Loan.sol";
import {LoanUtil} from "./LoanUtil.sol";
import {StringUtils} from "./StringLib.sol";

contract SimpleLoan is Loan {
    
    modifier onlyBorrowerOrOwner { require(msg.sender == borrower || msg.sender == owner(), "Authorized for borrower or owner only."); _; }
    modifier onlyBorrower { require(msg.sender == borrower, "Authorized for borrower only."); _; }
    
    modifier onlyFullyFundedAfterOneWeek { require(onlyAfter(fullyFundedTime + 1 weeks), "Authorized only after 1 week fully funded"); _; }
    modifier onlyFullyFundedAfterTwoWeek { require(onlyAfter(fullyFundedTime + 2 weeks), "Authorized only after 2 weeks fully funded"); _; }
    modifier onlyFullyFundedAfterThreeWeek { require(onlyAfter(fullyFundedTime + 3 weeks), "Authorized only after 3 weeks fully funded"); _; }
    modifier onlyFullyFundedAfterFourWeek { require(onlyAfter(fullyFundedTime + 4 weeks), "Authorized only after 4 weeks fully funded"); _; }

    modifier onlyCreatedAfterTenWeek { require(onlyAfter(creationTime + 10 weeks), "Authorized only after 10 weeks loan requested."); _; }

    modifier canRefund { require(status == Status.Funding || status == Status.Funded, "Required Status: Funding or Funded"); _; }

    constructor() public {
        status = Status.Requesting;
        id = LoanUtil.generateId(borrower, owner());
        creationTime = now;
    }

    function request(address _borrower, uint _amount) public {
        require(_borrower != address(0), "Address is empty");
        require(_borrower != owner(), "Owner can't be borrower at the same time.");
        require(_amount > 0, "0 is not a valid borrowing amount.");
        
        borrower = _borrower;
        loanAmount = _amount;
        status = Status.Funding;
        emit Requesting(id, borrower, owner());
    }
    
    function depositFund() public payable isFunding isNotStopped {
        require(msg.value <= loanAmount, "Lending amount is more the amount requested.");
        require(msg.value <= loanAmount - ownedAmount, "Lending amount is more than remaining fund needed.");
        require(lenders[msg.sender].account == address(0), "Existing lender.");
        require(msg.sender != owner(), "Owner can't be a lender in the same contract.");
        require(msg.sender != borrower, "Borrower can't be a lender in the same contract.");

        lenders[msg.sender] = Lender({account: msg.sender, lendingAmount: msg.value, repaidAmount: 0});
        lenderAddr[lenderCount] = msg.sender;
        lenderCount++;
        ownedAmount += msg.value;
        emit Funding(id, msg.sender, msg.value);

        /// set the status to funded when the fund reach the requested amount.
        if (getBalance() == loanAmount) {
            status = Status.Funded;
            fullyFundedTime = now;
            emit Funded(id, loanAmount);
        }
    }

    function refund() public payable canRefund isNotStopped onlyOwner {
        require(ownedAmount == getBalance(), "Balance is not enough to refund all lenders.");

        for(uint i=0; i<lenderCount; i++) {
            Lender memory lender = lenders[lenderAddr[i]];
            if (lender.account != address(0))
            {
                uint refundAmt = lender.lendingAmount;
                address refundAddr = lender.account;
                delete lenders[lenderAddr[i]];
                ownedAmount -= refundAmt;
                lender.account.transfer(refundAmt);
                emit Refunded(id, refundAddr, refundAmt);
            }
        }
        lenderCount = 0;
        status = Status.Refunded;
    }
    
    function withdrawToBorrower() public payable isFunded isNotStopped onlyBorrower {
        require(getBalance() > 0, "The balance is 0 currently.");
        status = Status.FundWithdrawn;
        msg.sender.transfer(getBalance());
        emit FundWithdrawn(id, ownedAmount);
    }

    function repay() public payable isWithdrawn isNotStopped onlyBorrower {
        require(msg.value == ownedAmount, "Repaid amount not the same as amount owned.");
        ownedAmount = ownedAmount - msg.value;
        status = Status.Repaid;
        emit Repaid(id, msg.value);
    }

    function withdrawToLenders() public payable isRepaid isNotStopped onlyOwner {
        require(ownedAmount == getBalance(), "Balance is not enough to refund all lenders.");
        for(uint i=0; i<lenderCount; i++) {
            Lender memory lender = lenders[lenderAddr[i]];
            if (lender.account != address(0))
            {
                uint repaidAmt = lender.lendingAmount;
                delete lenders[lenderAddr[i]];
                lender.repaidAmount = repaidAmt;
                ownedAmount -= repaidAmt;
                lender.account.transfer(repaidAmt);
            }
        }
        lenderCount = 0;
        status = Status.Closed;
        emit Closed(id);
    }
    
    function toDefault() public isWithdrawn isNotStopped onlyBorrowerOrOwner {
        status = Status.Defaulted;
        emit Defaulted(id, ownedAmount, loanAmount);
    }
    
    function cancel() public isNotStopped onlyBorrowerOrOwner {
        require(lenderCount == 0, "Can't cancelled contract when fund is provided. Fund need to be return first before cancel.");
        status = Status.Cancelled;
        emit Cancelled(id);
    }

}