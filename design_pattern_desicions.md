# Design Pattern Decisions

## Fail early and fail loud
All functions checks the condition required for execution as early as possible with function modifiers and in the function body and throws exception if the condition is not met.

```solidity
function request(address borrower, uint amount) public onlyOwner {
    require(borrower != address(0), "Address is empty");
    require(borrower != owner(), "Owner can't be borrower at the same time.");
    require(amount > 0, "0 is not a valid borrowing amount.");
    
    _borrower = borrower;
    _loanAmount = amount;
    _status = Status.Funding;
    emit Requesting(_id, _borrower, owner());
}
```

## Circuit Breaker Design Pattern

## Keeping logic simple

## Modular and reusable code