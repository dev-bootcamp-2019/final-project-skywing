const LoanUtil = artifacts.require('LoanUtil');
const SimpleLoan = artifacts.require('SimpleLoan');
const truffleAssert = require('truffle-assertions');

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

const emptyAddress = "0x0000000000000000000000000000000000000000";

contract('SimpleLoan-Setup', function(accounts)  {

    const owner = accounts[0];
    const borrower = accounts[1];
    const loanAmount = web3.utils.toWei(web3.utils.toBN(10), "ether");
    let loan;

    it("should create the contract without borrower info for funding", async() => {
        loan =  await SimpleLoan.new();
        assert.equal(await loan.getStatus(), LoanStatus.Requesting, "new created loan not in requesting status.");
        assert.equal(await loan.getBorrower(), emptyAddress, "Borrower shoud be empty.");
        assert.equal((await loan.getLoanAmount()).toString(), "0", "Loan amount should be 0.");
    });

    it("should create the contract with borrowing info for funding", async() => {
        tx = await loan.request(borrower, loanAmount);
        assert.equal(await loan.getStatus(), LoanStatus.Funding, "loan with borrowing info should be in funding status.")
        await truffleAssert.eventEmitted(tx, 'Requesting', ev => {
            return ev.id === loan.id && ev.borrower === borrower;
        });
        assert.equal(await loan.getStatus(), LoanStatus.Funding, "loan with borrowing info should be in funding status.")
        assert.equal(borrower, await loan.getBorrower(), "borrower address not matched.");
        assert.equal(loanAmount.toString(), (await loan.getLoanAmount()).toString(), "Request loan amount not matched.");
    });
}); 


// contract('SimpleLoan-Fund-Refund', function(accounts) {

//     const owner = accounts[0];
//     const borrower = accounts[1];

//     const lender1 = accounts[3];
//     const lender2 = accounts[4];
//     const lender3 = accounts[5];

//     const lendingAmt1 = web3.utils.toWei(web3.utils.toBN(2), "ether");
//     const lendingAmt2 = web3.utils.toWei(web3.utils.toBN(3), "ether");
//     const lendingAmt3 = web3.utils.toWei(web3.utils.toBN(5), "ether");

//     const loanAmount = web3.utils.toWei("10", "ether");

//     let loan;

//     it("should be funded by 3 lenders with the amount of 2, 3, and 5 either", async() => {
//         loan =  await SimpleLoan.new();
//         await loan.request(borrower, loanAmount);

//         await loan.depositFund({from: lender1, value: lendingAmt1});
//         assert.equal(lendingAmt1.toString(), (await loan.getOwnedAmount()).toString(), "1st loan amount not match what just funded");

//         await loan.depositFund({from: lender2, value: lendingAmt2});
//         assert.equal(lendingAmt1.add(lendingAmt2).toString(), (await loan.getOwnedAmount()).toString(), "2nd loan amount not match what just funded");

//         await loan.depositFund({from: lender3, value: lendingAmt3});
//         assert.equal(lendingAmt1.add(lendingAmt2).add(lendingAmt3).toString(), String(await loan.getOwnedAmount()), "3nd loan amount not match what just funded");
//         assert.equal((await loan.getBalance()).toString(), loanAmount.toString(), "Balance not matched");
//         assert.equal(await loan.getStatus(), LoanStatus.Funded, "Loan status should be funded");
//     });

//     it('should refund all the fund to the lender', async() => {

//         expected_lender1_balance = web3.utils.toBN(await web3.eth.getBalance(lender1)).add(lendingAmt1);
//         expected_lender2_balance = web3.utils.toBN(await web3.eth.getBalance(lender2)).add(lendingAmt2);
//         expected_lender3_balance = web3.utils.toBN(await web3.eth.getBalance(lender3)).add(lendingAmt3);

//         await loan.refund({from:owner});
//         assert.equal((await loan.getOwnedAmount()).toString(), "0", "Expecting owned amount to be 0.");
//         assert.equal((await loan.getLenderCount()).toString(), "0", "Expecting lender count to be 0.");
//         assert.equal((await loan.getBalance()).toString(), "0", "Expecting balance to be 0.");

//         current_lender1_balance = web3.utils.toBN(await web3.eth.getBalance(lender1));
//         assert.isTrue(current_lender1_balance.eq(expected_lender1_balance), 
//             "curreunt value:" + current_lender1_balance.toString() + " expected value:" + expected_lender1_balance.toString());

//         current_lender2_balance = web3.utils.toBN(await web3.eth.getBalance(lender2));
//             assert.isTrue(current_lender2_balance.eq(expected_lender2_balance), 
//             "curreunt value:" + current_lender2_balance.toString() + " expected value:" + expected_lender2_balance.toString());

