use starknet::ContractAddress;

#[derive(Drop, starknet::Event)]
pub struct Transfer {
    pub from: ContractAddress,
    pub to: ContractAddress,
    pub value: u256,
}

#[derive(Drop, starknet::Event)]
pub struct Approval {
    pub owner: ContractAddress,
    pub spender: ContractAddress,
    pub value: u256,
}
