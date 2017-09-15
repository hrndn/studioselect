pragma solidity ^0.4.6;

import "./Owned.sol"

contract Movie is Owned {
 
    address public owner;
    address public producer;
    uint    public deadline;
    uint    public goal;
    uint    public fundsRaised;
    uint    public fee;

    struct FunderStruct {
        uint amountContributed;
        uint amountRefunded;
    }
    

    mapping (address => FunderStruct) public funderStructs;
    
    event LogContribution(address sender, uint amount);
    event LogRefundSent(address funder, uint amount);
    event LogWithdrawalOwner(address beneficiary, uint amount);
    event LogWithdrawalProducer(address beneficiary, uint amount);

    
    function Movie(uint MovieDuration, uint MovieGoal, address _producer, uint _fee) {
            owner = msg.sender; 
            deadline = block.number + MovieDuration; 
            goal = MovieGoal; 
            producer = _producer;
            fee = _fee;

    }
    
    function isSuccess()
        public
        constant
        returns(bool isIndeed)
    {
        return (fundsRaised >= goal);
    }
    
    function hasFailed()
        public
        constant
        returns(bool hasIndeed)
    {
        return (fundsRaised < goal && block.number > deadline);
    }
    
    function contribute()
        public
        payable
        returns(bool success)
    {
        if(msg.value ==0) throw;
        if(isSuccess()) throw;
        if(hasFailed()) throw;
        
        fundsRaised += msg.value;
        funderStructs[msg.sender].amountContributed + msg.value;
        LogContribution(msg.sender, msg.value);
        return true;
            
    }
    
    function withdrawFunds()
        public
        isOwner
        returns(bool success)
    {
            if (!isSuccess()) throw;
            uint owner_amount = this.balance * fee/100;
            uint producer_amount = this.balance - owner_amount;
            if(!owner.send(owner_amount)) throw;
            if(!producer.send(producer_amount)) throw;
            LogWithdrawalOwner (owner, owner_amount);
            LogWithdrawalProducer (owner, producer_amount);
            return true;
            
    }
        
    function requestRefund()
        public
        returns (bool success)
    {
        uint amountOwed = funderStructs[msg.sender].amountContributed - funderStructs[msg.sender].amountRefunded;
        if(amountOwed == 0) throw;
        if(!hasFailed()) throw;
        
        funderStructs[msg.sender].amountRefunded += amountOwed;
        if(!msg.sender.send(amountOwed)) throw;
        LogRefundSent(msg.sender, funderStructs[msg.sender].amountContributed);
        return true; 
    
    }   
}