//         current_lender3_balance = web3.utils.toBN(await web3.eth.getBalance(lender3));
//             assert.isTrue(current_lender3_balance.eq(expected_lender3_balance), 
//             "curreunt value:" + current_lender3_balance.toString() + " expected value:" + expected_lender3_balance.toString());

//         assert.equal(await loan.getStatus(), LoanStatus.Refunded, "Loan status should be refunded");
//     });

//     it("should fail because the status is refunded", async() => {
//         await truffleAssert.fails(loan.refund({from:owner}), truffleAssert.ErrorType.REVERT);
//     });

// });


// contract('SimpleLoan-Fund-Witdrawn', function(accounts) {
//     const owner = accounts[0];
//     const borrower = accounts[1];

//     const lender1 = accounts[3];
//     const lender2 = accounts[4];
//     const lender3 = accounts[5];

//     const lendingAmt1 = web3.utils.toWei(web3.utils.toBN(2), "ether");
//     const lendingAmt2 = web3.utils.toWei(web3.utils.toBN(3), "ether");
//     const lendingAmt3 = web3.utils.toWei(web3.utils.toBN(5), "ether");

//     const loanAmount = web3.utils.toWei(web3.utils.toBN(10), "ether");

//     let loan;

//     it('should witdrawn all the fund to the borrower', async() => {

//         loan = await SimpleLoan.new();
//         await loan.request(borrower, loanAmount);
//         await loan.depositFund({from: lender1, value: lendingAmt1});
//         await loan.depositFund({from: lender2, value: lendingAmt2});
//         await loan.depositFund({from: lender3, value: lendingAmt3});
        
//         borrower_balance_before_withdrawn = web3.utils.toBN(await web3.eth.getBalance(borrower));
        
//         tx = await loan.withdrawToBorrower({from:borrower});
//         tx_cost = web3.utils.toBN(tx.receipt.gasUsed).mul(web3.utils.toBN(await web3.eth.getGasPrice()));

//         let borrower_balance_after_withdrawn = web3.utils.toBN(await web3.eth.getBalance(borrower));
        
//         // the balance after widthdrawn minus the loanAmount and add the transaction cost back to it should match 
//         // the balance beforre widthdrawing fund.
//         let balance_af = borrower_balance_after_withdrawn.sub(loanAmount).add(tx_cost);
        
//         assert.strictEqual(borrower_balance_before_withdrawn.toString(), balance_af.toString(), 
//             "borrower balance before withdrawn: " + web3.utils.fromWei(borrower_balance_after_withdrawn, "ether") + 
//             ", borrower balancer after withdrawn: " + web3.utils.fromWei(balance_af, "ether"));

//         assert.strictEqual((await loan.getStatus()).toNumber(), LoanStatus.FundWithdrawn, "Expecting loan status in FundWithdrawn.");
//     });

//     it("should fail because the status is withdrawn", async() => {
//         await truffleAssert.fails(loan.withdrawToBorrower({from:borrower}), truffleAssert.ErrorType.REVERT);
//     });

// });

contract('SimpleLoan-Borrower-Repay', function(accounts) {
    const owner = accounts[0];
    const borrower = accounts[1];

    const lender1 = accounts[3];
    const lender2 = accounts[4];
    const lender3 = accounts[5];

    const lendingAmt1 = web3.utils.toWei(web3.utils.toBN(2), "ether");
    const lendingAmt2 = web3.utils.toWei(web3.utils.toBN(3), "ether");
    const lendingAmt3 = web3.utils.toWei(web3.utils.toBN(5), "ether");

    const loanAmount = web3.utils.toWei(web3.utils.toBN(10), "ether");

    let loan;

    it('should re-pay all the fund to the contract', async() => {

        loan = await SimpleLoan.new();
        await loan.request(borrower, loanAmount);
        await loan.depositFund({from: lender1, value: lendingAmt1});
        await loan.depositFund({from: lender2, value: lendingAmt2});
        await loan.depositFund({from: lender3, value: lendingAmt3});
        await loan.withdrawToBorrower({from:borrower});
        
        await truffleAssert.fails(loan.repay({from: owner}), truffleAssert.ErrorType.REVERT);
        tx = await loan.repay({from: borrower, value: loanAmount});
        
        await truffleAssert.eventEmitted(tx, 'Repaid', ev => {
            return ev.loanId === loan.id && ev.amount.eq(loanAmount);
        });
        assert.strictEqual((await loan.getStatus()).toNumber(), LoanStatus.Repaid, "Loan status should be in Repaid.");

    });
});
