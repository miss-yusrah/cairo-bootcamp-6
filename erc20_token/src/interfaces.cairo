use starknet::ContractAddress;

#[starknet::interface]
pub trait IERC20<TContractState> {
    fn get_name(self: @TContractState) -> ByteArray;
    fn get_symbol(self: @TContractState) -> ByteArray;
    fn get_decimals(self: @TContractState) -> u8;
    fn get_total_supply(self: @TContractState) -> u256;
    fn balance_of(self: @TContractState, account: ContractAddress) -> u256;
    fn allowance(
        self: @TContractState, owner: ContractAddress, spender: ContractAddress,
    ) -> u256;
    fn get_owner(self: @TContractState) -> ContractAddress;
    fn transfer(ref self: TContractState, recipient: ContractAddress, amount: u256);
    fn transfer_from(
        ref self: TContractState,
        sender: ContractAddress,
        recipient: ContractAddress,
        amount: u256,
    );
    fn approve(ref self: TContractState, spender: ContractAddress, amount: u256);
    fn revoke(ref self: TContractState, spender: ContractAddress);
    fn mint(ref self: TContractState, recipient: ContractAddress, amount: u256);
    fn burn(ref self: TContractState, from: ContractAddress, amount: u256);
    fn set_max_limit(ref self: TContractState, new_limit: u256);
}
