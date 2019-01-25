import React, { Component } from 'react';
import { BrowserRouter as Router, Route, NavLink } from 'react-router-dom';
import SimpleLoanContract from "./contracts/SimpleLoan.json";
import getWeb3 from "./utils/getWeb3";
import Navbar from "./components/navbar";
import Home from "./components/home";
import NewLoanForm from "./components/newloanform";
import LoanDetails from "./components/loandetails";

import './App.css';

class App extends Component {
  STORAGE_KEY = 'contracts';
  state = { web3: null, accounts: null, contracts: [], formTitle: "[Title Here]"};

  componentDidMount = async () => {
    try {
      // Get network provider and web3 instance
      const web3 = await getWeb3();
      // Use web3 to get the user accounts
      const accounts = await web3.eth.getAccounts();
      web3.eth.coinbase = accounts[0];
      //Get the contract instance
      //const networkId = await web3.eth.net.getId();
      //const deployedNetwork = SimpleLoan.networks[networkId];
      //const instance = new web3.eth.Contract(SimpleLoan.abi, deployedNetwork && deployedNetwork.address);
      // Set web3, accounts, and contract to the state, and the proceed with an 
      // example of interacting with contract's methods.
      this.setState({web3, accounts});
    } catch(error) {
      // Catch any errors for any of the above operations.
      alert('Failed to load web3, accounts, or contract. Check console for details.');
      console.error(error);
    }

    if (localStorage.hasOwnProperty(this.STORAGE_KEY)) {
      let value = localStorage.getItem(this.STORAGE_KEY);
      this.setState({contracts: JSON.parse(value)});
    } 
  }

  setFormTitle = title => {
    this.setState({formTitle: title});
  }

  onNewLoan = (loan) => {
    let value = localStorage.getItem(this.STORAGE_KEY);
    this.setState({contracts: JSON.parse(value)});
  }

  render() {
    if (!this.state.web3) {
      return (<div>Loading Web3, accounts, and contract...</div>);
    } else {
      return (
        <React.Fragment>
          <Navbar userAddress={this.state.accounts[0]}/>
          <Router>
          <div className="container-fluid">
            <div className="row">
              <nav className="col-md-2 d-none d-md-block bg-light sidebar flex-fill h-100">
                <div className="sidebar-sticky">
                  <ul className="nav flex-column">
                    <li className="nav-item">
                      <NavLink className="nav-link sm active" to="/">
                        Home 
                      </NavLink>
                    </li>
                    <li className="nav-item">
                      <NavLink className="nav-link sm active" to="/newloan">
                         New Loan Request
                      </NavLink>
                    </li>
                  </ul>
                </div>
              </nav>

              <main role="main" className="col-md-9 ml-sm-auto col-lg-10 px-4">
                <div className="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                  <h1 className="h4">{this.state.formTitle}</h1>
                </div>

              
                <Route exact={true} path="/" render={() =>
                   <Home 
                    onTitle={this.setFormTitle}
                    web3={this.state.web3}
                    contracts={this.state.contracts}
                   />}/>
                <Route exact={true} path="/newloan" render={() =>
                    <NewLoanForm 
                      onTitle={this.setFormTitle} 
                      web3={this.state.web3} 
                      owner={this.state.account}
                      onNewLoan={this.onNewLoan}
                    />
                  } 
                />
                <Route exact={true} path="/loandetails/:id" render={(props) => 
                  <LoanDetails 
                    onTitle={this.setFormTitle}
                    web3={this.state.web3}
                    {...props}
                  />
                }/>

              </main>
            </div>
          </div>
          </Router>
        </React.Fragment>
      );
    }
  }
}

export default App;
