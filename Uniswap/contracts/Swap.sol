// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.5;
pragma abicoder v2;

import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Swap {
    // It should be noted that for the sake of these examples, we purposefully pass in the swap router instead of inherit the swap router for simplicity.
    // More advanced example contracts will detail how to inherit the swap router safely.

    ISwapRouter public immutable swapRouter =
        ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);

    IUniswapV3Factory public immutable swapFactory3 =
        IUniswapV3Factory(0x1F98431c8aD98523631AE4a59f267346ea31F984);

    IUniswapV2Factory public immutable swapFactory2 =
        IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);

    event Params(
        address _token1,
        address _token2,
        address recipient,
        uint256 deadline
    );
    //event Message(bytes data, address sender, bytes4 sig);
    event Pair(address _add);
    event Log(string word, address _add, string reason);
    event LogBytes(string word, address _add, bytes reason);

    address public constant WETH = 0xc778417E063141139Fce010982780140Aa0cD5Ab; //Actually WETH
    address public constant rETH = 0xc7AD46e0b8a400Bb3C915120d284AafbA8fc4735; //RocketPool Token - Address for DAI
    address public constant stETH = 0x01BE23585060835E02B77ef475b0Cc51aA1e0709; //Lido Token - Address for LINK
    // address public constant sETH2 = 0xFb1D709cb959aC0EA14cAD0927EABC7832e65058; //Stakewise Staking Token - Address for USDT
    //address public constant rETH2 = 0x3d2aB6aa7BAaef25a39D1B3b1ce22418f3ef0223; //Stakewise Rewards Token - Address for USDM

    uint256 public constant rocket_value = 50;
    uint256 public constant lido_value = 50;
    // uint256 public constant stakewise_value = 20;

    address[2] staking_options = [rETH, stETH];
    uint256[2] staking_percentages = [rocket_value, lido_value];

    // For this example, we will set the pool fee to 0.3%.
    uint24 public constant poolFee = 3000;

    constructor() {}

    //Returns pair address from Uniswap v2 if exists
    function testSwapV2(address token1, address token2)
        external
        returns (address pair)
    {
        pair = swapFactory2.getPair(token1, token2);
        emit Pair(pair);
    }

    //Returns pool address from Uniswap V3 if exists
    function testSwapV3(
        address token1,
        address token2,
        uint24 fee
    ) external returns (address a) {
        a = swapFactory3.getPool(token1, token2, fee);
        emit Pair(a);
    }

    //internal function to execute the swap via uniswap router
    function executeSwap(
        address tokenIn,
        address tokenOut,
        uint256 amount
    ) internal {
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: tokenIn,
                tokenOut: tokenOut,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp + 15,
                amountIn: amount,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        // The call to `exactInputSingle` executes the swap.
        try swapRouter.exactInputSingle(params) {
            emit Log("Swapped successfully", tokenOut, "");
        } catch Error(string memory reason) {
            emit Log(
                "String error while trying to swap coin",
                tokenOut,
                reason
            );
        } catch (bytes memory otherError) {
            emit LogBytes(
                "Bytes error while trying to swap coin ",
                tokenOut,
                otherError
            );
        }
    }

    //external function to test swapping two coins specified by arguments
    function swapCoinsWithParams(
        address token1,
        address token2,
        uint256 amountIn
    ) external {
        TransferHelper.safeTransferFrom(
            token1,
            msg.sender,
            address(this),
            amountIn
        );
        // Approve the router to spend ETH.
        TransferHelper.safeApprove(token1, address(swapRouter), amountIn);
        executeSwap(token1, token2, amountIn);
    }

    /// @notice swapExactInputSingle swaps a fixed amount of each staked token for ETH
    /// using the ETH/WETH 0.3% pool by calling `exactInputSingle` in the swap router.
    /// @dev The calling address must approve this contract to spend at least `amountIn` worth of its ETH for this function to succeed.
    /// @param rETH_in amount of rETH that will be swapped for ETH
    /// @param stETH_in amount of stETH that will be swapped for ETH
    function swapStakeforEth(uint256 rETH_in, uint256 stETH_in) external {
        require(rETH_in >= 1000);
        require(stETH_in >= 1000);
        // Transfer the specified amount of ETH to this contract.
        //uint256 num_tokens = 2;
        TransferHelper.safeTransferFrom(
            rETH,
            msg.sender,
            address(this),
            rETH_in
        );

        // Transfer the specified amount of stETH_in to this contract.
        TransferHelper.safeTransferFrom(
            stETH,
            msg.sender,
            address(this),
            stETH_in
        );

        // Approve the router to spend ETH.
        TransferHelper.safeApprove(rETH, address(swapRouter), rETH_in);
        TransferHelper.safeApprove(stETH, address(swapRouter), stETH_in);

        executeSwap(rETH, WETH, rETH_in);
        executeSwap(stETH, WETH, stETH_in);
    }

    /// @notice swapEthForStake swaps a fixed amount of ETH for a maximum possible amount of each staking token
    /// using the ETH/WETH 0.3% pool by calling `exactInputSingle` in the swap router.
    /// @dev The calling address must approve this contract to spend at least `amountIn` worth of its ETH for this function to succeed.
    /// @param amountIn The exact amount of ETH that will be swapped for staking tokens.
    function swapEthForStake(uint256 amountIn) external {
        require(amountIn >= 1000);
        // msg.sender must approve this contract

        // Transfer the specified amount of ETH to this contract.
        TransferHelper.safeTransferFrom(
            WETH,
            msg.sender,
            address(this),
            amountIn
        );

        // Approve the router to spend ETH.
        TransferHelper.safeApprove(WETH, address(swapRouter), amountIn);

        uint256 split = amountIn / staking_options.length;
        for (uint256 i = 0; i < staking_options.length; i++) {
            executeSwap(WETH, staking_options[i], split);
        }

        uint256 sendBack = amountIn % staking_options.length;
        if (sendBack > 0) {
            TransferHelper.safeApprove(WETH, address(swapRouter), 0);
            TransferHelper.safeTransfer(WETH, msg.sender, sendBack);
        }
    }

    // /// @notice swapExactOutputSingle swaps a minimum possible amount of ETH for a fixed amount of WETH.
    // /// @dev The calling address must approve this contract to spend its ETH for this function to succeed. As the amount of input ETH is variable,
    // /// the calling address will need to approve for a slightly higher amount, anticipating some variance.
    // /// @param amountOut The exact amount of WETH to receive from the swap.
    // /// @param amountInMaximum The amount of ETH we are willing to spend to receive the specified amount of WETH.
    // /// @return amountIn The amount of ETH actually spent in the swap.
    // function swapExactOutputSingle(uint256 amountOut, uint256 amountInMaximum)
    //     external
    //     returns (uint256 amountIn)
    // {
    //     // Transfer the specified amount of ETH to this contract.
    //     TransferHelper.safeTransferFrom(
    //         WETH,
    //         msg.sender,
    //         address(this),
    //         amountInMaximum
    //     );

    //     // Approve the router to spend the specifed `amountInMaximum` of ETH.
    //     // In production, you should choose the maximum amount to spend based on oracles or other data sources to acheive a better swap.
    //     TransferHelper.safeApprove(WETH, address(swapRouter), amountInMaximum);

    //     ISwapRouter.ExactOutputSingleParams memory params = ISwapRouter
    //         .ExactOutputSingleParams({
    //             tokenIn: WETH,
    //             tokenOut: rETH,
    //             fee: poolFee,
    //             recipient: msg.sender,
    //             deadline: block.timestamp,
    //             amountOut: amountOut,
    //             amountInMaximum: amountInMaximum,
    //             sqrtPriceLimitX96: 0
    //         });
    //     emit Params(WETH, rETH, msg.sender, block.timestamp);

    //     // Executes the swap returning the amountIn needed to spend to receive the desired amountOut.
    //     amountIn = swapRouter.exactOutputSingle(params);

    //     // For exact output swaps, the amountInMaximum may not have all been spent.
    //     // If the actual amount spent (amountIn) is less than the specified maximum amount, we must refund the msg.sender and approve the swapRouter to spend 0.
    //     if (amountIn < amountInMaximum) {
    //         TransferHelper.safeApprove(WETH, address(swapRouter), 0);
    //         TransferHelper.safeTransfer(
    //             WETH,
    //             msg.sender,
    //             amountInMaximum - amountIn
    //         );
    //     }
    // }
}
