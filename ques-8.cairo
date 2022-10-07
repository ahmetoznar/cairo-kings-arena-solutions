%builtins output range_check bitwise

from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math_cmp import is_le, is_not_zero

from starkware.cairo.common.bitwise import bitwise_and
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin

from starkware.cairo.common.registers import get_fp_and_pc

struct BaseIndices:
    member base : felt
    member amount_of_indices : felt
end

func collatz{range_check_ptr, bitwise_ptr : BitwiseBuiltin*, output_ptr : felt*}(
    bases_len : felt, bases : felt*, range : felt
) -> (res : BaseIndices):
    alloc_locals

    let (local base_indices_start : BaseIndices*) = alloc()
    let (local couples : BaseIndices*) = get_couples(
        bases_len=bases_len, bases=bases, base_indices_start=base_indices_start, range=range
    )
    let first_couple : BaseIndices = [base_indices_start]

    let (max_couple : BaseIndices) = get_max_couple{max=first_couple}(
        couples=base_indices_start + BaseIndices.SIZE, size_couples=bases_len - 1
    )
    return (res=max_couple)
end

func get_max_couple{max : BaseIndices, range_check_ptr}(
    couples : BaseIndices*, size_couples : felt
) -> (max_couple : BaseIndices):
    alloc_locals
    if size_couples == 0:
        return (max_couple=max)
    end

    local max_amount = max.amount_of_indices

    local current_amount = couples.amount_of_indices

    let (le) = is_le(max_amount, current_amount)
    if le == 1:
        local new_max : BaseIndices = [couples]
        return get_max_couple{max=new_max}(
            couples=couples + BaseIndices.SIZE, size_couples=size_couples - 1
        )
    end

    return get_max_couple{max=max}(
        couples=couples + BaseIndices.SIZE, size_couples=size_couples - 1
    )
end

func get_couples{range_check_ptr, bitwise_ptr : BitwiseBuiltin*, output_ptr : felt*}(
    bases_len : felt, bases : felt*, base_indices_start : BaseIndices*, range : felt
) -> (res : BaseIndices*):
    alloc_locals

    if bases_len == 0:
        return (res=base_indices_start)
    end

    let current_N = [bases]
    let (amount_indices : felt) = _get_amount_indices{countdown=range, bitwise_ptr=bitwise_ptr}(
        current_N
    )

    assert base_indices_start.base = current_N
    assert base_indices_start.amount_of_indices = amount_indices

    return get_couples(
        bases_len=bases_len - 1,
        bases=bases + 1,
        base_indices_start=base_indices_start + BaseIndices.SIZE,
        range=range,
    )
end

func _get_amount_indices{
    countdown : felt, range_check_ptr, bitwise_ptr : BitwiseBuiltin*, output_ptr : felt*
}(N : felt) -> (res : felt):
    alloc_locals

    local count_zero = 0
    let (sol) = _do_collatz{count=count_zero, bitwise_ptr=bitwise_ptr}(prev=N, limit=countdown)
    return (res=sol)
end

func _do_collatz{count : felt, range_check_ptr, bitwise_ptr : BitwiseBuiltin*, output_ptr : felt*}(
    prev : felt, limit : felt
) -> (res_count : felt):
    alloc_locals
    if limit == 0:
        return (res_count=count)
    end

    let (is_even) = bitwise_and(prev, 1)

    if is_even == 0:
        local new_val = prev / 2
        if new_val == 1:
            local new_count = count + 1
            return _do_collatz{count=new_count, bitwise_ptr=bitwise_ptr}(
                prev=new_val, limit=limit - 1
            )
        end
        return _do_collatz{count=count, bitwise_ptr=bitwise_ptr}(prev=new_val, limit=limit - 1)
    end

    local new_val = prev * 3 + 1

    if new_val == 1:
        local new_count = count + 1
        return _do_collatz{count=new_count, bitwise_ptr=bitwise_ptr}(prev=new_val, limit=limit - 1)
    end
    return _do_collatz{count=count, bitwise_ptr=bitwise_ptr}(prev=new_val, limit=limit - 1)
end

func main{output_ptr : felt*, range_check_ptr, bitwise_ptr : BitwiseBuiltin*}():
    alloc_locals
    local list : (felt, felt, felt, felt) = (15, 2, 199, 11)
    let (__fp__, _) = get_fp_and_pc()

    let (res : BaseIndices) = collatz(bases_len=4, bases=cast(&list, felt*), range=20)
    serialize_word(res.base)
    serialize_word(res.amount_of_indices)
    return ()
end
