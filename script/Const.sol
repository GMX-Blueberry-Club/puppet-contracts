// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

library Address {
    address constant dao = 0x189b21eda0cff16461913D616a0A4F711Cd986cB;

    address constant Dictator = 0xeC4B2FEB1C314744D55f5b280A8C632015774dcd;
    address constant PuppetToken = 0x4F489Ef21E74E6736F4e5929Dc9865E4C5fe4040;
    address constant Router = 0xdC42a2f75a7000007C683Cb076EC5c805211F210;

    address constant BasePool = 0xF2658f994C882237d3612099cae541d50348FCf9;

    address constant OracleLogic = 0x412979f3210d8cf121971B0176cA3704b8bE0945;
    address constant PriceStore = 0xe9e9ce24275Ec23257551Cbb62D79A4e9cfE2428;
    address constant RewardLogic = 0x356Df7BE8a48d514c3A24A4b4cC0CB4AAd45B617;
    address constant VotingEscrow = 0xd6D057D0b2f16a9bcdca4b8A7EF3532386cB3058;
    address constant RewardRouter = 0xeBE43819468Bc0B167Baa5224Fe46A9EaDCA67Ce;

    address constant nt = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address constant wnt = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;

    address constant usdc = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;
    address constant dai = 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1;

    address constant datastore = 0x75236b405F460245999F70bc06978AB2B4116920;

    address constant gmxExchangeRouter = 0x7C68C7866A64FA2160F78EEaE12217FFbf871fa8;
    address constant gmxRouter = 0x7452c558d45f8afC8c83dAe62C3f8A5BE19c71f6;
    address constant gmxOracle = 0xa11B501c2dd83Acd29F6727570f2502FAaa617F2;
    address constant gmxDatastore = 0xFD70de6b91282D8017aA4E741e9Ae325CAb992d8;
    address constant gmxOrderHandler = 0x352f684ab9e97a6321a13CF03A61316B681D9fD2;
    address constant gmxOrderVault = 0x31eF83a530Fde1B38EE9A18093A333D8Bbbc40D5;
    address constant gmxEthUsdcMarket = 0x70d95587d40A2caf56bd97485aB3Eec10Bee6336;

    bytes32 constant referralCode = 0x5055505045540000000000000000000000000000000000000000000000000000;
}

library Role {
    uint8 constant ADMIN = 0;
    uint8 constant TOKEN_TRANSFER = 1;
    uint8 constant MINT_PUPPET = 2;
    uint8 constant MINT_CORE_RELEASE = 3;

    uint8 constant SET_ORACLE_PRICE = 4;
    uint8 constant CLAIM = 5;
    uint8 constant INCREASE_CONTRIBUTION = 6;
    uint8 constant CONTRIBUTE = 7;
    uint8 constant VEST = 8;

    uint8 constant SUBACCOUNT_CREATE = 9;
    uint8 constant SUBACCOUNT_SET_OPERATOR = 10;
    uint8 constant EXECUTE_ORDER = 11;
    uint8 constant PUPPET_DECREASE_BALANCE_AND_SET_ACTIVITY = 12;
}