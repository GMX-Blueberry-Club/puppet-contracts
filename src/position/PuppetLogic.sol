// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.23;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Auth, Authority} from "@solmate/contracts/auth/Auth.sol";

import {Router} from "../utilities/Router.sol";
import {PuppetStore} from "./store/PuppetStore.sol";

contract PuppetLogic is Auth {
    event PuppetLogic__UpdateDeposit(address from, address to, bool isIncrease, IERC20 token, uint amount);
    event PuppetLogic__UpdateSubscription(bytes32 key, address puppet, address trader, bytes32 routeKey, uint allowanceFactor, uint expiry);

    constructor(Authority _authority) Auth(address(0), _authority) {}

    function subscribe(PuppetStore store, address puppet, PuppetStore.PuppetTraderSubscription calldata subscriptionParams) external requiresAuth {
        if (subscriptionParams.expiry < (block.timestamp + 1 days)) {
            revert PuppetLogic__InvalidExpiry();
        }

        if (subscriptionParams.allowanceFactor < 100) {
            revert PuppetLogic__DepositLimitReached();
        }

        PuppetStore.PuppetTraderSubscription memory pts = store.getPuppetTraderSubscription(subscriptionParams.routeKey);

        bytes32 subscriptionKey = keccak256(abi.encodePacked(puppet, subscriptionParams.trader, subscriptionParams.routeKey));

        pts.trader = subscriptionParams.trader;
        pts.routeKey = subscriptionParams.routeKey;
        pts.allowanceFactor = subscriptionParams.allowanceFactor;
        pts.expiry = subscriptionParams.expiry;

        store.setPuppetTraderSubscription(pts, subscriptionKey);

        emit PuppetLogic__UpdateSubscription(
            subscriptionKey,
            puppet,
            subscriptionParams.trader,
            subscriptionParams.routeKey,
            subscriptionParams.allowanceFactor,
            subscriptionParams.expiry
        );
    }

    function removeSubscription(PuppetStore store, address puppet, address trader, bytes32 routeKey) external requiresAuth {
        bytes32 subscriptionKey = keccak256(abi.encodePacked(puppet, trader, routeKey));

        store.removePuppetTraderSubscription(subscriptionKey);

        emit PuppetLogic__UpdateSubscription(subscriptionKey, puppet, trader, routeKey, 0, 0);
    }

    function deposit(Router router, PuppetStore store, IERC20 token, address from, address to, uint amount) external requiresAuth {
        if (amount == 0) {
            revert PuppetLogic__ZeroAmount();
        }

        PuppetStore.PuppetAccount memory pa = store.getPuppetAccount(from);

        router.pluginTransfer(token, from, address(store), amount);

        unchecked {
            pa.deposit += amount;
        }
        store.setPuppetAccount(from, pa);

        emit PuppetLogic__UpdateDeposit(from, to, true, token, amount);
    }

    function withdraw(Router router, PuppetStore store, IERC20 token, address from, address to, uint amount) external requiresAuth {
        PuppetStore.PuppetAccount memory pa = store.getPuppetAccount(from);

        if (amount > pa.deposit) {
            revert PuppetLogic__WithdrawExceedsDeposit();
        }

        router.pluginTransfer(token, address(store), to, amount);

        pa.deposit -= amount; // underflow check is guranteed above?
        store.setPuppetAccount(from, pa);

        emit PuppetLogic__UpdateDeposit(from, to, false, token, amount);
    }

    error PuppetLogic__DepositLimitReached();
    error PuppetLogic__ZeroAmount();
    error PuppetLogic__WithdrawExceedsDeposit();
    error PuppetLogic__InvalidExpiry();
}