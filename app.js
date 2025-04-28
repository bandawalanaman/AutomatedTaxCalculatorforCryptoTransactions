// app.js

const contractAddress = "0x6922dF0f3D2E380DB39DE3E1B9ADdEd5Dd7e5049"; 
const contractABI = [ /* PASTE YOUR CONTRACT ABI HERE */ ];

let contract;
let signer;

async function connectWallet() {
    if (typeof window.ethereum !== "undefined") {
        try {
            await ethereum.request({ method: "eth_requestAccounts" });
            const provider = new ethers.providers.Web3Provider(window.ethereum);
            signer = provider.getSigner();
            contract = new ethers.Contract(contractAddress, contractABI, signer);
            console.log("Wallet connected");
            loadContractData();
        } catch (error) {
            console.error("Connection Error:", error);
        }
    } else {
        alert("Please install MetaMask!");
    }
}

async function loadContractData() {
    try {
        const owner = await contract.owner();
        const taxRate = await contract.getUserTaxRate(await signer.getAddress());
        const balance = await contract.getBalance();

        document.getElementById("owner").innerText = `Owner: ${owner}`;
        document.getElementById("userRate").innerText = `Your Tax Rate: ${taxRate / 100}%`;
        document.getElementById("balance").innerText = `Contract Balance: ${ethers.utils.formatEther(balance)} ETH`;
    } catch (error) {
        console.error("Error loading contract data:", error);
    }
}

async function deposit() {
    const amount = document.getElementById("depositAmount").value;
    if (!amount || amount <= 0) {
        alert("Enter a valid amount");
        return;
    }

    try {
        const tx = await contract.deposit({ value: ethers.utils.parseEther(amount) });
        await tx.wait();
        alert("Deposit successful!");
        loadContractData();
    } catch (error) {
        console.error("Deposit Error:", error);
    }
}

async function estimateTax() {
    const amount = document.getElementById("estimateAmount").value;
    if (!amount || amount <= 0) {
        alert("Enter a valid amount");
        return;
    }

    try {
        const tax = await contract.calculateTax(ethers.utils.parseEther(amount));
        alert(`Estimated Tax: ${ethers.utils.formatEther(tax)} ETH`);
    } catch (error) {
        console.error("Estimate Tax Error:", error);
    }
}

async function updateUserRate() {
    const newRate = document.getElementById("newRate").value;
    if (newRate < 0 || newRate > 100) {
        alert("Rate must be between 0-100%");
        return;
    }

    try {
        const basisPoints = newRate * 100;
        const tx = await contract.updateUserTaxRateSelf(basisPoints);
        await tx.wait();
        alert("Tax rate updated!");
        loadContractData();
    } catch (error) {
        console.error("Update Tax Rate Error:", error);
    }
}

async function withdraw() {
    const to = document.getElementById("withdrawTo").value;
    const amount = document.getElementById("withdrawAmount").value;
    if (!to || !amount || amount <= 0) {
        alert("Fill in all fields correctly");
        return;
    }

    try {
        const tx = await contract.withdraw(to, ethers.utils.parseEther(amount));
        await tx.wait();
        alert("Withdraw successful!");
        loadContractData();
    } catch (error) {
        console.error("Withdraw Error:", error);
    }
}

async function pauseContract() {
    try {
        const tx = await contract.pause();
        await tx.wait();
        alert("Contract paused!");
    } catch (error) {
        console.error("Pause Error:", error);
    }
}

async function unpauseContract() {
    try {
        const tx = await contract.unpause();
        await tx.wait();
        alert("Contract unpaused!");
    } catch (error) {
        console.error("Unpause Error:", error);
    }
}

document.getElementById("connectButton").addEventListener("click", connectWallet);
document.getElementById("depositButton").addEventListener("click", deposit);
document.getElementById("estimateButton").addEventListener("click", estimateTax);
document.getElementById("updateRateButton").addEventListener("click", updateUserRate);
document.getElementById("withdrawButton").addEventListener("click", withdraw);
document.getElementById("pauseButton").addEventListener("click", pauseContract);
document.getElementById("unpauseButton").addEventListener("click", unpauseContract);
