%builtins output range_check

from starkware.cairo.common.dict_access import DictAccess
from starkware.cairo.common.squash_dict import squash_dict
from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math_cmp import is_le, is_not_zero

from starkware.cairo.common.registers import get_fp_and_pc

struct ArraySatisfied:
    member array : felt*
    member size_array : felt
end

func satisfy{output_ptr : felt*, range_check_ptr}(array_len : felt, numbers_array : felt*) -> (
    array_struct : ArraySatisfied
):
    alloc_locals

    with_attr error_message("list is empty"):
        let (zeroed) = is_not_zero(array_len)
        assert 1 = zeroed
    end

    let (local dict_start : DictAccess*) = alloc()

    let (dict_end : DictAccess*) = make_dict(
        list=numbers_array, size_list=array_len, dict=dict_start
    )

    let (local squashed_dict : DictAccess*) = alloc()

    let (squashed_dict_res : DictAccess*) = squash_dict(
        dict_accesses=dict_start, dict_accesses_end=dict_end, squashed_dict=squashed_dict
    )

    let squash_size = (squashed_dict_res - squashed_dict) / DictAccess.SIZE

    let (local array_start_pointer : felt*) = alloc()
    let (array_res : felt*) = _remove(
        array_start_pointer=array_start_pointer, dict_to_access=squashed_dict, dict_size=squash_size
    )

    let res_struct : ArraySatisfied = ArraySatisfied(
        array=array_start_pointer, size_array=array_res - array_start_pointer
    )

    return (array_struct=res_struct)
end

func _remove{range_check_ptr, output_ptr : felt*}(
    array_start_pointer : felt*, dict_to_access : DictAccess*, dict_size : felt
) -> (array_end_pointer : felt*):
    alloc_locals

    if dict_size == 0:
        return (array_end_pointer=array_start_pointer)
    end
    # remove the elements that dont satisfy the statement
    local key : felt
    local prev : felt
    local next : felt

    assert key = dict_to_access.key
    assert prev = dict_to_access.prev_value
    assert next = dict_to_access.new_value

    let (root_res) = _do_math(x=key, y=prev, z=next)
    if root_res == 0:
        assert [array_start_pointer] = key + prev + next
        return _remove(
            array_start_pointer=array_start_pointer + 1,
            dict_to_access=dict_to_access + DictAccess.SIZE,
            dict_size=dict_size - 1,
        )
    end

    return _remove(
        array_start_pointer=array_start_pointer,
        dict_to_access=dict_to_access + DictAccess.SIZE,
        dict_size=dict_size - 1,
    )
end

func _do_math(x : felt, y : felt, z : felt) -> (res : felt):
    return (res=x * x * x + y * y + z)
end

func _output_values{output_ptr : felt*}(array : felt*, size : felt):
    if size == 0:
        return ()
    end
    let val = [array]
    serialize_word(val)

    return _output_values(array=array + 1, size=size - 1)
end

func _output_initial_values{output_ptr : felt*}(squashed_dict : DictAccess*, n):
    if n == 0:
        return ()
    end

    serialize_word(squashed_dict.key)
    serialize_word(squashed_dict.prev_value)
    serialize_word(squashed_dict.new_value)

    return _output_initial_values(squashed_dict=squashed_dict + DictAccess.SIZE, n=n - 1)
end

func make_dict(list : felt*, size_list : felt, dict : DictAccess*) -> (dict_init : DictAccess*):
    if size_list == 0:
        return (dict_init=dict)
    end

    assert dict.key = [list]
    assert dict.prev_value = [list + 1]
    assert dict.new_value = [list + 2]

    return make_dict(list=list + 3, size_list=size_list - 3, dict=dict + DictAccess.SIZE)
end

func main{output_ptr : felt*, range_check_ptr}():
    alloc_locals
    local list : (
        felt,
        felt,
        felt,
        felt,
        felt,
        felt,
        felt,
        felt,
        felt,
        felt,
        felt,
        felt,
        felt,
        felt,
        felt,
        felt,
        felt,
        felt,
    ) = (0, 2, 199, 11, 1, 66, 0, 199, -4, 11, 66, 66, 18, 78, -11916, 11, 66, 22)

    let (__fp__, _) = get_fp_and_pc()

    let (struct_res : ArraySatisfied) = satisfy(array_len=18, numbers_array=cast(&list, felt*))
    _output_values(array=struct_res.array, size=struct_res.size_array)
    return ()
end
