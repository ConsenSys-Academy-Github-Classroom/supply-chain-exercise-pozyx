// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16 <0.9.0;

import "../contracts/SupplyChain.sol";

contract Alice
{
    function askToShip(address supplyChainAddress, uint sku) public {
        SupplyChain supplyChain = SupplyChain(supplyChainAddress);        
        supplyChain.shipItem(sku);
    }

    function askToReceive(address supplyChainAddress, uint sku) public {
        SupplyChain supplyChain = SupplyChain(supplyChainAddress);        
        supplyChain.receiveItem(sku);
    }
}