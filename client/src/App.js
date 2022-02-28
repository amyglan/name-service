import React from 'react';
import { useEffect, useState } from 'react';
import {ethers} from "ethers";
import './styles/App.css';
import twitterLogo from './assets/twitter-logo.svg';
import contractAbi from './utils/Domains.json';

// Constants
const TWITTER_HANDLE = 'amyglan';
const TWITTER_LINK = `https://twitter.com/${TWITTER_HANDLE}`;
const tld = '.trapdoor';
const CONTRACT_ADDRESS = '0xb200643Fec1328a99543eEeb412d43B9F0990800';

const App = () => {

	const [domain, setDomain] = useState('');
	const[record, setRecord] = useState('');
	const [currAcc, setCurrAcc] = useState('');

	const connectWallet = async () => {
		try {
			const { ethereum } = window;

			if (!ethereum) {
				alert("Get MetaMask -> https://metamask.io/");
				return;
			}

			// Fancy method to request access to account.
			const accounts = await ethereum.request({ method: "eth_requestAccounts" });
		
			// Boom! This should print out public address once we authorize Metamask.
			console.log("Connected", accounts[0]);
			setCurrAcc(accounts[0]);
		} catch (error) {
			console.log(error)
		}
	}

	const checkIfWalletIsConnected = () => {

		const {ethereum} = window;

		if(!ethereum){
			console.log("Make sure you have metamask");
		}
	

	const accounts = ethereum.request({method: 'eth_accounts'});

	if(accounts.length !== 0){
		const account = accounts[0];
		setCurrAcc(account);
	}else {
		console.log("No autorized account found");
	}
};

const mintDomain = async () => {
	// Don't run if the domain is empty
	if (!domain) { return }
	// Alert the user if the domain is too short
	if (domain.length < 3) {
		alert('Domain must be at least 3 characters long');
		return;
	}
	// Calculate price based on length of domain (change this to match your contract)	
	// 3 chars = 0.5 MATIC, 4 chars = 0.3 MATIC, 5 or more = 0.1 MATIC
	const price = domain.length === 3 ? '0.5' : domain.length === 4 ? '0.3' : '0.1';
	console.log("Minting domain", domain, "with price", price);
  try {
    const { ethereum } = window;
    if (ethereum) {
      const provider = new ethers.providers.Web3Provider(ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(CONTRACT_ADDRESS, contractAbi.abi, signer);

		console.log("Going to pop wallet now to pay gas...")
      let tx = await contract.register(domain, {value: ethers.utils.parseEther(price)});
      // Wait for the transaction to be mined
			const receipt = await tx.wait();

			// Check if the transaction was successfully completed
			if (receipt.status === 1) {
				console.log("Domain minted! https://mumbai.polygonscan.com/tx/"+tx.hash);
				
				// Set the record for the domain
				tx = contract.storeRecord(domain, record);
				await tx.wait();

				console.log("Record set! https://mumbai.polygonscan.com/tx/"+tx.hash);
				
				setRecord('');
				setDomain('');
			}
			else {
				alert("Transaction failed! Please try again");
			}
    }
  }
  catch(error){
    console.log(error);
  }
}

	const renderNotConnectedContainer = () => (
		<div className="connect-wallet-container">
			<img src="https://i.gifer.com/GXjn.gif" alt="Fsociety gif" />
			<button onClick={connectWallet} className="cta-button connect-wallet-button">
				Connect Wallet
			</button>
		</div>
  	);
	  const renderInputForm = () =>{
		return (
			<div className="form-container">
				<div className="first-row">
					<input
						type="text"
						value={domain}
						placeholder='domain'
						onChange={e => setDomain(e.target.value)}
					/>
					<p className='tld'> {tld} </p>
				</div>

				<input
					type="text"
					value={record}
					placeholder='Spin up your song hackerboy'
					onChange={e => setRecord(e.target.value)}
				/>

				<div className="button-container">
					<button className='cta-button mint-button' disabled={null} onClick={mintDomain}>
						Mint
					</button>  
					{/* <button className='cta-button mint-button' disabled={null} onClick={null}>
						Set data
					</button>   */}
				</div>

			</div>
		);
	}

	useEffect(() => {
		checkIfWalletIsConnected();
	}, []);

  return (
		<div className="App">
			<div className="container">

				<div className="header-container">
					<header>
            <div className="left">
              <p className="title">💀Trapdoor Name Service</p>
              <p className="subtitle">D0 Handshake</p>
            </div>
					</header>
				</div>

				{!currAcc && renderNotConnectedContainer()}
				{currAcc && renderInputForm()}

        <div className="footer-container">
					<img alt="Twitter Logo" className="twitter-logo" src={twitterLogo} />
					<a
						className="footer-text"
						href={TWITTER_LINK}
						target="_blank"
						rel="noreferrer"
					>{`built with ❤️ by @${TWITTER_HANDLE}`}</a>
				</div>
			</div>
		</div>
	);
}

export default App;
