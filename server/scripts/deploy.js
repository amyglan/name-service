async function main() {
    const [owner, randomPerson] = await hre.ethers.getSigners();
    const domainContractFactory = await hre.ethers.getContractFactory('Domains');
    const domainContract = await domainContractFactory.deploy("trapdoor");
    await domainContract.deployed();
    console.log("Contract deployed to : ", domainContract.address);

    let txn = await domainContract.register("3xp10its", {value: hre.ethers.utils.parseEther('0.1')});
    await txn.wait();
    console.log("Minted domain 3xp0its.trapdoor");

    txn = await domainContract.storeRecord("3xp10its", "https://music.youtube.com/watch?v=HWi1lBRUh0M&list=OLAK5uy_kalb6tJq2w0RnC4OcumcgfK52p-ev5YgA");
    await txn.wait();
    console.log("Spinned up a song for 3xp10its.trapdoor");

    const domainOwner = await domainContract.getAddress("3xp10its");
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