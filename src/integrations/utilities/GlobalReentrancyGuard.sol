// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.23;

import {Keys} from "../libraries/Keys.sol";

import {IDataStore} from "./interfaces/IDataStore.sol";

/// @title GlobalReentrancyGuard
/// @author johnnyonline
/// @notice Inspired by GMX V2 GlobalReentrancyGuard
/// @notice GlobalReentrancyGuard is used to prevent reentrancy on dataStore
abstract contract GlobalReentrancyGuard {

    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.
    uint256 private constant _NOT_ENTERED = 0;
    uint256 private constant _ENTERED = 1;

    IDataStore public immutable dataStore;

    // ============================================================================================
    // Constructor
    // ============================================================================================

    constructor(IDataStore _dataStore) {
        dataStore = _dataStore;
    }

    // ============================================================================================
    // Modifiers
    // ============================================================================================

    modifier globalNonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    // ============================================================================================
    // Internal Functions
    // ============================================================================================

    function _nonReentrantBefore() private {
        uint256 _status = dataStore.getUint(Keys.REENTRANCY_GUARD_STATUS);

        if (_status == _ENTERED) revert ReentrantCall();

        dataStore.setUint(Keys.REENTRANCY_GUARD_STATUS, _ENTERED);
    }

    function _nonReentrantAfter() private {
        dataStore.setUint(Keys.REENTRANCY_GUARD_STATUS, _NOT_ENTERED);
    }

    // ============================================================================================
    // Errors
    // ============================================================================================

    error ReentrantCall();
}