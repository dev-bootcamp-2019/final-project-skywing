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
        const { web3 } = this.props;
        this.props.onTitle(this.state.formTitle + this.props.match.params.id);
        try {
            const c = new web3.eth.Contract(SimpleLoanContract.abi, this.props.match.params.id);
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

    render() {
        return (
            <div class="row">
                <div class="col">
                <h6 htmlFor="borrowerAddr">Borrower: {this.state.loan.borrower}</h6>
                <h5>Loan Amount: {this.state.loan.loanAmount} ETH</h5>
                <h6>Status: {this.state.loan.status}</h6>
                <form>
                    <div className="form-group row">
                        
                    </div>
                </form>
                </div>
            </div>
        );
    }
}

export default LoanDetails;