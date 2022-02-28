
async function main() {
    const [owner, randomPerson] = await hre.ethers.getSigners();
    const domainContractFactory = await hre.ethers.getContractFactory('Domains');
    const domainContract = await domainContractFactory.deploy("trapdoor");
    await domainContract.deployed();
    console.log("Contract deployed to : ", domainContract.address);
    console.log("Contract deployed by : ", owner.address);

    const txn = await domainContract.register("3xp0its", {value: hre.ethers.utils.parseEther('0.1')});
    await txn.wait();

    const domainOwner = await domainContract.getAddress("3xp0its");
    console.log("The domain belongs to : ", domainOwner);

    const balance = await hre.ethers.provider.getBalance(domainContract.address);
    console.log("Contract balance:", hre.ethers.utils.formatEther(balance));
}



async function runMain() {
    try {
        await main();
        process.exit(0);
    } catch (error) {
        console.log(error);
        process.exit(1);
    }
}

runMain();