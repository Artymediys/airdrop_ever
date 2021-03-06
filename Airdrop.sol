pragma ton-solidity >= 0.39.0;
pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "interfaces/ITokenRoot.sol";
import "interfaces/ITokenWallet.sol";
import "interfaces/IAcceptTokensTransferCallback.sol";
import "libraries/TokenMsgFlag.sol";
import "ACheckOwner.sol";


// Callback structure.
struct Callback {
    address token_wallet;
    address token_root;
    uint128 amount;
    uint256 sender_public_key;
    address sender_address;
    address sender_wallet;
    address original_gas_to;
    uint128 updated_balance;
    uint8 payload_arg0;
    address payload_arg1;
    address payload_arg2;
    uint128 payload_arg3;
    uint128 payload_arg4;
}

contract Airdrop is ACheckOwner, IAcceptTokensTransferCallback {
    address token;
    address token_wallet;

    // example value
    uint128 constant deploy_wallet_grams = 0.2 ton;
    uint128 constant transfer_grams = 0.1 ton;
    uint128 constant settings_grams = 0.2 ton;
    uint128 constant iteration_cost = 0.005 ton;
    uint128 constant comission = 0.2 ton;

    mapping(address => uint128) public depositors;
    mapping (uint => Callback) public callbacks;

    uint public counterCallback = 0;

    uint128 transferred_count = 0;

    constructor(address _token) public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();

        token = _token;
        setUpTokenWallet();
    }



    function AirDrop(address clientAirDropAddress, address[] arrayAddresses, uint256 [] arrayValues) external {
        require(msg.value >= (arrayAddresses.length * (transfer_grams + iteration_cost)) + comission, 112);
        require(depositors.exists(clientAirDropAddress), 111);
        require(arrayAddresses.length == arrayValues.length && arrayAddresses.length > 0, 102);
        tvm.rawReserve(address(this).balance - (msg.value - comission), 0);
        
        uint256 count = arrayAddresses.length;
        for (uint256 i = 0; i < count; i++) {
            // calling transfer function from contract
            TvmCell empty;
            ITokenWallet(token_wallet).transfer{
                value: transfer_grams,
                flag: 0
            }(
                uint128(arrayValues[i]),
                arrayAddresses[i],
                transfer_grams,
                clientAirDropAddress,
                false,
                empty
            );
        }
    }

    // Function for get first callback id.
    function getFirstCallback() private inline view returns (uint) {
        optional(uint, Callback) rc = callbacks.min();
        if (rc.hasValue()) {(uint number, ) = rc.get();return number;} else {return 0;}
    }
    

    function onAcceptTokensTransfer(
        address tokenRoot,
        uint128 amount,
        address sender,
        address senderWallet,
        address remainingGasTo,
        TvmCell payload
        ) external override {
        tvm.accept();
        if (depositors.exists(senderWallet)) {
            depositors[senderWallet] += amount;
        }
        else {
            depositors[senderWallet] = amount;
        }
        counterCallback++;
    }
        


    function setUpTokenWallet() internal view {
        // Deploy token wallet
        ITokenRoot(token).deployWallet{
            value: 1 ton,
            callback: Airdrop.setTokenWalletAddress
            }(
            address(this),
            deploy_wallet_grams
        );
    }
    
    function setTokenWalletAddress(address wallet) external {
        require(msg.sender == token, 103);
        token_wallet = wallet;
        // setReceiveCallback();
    }

    function getDetails() external view returns(
        address _token,
        address _token_wallet,
        uint128 _transferred_count,
        address _airdrop_sc,
        uint128 _airdrop_sc_balance
    ) {
        return (
            token,
            token_wallet,
            transferred_count,
            address(this),
            address(this).balance
        );
    }

    function getTokensBack(address clientWalletAddress, uint128 amount) external view {
        require(depositors.exists(msg.sender) && amount <= depositors[msg.sender], 104);
        uint256 tokensBack_required_value = 150000000;
        require(msg.value >= tokensBack_required_value, 105);

        tvm.rawReserve(address(this).balance - msg.value, 0);
              
        // Transfer tokens
        TvmCell empty;
        ITokenWallet(token_wallet).transfer{
            value: 0,
            flag: TokenMsgFlag.ALL_NOT_RESERVED
        }(  
            amount,
            clientWalletAddress,
            uint128(tokensBack_required_value),
            msg.sender,
            false,
            empty
        );
    }
}
