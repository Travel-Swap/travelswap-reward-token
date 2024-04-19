
module travelswap_reward_token::travl_rt {
    
    // Imports
    use sui::coin::{Self, TreasuryCap};
    use sui::event;
    use sui::token::{Self, Token};

    // Errors
    
    // Token amount does not match the spend `amount`.
    const EIncorrectAmount: u64 = 0;
    const EIncorrectLength: u64 = 1;

    // Structs

    // Events
    public struct MintEvent has copy, drop {
        amount: u64,
        recipient: address,
    }

    public struct BurnEvent has copy, drop {
        amount: u64,
        spender: address,
    }   

    // Token
    public struct TRAVL_RT has drop {}

    /* 
        Initializer is called once on module publish. A treasury
        cap is sent to the publisher, who then controls minting and burning
    */ 
    fun init(otw: TRAVL_RT, ctx: &mut TxContext) {
        let treasury = create_currency(otw, ctx);

        transfer::public_transfer(treasury, tx_context::sender(ctx))
    }

    fun create_currency<T: drop>(
        otw: T,
        ctx: &mut TxContext
    ): TreasuryCap<T> {
        let (treasury_cap, metadata) = coin::create_currency(
            otw, 
            6, 
            b"TRAVL_RT", 
            b"Travelswap Reward Token", 
            b"Reward tokens issued for participating in the TravelSwap ecosystem", 
            option::none(), 
            ctx
        );

        transfer::public_freeze_object(metadata);
        treasury_cap
    }

    // Public functions

    public fun mint(
        cap: &mut TreasuryCap<TRAVL_RT>, 
        amount: u64,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        let token = token::mint(cap, amount, ctx);
        let req = token::transfer(token, recipient, ctx);
        
        token::confirm_with_treasury_cap(cap, req, ctx);
        event::emit(MintEvent { amount, recipient });
    }

    // mintBatch to multiple recipients, this will be used to distribute the initial set of RT's
    public fun mint_batch(
        cap: &mut TreasuryCap<TRAVL_RT>,
        amounts: &vector<u64>,
        recipients: &vector<address>,
        ctx: &mut TxContext,
    ) {
        let max = amounts.length();
        assert!(max == recipients.length(), EIncorrectLength);

        let mut i: u64 = 0;
        while (i < max) {
            mint(cap, *std::vector::borrow(amounts, i), *std::vector::borrow(recipients, i), ctx);
            i = i + 1;
        }
    }

    public fun spend(
        cap: &mut TreasuryCap<TRAVL_RT>, 
        token: Token<TRAVL_RT>,
        amount: u64,
        spender: address,
        ctx: &mut TxContext
    ) {
        assert!(token::value(&token) == amount, EIncorrectAmount);
        let req = token::spend(token, ctx);

        token::confirm_with_treasury_cap(cap, req, ctx);
        event::emit(BurnEvent { amount, spender });
    }

    #[test_only]
    public fun init_for_testing(ctx: &mut TxContext) {
        init(TRAVL_RT {}, ctx);
    }
}