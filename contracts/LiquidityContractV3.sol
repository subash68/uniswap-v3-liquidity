// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/v3-core/contracts/libraries/TickMath.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@uniswap/v3-periphery/contracts/base/PeripheryImmutableState.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import "@uniswap/v3-periphery/contracts/base/LiquidityManagement.sol";


contract UniswapLiquidity is IERC721Receiver {

    address public constant DAI = 0x28689A5cC9c935CB10175a079Eb109fEAceE7eDD;
    address public constant USDC = 0x5CA2d766EB31c8f7106f6A049641DCA22F48950B;
    uint24 public constant poolFee = 3000;
    uint256 public immutable DAI_AMOUNT = 10000;        
    uint256 public immutable USDC_AMOUNT = 10000;


    INonfungiblePositionManager public immutable nonfungiblePositionManager;

    struct Deposit {        
        address owner;        
        uint128 liquidity;        
        address token0;        
        address token1;    
    }

    mapping(uint256 => Deposit) public deposits;

    constructor(
        INonfungiblePositionManager _nonfungiblePositionManager,
        address _factory,
        address _WETH9
        // PeripheryImmutableState(_factory, _WETH9)
    ) {
        nonfungiblePositionManager = _nonfungiblePositionManager;
    }

    // Implementing `onERC721Received` so this contract can receive custody of erc721 tokens    
    function onERC721Received(
        address operator, 
        address,
        uint256 tokenId,
        bytes calldata 
    ) external override returns (bytes4) {  
        // get position information
        _createDeposit(operator, tokenId);
        return this.onERC721Received.selector;   
    }

    function _createDeposit(address owner, uint256 tokenId) internal {
        (, , address token0, address token1, , , , uint128 liquidity, , , , ) =            
        nonfungiblePositionManager.positions(tokenId);

        // set the owner and data for position        
        // operator is msg.sender        
        deposits[tokenId] = Deposit(
            {
                owner: owner, 
                liquidity: liquidity, 
                token0: token0, 
                token1: token1
            });
    }

    function approve() public {
       
        TransferHelper.safeApprove(DAI, address(this), DAI_AMOUNT);
        TransferHelper.safeApprove(USDC, address(this), USDC_AMOUNT);
    }

    function safeTransfer() public {
        // transfer tokens to contract    
        TransferHelper.safeTransferFrom(DAI, msg.sender, address(this), DAI_AMOUNT);        
        TransferHelper.safeTransferFrom(USDC, msg.sender, address(this), USDC_AMOUNT);
    }

    function mintNewPosition()        
        external
        returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1        
        )
    {
        // For this example, we will provide equal amounts of liquidity in both assets.        
        // Providing liquidity in both assets means liquidity will be earning fees and is considered in-range.        

        
        // // Approve the position manager        
        TransferHelper.safeApprove(DAI, address(nonfungiblePositionManager), DAI_AMOUNT);        
        TransferHelper.safeApprove(USDC, address(nonfungiblePositionManager), USDC_AMOUNT);

        INonfungiblePositionManager.MintParams memory params = 
            INonfungiblePositionManager.MintParams({
                token0: DAI,
                token1: USDC,
                fee: poolFee,
                tickLower: TickMath.MIN_TICK,
                tickUpper: TickMath.MAX_TICK,
                amount0Desired: DAI_AMOUNT,
                amount1Desired: USDC_AMOUNT,
                amount0Min: 0,
                amount1Min: 0,
                recipient: address(this),
                deadline: block.timestamp
            });
        // Note that the pool defined by DAI/USDC and fee tier 0.3% must already be created and initialized in order to mint        
        
        (tokenId, liquidity, amount0, amount1) = nonfungiblePositionManager.mint(params);
        // Create a deposit        
        _createDeposit(msg.sender, tokenId);
        // Remove allowance and refund in both assets.        
        if (amount0 < DAI_AMOUNT) {            
            TransferHelper.safeApprove(DAI, address(nonfungiblePositionManager), 0);            
            uint256 refund0 = DAI_AMOUNT - amount0;            
            TransferHelper.safeTransfer(DAI, msg.sender, refund0);        
        }
        if (amount1 < USDC_AMOUNT) {            
            TransferHelper.safeApprove(USDC, address(nonfungiblePositionManager), 0);            
            uint256 refund1 = USDC_AMOUNT - amount1;            
            TransferHelper.safeTransfer(USDC, msg.sender, refund1);        
        }
    }


}