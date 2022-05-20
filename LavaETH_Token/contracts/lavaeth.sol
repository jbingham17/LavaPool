// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/presets/ERC20PresetMinterPauser.sol)

pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC777/ERC777.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import '../IWETH9.sol';
import '../Swap.sol';

/**
 * @dev {ERC20} token, including:
 *
 */
contract lavapoolEthereum is ERC777, IERC777Recipient {

    using SafeMath for uint;
    
    bytes32 private constant _TOKENS_SENDER_INTERFACE_HASH = keccak256("ERC777TokensSender");
    bytes32 private constant _TOKENS_RECIPIENT_INTERFACE_HASH = keccak256("ERC777TokensRecipient");
    address private constant WETH9_addr = 0xc778417E063141139Fce010982780140Aa0cD5Ab;
    address private constant Swap_addr = 0xc6389f1a5a92ab7e124c25b5139E0CC4B60DB4Dc;
    address public constant WETH = 0xc778417E063141139Fce010982780140Aa0cD5Ab; //Actually WETH
    address public constant rETH = 0xc7AD46e0b8a400Bb3C915120d284AafbA8fc4735; //RocketPool Token - Address for DAI
    address public constant stETH = 0x01BE23585060835E02B77ef475b0Cc51aA1e0709; //Lido Token - Address for LINK
    // address public constant sETH2 = 0xFb1D709cb959aC0EA14cAD0927EABC7832e65058; //Stakewise Staking Token - Address for USDT
    // address public constant rETH2 = 0x3d2aB6aa7BAaef25a39D1B3b1ce22418f3ef0223; //Stakewise Rewards Token - Address for USDM
    address private senderAddress;
    address router_addr = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    uint public gas = 0;
    
    /**
     */
    constructor(string memory name, string memory symbol) ERC777(name, symbol, new address[](0)) {
        _ERC1820_REGISTRY.setInterfaceImplementer(
            address(this),
            _TOKENS_RECIPIENT_INTERFACE_HASH,
            address(this)
        );
    }


    function _swapEthForWeth (uint amount) public {
        
        // send the Eth to WEth
        // payable(WETH9_addr).send(amount - gas);
	IWETH9(WETH9_addr).deposit{ value: amount }();
        
    }
    
    function _swapWethForEth (uint amount) public {
        
        IERC20(WETH9_addr).approve(address(this), amount);

        if (amount > 0) {
            IWETH9(WETH9_addr).withdraw(amount);
        }
        
    }
    
    function _swapEthForStake (uint amount) public {
       
	// perform the swap to WEth
	IWETH9(WETH9_addr).deposit{ value: amount }();

        // perform the swap for stake
        //require(IWETH9(WETH9_addr).approve(address(router_addr), amount), "Approve has failed");
	TransferHelper.safeApprove(WETH9_addr, address(Swap_addr), amount);

	_mint(msg.sender, amount, "", "");
        Swap(Swap_addr).swapEthForStake(amount);
    }
    
    function _swapStakeForEth (uint amount, address payable from) public {

	uint multiplier = 1e24;

        // calculate the value of the user's lava
        uint user_frac = (amount * multiplier).div(IERC20(address(this)).totalSupply());

        uint user_stETH = (user_frac * IERC20(stETH).balanceOf(address(this))).div(multiplier);

        uint user_rETH = (user_frac * IERC20(rETH).balanceOf(address(this))).div(multiplier);

        require(IERC20(stETH).approve(address(Swap_addr), user_stETH), "Approve has failed");
        require(IERC20(rETH).approve(address(Swap_addr), user_rETH), "Approve has failed");
        
	// burn the user's lava
	_burn(address(this), amount, "", "");

        // perform the swap
        Swap(Swap_addr).swapStakeforEth(user_rETH, user_stETH);

	uint send_back = IERC20(WETH9_addr).balanceOf(address(this));

        IERC20(WETH9_addr).approve(address(this), send_back);

        if (send_back > 0) {
            IWETH9(WETH9_addr).withdraw(send_back);
        }

	from.call{value: send_back}("");
    }

    /**
    */
    receive () external payable {
        
        // check if this is from the WETH9 contract or a user
        if (msg.sender != WETH9_addr) {
		_swapEthForStake(msg.value);
	}
        
    }
    
    
    /**
     */
    function tokensReceived (
        address /*operator*/,
        address from,
        address /*to*/,
        uint256 amount,
        bytes calldata /*userData*/,
        bytes calldata /*operatorData*/
    ) external override {
        
        // check if the token is lava
        if(msg.sender == address(this)) {
            _swapStakeForEth(amount, payable(from));
        } 
    }
}
