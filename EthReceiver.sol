pragma solidity ^0.4.18;

import "./SafeMath.sol";
import "./UmkaToken.sol";
import "./GroupManager.sol";
import "./PaymentsList.sol";

contract EthReceiver is GroupManager{

    using SafeMath for uint256;
    using PaymentsList for PaymentsList.LinkedList;

    uint256 public              weiPerMinToken;

    bytes32 private             saleDist;
    bytes32 private             bonusDist;

    UmkaToken public            token;

    PaymentsList.LinkedList     private payments;

    //_weiPerMinToken: wei div 10 ** tokendecimal
    function EthReceiver(address _token, bytes32 _saleDist, bytes32 _bonusDist, uint256 _weiPerMinToken) public{
        token = UmkaToken(_token);
        saleDist = _saleDist;
        bonusDist = _bonusDist;
        weiPerMinToken = _weiPerMinToken;
    }

    modifier onlyOwner(){
        require(msg.sender == token.owner());
        _;
    }

    function transfer(address _to, uint256 _value) external minGroup(currentState._backend){
        token.serviceTrasferFromDist(saleDist, _to, _value);
    }

    function transferBonus(address _to, uint256 _value) external minGroup(currentState._backend){
        token.serviceTrasferFromDist(bonusDist, _to, _value);
    }

    function removePayment(uint256 _id) external minGroup(currentState._backend){
        payments.remove(_id + 1);
    }

    function serviceGetWei() external minGroup(currentState._admin) returns(bool success) {
        uint256 contractBalance = this.balance;
        token.owner().transfer(contractBalance);

        return true;
    }

    //wei div 10 ** decimal
    function serviceSetWeiPerMinToken(uint256 _weiPerMinToken) external minGroup(currentState._admin)  {
        require (_weiPerMinToken > 0);

        weiPerMinToken = _weiPerMinToken;
    }

    function serviceDestroy() external onlyOwner() {
        selfdestruct(token.owner());
    }

    function calculateTokenCount(uint256 weiAmount) external constant returns(uint256 summary){
        return weiAmount.div(weiPerMinToken);
    }

    function getPaymentById(uint256 _id) external constant returns(address, uint256, uint256){
        return payments.getNode(_id + 1);
    }

    function getPaymentsCount() external constant returns(uint256){
        return payments.sizeOf();
    }

    function () external payable{
        uint256 tokenCount = msg.value.div(weiPerMinToken);
        require(tokenCount > 0);

        token.serviceTrasferFromDist(saleDist, msg.sender, tokenCount);
        payments.push(msg.sender, msg.value, tokenCount);
    }
}