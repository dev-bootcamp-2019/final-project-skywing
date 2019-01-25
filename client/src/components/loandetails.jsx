import React, { Component } from "react";
import { Redirect } from 'react-router-dom';
import SimpleLoanContract from "../contracts/SimpleLoan.json"; 

class LoanDetails extends Component {
    state = {formTitle: "Contract - ", loan: null}

    async componentDidMount() {
        const { web3 } = this.props;
        this.props.onTitle(this.state.formTitle + this.props.match.params.id);
        try {
            let loanInstance = new web3.eth.Contract(SimpleLoanContract.abi, this.props.match.params.id);
            console.log(loanInstance);
            loanInstance.methods.owner().call().then((addr) => { console.log(addr)});
            this.setState({loan: loanInstance});

            this.setState({test: 'hello world'});
            //console.log(this.state.test);
        } catch(error) {
            console.error(error);
        }
        
    }

    render() {
        return (
            <form>
                <div className="form-group row">
                    <label htmlFor="borrowerAddr">Borrower</label>
                    <input type="text" id="borrowerAddr" className="form-control" planceholder={this.state.test}/>
                </div>
            </form>
        );
    }
}

export default LoanDetails;