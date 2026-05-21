#[starknet::contract]
pub mod ERC20Token {
    use core::num::traits::Zero;
    use starknet::get_caller_address;
    use starknet::ContractAddress;
    use starknet::storage::{
        Map, StorageMapReadAccess, StorageMapWriteAccess, StoragePointerReadAccess,
        StoragePointerWriteAccess,
    };

    use crate::checks::{
        assert_enough_allowance, assert_enough_balance, assert_is_owner, assert_within_limit,
    };
    use crate::errors;
    use crate::events::{Approval, Transfer};
    use crate::storage::MAX_LIMIT;

    #[storage]
    struct Storage {
        owner: ContractAddress,
        name: felt252,
        symbol: felt252,
        decimals: u8,
        total_supply: felt252,
        max_limit: felt252,
        balances: Map::<ContractAddress, felt252>,
        allowances: Map::<(ContractAddress, ContractAddress), felt252>,
    }

    #[event]
    #[derive(Copy, Drop, starknet::Event)]
    enum Event {
        Transfer: Transfer,
        Approval: Approval,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        admin: ContractAddress,
        recipient: ContractAddress,
        name: felt252,
        symbol: felt252,
        decimals: u8,
        initial_supply: felt252,
    ) {
        self.owner.write(admin);
        self.name.write(name);
        self.symbol.write(symbol);
        self.decimals.write(decimals);
        self.max_limit.write(MAX_LIMIT);
        self.total_supply.write(initial_supply);
        self.balances.write(recipient, initial_supply);
    }

    #[abi(embed_v0)]
    impl ERC20Impl of crate::interfaces::IERC20<ContractState> {
        fn get_name(self: @ContractState) -> felt252 {
            self.name.read()
        }

        fn get_symbol(self: @ContractState) -> felt252 {
            self.symbol.read()
        }

        fn get_decimals(self: @ContractState) -> u8 {
            self.decimals.read()
        }

        fn get_total_supply(self: @ContractState) -> felt252 {
            self.total_supply.read()
        }


        fn balance_of(self: @ContractState, account: ContractAddress) -> felt252 {
            self.balances.read(account)
        }

        fn allowance(
            self: @ContractState, owner: ContractAddress, spender: ContractAddress,
        ) -> felt252 {
            self.allowances.read((owner, spender))
        }

        fn get_owner(self: @ContractState) -> ContractAddress {
            self.owner.read()
        }

        fn transfer(ref self: ContractState, recipient: ContractAddress, amount: felt252) {
            assert_within_limit(amount, self.max_limit.read());

            let sender = get_caller_address();
            assert(sender.is_non_zero(), errors::FROM_ZERO);
            // assert(recipient.is_non_zero(), errors::TO_ZERO);

            let bal = self.balances.read(sender);
            assert_enough_balance(bal, amount);

            self.balances.write(sender, bal - amount);
            self.balances.write(recipient, self.balances.read(recipient) + amount);
            self.emit(Event::Transfer(Transfer { from: sender, to: recipient, value: amount }));
        }

        fn transfer_from(
            ref self: ContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            amount: felt252,
        ) {
            assert_within_limit(amount, self.max_limit.read());

            let caller = get_caller_address();
            let allowed = self.allowances.read((sender, caller));
            assert_enough_allowance(allowed, amount);
            self.allowances.write((sender, caller), allowed - amount);

            let bal = self.balances.read(sender);
            assert_enough_balance(bal, amount);

            self.balances.write(sender, bal - amount);
            self.balances.write(recipient, self.balances.read(recipient) + amount);
            self.emit(Event::Transfer(Transfer { from: sender, to: recipient, value: amount }));
        }

        fn approve(ref self: ContractState, spender: ContractAddress, amount: felt252) {
            assert(spender.is_non_zero(), errors::SPENDER_ZERO);

            let owner = get_caller_address();
            self.allowances.write((owner, spender), amount);
            self.emit(Event::Approval(Approval { owner, spender, value: amount }));
        }

        fn revoke(ref self: ContractState, spender: ContractAddress) {
            let owner = get_caller_address();
            self.allowances.write((owner, spender), 0);
            self.emit(Event::Approval(Approval { owner, spender, value: 0 }));
        }

        fn burn(ref self: ContractState, from: ContractAddress, amount: felt252) {
            assert_is_owner(get_caller_address(), self.owner.read());

            let bal = self.balances.read(from);
            assert_enough_balance(bal, amount);

            self.balances.write(from, bal - amount);
            self.total_supply.write(self.total_supply.read() - amount);
        }

        fn set_max_limit(ref self: ContractState, new_limit: felt252) {
            assert_is_owner(get_caller_address(), self.owner.read());
            self.max_limit.write(new_limit);
        }
    }
}
