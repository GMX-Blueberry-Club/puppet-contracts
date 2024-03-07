// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.23;

// ==============================================================
//  _____                 _      _____ _                        |
// |  _  |_ _ ___ ___ ___| |_   |   __|_|___ ___ ___ ___ ___    |
// |   __| | | . | . | -_|  _|  |   __| |   | .'|   |  _| -_|   |
// |__|  |___|  _|  _|___|_|    |__|  |_|_|_|__,|_|_|___|___|   |
//           |_| |_|                                            |
// ==============================================================
// ======================= SharesHelper =========================
// ==============================================================
// Puppet Finance: https://github.com/GMX-Blueberry-Club/puppet-contracts

// Primary Author
// johnnyonline: https://github.com/johnnyonline

// Reviewers
// itburnz: https://github.com/nissoh

// ==============================================================

/// @title SharesHelper
/// @author johnnyonline
/// @notice Helper functions for calculating shares
library SharesHelper {

    /// @notice The ```convertToShares``` function is used to convert an amount of assets to shares, given the total assets and total supply
    /// @param _totalAssets The total assets
    /// @param _totalSupply The total supply
    /// @param _assets The amount of assets to convert
    /// @return _shares The amount of shares
    function convertToShares(uint256 _totalAssets, uint256 _totalSupply, uint256 _assets) public pure returns (uint256 _shares) {
        if (_assets == 0) revert ZeroAmount();

        if (_totalAssets == 0) {
            _shares = _assets;
        } else {
            _shares = (_assets * _totalSupply) / _totalAssets;
        }

        if (_shares == 0) revert ZeroAmount();
    }

    /// @notice The ```convertToAssets``` function is used to convert an amount of shares to assets, given the total assets and total supply
    /// @param _totalAssets The total assets
    /// @param _totalSupply The total supply
    /// @param _shares The amount of shares to convert
    /// @return _assets The amount of assets
    function convertToAssets(uint256 _totalAssets, uint256 _totalSupply, uint256 _shares) public pure returns (uint256 _assets) {
        if (_shares == 0) revert ZeroAmount();

        if (_totalSupply == 0) {
            _assets = _shares;
        } else {
            _assets = (_shares * _totalAssets) / _totalSupply;
        }

        if (_assets == 0) revert ZeroAmount();
    }

    // ============================================================================================
    // Errors
    // ============================================================================================

    error ZeroAmount();
}