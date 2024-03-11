// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.23;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {IGmxExchangeRouter} from "./IGmxExchangeRouter.sol";
import {Router} from "../../utils/Router.sol";

import {PositionStore} from "./../store/PositionStore.sol";
import {PuppetStore} from "./../store/PuppetStore.sol";

// gmx-synthetics/blob/main/contracts/order/Order.sol
library PositionUtils {
    enum OrderType {
        MarketSwap,
        LimitSwap,
        MarketIncrease,
        LimitIncrease,
        MarketDecrease,
        LimitDecrease,
        StopLossDecrease,
        Liquidation
    }

    enum DecreasePositionSwapType {
        NoSwap,
        SwapPnlTokenToCollateralToken,
        SwapCollateralTokenToPnlToken
    }

    struct CallPositionConfig {
        PositionStore positionStore;
        PuppetStore puppetStore;
        Router router;
        IGmxExchangeRouter gmxExchangeRouter;
        IERC20 depositCollateralToken;
        address feeReceiver;
        uint limitPuppetList;
        uint adjustmentFeeFactor;
        uint minExecutionFee;
        uint maxCallbackGasLimit;
        uint minMatchTokenAmount;
        bytes32 referralCode;
    }

    struct CallPositionAdjustment {
        address trader;
        address receiver;
        address market;
        uint executionFee;
        uint collateralDelta;
        uint sizeDelta;
        uint acceptablePrice;
        uint triggerPrice;
        bool isLong;
    }

    struct Props {
        Addresses addresses;
        Numbers numbers;
        Flags flags;
    }

    struct Addresses {
        address account;
        address receiver;
        address callbackContract;
        address uiFeeReceiver;
        address market;
        address initialCollateralToken;
        address[] swapPath;
    }

    struct Numbers {
        OrderType orderType;
        DecreasePositionSwapType decreasePositionSwapType;
        uint sizeDeltaUsd;
        uint initialCollateralDeltaAmount;
        uint triggerPrice;
        uint acceptablePrice;
        uint executionFee;
        uint callbackGasLimit;
        uint minOutputAmount;
        uint updatedAtBlock;
    }

    struct Flags {
        bool isLong;
        bool shouldUnwrapNativeToken;
        bool isFrozen;
    }

    error InvalidOrderType();

    struct CreateOrderParams {
        CreateOrderParamsAddresses addresses;
        CreateOrderParamsNumbers numbers;
        OrderType orderType;
        DecreasePositionSwapType decreasePositionSwapType;
        bool isLong;
        bool shouldUnwrapNativeToken;
        bytes32 referralCode;
    }

    struct CreateOrderParamsAddresses {
        address receiver;
        address callbackContract;
        address uiFeeReceiver;
        address market;
        address initialCollateralToken;
        address[] swapPath;
    }

    struct CreateOrderParamsNumbers {
        uint sizeDeltaUsd;
        uint initialCollateralDeltaAmount;
        uint triggerPrice;
        uint acceptablePrice;
        uint executionFee;
        uint callbackGasLimit;
        uint minOutputAmount;
    }

    function isIncreaseOrder(OrderType orderType) internal pure returns (bool) {
        return orderType == OrderType.MarketIncrease || orderType == OrderType.LimitIncrease;
    }

    function isDecreaseOrder(OrderType orderType) internal pure returns (bool) {
        return orderType == OrderType.MarketDecrease || orderType == OrderType.LimitDecrease || orderType == OrderType.StopLossDecrease
            || orderType == OrderType.Liquidation;
    }

    function isLiquidationOrder(OrderType orderType) internal pure returns (bool) {
        return orderType == OrderType.Liquidation;
    }

    function getPositionKey(address account, address market, address collateralToken, bool isLong) internal pure returns (bytes32) {
        return keccak256(abi.encode(account, market, collateralToken, isLong));
    }
}
