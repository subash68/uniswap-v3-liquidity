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

    address public constant DAI = 0xc9289B08C127D90Ad2dF2C7Ed93Cc6D6a08E623B;
    address public constant USDC = 0x9ceB8Cc86A2d8C9f9F6d3Ccd32013dDe9A5cb974;
    uint24 public constant poolFee = 3000;
    uint256 public immutable DAI_AMOUNT = 1000;        
    uint256 public immutable USDC_AMOUNT = 1000;
    address public SENDER = msg.sender;
    address public CURRENT = address(this);

    INonfungiblePositionManager public immutable nonfungiblePositionManager;

    struct Deposit {        
        address owner;        
        uint128 liquidity;        
        address token0;        
        address token1;    
    }

    mapping(uint256 => Deposit) public deposits;

    constructor(
        INonfungiblePositionManager _nonfungiblePositionManager
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

    // function safeApproveDAI() external {
    //     TransferHelper.safeApprove(DAI, address(this), DAI_AMOUNT);
    // }


    // function safeTransferDAI() external {
    //     address sender = 0x4db8bcCF4385C7AA46F48eb42f70FA41Df917b44;
    //     IERC20(DAI).allowance(sender, address(this));
    //     IERC20(DAI).approve(address(this), DAI_AMOUNT);
    //     IERC20(DAI).transferFrom(sender, address(this), DAI_AMOUNT);
    //     // TransferHelper.safeTransferFrom(DAI, sender, address(this), DAI_AMOUNT);   
    // }


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

        // address sender = 0x4db8bcCF4385C7AA46F48eb42f70FA41Df917b44;

        TransferHelper.safeTransferFrom(DAI, msg.sender, address(this), DAI_AMOUNT);   
        TransferHelper.safeTransferFrom(USDC, msg.sender, address(this), USDC_AMOUNT);


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


       
    function collectAllFees(uint256 tokenId) external returns (uint256 amount0, uint256 amount1) {
        nonfungiblePositionManager.safeTransferFrom(msg.sender, address(this), tokenId);


        INonfungiblePositionManager.CollectParams memory params =
            INonfungiblePositionManager.CollectParams({
                tokenId: tokenId,
                recipient: address(this),
                amount0Max: type(uint128).max,
                amount1Max: type(uint128).max
            });

        (amount0, amount1) = nonfungiblePositionManager.collect(params);

        // send collected feed back to owner
        _sendToOwner(tokenId, amount0, amount1);
    }

    function _sendToOwner(
        uint256 tokenId,
        uint256 amount0,
        uint256 amount1
    ) internal {
        // get owner of contract
        address owner = deposits[tokenId].owner;

        address token0 = deposits[tokenId].token0;
        address token1 = deposits[tokenId].token1;
        // send collected fees to owner
        TransferHelper.safeTransfer(token0, owner, amount0);
        TransferHelper.safeTransfer(token1, owner, amount1);
    }

    function decreaseLiquidityInHalf(uint256 tokenId) external returns (uint256 amount0, uint256 amount1) {
        // caller must be the owner of the NFT
        require(msg.sender == deposits[tokenId].owner, 'Not the owner');
        // get liquidity data for tokenId
        uint128 liquidity = deposits[tokenId].liquidity;
        uint128 halfLiquidity = liquidity / 2;

        // amount0Min and amount1Min are price slippage checks
        // if the amount received after burning is not greater than these minimums, transaction will fail
        INonfungiblePositionManager.DecreaseLiquidityParams memory params =
            INonfungiblePositionManager.DecreaseLiquidityParams({
                tokenId: tokenId,
                liquidity: halfLiquidity,
                amount0Min: 0,
                amount1Min: 0,
                deadline: block.timestamp
            });

        (amount0, amount1) = nonfungiblePositionManager.decreaseLiquidity(params);

        //send liquidity back to owner
        _sendToOwner(tokenId, amount0, amount1);
    }


    function increaseLiquidityCurrentRange(
        uint256 tokenId,
        uint256 amountAdd0,
        uint256 amountAdd1
    )
        external
        returns (
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        )
    {
        INonfungiblePositionManager.IncreaseLiquidityParams memory params =
            INonfungiblePositionManager.IncreaseLiquidityParams({
                tokenId: tokenId,
                amount0Desired: amountAdd0,
                amount1Desired: amountAdd1,
                amount0Min: 0,
                amount1Min: 0,
                deadline: block.timestamp
            });

        (liquidity, amount0, amount1) = nonfungiblePositionManager.increaseLiquidity(params);
    }


}