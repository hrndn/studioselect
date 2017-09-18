pragma solidity ^0.4.10;

import "./Owned.sol";

/**
 * Base for contracts that can stopped/resumed.
 */ 
contract Stoppable is Owned {
    
    bool public running;
    event LogRunSwitch(address sender, bool switchSetting);


    modifier onlyIfRunning {
        require(running);
        _;
    }

    function Stoppable() {
        running = true;
    }
    
    
    
    function runSwitch(bool onOff)
    onlyOwner
    returns (bool success)
    {
        running = onOff;
        LogRunSwitch(msg.sender,onOff);
        return true;
    }
}