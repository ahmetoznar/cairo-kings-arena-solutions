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

@view
func is_palindrome_number{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}(
    number
) -> (bool):
    let (arr_len, arr) = number_to_array(number)
    return is_palindrome_array(arr_len, arr)
end

func number_to_array{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}(number) -> (
    arr_len, arr : felt*
):
    alloc_locals
    let (q, r) = unsigned_div_rem(number, 10)
    if q != 0:
        let (arr_len, arr) = number_to_array(q)
        assert arr[arr_len] = r
        return (arr_len + 1, arr)
    end
    let (arr) = alloc()
    assert arr[0] = r
    return (1, arr)
end

func is_palindrome_array{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}(
    arr_len, arr : felt*
) -> (bool):
    if arr_len == 0:
        return (TRUE)
    end

    if arr_len == 1:
        return (TRUE)
    end

    if arr[0] != arr[arr_len - 1]:
        return (FALSE)
    end

    return is_palindrome_array(arr_len - 2, arr + 1)
end
