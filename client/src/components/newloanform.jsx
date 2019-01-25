import React, { Component } from "react";
import { Redirect } from 'react-router-dom';
import SimpleLoanContract from "../contracts/SimpleLoan.json"; 

class NewLoanForm extends Component {
    state = {formTitle: "New Loan Request", web3: null, toHome: false }
    componentDidMount() {
        this.props.onTitle(this.state.formTitle)
        this.setState({web3: this.props.web3});
    }
    
    handleSubmit = (e) => {
        e.preventDefault();
        // let borrower = e.target.borrowerAddr.value;
        // let loanAmount = e.target.loanAmt.value;
        // let loanTitle = e.target.loanTitle.value;
        // let SimpleLoan = new this.state.web3.eth.Contract(SimpleLoanContract.abi);
        // //console.log(SimpleLoan);
        // //console.log('coinbase:', this.state.web3.eth.coinbase);
        // //let newLoan = SimpleLoan.new({data: SimpleLoanContract.bytecode, from: this.state.web3.eth.coinbase});
        // SimpleLoan.deploy({
        //     data: SimpleLoanContract.bytecode
        // }).send({
        //     from: this.state.web3.eth.coinbase
        // })
        // .on('error', function(error) { console.log(error); })
        // .then((newInstance) => {
        //     //console.log(newInstance.options.address);
        //     this.props.onNewLoan({contractAddress: newInstance.options.address, title: loanTitle});
        // });
        
        this.props.onNewLoan({contractAddress: 'address', title: 'new title'});
        this.setState({toHome: true});
    }

    render() {
        if (this.state.toHome === true) {
            return <Redirect to='/'/>
        }
        return (
            <form onSubmit={this.handleSubmit}>
                <div className="form-group">
                    <label>
                        Title: 
                    </label>
                    <input type="text" className="form-control" id="loanTitle"  placeholder="Loan Title" />
                </div>
                <div className="form-group">
                    <label>
                        Borrower Address: 
                    </label>
                    <input type="text" className="form-control" id="borrowerAddr" aria-describedby="borrowerAddress" placeholder="Enter borrower address" />
                    <small id="borrowerAddress" className="form-text text-muted">Ethereum Address</small>
                </div>
                <div className="form-group">
                    <label>Loan Amount:</label>
                    <input type="text" className="form-control" id="loanAmt" placeholder="Loan Amount In Ether"/>
                </div>
                <button type="submit" className="btn btn-primary">Submit</button>
            </form>
        );
    }
}

export default NewLoanForm;