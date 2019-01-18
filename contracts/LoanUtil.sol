pragma solidity ^0.5.0;

library LoanUtil {
    function generateId(address addr1, address addr2) internal view returns(bytes32) {
        uint256 generatedId = uint256(addr1) - uint256(addr2) + now;
        return bytes32(generatedId);
    }
}