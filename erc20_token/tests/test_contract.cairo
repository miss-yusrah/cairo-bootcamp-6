use snforge_std::{
    ContractClassTrait, DeclareResultTrait, declare, start_cheat_caller_address,
    stop_cheat_caller_address,
};
use starknet::ContractAddress;

use erc20_token::interfaces::{IERC20Dispatcher, IERC20DispatcherTrait};
use erc20_token::storage::MAX_LIMIT;

fn admin() -> ContractAddress {
    'admin'.try_into().unwrap()
}

fn user() -> ContractAddress {
    'user'.try_into().unwrap()
}

fn spender() -> ContractAddress {
    'spender'.try_into().unwrap()
}

fn deploy(
    admin_addr: ContractAddress,
    recipient: ContractAddress,
    initial_supply: felt252,
) -> ContractAddress {
    let contract = declare("ERC20Token").unwrap().contract_class();
    let mut calldata = array![
        admin_addr.into(),
        recipient.into(),
        'TestToken',
        'TTK',
        18,
        initial_supply,
    ];
    let (address, _) = contract.deploy(@calldata).unwrap();
    address
}

#[test]
fn constructor_sets_state() {
    let token = deploy(admin(), user(), 50_000);
    let dispatcher = IERC20Dispatcher { contract_address: token };

    assert(dispatcher.get_name() == 'TestToken', 'name');
    assert(dispatcher.get_symbol() == 'TTK', 'symbol');
    assert(dispatcher.get_decimals() == 18, 'decimals');
    assert(dispatcher.get_total_supply() == 50_000, 'supply');
    assert(dispatcher.get_owner() == admin(), 'owner');
    assert(dispatcher.balance_of(user()) == 50_000, 'recipient balance');
    assert(dispatcher.balance_of(admin()) == 0, 'admin balance');
}

#[test]
fn transfer_moves_tokens() {
    let token = deploy(admin(), user(), 10_000);
    let dispatcher = IERC20Dispatcher { contract_address: token };

    start_cheat_caller_address(token, user());
    dispatcher.transfer(admin(), 1000);
    stop_cheat_caller_address(token);

    assert(dispatcher.balance_of(user()) == 9000, 'sender');
    assert(dispatcher.balance_of(admin()) == 1000, 'recipient');
}

#[test]
#[should_panic(expected: ('Over limit',))]
fn transfer_over_max_limit_panics() {
    let token = deploy(admin(), user(), 50_000);
    let dispatcher = IERC20Dispatcher { contract_address: token };

    start_cheat_caller_address(token, user());
    dispatcher.transfer(admin(), MAX_LIMIT + 1);
    stop_cheat_caller_address(token);
}

#[test]
#[should_panic(expected: ('Low balance',))]
fn transfer_insufficient_balance_panics() {
    let token = deploy(admin(), user(), 100);
    let dispatcher = IERC20Dispatcher { contract_address: token };

    start_cheat_caller_address(token, user());
    dispatcher.transfer(admin(), 101);
    stop_cheat_caller_address(token);
}

#[test]
fn approve_and_transfer_from() {
    let token = deploy(admin(), user(), 10_000);
    let dispatcher = IERC20Dispatcher { contract_address: token };

    start_cheat_caller_address(token, user());
    dispatcher.approve(spender(), 3000);
    stop_cheat_caller_address(token);

    assert(dispatcher.allowance(user(), spender()) == 3000, 'allowance');

    start_cheat_caller_address(token, spender());
    dispatcher.transfer_from(user(), admin(), 2000);
    stop_cheat_caller_address(token);

    assert(dispatcher.balance_of(user()) == 8000, 'owner balance');
    assert(dispatcher.balance_of(admin()) == 2000, 'recipient balance');
    assert(dispatcher.allowance(user(), spender()) == 1000, 'remaining allowance');
}

#[test]
fn revoke_clears_allowance() {
    let token = deploy(admin(), user(), 10_000);
    let dispatcher = IERC20Dispatcher { contract_address: token };

    start_cheat_caller_address(token, user());
    dispatcher.approve(spender(), 500);
    dispatcher.revoke(spender());
    stop_cheat_caller_address(token);

    assert(dispatcher.allowance(user(), spender()) == 0, 'revoked');
}

#[test]
fn owner_burn_reduces_balance_and_supply() {
    let token = deploy(admin(), user(), 10_000);
    let dispatcher = IERC20Dispatcher { contract_address: token };

    start_cheat_caller_address(token, admin());
    dispatcher.burn(user(), 2500);
    stop_cheat_caller_address(token);

    assert(dispatcher.balance_of(user()) == 7500, 'balance');
    assert(dispatcher.get_total_supply() == 7500, 'supply');
}

#[test]
fn owner_can_update_max_limit() {
    let token = deploy(admin(), user(), 10_000);
    let dispatcher = IERC20Dispatcher { contract_address: token };

    start_cheat_caller_address(token, admin());
    dispatcher.set_max_limit(500);
    stop_cheat_caller_address(token);

    start_cheat_caller_address(token, user());
    dispatcher.transfer(admin(), 500);
    stop_cheat_caller_address(token);

    assert(dispatcher.balance_of(admin()) == 500, 'transfer at new limit');
}

#[test]
#[should_panic(expected: ('Not owner',))]
fn non_owner_cannot_burn() {
    let token = deploy(admin(), user(), 10_000);
    let dispatcher = IERC20Dispatcher { contract_address: token };

    start_cheat_caller_address(token, user());
    dispatcher.burn(user(), 1);
    stop_cheat_caller_address(token);
}
