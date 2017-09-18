pragma solidity ^0.4.6;

import "./Stoppable.sol";
import "./Token.sol";

contract Movie is Stoppable {
 
    address public owner;
    address public producer;
    uint    public deadline;
    uint    public goal;
    uint    public fundsRaised;
    uint    public fee;
    Token   public movieToken;


    struct FunderStruct {
        uint amountContributed;
        uint amountRefunded;
    }

    

    mapping (address => FunderStruct) public funderStructs;
    maaping (address => uint) public tokenHolders;

    event LogContribution(address sender, uint amount);
    event LogRefundSent(address funder, uint amount);
    event LogWithdrawalOwner(address beneficiary, uint amount);
    event LogWithdrawalProducer(address beneficiary, uint amount);
    event LogNewProducer(address sender, address oldProducer, address newProducer);
    event LogMovieTokenHolders(address tokenHolder, uint amount);
    event LogProfitSent(address beneficiary, uint amount);


    function Movie(uint movieDuration, uint movieGoal, address movieProducer, uint hubFee) {
            owner = msg.sender; 
            deadline = block.number + movieDuration; 
            goal = movieGoal; 
            producer = movieProducer;
            fee = hubFee;
            movieToken = new Token(movieGoal);


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
        onlyIfRunning
        payable
        returns(bool success)
    {
        if(msg.value==0) throw;
        if(isSuccess()) throw;
        if(hasFailed()) throw;
        
        fundsRaised += msg.value;
        funderStructs[msg.sender].amountContributed += msg.value;
        LogContribution(msg.sender, msg.value);

    //cannot contribute if goal has been reached --> exact movieToken supply = campaign goal
        if(!movieToken.transferFrom(owner,msg.sender,msg.value)) throw;
        LogMovieTokenHolders(msg.sender,msg.value);
        tokenHolders[msg.sender] += msg.value;
        return  true;
            
    }
    
    function withdrawFunds()
        public
        onlyOwner
        onlyIfRunning
        returns(bool success)
    {
            if (!isSuccess()) throw;

            uint amountRaised = this.balance;
            uint ownerAmount = amountRaised * fee/100;
            uint producerAmount = amountRaised - owner_amount;
           
            if(!owner.send(ownerAmount)) throw;
            LogWithdrawalOwner (owner, ownerAmount);

            if(!producer.send(producerAmount)) throw;
            LogWithdrawalProducer (owner, producerAmount);

            return true;
            
    }
        
    function requestRefund()
        public
        onlyIfRunning
        returns (bool success)
    {
        uint amountOwed = funderStructs[msg.sender].amountContributed - funderStructs[msg.sender].amountRefunded;
        if(amountOwed == 0) throw;
        if(!hasFailed()) throw;
        
        if(!msg.sender.send(amountOwed)) throw;
        if(!movieToken.burnFrom(msg.sender, amountOwed)) throw;
        
        funderStructs[msg.sender].amountRefunded += amountOwed;
        tokenHolders[msg.sender] -= amountOwed;
        LogRefundSent(msg.sender, amountOwed);

        return true;
    
    }

    function changeProducer(address newProducer)
    onlyOwner
    returns (bool success)
    {
        require(newProducer != 0);
        oldProducer = this.producer;
        this.producer = newProducer;
        LogNewProducer(msg.sender, oldProducer, newProducer);
        return true;
    }

    //Once the movie is distrbuted and makes profit, the owner can send the proceeds to the contract, 
    //which will then be redistributed to the token holders

    function sendProfits()
    public
    onlyOwner
    payable
    return (bool success)
    {


    if(msg.value==0) throw;
    if(hasFailed()) throw;
//Check is balance = msg.value. If not, that means that funds were not withdrawn in the first place
    if(this.balance>msg.value) throw;
    }


    function requestProfits()
    public 
    onlyIfRunning
    returns (bool success)
    {
        if(hasFailed()) throw;

        uint totalProfits = this.balance
        if(totalProfits == 0) throw;

        uint tokenHeld = tokenHolders[msg.sender];
        if (tokenHeld == 0) throw; 

        uint amountOwed = tokenHeld / movieToken.totalSupply * totalProfits;

        if(!msg.sender.send(amountOwed)) throw;
        
        LogProfitSent(msg.sender, amountOwed);
        return true;
    }    


}