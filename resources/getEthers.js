// use this file to connect with metamask or with some JSON RPC
import ethers from 'ethers';

// returns an object:-
//  1) provider
//  2) ethers
const getEthers = () => 
    new Promise((resolve, reject)=> {
        window.addEventListener('load', async () => {
            if(window.ethereum){
                const provider = new ethers.providers.Web3Provider(window.ethereum);
                try{
                    await window.ethereum.enable();
                    resolve({provider, ethers});
                }catch (error) {
                    reject(error)
                }
            }
            else {
                const provider = new ethers.providers.JsonRpcProvider(
                    "http://127.0.0.1:8545"
                );
                console.log("No web3 instance injected, using local web3.");
                resolve({provider, ethers});
            }
        });
    });

export default getEthers;