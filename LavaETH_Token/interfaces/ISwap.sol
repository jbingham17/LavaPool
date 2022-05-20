// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.5;
pragma abicoder v2;

import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ISwap {

    function swapStakeforEth(uint256 rETH_in, uint256 stETH_in) external;
    function swapEthForStake(uint256 amountIn) external;
    
}
