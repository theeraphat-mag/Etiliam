// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

// This contract now supports buying any character (identified by name) for a single, fixed price.
contract RovMarket {

    struct Purchase {
        address owner;
        string characterName; // Stores the identifier of the character/image bought, e.g., "Yorn.jpeg"
        uint256 timestamp;
    }

    Purchase[] public purchaseHistory;
    uint256 public constant CHARACTER_PRICE = 0.001 ether;

    event BuyCharacter(address from, string characterName, uint256 timestamp);

    /**
     * @dev Buys a character for a fixed price. The name is used as a simple identifier.
     * @param name The name of the character/image being purchased (e.g., "Yorn.jpeg").
     */
    function buyCharacter(string memory name) public payable {
        require(msg.value == CHARACTER_PRICE, "Incorrect price sent. Price is 0.001 ETH for all characters.");

        purchaseHistory.push(Purchase(msg.sender, name, block.timestamp));
        emit BuyCharacter(msg.sender, name, block.timestamp);
    }

    /**
     * @dev Returns the entire purchase history stored on the contract.
     */
    function getPurchaseHistory() public view returns (Purchase[] memory) {
        return purchaseHistory;
    }
}