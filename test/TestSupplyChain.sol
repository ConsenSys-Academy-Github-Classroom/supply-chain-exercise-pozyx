pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SupplyChain.sol";
import "./Alice.sol";

contract TestSupplyChain {

    // Test for failing conditions in this contracts:
    // https://truffleframework.com/tutorials/testing-for-throws-in-solidity-tests

    // buyItem

    uint public initialBalance = 1 ether;

    SupplyChain private supplyChain;

    function () external payable {        
    }

    function beforeAll() public {
        supplyChain = SupplyChain(DeployedAddresses.SupplyChain());
    }
       
    // test for failure if user does not send enough funds
    function testFailIfUserDoesNotSendEnoughFunds() public {        
        uint sku = supplyChain.addItem("item 1", 10);

        bool r;
        (r, ) = address(supplyChain).call.value(5)(abi.encodeWithSignature("buyItem(uint256)", sku));
        Assert.isFalse(r, "did not fail if user does not send enough funds");
    }

    // test for purchasing an item that is not for Sale
    function testFailWhenPurchasingAnItemThatIsNotForSale() public {    
        uint sku = supplyChain.addItem("item 2", 10);
        supplyChain.buyItem.value(10)(sku);

        bool r;
        (r, ) = address(supplyChain).call.value(10)(abi.encodeWithSignature("buyItem(uint256)", sku));
        Assert.isFalse(r, "did not fail when purchasing an item that is not for Sale");
    }

    // shipItem

    // test for calls that are made by not the seller
    function testFailWhenTryingToShipFromSomeoneWhoIsNotSeller() public {        
        uint sku = supplyChain.addItem("item 3", 10);
        supplyChain.buyItem.value(10)(sku);
        
        Alice alice = new Alice();    
        bool r;
        (r, ) = address(alice).call(abi.encodeWithSignature("askToShip(address, uint256)", address(supplyChain), sku));
        Assert.isFalse(r, "did not fail when trying to ship from someone who is not seller");
    }

    // test for trying to ship an item that is not marked Sold
    function testFailWhenTryingToShipAnItemThatIsNotSold() public {        
        uint sku = supplyChain.addItem("item 4", 10);

        bool r;
        (r, ) = address(supplyChain).call(abi.encodeWithSignature("shipItem(uint256)", sku));
        Assert.isFalse(r, "did not fail when trying to ship an item that is not marked Sold");
    }

    // receiveItem

    // test calling the function from an address that is not the buyer
    function testFailWhenTryingToReceiveFromSomeoneWhoIsNotBuyer() public {        
        uint sku = supplyChain.addItem("item 5", 10);
        supplyChain.buyItem.value(10)(sku);
        supplyChain.shipItem(sku);
        
        Alice alice = new Alice();    
        bool r;
        (r, ) = address(alice).call(abi.encodeWithSignature("askToReceive(address, uint256)", address(supplyChain), sku));
        Assert.isFalse(r, "did not fail when trying to receive from someone who is not buyer");
    }

    // test calling the function on an item not marked Shipped
    function testFailWhenTryingToReceiveAnItemThatIsNotShipped() public {        

        uint sku = supplyChain.addItem("item 6", 10);
        
        bool r;
        (r, ) = address(supplyChain).call(abi.encodeWithSignature("receiveItem(uint256)", sku));
        Assert.isFalse(r, "did not fail when trying to receive an item that is not marked Shipped");
    }
}