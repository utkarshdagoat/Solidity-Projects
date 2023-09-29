//SPDX-License-Identifier: q
pragma solidity ^0.8.10;

//A multi-signature wallet consists of multiple addresses that can approve (or revoke approval) of transactions before they are executed

contract multiSigWallet{
    event Deposit(address indexed sender, uint amount);
    event Submit(uint indexed txID);
    event Approve(address indexed owner, uint indexed txID);
    event Revoke(address indexed owner, uint indexed txID);
    event Execute(uint indexed txID);

    struct Transaction{
        address to;//Represents the address where the transaction is executed
        uint value;//Represents the amount of ETH sent to 'to'
        bytes data;//Represents data sent to 'to'
        bool executed;//This will be 'true' once a transaction is executed
    }

    address[] public owners;//Just an array of owners
    mapping(address => bool) public isOwner;//If an address is an owner of a multi sig wallet, it will return true
    uint public required;//Represents number of approvals required before a transaction can be executed
    mapping(uint => mapping(address => bool)) public approved;//tx number -> n owner -> whether it's approved
    Transaction[] public transactions;

    constructor(address[] memory _owners, uint _required){//You can pass an array like this, '["address(n)"]'
    //You start out by giving an array of owner addresses & a number of required owners for approval
        require(_owners.length > 0, "owners required");
        require(_required > 0 && _required <= _owners.length, "invalid number of required owners");

        for(uint i; i < _owners.length; i++){//adds unique owner to the array of owners
            address owner = _owners[i];

            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner is not unique");//the iterated owner cannot already be an owner of a multi-signature wallet
            
            isOwner[owner] = true;//in the event that the iterated owner isn't already an owner of a multisig wallet, then the iterated owner is set as an owner of a multi-signature wallet
            owners.push(owner);//adds the iterated owner to the array of current owners
        }
        required = _required;
    }

    receive() external payable{
        emit Deposit(msg.sender, msg.value);
    }

    modifier onlyOwner(){//requires that the user is an owner of a multi-signature wallet
        require(isOwner[msg.sender], "not owner");
        _;
    }
    modifier txExists(uint _txID){
        require(_txID < transactions.length, "tx doesn't exist");
        _;
    }
    modifier notApproved(uint _txID){
        require(!approved[_txID][msg.sender], "tx already approved");
        _;
    }
    modifier notExecuted(uint _txID){
        require(!transactions[_txID].executed, "tx already executed");
        _;
    }

    function submit(address _to, uint _value, bytes calldata _data, bool _executed)external onlyOwner{//uses 'bytes calldata' instead of 'bytes memory' to be more gas efficient
        transactions.push(Transaction(_to, _value, _data, _executed));
        
        emit Submit(transactions.length-1);
    }//This function submits a transaction (and its details) into the collection [array] of transactions
    function approve(uint _txID)external onlyOwner txExists(_txID) notApproved(_txID) notExecuted(_txID){
        approved[_txID][msg.sender] = true;
        
        emit Approve(msg.sender, _txID);
    }//This function represents the approval of a transaction
    function _getApprovalCount(uint _txID)private view returns(uint count){
        for(uint j; j<owners.length; j++){
            if(approved[_txID][owners[j]]){
                count++;
            }
        }
        //return count; (commented out) Keep in mind that this return statement is not needed because an implicit return is in the function declaration
    }
    function execute(uint _txID) external txExists(_txID) notExecuted(_txID){
        require(_getApprovalCount(_txID) >= required, "not enough approvals to meet required");
        Transaction storage transaction = transactions[_txID];
        transaction.executed = true;
        (bool success, ) = transaction.to.call{value: transaction.value}(transaction.data);
        require(success, "tx failed");

        emit Execute(_txID);
    }//Checks the number of approvals required before a transaction can be executed
    function revoke(uint _txID) external onlyOwner txExists(_txID) notExecuted(_txID){
        require(approved[_txID][msg.sender], "tx not approved");
        approved[_txID][msg.sender] = false;

        emit Revoke(msg.sender, _txID);
    }//"Cancels" a transaction that has already been approved
}

/*Multi-Signature Wallet Checklist
- Proper Logging (w/ 'events')
- Error Checking (w/ 'require()' or 'modifier()')
- Appropriate functions/functionality (ofc)
- Transaction infrastructure (w/ a struct)
- Accountability (necessary arrays to keep collections of similar data types)
- Proper data storage/record types*/