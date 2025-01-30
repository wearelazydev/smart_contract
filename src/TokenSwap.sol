// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ISwapRouter {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(
        ExactInputSingleParams calldata params
    ) external payable returns (uint256 amountOut);
}

contract TokenSwap {
    address private owner;
    ISwapRouter public uniswapRouter;
    IERC20 public lazyToken;

    constructor(address _uniswapRouter, address _lazyToken) {
        owner = msg.sender;
        uniswapRouter = ISwapRouter(_uniswapRouter); // Initializing the Uniswap router address
        lazyToken = IERC20(_lazyToken); // Initializing the Lazy token address
    }

    function swapLazyForETH(uint256 amount) external {
        // Transfer the Lazy tokens to this contract
        require(
            lazyToken.transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );

        // Approve the Uniswap router to spend Lazy tokens
        require(
            lazyToken.approve(address(uniswapRouter), amount),
            "Approval failed"
        );

        // Create the swap parameters
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: address(lazyToken),
                tokenOut: address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2), // WETH address
                fee: 3000, // 0.3% fee for Uniswap V3
                recipient: msg.sender,
                deadline: block.timestamp + 300, // Deadline is 5 minutes from now
                amountIn: amount,
                amountOutMinimum: 1, // Accept 1 wei minimum for example
                sqrtPriceLimitX96: 0
            });

        // Perform the swap and handle potential errors
        try uniswapRouter.exactInputSingle(params) {
            // Successfully swapped
        } catch {
            revert("Swap failed");
        }
    }

    // Function for swapping Lazy tokens to USDT
    function swapLazyForUSDT(uint256 amount, address usdtAddress) external {
        require(
            lazyToken.transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );

        // Approve the Uniswap router to spend Lazy tokens
        require(
            lazyToken.approve(address(uniswapRouter), amount),
            "Approval failed"
        );

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: address(lazyToken),
                tokenOut: usdtAddress, // USDT address
                fee: 3000, // 0.3% fee for Uniswap V3
                recipient: msg.sender,
                deadline: block.timestamp + 300, // Deadline is 5 minutes from now
                amountIn: amount,
                amountOutMinimum: 1, // Accept 1 wei minimum for example
                sqrtPriceLimitX96: 0
            });

        // Perform the swap and handle potential errors
        try uniswapRouter.exactInputSingle(params) {
            // Successfully swapped
        } catch {
            revert("Swap failed");
        }
    }
}
