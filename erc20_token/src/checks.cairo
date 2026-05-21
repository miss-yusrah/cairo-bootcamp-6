pub fn assert_within_limit(amount: u256, max_limit: u256) {
    if amount > max_limit {
        assert(false, 'Over limit');
    }
}

pub fn assert_enough_balance(balance: u256, amount: u256) {
    if balance < amount {
        assert(false, 'Low balance');
    }
}

pub fn assert_enough_allowance(allowed: u256, amount: u256) {
    if allowed < amount {
        assert(false, 'Low allowance');
    }
}

pub fn assert_is_owner(caller: starknet::ContractAddress, owner: starknet::ContractAddress) {
    assert(caller == owner, 'Not owner');
}
