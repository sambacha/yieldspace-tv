// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.13;

import "../Pool.sol";
import "../../interfaces/IYVToken.sol";

/*

  __     ___      _     _
  \ \   / (_)    | |   | |
   \ \_/ / _  ___| | __| |
    \   / | |/ _ \ |/ _` |
     | |  | |  __/ | (_| |
     |_|  |_|\___|_|\__,_|
       yieldprotocol.com

 ██████╗  ██████╗  ██████╗ ██╗     ███╗   ██╗ ██████╗ ███╗   ██╗████████╗██╗   ██╗
 ██╔══██╗██╔═══██╗██╔═══██╗██║     ████╗  ██║██╔═══██╗████╗  ██║╚══██╔══╝██║   ██║
 ██████╔╝██║   ██║██║   ██║██║     ██╔██╗ ██║██║   ██║██╔██╗ ██║   ██║   ██║   ██║
 ██╔═══╝ ██║   ██║██║   ██║██║     ██║╚██╗██║██║   ██║██║╚██╗██║   ██║   ╚██╗ ██╔╝
 ██║     ╚██████╔╝╚██████╔╝███████╗██║ ╚████║╚██████╔╝██║ ╚████║   ██║    ╚████╔╝
 ╚═╝      ╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝     ╚═══╝ .SOL
*/

/// Module for using non tokenized vault tokens as base for the Yield Protocol Pool.sol AMM contract.
/// For example ordinary DAI, as opposed to yvDAI or Compound DAI.
/// @title  PoolNonTv.sol
/// @dev Deploy pool with base token and associated fyToken.
/// @author @devtooligan
contract PoolNonTv is Pool {
    /* CONSTRUCTOR
     *****************************************************************************************************************/

    constructor(
        address base_,
        address fyToken_,
        int128 ts_,
        uint16 g1Fee_
    ) Pool(base_, fyToken_, ts_, g1Fee_) {}

    /// Returns the current price of one share.  For non-tokenized vaults this is always 1..
    /// This function should be overriden by modules.
    /// @return By always returning 1, we can use this module with any non-tokenized vault base such as WETH.
    function _getCurrentSharePrice() internal view virtual override returns (uint256) {
        return uint256(10**IERC20Like(address(sharesToken)).decimals());
    }

    /// Returns the base token current price.
    /// @dev This fn is called from the constructor and avoids the use of unitialized immutables.
    /// This function should be overriden by modules.
    /// @return The price of 1 share of a tokenized vault token in terms of its underlying cast as uint256.
    function _getCurrentSharePriceConstructor(address sharesToken_) internal view virtual override returns (uint256) {
        return uint256(10**IERC20Like(address(sharesToken_)).decimals());
    }

    /// Internal function for wrapping underlying asset tokens.  This should be overridden by modules.
    /// Since there is nothing to unwrap, we return the surplus balance.
    /// @return shares The amount of wrapped tokens that are sent to the receiver.
    function _wrap(address) internal virtual override returns (uint256 shares) {
        shares = _getSharesBalance() - sharesCached;
    }

    /// Internal function to preview how many shares will be received when depositing a given amount of assets.
    /// @param assets The amount of base asset tokens to preview the deposit.
    /// @return shares The amount of shares that would be returned from depositing.
    function _wrapPreview(uint256 assets) internal view virtual override returns (uint256 shares) {
        shares = assets;
    }

    /// Internal function for unwrapping unaccounted for base in this contract.
    /// Since there is nothing to unwrap, we return the surplus balance.
    /// @return assets The amount of underlying asset assets sent to the receiver.
    function _unwrap(address) internal virtual override returns (uint256 assets) {
        assets = _getSharesBalance() - sharesCached;
    }

    /// Internal function to preview how many asset tokens will be received when unwrapping a given amount of shares.
    /// @dev This should be overridden by modules.
    /// @param shares The amount of shares to preview a redemption.
    /// @return assets The amount of base asset tokens that would be returned from redeeming.
    function _unwrapPreview(uint256 shares) internal view virtual override returns (uint256 assets) {
        assets = shares;
    }

    /// This is used by the constructor to set the base's underlying asset as immutable.
    /// For Non-tokenized vaults, the base is the same as the underlying asset.
    function _getBaseUnderlyingAsset(address sharesToken_) internal virtual override returns (IERC20Like) {
        return IERC20Like(sharesToken_);
    }
}