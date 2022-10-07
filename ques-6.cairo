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
func count_digit{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}(
    number, digit, base
) -> (amount):
    if number == digit:
        return (1)
    end
    return count_digit_util(number, digit, base, 0)
end

@view
func count_digit_util{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}(
    number, digit, base, counter
) -> (amount):
    let (q, r) = unsigned_div_rem(number, base)
    if q != 0:
        if r == digit:
            return count_digit_util(q, digit, base, counter + 1)
        end
        return count_digit_util(q, digit, base, counter)
    end
    return (counter)
end
