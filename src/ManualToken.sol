// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface tokenRecipient {
    function  receiveApproval(
        address _from,
        uint256 _value,
        address _token,
        bytes calldata _extraData
    ) external;
}

contract ManualToken {
    string public name;
    string public symbol;
    uint8 decimals = 18;
    // 18 decimals is the stringly suggested default , avoid changing it
    uint256 public totalSupply;

    // let's create an array with all branches
    mapping(address => uint256 ) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    //This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);

    //let's generate a public event on the blockchain that will notify clients for approval
    event Approval (uint256 indexed _owner, address indexed _spender, uint256 _value);

    //Let's notify clients about the amount burnt
    event Burn(address indexed from, uint256 value);

    // initialize contract with initial supply tokens to the creator of the contract
    constructor(
        uint256 initialSupply,
        string memory tokenName,
        string memory tokenSymbol
    ) {
        totalSupply = initialSupply * 10 ** uint256(decimals); //Update total supply with the decimal amount
        balanceOf[msg.sender] = totalSupply; //give the creator all initial tokens
        name = tokenName; // set the name for display purposes
        symbol = tokenSymbol; //set the symbol for display purposes
    }
     // Internal transfer to be called by this contract
    function _transfer(address _from, address _to, uint256 _value) internal {
        //prevernt transfer to 0x0 address .. use burn() instead
        require(_to != address(0x0));
        //check if sender has enough eth
        require(balanceOf[_from] >= _value);
        //check for overflows
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        //save this for an assertion in the future
        uint256 previousBalances = balanceOf[_from] + balanceOf[_to];
        //Subtract from sender
        balanceOf[_from] -=_value;

        //when conditions satisfied, emit event
        emit Transfer(_from, _to, _value);

        //sserts are used to use static analysis to find bugs in ur code. they should never fail
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    /**
    *Transfer tokens
    *send `_value`  tokens to `_to` from your account
    *@param _to the address of the recipient
    *@param _value the amount to send
    */

    function transfer(address _to, uint256 _value) public returns(bool success) {
        _transfer(msg.sender, _to, _value);
        return true;

    }

    /*
    *Transfer tokens from other address
    *Send `_value` tokens to `_to`on behalf of `_from`
    *@param `_from` The address of the sender
    *@param `_to` The address of the recipient
    *@param `_value` the amount  to send 
    */

    function transferFrom(address _from, address _to, uint256 _value) 
    public returns(bool success) {
        require(_value <= allowance[_from][msg.sender]); // check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);

        return true;
    }

    /*
    *set allowances for other address
    *allows `_spender` to spend no more than `_value` tokens on your behalf
    *@param `_spender` The address authorised to spend
    *@param `_value` the max amount they can spend
    */

    function approve(address _spender, uint256 _value) public returns(bool success) {
        allowance[msg.sender][_spender] = _value;
        //approve with event
        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    /*
    *set allowance for other address and notify
    *Allows `_spender` to spend no more than `_value` tokens on your behalf, and then ping the contract  about it
    *@param `_spender` The address authorised to spend
    *@param `_value` the max amount they can spend
    *@param `_extraData` some extra information to send to the approved contract
    */

    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData)
    public returns(bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        
        if (approve(_spender, _value)) {
            spender.receiveApproval(
                msg.sender, _value, address(this), _extraData
            );
            return true;
        }
    }

    /*
    *Destroy tokens 
    *Remove `_value` tokens from the system irreversibly on behalf of `_from`
    
    *@param `_value the amount of money to burn
    */

    function burn(uint256 _value) public returns(bool success) {
        require(balanceOf[msg.sender] >= _value); //check if sender has enough ETH
        balanceOf[msg.sender] -= _value; // subtract from the sender
        totalSupply -= _value; // updates totalSupply

        emit Burn(msg.sender, _value);
        return true;
    }

    /*
    *Destroy tokens from other accounts
    *Remove `_value` tokens from the system irreversibly on behalf of `_from`
    
    *@param `_value the amount of money to burn
    */

    function burnFrom(address _from, uint256 _value)
    public  returns(bool success) {
        require(balanceOf[_from] >= _value); //check if the targeted balance is enough
        require(_value <= allowance[_from][msg.sender]); // check allowance
        balanceOf[_from] -= _value; // Subtract from the targeted balance
        allowance[_from][msg.sender] -= _value; //Subtract from the sender's allowance
        totalSupply -= _value; // Update totalSupply

        // actually emit burn event for tokens
        emit Burn(_from, _value);
        return true;
    }
}