var LoanUtil = artifacts.require('LoanUtil');
var SimpleLoan = artifacts.require('SimpleLoan');

contract('SimpleLoan', function(accounts) {

    const owner = accounts[0];
    const borrower = accounts[1];
    const requestedLoanAmt = "10";

    const lender1 = accounts[3];
    const lender2 = accounts[4];
    const lender3 = accounts[5];

    const lendingAmt1 = web3.utils.toWei(web3.utils.toBN(2), "ether");
    const lendingAmt2 = web3.utils.toWei(web3.utils.toBN(3), "ether");
    const lendingAmt3 = web3.utils.toWei(web3.utils.toBN(5), "ether");

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
        await loan.depositFund({from: lender1, value: lendingAmt1});
        assert.equal(lendingAmt1.toString(), (await loan.ownedAmount()).toString(), "1st loan amount not match what just funded");

        await loan.depositFund({from: lender2, value: lendingAmt2});
        assert.equal(lendingAmt1.add(lendingAmt2).toString(), (await loan.ownedAmount()).toString(), "2nd loan amount not match what just funded");

        await loan.depositFund({from: lender3, value: lendingAmt3});
        assert.equal(lendingAmt1.add(lendingAmt2).add(lendingAmt3).toString(), String(await loan.ownedAmount()), "3nd loan amount not match what just funded");

        assert.equal((await loan.getBalance()).toString(), loanAmount.toString(), "Balance not matched");
        assert.equal(await loan.status(), LoanStatus.Funded, "Loan status should be funded");
    });

    it('should refund all the fund to the lender', async() => {
        var lender1_initialBalance, lender2_initialBalance, lender3_initialBalance;

        lender1_initialBalance = await web3.eth.getBalance(lender1);
        lender2_initialBalance = await web3.eth.getBalance(lender2);
        lender3_initialBalance = await web3.eth.getBalance(lender3);

        expected_lender1_balance = web3.utils.toBN(lender1_initialBalance); //.add(lendingAmt1);
         //.sub(web3.utils.toBN(await web3.eth.getGasPrice()));

        await loan.refund({from:owner});
        assert.equal((await loan.ownedAmount()).toString(), "0", "Expecting owned amount to be 0.");
        assert.equal((await loan.lenderCount()).toString(), "0", "Expecting lender count to be 0.");
        assert.equal((await loan.getBalance()).toString(), "0", "Expecting balance to be 0.");

        
        current_lender1_balance = web3.utils.toBN(await web3.eth.getBalance(lender1));
        assert.isTrue(current_lender1_balance.eq(expected_lender1_balance), 
            "curreunt value:" + current_lender1_balance.toString() + " expected value:" + expected_lender1_balance.toString());
    });
}); 