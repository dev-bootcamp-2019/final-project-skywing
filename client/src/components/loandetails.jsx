import React, { Component } from "react";
import { Redirect } from 'react-router-dom';
import SimpleLoanContract from "../contracts/SimpleLoan.json"; 

class LoanDetails extends Component {
    state = {formTitle: "Contract - "}

    componentDidMount = async() => {
        this.props.onTitle(this.state.formTitle + this.props.match.params.id);
        //console.log(this.props.web3);
               
        let loanInstance = new this.props.web3.eth.Contract(SimpleLoanContract.abi, this.props.match.params.id);
        //console.log(loanInstance);
        //console.log('owner', await loanInstance.methods.owner().call());
        this.setState(() => ({loan: loanInstance}));
        console.log(this.state.loan);
    }

    render() {
        return (
            <div>
                <h1>details</h1>
                
            </div>
        );
    }
}

export default LoanDetails;