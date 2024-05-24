
module travelswap_reward_token::travl_rt {
    
    // Imports
    use sui::coin::{Self, TreasuryCap};
    use sui::event;
    use sui::token::{Self, Token, TokenPolicy};

    // Errors
    
    // Token amount does not match the spend `amount`.
    const EIncorrectLength: u64 = 1;

    // Structs

    // Events
    public struct MintEvent has copy, drop {
        amount: u64,
        recipient: address,
    }

    public struct SpentEvent has copy, drop {
        amount: u64,
        spender: address,
    }   

    // Token
    public struct TRAVL_RT has drop {}

    // Rules
    public struct Rule has drop {}

    /* 
        Initializer is called once on module publish. A treasury
        cap is sent to the publisher, who then controls minting and burning
    */ 
    fun init(otw: TRAVL_RT, ctx: &mut TxContext) {
        let (treasury_cap, metadata) = coin::create_currency(
            otw, 
            0, 
            b"TRAVL_RT", 
            b"Travelswap Reward Token", 
            b"Reward tokens issued for participating in the TravelSwap ecosystem", 
            option::none(), 
            ctx
        );

        let (mut policy, policy_cap) = token::new_policy(&treasury_cap, ctx);
        token::add_rule_for_action<TRAVL_RT, Rule>(
            &mut policy,
            &policy_cap,
            token::spend_action(),
            ctx
        );
        token::share_policy(policy);

        // transfer::public_freeze_object(metadata);
        transfer::public_transfer(metadata, tx_context::sender(ctx));
        transfer::public_transfer(policy_cap, tx_context::sender(ctx));
        transfer::public_transfer(treasury_cap, tx_context::sender(ctx));
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
            mint(cap, amounts[i], recipients[i], ctx);
            i = i + 1;
        }
    }

    public fun spend(
        policy: &mut TokenPolicy<TRAVL_RT>,
        spentToken: Token<TRAVL_RT>,
        spender: address,
        ctx: &mut TxContext
    ) {
        let amount = token::value<TRAVL_RT>(&spentToken);
        let mut action_request = token::spend<TRAVL_RT>(spentToken, ctx);

        token::add_approval( Rule {}, &mut action_request, ctx);

        token::confirm_request_mut(policy, action_request, ctx);
        event::emit(SpentEvent { amount, spender });
    }

    #[test_only]
    public fun init_for_testing(ctx: &mut TxContext) {
        init(TRAVL_RT {}, ctx);
    }
}