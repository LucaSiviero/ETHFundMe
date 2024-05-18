//Get funds from users
//Allow owner to withdraw funds
//Set a minimum funding value in USD

//SPDX-License-Identifier: MIT

pragma solidity ^0.8;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

error NotOwner();

contract FundMe {
    // Remember to use constant for data that won't change. Data marked with constant keyword won't be saved in the blockchain, allowing us to save gas
    // during the deploy phase
    uint public constant MINIMUM_USD = 5 * 1e18;
    address[] public funders;
    using PriceConverter for uint;

    mapping(address funder => uint amountFunded) public addressToAmountFunded;

    // Another good practice to save up on gas fees is the usage of the immutable keyword. It works like constant when it comes to saving gas fees, but they
    // have two different behaviors.
        // A constant can only be set at compile time, while an immutable variable can be set at compile time
    address public immutable i_owner;

    constructor(){
        i_owner = msg.sender;
    }

    function fund() public payable {
        //Allow users to send money
        // Have a mimumum amount sent
        // How do we move ETH to this contract account?

        // Remember that when you have a library method with one or more parameters, you´ll have to
        //      call the method on a variable that´s going to be the actual first argument of the method.
        //      When the method has more parameters, you´ll have to pass the other parameters to the function!!!
        //      Refer to the next line of code for an example of how this shit syntax works! :) 
        //      (msg.value is the first parameter of getConversionRate)
        require(msg.value.getConversionRate() >= MINIMUM_USD, "Not enough ETH");  //1e18 = 1ETH
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }
    
    
    function withdraw() public onlyOwner{
        for(uint funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        // Transfer ethereum to owner of contract
        // You need to cast the msg.sender - an address - to a payable address

        // Token transferring can be done in 3 ways (Refer to solidity-by-example.org for more info):
            // transfer method
                // The transfer method moves balance from one address to the other and reverts the transaction if
                // more gas fees than standard (2300) are used.

/*         payable(msg.sender).transfer(address(this).balance);
 */            
            //send method
                // The send method doesn't revert anything. it just outputs true or false depending on whether the operation was successful
        /* bool sendSuccess = payable(msg.sender).send(address(this).balance);
        require(sendSuccess, "Send failed"); */

            //call method
                // call is similar in a way to send. What call actually does, is to call any function in the Blockchain!
                // Since we're not calling a method, we leave the call argument empty, but we assign something to value object in the transaction block!
                // value is the amount of ethers involved in a transaction. So, call with an empty method just creates a tx towards the receiver (msg.sender)
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    function getVersion() public view returns (uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        return priceFeed.version();
    }
    

    modifier onlyOwner(){
        // Another kinf of gas fees optimization is to avoid storing a string error in each require method.
        // It's important to know that there are actual pre-defined errors that you can use to avoid storing the string for the require fault case
        //require(msg.sender == i_owner, "Sender is not the owner");
        if(msg.sender != i_owner){
            revert NotOwner();
        }
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
    
}