// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract CryptoTaxCalculator {
    address public owner;
    uint256 public taxRateBasisPoints = 1500; // Default = 15%
    bool public paused = false;

    mapping(address => uint256) private userTaxRates;

    event TaxCalculated(address indexed user, uint256 amount, uint256 taxAmount);
    event TaxRateUpdated(uint256 oldRate, uint256 newRate);
    event UserTaxRateSet(address indexed user, uint256 rate);
    event UserTaxRateRemoved(address indexed user);
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);
    event Paused();
    event Unpaused();
    event OwnershipRenounced();
    event EmergencyWithdrawal(address indexed to, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Unauthorized");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function calculateTax(uint256 _amount) external whenNotPaused returns (uint256) {
        require(_amount > 0, "Amount must be positive");
        uint256 rate = userTaxRates[msg.sender] > 0 ? userTaxRates[msg.sender] : taxRateBasisPoints;
        uint256 tax = (_amount * rate) / 10000;
        emit TaxCalculated(msg.sender, _amount, tax);
        return tax;
    }

    function updateTaxRate(uint256 _newRate) external onlyOwner {
        require(_newRate <= 10000, "Rate must be <= 100%");
        emit TaxRateUpdated(taxRateBasisPoints, _newRate);
        taxRateBasisPoints = _newRate;
    }

    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "Invalid new owner");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }

    function pause() external onlyOwner {
        paused = true;
        emit Paused();
    }

    function unpause() external onlyOwner {
        paused = false;
        emit Unpaused();
    }

    function setUserTaxRate(address _user, uint256 _rate) external onlyOwner {
        require(_rate <= 10000, "Rate must be <= 100%");
        userTaxRates[_user] = _rate;
        emit UserTaxRateSet(_user, _rate);
    }

    function removeUserTaxRate(address _user) external onlyOwner {
        require(userTaxRates[_user] > 0, "No custom rate");
        delete userTaxRates[_user];
        emit UserTaxRateRemoved(_user);
    }

    function getUserTaxRate(address _user) external view returns (uint256) {
        return userTaxRates[_user] > 0 ? userTaxRates[_user] : taxRateBasisPoints;
    }

    function getContractSummary() external view returns (address currentOwner, uint256 baseRate, bool isPaused) {
        return (owner, taxRateBasisPoints, paused);
    }

    function estimateNetAmount(uint256 _amount) external view returns (uint256 netAmount, uint256 taxAmount) {
        require(_amount > 0, "Amount must be positive");
        uint256 rate = userTaxRates[msg.sender] > 0 ? userTaxRates[msg.sender] : taxRateBasisPoints;
        taxAmount = (_amount * rate) / 10000;
        netAmount = _amount - taxAmount;
    }

    function isCustomRateSet(address _user) external view returns (bool) {
        return userTaxRates[_user] > 0;
    }

    function getAllInfoForUser(address _user) external view returns (uint256 effectiveRate, bool hasCustomRate) {
        effectiveRate = userTaxRates[_user] > 0 ? userTaxRates[_user] : taxRateBasisPoints;
        hasCustomRate = userTaxRates[_user] > 0;
    }

    function renounceOwnership() external onlyOwner {
        emit OwnershipRenounced();
        owner = address(0);
    }

    // Only for emergency recovery of accidentally sent funds
    function emergencyWithdraw(address payable _to) external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");
        _to.transfer(balance);
        emit EmergencyWithdrawal(_to, balance);
    }

    // Accept ETH just in case someone sends it
    receive() external payable {}
}
