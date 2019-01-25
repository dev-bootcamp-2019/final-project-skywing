import React, { Component } from "react";
import { Redirect } from 'react-router-dom';
import SimpleLoanContract from "../contracts/SimpleLoan.json"; 

class LoanDetails extends Component {
    state = {formTitle: "Contract - ", loan: { borrower: null, loanAmount: null, status: null, lender: null }};

    getStatusDescription(idx) {
        switch(idx) {
            case "0": return 'Requesting';
            case "1": return 'Funding';
            case "2": return 'Funded';
            case "3": return 'FundWithdrawn';
            case "4": return 'Repaid';
            case "5": return 'Defaulted';
            case "6": return 'Refunded';
            case "7": return 'Cancelled';
            case "8": return 'Closed';
            default: return 'None';
        }
    }
    
    componentDidMount = async() => {
        this.setState({web3: this.props.web3});
        this.props.onTitle(this.state.formTitle + this.props.match.params.id);
        try {
            const c = new this.props.web3.eth.Contract(SimpleLoanContract.abi, this.props.match.params.id);
            this.setState({loan: {
                borrower: await c.methods.borrower().call(),
                loanAmount: await c.methods.loanAmount().call(),
                status: this.getStatusDescription(await c.methods.status().call()),
                lenderCount: await c.methods.lenderCount().call()  
            }});
        } catch(error) {
            console.error(error);
        }
    }

    handleFundIt = async(e) => {
        e.preventDefault();
        const { web3 } = this.state;
        let loanAmount = e.target.fundAmount.value;
        let lenderAddr = await this.state.web3.eth.coinbase;
        console.log(lenderAddr, ' - ', loanAmount);
        
        try {
            const loan = new this.props.web3.eth.Contract(SimpleLoanContract.abi, this.props.match.params.id);
            await loan.methods.depositFund().call({from: lenderAddr, value: loanAmount});
            let tx = await loan.methods.depositFund().send({from: lenderAddr, value: loanAmount});
            console.log(tx);
        } catch(err) {
            console.log(err);
        }
    }

    // renderLenders = async(e) => {
    //     try {
    //         const loan = new this.props.web3.eth.Contract(SimpleLoanContract.abi, this.props.match.params.id);
    //         if (this.state.loan.lenderCount > 0) {
    //             for(i=0;)
    //             let tx = await loan.methods.depositFund().send({from: lenderAddr, value: loanAmount});    
    //         }
    //     } catch(err) {
    //         console.log(err);
    //     }
    // }

    handleBorrowerWithdraw = async() => {
        const { web3 } = this.state;
        let borrowerAddr = await this.state.web3.eth.coinbase;
        try {
            const loan = new web3.eth.Contract(SimpleLoanContract.abi, this.props.match.params.id);
            await loan.methods.withdrawToBorrower().call({from: borrowerAddr});
            let tx = await loan.methods.withdrawToBorrower().send({from: borrowerAddr});
            console.log(tx);
        } catch(err) {
            console.log(err);
        }
    }

    render() {
        return (
            <div>
            <div className="row">
                <div className="col">
                <h6 htmlFor="borrowerAddr">Borrower: {this.state.loan.borrower}</h6>
                <h5>Loan Amount: {this.state.loan.loanAmount} ETH</h5>
                <h6>Status: {this.state.loan.status}</h6>
                </div>
            </div>
            <div className="row">
                <div className="col">
                <hr/>
                <h4>Lender Information</h4>
                Lender count: {this.state.loan.lenderCount}
                { this.state.loan.status === 'Funding' ? (
                    <form className="form-inline" onSubmit={this.handleFundIt}>
                        <div className="form-group mb-2">
                            <input type="text" readonly className="form-control-plaintext" id="staticEmail2" value="Funding Amount"/>
                        </div>
                        <div className="form-group mx-sm-3 mb-2">
                            <input type="text" className="form-control" id="fundAmount" placeholder="Amount In Ether"/>
                        </div>
                        <button type="submit" className="btn btn-primary mb-2">Fund It !!!</button>
                    </form>
                  ) : (<div></div>)
                }
                { this.state.loan.status === 'Funded' ? (
                    <div>
                        <button onClick={this.handleBorrowerWithdraw} className="btn btn-success mr-5">Widthdraw To Borrower Account</button>
                    </div>
                )  : (<div></div>)}
                </div>
            </div>
            </div>
        );
    }
}

export default LoanDetails;