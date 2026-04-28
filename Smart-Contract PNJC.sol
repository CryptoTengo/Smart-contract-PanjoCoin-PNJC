// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/token/ERC20/IERC20.sol";

contract PanjoCoin is ERC20, ERC20Burnable, ERC20Permit {

    uint256 public constant MAX_SUPPLY = 1_000_000_000_000 * 1e18;

    address public immutable TREASURY;

    constructor(address _treasury)
        ERC20("PanjoCoin", "PNJC")
        ERC20Permit("PanjoCoin")
    {
        require(_treasury != address(0), "PNJC: zero address");

        TREASURY = _treasury;

        _mint(_treasury, MAX_SUPPLY);
    }

    function recoverERC20(address tokenAddress) external {
        require(tokenAddress != address(0), "PNJC: zero token");

        uint256 amount = IERC20(tokenAddress).balanceOf(address(this));
        require(amount > 0, "PNJC: no balance");

        IERC20(tokenAddress).transfer(TREASURY, amount);
    }
}
