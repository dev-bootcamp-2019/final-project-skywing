pragma solidity ^0.5.0;

import "./Ownable.sol";
import "./Loan.sol";
import {LoanUtil} from "./LoanUtil.sol";
import {StringUtils} from "./StringLib.sol";

contract SimpleLoan is Loan {
    
    constructor() public {
        _status = Status.Requesting;
        _id = LoanUtil.generateId(_borrower, owner());
        _creationTime = now;
    }

    // Modifier functions
    modifier onlyBorrowerOrOwner { 
        require(msg.sender == _borrower || msg.sender == owner(), "Authorized for borrower or owner only."); 
        _; 
    }
    
    modifier onlyBorrower { 
        require(msg.sender == _borrower, "Authorized for borrower only."); 
        _; 
    }
    
    modifier onlyFullyFundedAfterOneWeek { 
        require(onlyAfter(_fullyFundedTime + 1 weeks), "Authorized only after 1 week fully funded"); 
        _; 
    
    }
    
    modifier onlyFullyFundedAfterTwoWeek { 
        require(onlyAfter(_fullyFundedTime + 2 weeks), "Authorized only after 2 weeks fully funded"); 
        _; 
    }

    modifier onlyFullyFundedAfterThreeWeek { 
        require(onlyAfter(_fullyFundedTime + 3 weeks), "Authorized only after 3 weeks fully funded"); 
        _; 
    }
    
    modifier onlyFullyFundedAfterFourWeek { 
        require(onlyAfter(_fullyFundedTime + 4 weeks), "Authorized only after 4 weeks fully funded"); 
        _; 
    }

    modifier onlyCreatedAfterTenWeek { 
        require(onlyAfter(_creationTime + 10 weeks), "Authorized only after 10 weeks loan requested."); 
        _; 
    }

    modifier canRefund { 
        require(_status == Status.Funding || _status == Status.Funded, "Required Status: Funding or Funded"); 
        _; 
    }

    
    // Public functions
    function request(address borrower, uint amount) public {
        require(borrower != address(0), "Address is empty");
        require(borrower != owner(), "Owner can't be borrower at the same time.");
        require(amount > 0, "0 is not a valid borrowing amount.");
        
        _borrower = borrower;
        _loanAmount = amount;
        _status = Status.Funding;
        emit Requesting(_id, _borrower, owner());
    }
    
    function depositFund() public payable isFunding isNotStopped {
        require(msg.value <= _loanAmount, "Lending amount is more the amount requested.");
        require(msg.value <= _loanAmount - _ownedAmount, "Lending amount is more than remaining fund needed.");
        require(_lenders[msg.sender].account == address(0), "Existing lender.");
        require(msg.sender != owner(), "Owner can't be a lender in the same contract.");
        require(msg.sender != _borrower, "Borrower can't be a lender in the same contract.");

        _lenders[msg.sender] = Lender({account: msg.sender, lendingAmount: msg.value, repaidAmount: 0});
        _lenderAddr[_lenderCount] = msg.sender;
        _lenderCount++;
        _ownedAmount += msg.value;
        emit Funding(_id, msg.sender, msg.value);

        /// set the status to funded when the fund reach the requested amount.
        if (balance() == _loanAmount) {
            _status = Status.Funded;
            _fullyFundedTime = now;
            emit Funded(_id, _loanAmount);
        }
    }

    function refund() public payable canRefund isNotStopped onlyOwner {
        require(_ownedAmount == balance(), "Balance is not enough to refund all lenders.");

        for(uint i = 0; i < _lenderCount; i++) {
            Lender memory lender = _lenders[_lenderAddr[i]];
            if (lender.account != address(0))
            {
                uint refundAmt = lender.lendingAmount;
                address refundAddr = lender.account;
                delete _lenders[_lenderAddr[i]];
                _ownedAmount -= refundAmt;
                lender.account.transfer(refundAmt);
                emit Refunded(_id, refundAddr, refundAmt);
            }
        }
        _lenderCount = 0;
        _status = Status.Refunded;
    }
    
    function withdrawToBorrower() public payable isFunded isNotStopped onlyBorrower {
        require(balance() > 0, "The balance is 0 currently.");
        _status = Status.FundWithdrawn;
        msg.sender.transfer(balance());
        emit FundWithdrawn(_id, _ownedAmount);
    }

    function repay() public payable isWithdrawn isNotStopped onlyBorrower {
        require(msg.value == _ownedAmount, "Repaid amount not the same as amount owned.");
        _ownedAmount -= msg.value;
        _status = Status.Repaid;
        emit Repaid(_id, msg.value);
    }

    function withdrawToLenders() public payable isRepaid isNotStopped onlyOwner {
        require(_loanAmount == balance(), "Balance is not enough to refund all lenders.");
        for(uint i = 0; i < _lenderCount; i++) {
            Lender memory lender = _lenders[_lenderAddr[i]];
            if (lender.account != address(0))
            {
                lender.repaidAmount = lender.lendingAmount;
                _lenders[_lenderAddr[i]] = lender;
                lender.account.transfer(lender.repaidAmount);
            }
        }
        _status = Status.Closed;
        emit Closed(_id);
    }
    
    function toDefault() public isWithdrawn isNotStopped onlyBorrowerOrOwner {
        _status = Status.Defaulted;
        emit Defaulted(_id, _ownedAmount, _loanAmount);
    }
    
    function cancel() public isNotStopped onlyBorrowerOrOwner {
        require(_lenderCount == 0, "Can't cancelled contract when fund is provided. Fund need to be return first before cancel.");
        _status = Status.Cancelled;
        emit Cancelled(_id);
    }

}