use starknet::ContractAddress;

#[derive(Copy, Drop, starknet::Event)]
pub struct Transfer {
    pub from: ContractAddress,
    pub to: ContractAddress,
    pub value: felt252,
}

#[derive(Copy, Drop, starknet::Event)]
pub struct Approval {
    pub owner: ContractAddress,
    pub spender: ContractAddress,
    pub value: felt252,
}
