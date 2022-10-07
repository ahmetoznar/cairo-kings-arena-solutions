%lang starknet
from starkware.cairo.common.math import assert_nn
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.find_element import find_element
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_eq,
    uint256_le,
    uint256_lt,
    uint256_signed_div_rem,
)
from starkware.cairo.common.math import assert_nn_le, split_felt, unsigned_div_rem
from starkware.cairo.common.math_cmp import is_le, is_le_felt
from starkware.cairo.common.hash import hash2

//MERKLE ROOT = 0x9c5260ebda97651da7c463e61900301fded95167b97bfc96eece9c9571fec6
//LEAF = 0x9c5260ebda97651da7c463e61900301fded95167b97bfc96eece9c9571fec6
//PROOF = []
//ADDRESS = 3496565790028512688432690794941547605668654112795668502453340134635423433156 
//AMOUNT = 1500000000000000
//RANDOM = 164984651216568

@storage_var
func MERKLE_ROOT() -> (MERKLE_ROOT: felt) {
}

@external
func setMerkleRoot{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(root: felt) {
    MERKLE_ROOT.write(root);
    return ();
}

@view
func isWhitelisted{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    leaf: felt, proof_len: felt, proof: felt*
) -> (res: felt) {
    alloc_locals;
    let merkle_root: felt = MERKLE_ROOT.read();
    let res: felt = merkle_verify(leaf, merkle_root, proof_len, proof);
    return (res,);
}

func hash_user_data{pedersen_ptr: HashBuiltin*}(account: felt, amount: felt, random: felt) -> (
    res: felt
) {
    let (res) = hash2{hash_ptr=pedersen_ptr}(account, random);
    let (res) = hash2{hash_ptr=pedersen_ptr}(res, amount);
    return (res=res);
}

func merkle_verify{pedersen_ptr: HashBuiltin*, range_check_ptr}(
    leaf: felt, root: felt, proof_len: felt, proof: felt*
) -> (res: felt) {
    let (calc_root) = calc_merkle_root(leaf, proof_len, proof);
    // check if calculated root is equal to expected
    if (calc_root == root) {
        return (1,);
    } else {
        return (0,);
    }
}

// calculates the merkle root of a given proof
func calc_merkle_root{pedersen_ptr: HashBuiltin*, range_check_ptr}(
    curr: felt, proof_len: felt, proof: felt*
) -> (res: felt) {
    alloc_locals;

    if (proof_len == 0) {
        return (curr,);
    }

    local node;
    local proof_elem = [proof];
    let le = is_le_felt(curr, proof_elem);

    if (le == 1) {
        let (n) = hash2{hash_ptr=pedersen_ptr}(curr, proof_elem);
        node = n;
    } else {
        let (n) = hash2{hash_ptr=pedersen_ptr}(proof_elem, curr);
        node = n;
    }

    let (res) = calc_merkle_root(node, proof_len - 1, proof + 1);
    return (res,);
}