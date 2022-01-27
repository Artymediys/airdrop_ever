pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;


import "IRootTokenContract.sol";
//import "ITokenWallet.sol";
//import "TokenWallet.sol";


contract RootTokenContract is IRootTokenContract {
    bytes public static name;
    bytes public static symbol;
    uint8 public static decimals;

    TvmCell static wallet_code;

    uint128 total_supply;

    uint256 root_public_key;
    address root_owner_address;

    /*
        root_public_key_   Root token owner public key
        root_owner_address_   Root token owner address
    */
    constructor(uint256 root_public_key_, address root_owner_address_) public {
        require((root_public_key_ != 0 && root_owner_address_.value == 0) ||
                (root_public_key_ == 0 && root_owner_address_.value != 0), 101);
        
        tvm.accept();

        root_public_key = root_public_key_;
        root_owner_address = root_owner_address_;

        total_supply = 0;
    }


    function getDetails() override external view returns (IRootTokenContractDetails) {
        return IRootTokenContractDetails(
            name,
            symbol,
            decimals,
            root_public_key,
            root_owner_address,
            total_supply
        );
    }

    function getTotalSupply() override external view returns (uint128) {
        return total_supply;
    }

    function getWalletCode() override external view returns (TvmCell) {
        return wallet_code;
    }

    /*
        wallet_public_key_  Token wallet owner public key
        owner_address_  Token wallet owner address
        return Token wallet address
    */
    function getWalletAddress(
        uint256 wallet_public_key_,
        address owner_address_
    ) override external view responsible returns (address) {
        require((owner_address_.value != 0 && wallet_public_key_ == 0) ||
                (owner_address_.value == 0 && wallet_public_key_ != 0), 102);
        return getExpectedWalletAddress(wallet_public_key_, owner_address_);
    }

    /*
        wallet_public_key_  Token wallet owner public key
        owner_address_  Token wallet owner address
        gas_back_address  Receiver the remaining balance after deployment. msg.sender by default
        return Token wallet address
    */
    function deployEmptyWallet(
        uint128 deploy_grams,
        uint256 wallet_public_key_,
        address owner_address_,
        address gas_back_address
    ) override external returns (address) {
        require((owner_address_.value != 0 && wallet_public_key_ == 0) ||
                (owner_address_.value == 0 && wallet_public_key_ != 0), 102);

        tvm.rawReserve(address(this).balance - msg.value, 2);

        /* Needed SC of TokenWallet
        address wallet = new TokenWallet{
            value: deploy_grams,
            flag: 1,
            code: wallet_code,
            pubkey: wallet_public_key_,
            varInit: {
                root_address: address(this),
                code: wallet_code,
                wallet_public_key: wallet_public_key_,
                owner_address: owner_address_
            }
        }(); 
        */

        if (gas_back_address.value != 0) {
            gas_back_address.transfer({ value: 0, flag: 128 });
        } else {
            msg.sender.transfer({ value: 0, flag: 128 });
        }

        //return wallet;
    }

    /*
        tokens  How much tokens to mint
        to  Receiver token wallet address
    */
    function mint(uint128 tokens, address to) override external onlyOwner {
        tvm.accept();

        //ITokenWallet(to).accept(tokens);

        total_supply += tokens;
    }


    /*
        Description: Transfer root token ownership

        root_public_key_  Root token owner public key
        root_owner_address_  Root token owner address
    */
    function transferOwner(
        uint256 root_public_key_,
        address root_owner_address_
    ) external onlyOwner {
        require((root_public_key_ != 0 && root_owner_address_.value == 0) ||
                (root_public_key_ == 0 && root_owner_address_.value != 0), 101);
        tvm.accept();
        
        root_public_key = root_public_key_;
        root_owner_address = root_owner_address_;
    }


    // =============== Support functions ==================

    modifier onlyOwner() {
        require(isOwner(), 103);
        _;
    }

    function isOwner() private inline view returns (bool) {
        return isInternalOwner() || isExternalOwner();
    }

    function isInternalOwner() private inline view returns (bool) {
        return root_owner_address.value != 0 && root_owner_address == msg.sender;
    }

    function isExternalOwner() private inline view returns (bool) {
        return root_public_key != 0 && root_public_key == msg.pubkey();
    }

    /*
        Description: Derive wallet address from owner

        wallet_public_key_  Token wallet owner public key
        owner_address_  Token wallet owner address
    */
    function getExpectedWalletAddress(
        uint256 wallet_public_key_,
        address owner_address_
    ) private inline view returns (address) {
        /*  Needed SC of TokenWallet
        TvmCell stateInit = tvm.buildStateInit({
            contr: TokenWallet,
            varInit: {
                root_address: address(this),
                code: wallet_code,
                wallet_public_key: wallet_public_key_,
                owner_address: owner_address_
            },
            pubkey: wallet_public_key_,
            code: wallet_code
        });
        return address(tvm.hash(stateInit));
        */
    }
}
