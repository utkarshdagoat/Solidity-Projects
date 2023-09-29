//SPDX-License-Identifier: q
pragma solidity ^0.8.10;

interface IERC20{
    function totalSupply()external view returns(uint);//Total amount of [this] ERC20 token
    function balanceOf(address account)external view returns(uint);//Returns the amount of [this] ERC20 token that the specified account has
    function transfer(address recipient, uint amount)external returns(bool);//Holder of [this] ERC20 token can call this function to transfer n amount of their held [this] ERC20 token to the specified recipient
    function allowance(address owner, address spender)external view returns(uint);//Deals w/ the amount that a spender can spend for the original holder
    function approve(address spender, uint amount)external returns(bool);//Allows for a holder to allow another user to spend the holder's amount of [this] ERC20 token, on their behalf
    function transferFrom(address sender, address recipient, uint amount)external returns(bool);//Once the holder of [this] ERC20 token approves another spender to transfer the original holder's share of [this] ERC20 token on the original holder's behalf, then the spender can call this function to transfer n amount of [this] token to another recipient

    //'indexed' params for events allows for the searching of these events by using the params as filters (using a console/terminal ig)
    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed owner, address indexed spender, uint amount);
}
contract ERC20 is IERC20{
    uint public totalSupply;//Total supply of [this] ERC20 token held by this contract
    mapping(address => uint) public heldBalance;//Amount of [this] ERC20 token held by the specified account
    mapping(address =>mapping(address => uint)) public allowance;//owner => approves spender => to spend n amount
    string public name = "qw";//name of the token
    string public symbol ="$QW";//symbol/ticker for the token
    uint8 public decimal = 8;//number of decimal spaces held by this token (e.g., USD has 2 decimal spaces)
    
    /*//The intent of the modifier here is noble, however due to the fact that solidity 0.8.0+ has implicit "safe math", the error check could not occur. Implementing the error checking modifier is actually less gas efficient than just leaving it out
    modifier checkBal(address mainSender, uint amount){
        require(heldBalance[mainSender]>=amount, "not enough QW");
        _;
    }*/

    //function totalSupply()external view returns(uint){} Commented out because for some reason, it's not needed
    function balanceOf(address account)external view returns(uint){//does the same thing as 'heldBalance', but as a function & not a state variable (kinda just here because it's part of the interface)
        return heldBalance[account];
    }
    function transfer(address recipient, uint amount)external /*checkBal(msg.sender, amount)*/ returns(bool){//The intent of the modifier here is noble, however due to the fact that solidity 0.8.0+ has implicit "safe math", the error check could not occur. Implementing the error checking modifier is actually less gas efficient than just leaving it out
        heldBalance[msg.sender] -= amount;
        heldBalance[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }
    //function allowance(address owner, address spender)external view checkBal(amount) returns(uint){} Commented out because for some reason, it's not needed
    function approve(address spender, uint amount)external returns(bool){
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint amount)external returns(bool){
        //require(allowance[msg.sender][s])
        allowance[sender][msg.sender] -= amount;
        heldBalance[sender] -= amount;
        heldBalance[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    //The following functions aren't part of the ERC20 standard but similar implementations can often be found as parts of ERC20 contracts
    function mint(uint amount)external{
        heldBalance[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }
    function burn(uint amount)external{
        heldBalance[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
}