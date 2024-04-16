#[test_only]
module travelswap_reward_token::travl_rt_test {
    use sui::coin::{TreasuryCap};
    use sui::token_test_utils::{Self as test};
    use sui::token::{Self, Token};
    use sui::test_scenario::{Self};
    use travelswap_reward_token::travl_rt::{Self as travl_rt, TRAVL_RT};

    const EWrongUserBalance: u64 = 1;

    #[test]
    fun test_mint_and_burn_tokens_to_user() {
        let admin = @0x1;
        let user = @0x2;

        // Setup the reward token
        let mut scenario_val = test_scenario::begin(admin);
        let scenario = &mut scenario_val;

        let ctx = &mut test::ctx(admin);
        travl_rt::init_for_testing(ctx);

        // Mint some tokens to user
        test_scenario::next_tx(scenario, admin);
        let mut treasury_cap = test_scenario::take_from_sender<TreasuryCap<TRAVL_RT>>(scenario);
        travl_rt::mint(&mut treasury_cap, 1000_000000, user, ctx);
        
        // Validate the user balance
        test_scenario::next_tx(scenario, user);
        {
            let user_token = test_scenario::take_from_sender<Token<TRAVL_RT>>(scenario);
            assert!(token::value(&user_token) == 1000_000000, EWrongUserBalance);
            test_scenario::return_to_sender(scenario, user_token);
        };

        // Burn some tokens from user
        test_scenario::next_tx(scenario, admin);
        {
            let mut user_token = test_scenario::take_from_address<Token<TRAVL_RT>>(scenario, user);
            let burn_token = token::split(&mut user_token, 400_000000, ctx);
            travl_rt::spend(&mut treasury_cap, burn_token, 400_000000, user, ctx);
            test_scenario::return_to_sender(scenario,  treasury_cap);
            test_scenario::return_to_address(user, user_token);
        };

        // Validate the user balance
        test_scenario::next_tx(scenario, user);
        {
            let user_token = test_scenario::take_from_sender<Token<TRAVL_RT>>(scenario);
            assert!(token::value(&user_token) == 600_000000, EWrongUserBalance);
            test_scenario::return_to_sender(scenario, user_token);
        };
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_mint_batch () {
        let admin = @0x1;
        
        // vector of recipients and amounts
        let recipients = vector<address>[@0x2, @0x3, @0x4];
        let amounts = vector<u64>[1000_000000, 2000_000000, 3000_000000];
        

        // Setup the reward token
        let mut scenario_val = test_scenario::begin(admin);
        let scenario = &mut scenario_val;

        let ctx = &mut test::ctx(admin);
        travl_rt::init_for_testing(ctx);

        // Mint some tokens to user
        test_scenario::next_tx(scenario, admin);
        let mut treasury_cap = test_scenario::take_from_sender<TreasuryCap<TRAVL_RT>>(scenario);
        travl_rt::mintBatch(&mut treasury_cap, &amounts, &recipients, ctx);
        test_scenario::return_to_sender(scenario,  treasury_cap);
        

        // Validate the users balances
        let max = amounts.length();
        let mut i: u64 = 0;
        while (i < max) {
            test_scenario::next_tx(scenario, recipients[i]);
            {
                let user_token = test_scenario::take_from_sender<Token<TRAVL_RT>>(scenario);
                assert!(token::value(&user_token) == amounts[i], EWrongUserBalance);
                test_scenario::return_to_sender(scenario, user_token);
            };
            i = i + 1;
        };

        test_scenario::end(scenario_val);
    }
}