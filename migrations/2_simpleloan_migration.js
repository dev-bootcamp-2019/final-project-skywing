var SimpleLoan = artifacts.require("./SimpleLoan.sol");
var Loan = artifacts.require("./Loan.sol");


module.exports = function(deployer) {
    deployer.deploy(Loan);
    deployer.link(Loan, SimpleLoan);    
    deployer.deploy(SimpleLoan, "0x2Ec4620781edcF4CA926b245C491BAcC2e751658", "0xC9CAa8934b4444e3cafD991E07A0408d2E482386", 10);
  
};
