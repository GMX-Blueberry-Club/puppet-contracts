// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {WNT} from "./WNT.sol";
import {ErrorUtils} from "./ErrorUtils.sol";

/**
 * @title TokenUtils
 * @dev Library for token functions, helps with transferring of tokens and
 * native token functions
 */
library TransferUtils {
    /**
     * @dev Deposits the specified amount of native token and sends the
     * corresponding amount of wrapped native token to the specified receiver address.
     *
     * @param wnt the address of the wrapped native token contract
     * @param holdingAddress the address of the holding account where the native token is held
     * @param gasLimit the maximum amount of gas that the native token transfer can consume
     * @param receiver the address of the recipient of the wrapped native token transfer
     * @param amount the amount of native token to deposit and the amount of wrapped native token to send
     */
    function sendNativeToken(WNT wnt, address holdingAddress, uint256 gasLimit, address receiver, uint256 amount) internal {
        if (amount == 0) return;
        validateDestination(receiver);

        bool success;
        // use an assembly call to avoid loading large data into memory
        // input mem[in…(in+insize)]
        // output area mem[out…(out+outsize))]
        assembly {
            success :=
                call(
                    gasLimit, // gas limit
                    receiver, // receiver
                    amount, // value
                    0, // in
                    0, // insize
                    0, // out
                    0 // outsize
                )
        }

        if (success) return;

        // if the transfer failed, re-wrap the token and send it to the receiver
        depositAndSendWrappedNativeToken(wnt, holdingAddress, gasLimit, receiver, amount);
    }

    /**
     * Deposits the specified amount of native token and sends the specified
     * amount of wrapped native token to the specified receiver address.
     *
     * @param wnt the address of the wrapped native token contract
     * @param holdingAddress the address of the holding account where the native token is held
     * @param gasLimit the maximum amount of gas that the native token transfer can consume
     * @param receiver the address of the recipient of the wrapped native token transfer
     * @param amount the amount of native token to deposit and the amount of wrapped native token to send
     */
    function depositAndSendWrappedNativeToken(WNT wnt, address holdingAddress, uint256 gasLimit, address receiver, uint256 amount) internal {
        if (amount == 0) return;
        validateDestination(receiver);

        wnt.deposit{value: amount}();

        transfer(gasLimit, holdingAddress, wnt, receiver, amount);
    }

    /**
     * @dev Withdraws the specified amount of wrapped native token and sends the
     * corresponding amount of native token to the specified receiver address.
     *
     * limit the amount of gas forwarded so that a user cannot intentionally
     * construct a token call that would consume all gas and prevent necessary
     * actions like request cancellation from being executed
     *
     * @param wnt the address of the WNT contract to withdraw the wrapped native token from
     * @param holdingAddress the address of the holding account where the native token is held
     * @param gasLimit the maximum amount of gas that the native token transfer can consume
     * @param receiver the address of the recipient of the native token transfer
     * @param amount the amount of wrapped native token to withdraw and the amount of native token to send
     */
    function withdrawAndSendNativeToken(WNT wnt, address holdingAddress, uint256 gasLimit, address receiver, uint256 amount) internal {
        if (amount == 0) return;
        validateDestination(receiver);

        wnt.withdraw(amount);

        bool success;
        // use an assembly call to avoid loading large data into memory
        // input mem[in…(in+insize)]
        // output area mem[out…(out+outsize))]
        assembly {
            success :=
                call(
                    gasLimit, // gas limit
                    receiver, // receiver
                    amount, // value
                    0, // in
                    0, // insize
                    0, // out
                    0 // outsize
                )
        }

        if (success) return;

        // if the transfer failed, re-wrap the token and send it to the receiver
        depositAndSendWrappedNativeToken(wnt, holdingAddress, gasLimit, receiver, amount);
    }

    /**
     * @dev Transfers the specified amount of `token` from the caller to `receiver`.
     * limit the amount of gas forwarded so that a user cannot intentionally
     * construct a token call that would consume all gas and prevent necessary
     * actions like request cancellation from being executed
     *
     * @param gasLimit The maximum amount of gas that the token transfer can consume.
     * @param holdingAddress The address of the holding account where the token is held.
     * @param token The address of the ERC20 token that is being transferred.
     * @param receiver The address of the recipient of the `token` transfer.
     * @param amount The amount of `token` to transfer.
     */
    function transfer(uint256 gasLimit, address holdingAddress, IERC20 token, address receiver, uint256 amount) internal {
        if (amount == 0) return;
        validateDestination(receiver);

        if (gasLimit == 0) {
            revert EmptyTokenTranferGasLimit(address(token));
        }

        (bool success0, /* bytes memory returndata */ ) = nonRevertingTransferWithGasLimit(token, receiver, amount, gasLimit);

        if (success0) return;

        if (holdingAddress == address(0)) {
            revert EmptyHoldingAddress();
        }

        // in case transfers to the receiver fail due to blacklisting or other reasons
        // send the tokens to a holding address to avoid possible gaming through reverting
        // transfers
        (bool success1, bytes memory returndata) = nonRevertingTransferWithGasLimit(token, holdingAddress, amount, gasLimit);

        if (success1) return;

        (string memory reason, /* bool hasRevertMessage */ ) = ErrorUtils.getRevertMessage(returndata);
        emit TokenTransferReverted(reason, returndata);

        // throw custom errors to prevent spoofing of errors
        // this is necessary because contracts like DepositHandler, WithdrawalHandler, OrderHandler
        // do not cancel requests for specific errors
        revert TokenTransferError(address(token), receiver, amount);
    }

    /**
     * @dev Transfers the specified amount of ERC20 token to the specified receiver
     * address, with a gas limit to prevent the transfer from consuming all available gas.
     * adapted from
     * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/utils/SafeERC20.sol
     *
     * @param token the ERC20 contract to transfer the tokens from
     * @param to the address of the recipient of the token transfer
     * @param amount the amount of tokens to transfer
     * @param gasLimit the maximum amount of gas that the token transfer can consume
     * @return a tuple containing a boolean indicating the success or failure of the
     * token transfer, and a bytes value containing the return data from the token transfer
     */
    function nonRevertingTransferWithGasLimit(IERC20 token, address to, uint256 amount, uint256 gasLimit) internal returns (bool, bytes memory) {
        bytes memory data = abi.encodeWithSelector(token.transfer.selector, to, amount);
        (bool success, bytes memory returndata) = address(token).call{gas: gasLimit}(data);

        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                if (!isContract(address(token))) {
                    return (false, "Call to non-contract");
                }
            }

            // some tokens do not revert on a failed transfer, they will return a boolean instead
            // validate that the returned boolean is true, otherwise indicate that the token transfer failed
            if (returndata.length > 0 && !abi.decode(returndata, (bool))) {
                return (false, returndata);
            }

            // transfers on some tokens do not return a boolean value, they will just revert if a transfer fails
            // for these tokens, if success is true then the transfer should have completed
            return (true, returndata);
        }

        return (false, returndata);
    }

    /**
     * @dev Checks if the specified address is a contract.
     *
     * @param account The address to check.
     * @return a boolean indicating whether the specified address is a contract.
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d246... is returned for accounts without code, i.e., `keccak256('')`
        uint256 size;
        // inline assembly is used to access the EVM's `extcodesize` operation
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Validates that the specified destination address is not the zero address.
     *
     * @param destination The address to validate.
     */
    function validateDestination(address destination) internal pure {
        if (destination == address(0)) {
            revert EmptyReceiver();
        }
    }

    error EmptyReceiver();
    error EmptyTokenTranferGasLimit(address token);
    error TokenTransferError(address token, address receiver, uint256 amount);
    error EmptyHoldingAddress();

    event TokenTransferReverted(string reason, bytes returndata);

    error InvalidNativeTokenSender(address msgSender);
    error TransferFailed(address sender, uint256 amount);
    error SelfTransferNotSupported(address receiver);
}