pragma ton-solidity >= 0.35.0;

interface IRootTokenContract {

    struct IRootTokenContractDetails {
        bytes name;
        bytes symbol;
        uint8 decimals;
        uint256 root_public_key;
        address root_owner_address;
        uint128 total_supply;
    }

    function getDetails() external view returns (IRootTokenContractDetails);

    function getTotalSupply() external view returns (uint128);

    function getWalletCode() external view returns (TvmCell);

    function getWalletAddress(uint256 wallet_public_key, address owner_address) external view responsible returns(address);

    function deployEmptyWallet(
        uint128 deploy_grams,
        uint256 wallet_public_key,
        address owner_address,
        address gas_back_address
    ) external returns(address);

    function mint(uint128 tokens, address to) external;
}