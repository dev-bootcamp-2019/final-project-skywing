import React, { Component } from "react";

const Navbar = ({ userAddress }) => {
  return (
    <nav className="navbar navbar-dark bg-dark flex-md-nowrap shadow">
      <span className="navbar-brand mb-0 h1">Simple Loan Demo</span>
      <form className="mx-2 my-auto w-50 d-inline">
            <div className="input-group input-group-sm">
                <div className="input-group-prepend">
                    <span className="input-group-text" id="inputGroup-sizing-sm">@address</span>
                </div>
                <input type="text" className="form-control" placeholder={userAddress} aria-describedby="inputGroup-sizing-sm"/>
            </div>
      </form>
    </nav>
  );
};

export default Navbar;