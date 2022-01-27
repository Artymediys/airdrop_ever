pragma ton-solidity >= 0.35.0;
pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "IRootTokenContract.sol";

// part of main Airdrop SC (edit what you need)
contract Airdrop {
    address token;
    address token_wallet;

    // example value
    uint128 deploy_wallet_grams = 0.2 ton;

    mapping(address => uint128) users;

    constructor(address _token) public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();

        token = _token;
        setUpTokenWallet();
    }

    function setUpTokenWallet() internal view {
        // Deploy token wallet
        IRootTokenContract(token).deployEmptyWallet(deploy_wallet_grams, 0, address(this), address(this));

        // Request for token wallet address
        IRootTokenContract(token).getWalletAddress{callback: Airdrop.setTokenWalletAddress}(0, address(this));
    }
    
    function setTokenWalletAddress(address wallet) external {
        require(msg.sender == token, 103);
        token_wallet = wallet;
    }

    // need to add everything we need here
    function getDetails() external view returns(
        address _token,
        address _token_wallet,
        address _airdrop_sc,
        uint128 _airdrop_sc_balance
    ) {
        return (
            token,
            token_wallet,
            address(this),
            address(this).balance
        );
    }

    function getTokensBack(uint128 amount) external view {
        require(users.exists(msg.sender) && amount <= users[msg.sender], 104);
        tvm.accept();

        msg.sender.transfer(amount, true, 1);
    }
}
