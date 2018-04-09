pragma solidity ^0.4.18;

library PaymentsList {

    struct LinkedList{
        mapping (uint256 => payment) list;
        uint256 tail;
    }

    struct payment{
        address holder;
        uint256 weiAmount;
        uint256 tokenAmount;
    }

    function listExists(LinkedList storage self)
    internal
    view returns (bool)
    {
        return 0 == self.tail;
    }

    function nodeExists(LinkedList storage self, uint256 _node)
    internal
    view returns (bool)
    {
        return _node > 0 && _node <= self.tail;
    }

    function sizeOf(LinkedList storage self) internal view returns (uint256 numElements) {
        return self.tail;
    }

    function getNode(LinkedList storage self, uint256 _node)
    internal view returns (address,uint256,uint256)
    {
        require (nodeExists(self,_node));
        payment storage data = self.list[_node];
        return (data.holder,data.weiAmount,data.tokenAmount);
    }

    function push(LinkedList storage self,address holder, uint256 weiAmount, uint256 tokenAmount) internal returns (bool)  {
        uint256 _new = sizeOf(self) + 1;
        if(!nodeExists(self,_new)) {
            self.tail += 1;
            self.list[_new] = payment(holder,weiAmount,tokenAmount);
            return true;
        } else {
            return false;
        }
    }

    function remove(LinkedList storage self, uint256 index) internal returns (bool) {
        require(index <= self.tail);

        if(index < self.tail){
            self.list[index] = self.list[self.tail];
        }
        delete self.list[self.tail];
        self.tail -= 1;

        return true;
    }
}
