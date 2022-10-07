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
from starkware.cairo.common.bool import FALSE, TRUE
from starkware.cairo.common.default_dict import default_dict_new
from starkware.cairo.common.dict import dict_read, dict_write
from starkware.cairo.common.dict_access import DictAccess
from starkware.cairo.common.math_cmp import is_le


func remove_k_last_x{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    array_len : felt, array : felt*, k : felt, x : felt
) -> (updated_arr_len : felt, updated_arr : felt*):
    alloc_locals
    let next_arr_size = array_len - k

    if array_len == 0:
        let (updated_arr) = alloc()
        return (0, updated_arr)
    end

    let (updated_arr_len : felt, updated_arr : felt*) = remove_k_last_x(
        array_len - 1, array + 1, k, x
    )

    if x == array[0] and array_len - k - 1 != updated_arr_len:
        return (updated_arr_len, updated_arr)
    end
    assert updated_arr[updated_arr_len] = array[0]
    return (updated_arr_len + 1, updated_arr)
end
