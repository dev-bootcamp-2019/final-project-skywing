import React, { Component } from "react";
import { homedir } from "os";

class Home extends Component {
    state = {formTitle: "All the Loans", web3: null}
    componentDidMount() {
        this.props.onTitle(this.state.formTitle)
        this.setState({web3: this.props.web3});
    }

    render() {
        return (
            <h1>Home</h1>
        );
    }
}

export default Home;