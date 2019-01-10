var LoanUtil = artifacts.require('LoanUtil');
var SimpleLoan = artifacts.require('SimpleLoan');

contract('SimpleLoan', function(accounts) {

    const owner = accounts[0];
    const borrower = accounts[1];
    const requestedLoanAmt = "10";

    const lender1 = accounts[3];
    const lender2 = accounts[4];
    const lender3 = accounts[5];

    const loanLib = LoanUtil.deployed();
    const simpleLoan = SimpleLoan.new()

    const loanAmount = web3.utils.toWei(requestedLoanAmt, "ether");
    const emptyAddress = '0x0000000000000000000000000000000000000000';
    
    const LoanStatus = { 
        Requesting: 0, 
        Funding: 1, 
        Funded: 2, 
        FundWithdrawn: 3, 
        Repaid: 4, 
        Defaulted: 5, 
        Refunded: 6, 
        Cancelled: 7, 
        Disabled: 8 
    };

    var loan;

    it("should create the contract with borrowing info for funding", async() => {
        loan = await SimpleLoan.deployed();
        assert.equal(await loan.status(), LoanStatus.Requesting, "new created loan not in requesting status.");

        await loan.requestLoan(borrower, loanAmount);
        assert.equal(await loan.status(), LoanStatus.Funding, "loan with borrowing info should be in funding status.")
        
        assert.equal(borrower, await loan.borrower(), "borrower address not matched.");
        assert.equal(loanAmount.toString(), String(await loan.loanAmount()), "Request loan amount not matched.");
    });

    it("should be funded by 3 lenders with the amount of 2, 3, and 5 either", async() => {
        lendingAmt1 = web3.utils.toWei(web3.utils.toBN(2), "ether");
        await loan.depositFund({from: lender1, value: lendingAmt1});
        assert.equal(lendingAmt1.toString(), (await loan.ownedAmount()).toString(), "1st loan amount not match what just funded");

        lendingAmt2 = web3.utils.toWei(web3.utils.toBN(3), "ether");
        await loan.depositFund({from: lender2, value: lendingAmt2});
        assert.equal(lendingAmt1.add(lendingAmt2).toString(), (await loan.ownedAmount()).toString(), "2nd loan amount not match what just funded");

        lendingAmt3 = web3.utils.toWei(web3.utils.toBN(5), "ether");
        await loan.depositFund({from: lender3, value: lendingAmt3});
        assert.equal(lendingAmt1.add(lendingAmt2).add(lendingAmt3).toString(), String(await loan.ownedAmount()), "3nd loan amount not match what just funded");

        assert.equal((await loan.getBalance()).toString(), loanAmount.toString(), "Balance not matched");
        assert.equal(await loan.status(), LoanStatus.Funded, "Loan status should be funded");
    });


});