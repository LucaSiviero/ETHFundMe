//SPDX-License-Identifier: MIT

pragma solidity ^0.8;

contract FallbackExample {
    uint public result;
    // Ethereum is sent to contract
    //      is msg.data empty?
    //          /    \
    //        yes     no
    //        /        \
    //    receive()?   fallback()
    //      /   \
    //    yes   no
    //    /       \
    //receive()   fallback()
    
    receive() external payable {
        result = 1;
    }
    
    fallback() external payable { 
        result = 2;
    }
}