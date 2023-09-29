//SPDX-License-Identifier:q
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract ShepherdToken is ERC20{
    address creator;
    constructor(string memory _name, string memory _symbol)ERC20(_name, _symbol){
        _mint(msg.sender, 10 * 10 ** 18);
        creator = msg.sender;
    }
    modifier onlyCreator(){
        require(msg.sender == creator, "not creator");
        _;
    }
    /* Burn functionality not fully implemented, but it could be...
    function burn(uint amount)external onlyCreator{
        heldBalance[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }*/

    //(June 16, 2022) You can find this contract on the Rinkeby Testnet @0xf83a62CD4dFD1fc967Eb65ff2083b81505bC5bc6
    //https://rinkeby.etherscan.io/token/0xf83a62cd4dfd1fc967eb65ff2083b81505bc5bc6
}