// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.24;

import {Precision} from "./../utils/Precision.sol";

import {RewardLogic} from "./../tokenomics/RewardLogic.sol";
import {RewardRouter} from "./../RewardRouter.sol";
import {UserGeneratedRevenueStore} from "./../shared/store/UserGeneratedRevenueStore.sol";

contract RewardReader {
    RewardRouter public rewardRouter;

    constructor(RewardRouter _rewardRouter) {
        rewardRouter = _rewardRouter;
    }

    function getExitClaimableAmount(RewardLogic.CallLockConfig calldata config, uint tokenAmount) public pure returns (uint) {
        return Precision.applyBasisPoints(tokenAmount, config.rate);
    }

    function getLockClaimableAmount(RewardLogic.CallExitConfig calldata config, uint tokenAmount) public pure returns (uint) {
        return Precision.applyBasisPoints(tokenAmount, config.rate);
    }

    function getUserGeneratedRevenue(UserGeneratedRevenueStore rewardStore, address account)
        public
        view
        returns (UserGeneratedRevenueStore.Revenue memory)
    {
        return rewardStore.getUserGeneratedRevenue(RewardLogic.getUserGeneratedRevenueKey(account));
    }
}