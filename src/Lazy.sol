// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Lazy is ERC20, Ownable {
    uint256 private _initialSupply;

    // Constructor now properly calls ERC20's constructor with the name and symbol
    constructor(uint256 initialSupply) ERC20("Lazy", "LAZY") {
        _initialSupply = initialSupply;
        _mint(msg.sender, initialSupply); // Mint the initial supply to the contract owner
    }

    // Minting function for the owner to mint more tokens if needed
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    // Optional: Burn function if you need to reduce the supply
    function burn(uint256 amount) external onlyOwner {
        _burn(msg.sender, amount);
    }
}
