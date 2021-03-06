//SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./test/AggregatorV3Interface.sol";
import "./PriceConverter.sol";


error FundMe__NotOwner();
//error NotSuccess();


/**@title A contract for crowd funding
* @author Dorian Da Silva
* @notice This contract is to demo a sample funding contract
* @dev This implements price feeds as our library
*/

contract FundMe {

    using PriceConverter for uint256;

 //State variables
    uint256 public constant MINIMUM_USD = 50 * 1e18; //1 * 10 ** 18
    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmountFunded;
    address private immutable i_owner;
    AggregatorV3Interface private s_priceFeed;

    modifier onlyOwner {
        //if(msg.sender != i_owner) require FundMe__NotOwner();
        require(msg.sender == i_owner);
        _;
    }

    constructor(address s_priceFeedAddress){
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(s_priceFeedAddress);
    }

    //  receive() external payable {
    //      fund();
    //  }

    //  fallback() external payable {
    //      fund();
    //  }

    function fund() public payable{
        //require(msg.value.getConversionRate(priceFeed) >= MINIMUM_USD, "Didn't send enough");
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] = msg.value;
    }

    function withdraw() public onlyOwner {

        for(uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex = funderIndex + 1){
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
 //reset the array
        s_funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");

    }

    function cheaperWithdraw() public payable onlyOwner {
        address[] memory funders = s_funders;
        //mappings can't be in memory
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool success, ) =i_owner.call{value: address(this).balance}("");
        require(success);
    }

// view / pure functions -> getters
    function getOwner() public view returns(address){
        return i_owner;
    }

    function getFunder(uint256 index) public view returns(address) {
        return s_funders[index];
    }

    function getAddressToAmountFunded(address funder) public view returns(uint256) {
        return s_addressToAmountFunded[funder];
    }

    function getPriceFeed() public view returns(AggregatorV3Interface) {
        return s_priceFeed;
    }
}

