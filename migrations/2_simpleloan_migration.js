var SimpleLoan = artifacts.require("./SimpleLoan.sol");
var LoanUtil = artifacts.require("./LoanUtil.sol");


module.exports = function(deployer) {
    deployer.deploy(LoanUtil);
    deployer.link(LoanUtil, SimpleLoan);    
    //deployer.deploy(SimpleLoan, "0x2Ec4620781edcF4CA926b245C491BAcC2e751658", "0xC9CAa8934b4444e3cafD991E07A0408d2E482386", 10);
    deployer.deploy(SimpleLoan);
};
