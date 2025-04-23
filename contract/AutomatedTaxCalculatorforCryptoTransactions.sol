// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
contract CryptoTaxCalculator {
    address public owner;
    uint256 public taxRateBasisPoints = 1500; 
    event TaxCalculated(address indexed user, uint256 amount, uint256 taxAmount);
    event TaxRateUpdated(uint256 oldRate, uint256 newRate);
    modifier onlyOwner() {
        require(msg.sender == owner, "Unauthorized");
        _;
    }
    constructor() {
        owner = msg.sender;
    }
    function calculateTax(uint256 _amount) external returns (uint256) {
        require(_amount > 0, "Amount must be positive");
        uint256 tax = (_amount * taxRateBasisPoints) / 10000;
        emit TaxCalculated(msg.sender, _amount, tax);
        return tax;
    }
    function updateTaxRate(uint256 _newRate) external onlyOwner {
        require(_newRate <= 10000, "Rate must be <= 100%");
        emit TaxRateUpdated(taxRateBasisPoints, _newRate);
        taxRateBasisPoints = _newRate;
    }
}

