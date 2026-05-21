use core::integer::u256;
use core::traits::Into;

use crate::errors;

pub fn assert_within_limit(amount: felt252, max_limit: felt252) {
    let amt: u256 = amount.into();
    let limit: u256 = max_limit.into();
    if amt > limit {
        assert(false, errors::OVER_LIMIT);
    }
}

pub fn assert_enough_balance(balance: felt252, amount: felt252) {
    let bal: u256 = balance.into();
    let amt: u256 = amount.into();
    if bal < amt {
        assert(false, errors::LOW_BALANCE);
    }
}

pub fn assert_enough_allowance(allowed: felt252, amount: felt252) {
    let allow: u256 = allowed.into();
    let amt: u256 = amount.into();
    if allow < amt {
        assert(false, errors::LOW_ALLOWANCE);
    }
}

pub fn assert_is_owner(caller: starknet::ContractAddress, owner: starknet::ContractAddress) {
    assert(caller == owner, errors::NOT_OWNER);
}
