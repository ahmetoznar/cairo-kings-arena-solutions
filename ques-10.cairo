%builtins output range_check

from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math_cmp import is_le, is_not_zero
from starkware.cairo.common.math import assert_nn

from starkware.cairo.common.registers import get_fp_and_pc

struct Row:
    member row_size : felt
    member row : felt*
end

struct Col:
    member col_size : felt
    member col : felt*
end

func wizard{output_ptr : felt*, range_check_ptr, count : felt}(
    array_len : felt, array_row : Row*, array_col : Col*
) -> (res : felt):
    alloc_locals
    if array_len == 0:
        return (res=1)
    end

    local arr_row : Row = [array_row]
    local size : felt = arr_row.row_size
    local row : felt* = arr_row.row

    local sum_r : felt = 0
    let (sum_tmp_row : felt) = _get_sum_row{
        output_ptr=output_ptr, range_check_ptr=range_check_ptr, sum_r=sum_r
    }(array=row, size=size)

    local arr_col : Col = [array_col]
    local col : felt* = arr_col.col

    local sum_c : felt = 0
    let (sum_tmp_col : felt) = _get_sum_col{
        output_ptr=output_ptr, range_check_ptr=range_check_ptr, sum_c=sum_c
    }(array=col, size=size)

    # serialize_word(sum_tmp_row)
    # serialize_word(sum_tmp_col)

    local new_count : felt = sum_tmp_col
    # check if row and col are the same val

    if count == 0:
        let diff = sum_tmp_col - sum_tmp_row
        assert_nn(diff)
        with_attr error_message("Its not a wizard matrix !"):
            assert diff = 0
        end
        return wizard{output_ptr=output_ptr, range_check_ptr=range_check_ptr, count=new_count}(
            array_len=array_len - 1, array_row=array_row + Row.SIZE, array_col=array_col + Col.SIZE
        )
    end
    let actual_val : felt = count
    let diff_row = sum_tmp_row - actual_val
    let diff_col = sum_tmp_col - actual_val
    assert_nn(diff_row)
    assert_nn(diff_col)
    assert_nn(diff_row + diff_col)

    with_attr error_message("Its not a wizard matrix !"):
        let sum_diff = diff_row + diff_col
        assert sum_diff = 0
    end

    return wizard{output_ptr=output_ptr, range_check_ptr=range_check_ptr, count=new_count}(
        array_len=array_len - 1, array_row=array_row + Row.SIZE, array_col=array_col + Col.SIZE
    )
end

func _get_sum_col{output_ptr : felt*, range_check_ptr, sum_c : felt}(
    array : felt*, size : felt
) -> (res : felt):
    alloc_locals

    if size == 0:
        return (res=sum_c)
    end
    let val = [array]
    local new_sum_c : felt = sum_c + val
    assert_nn(new_sum_c)

    return _get_sum_col{output_ptr=output_ptr, range_check_ptr=range_check_ptr, sum_c=new_sum_c}(
        array=array + 1, size=size - 1
    )
end

func _get_sum_row{output_ptr : felt*, range_check_ptr, sum_r : felt}(
    array : felt*, size : felt
) -> (sum : felt):
    alloc_locals

    if size == 0:
        return (sum=sum_r)
    end
    let val = [array]
    local new_sum_r : felt = sum_r + val
    assert_nn(new_sum_r)

    return _get_sum_row{output_ptr=output_ptr, range_check_ptr=range_check_ptr, sum_r=new_sum_r}(
        array=array + 1, size=size - 1
    )
end

func _output_values{output_ptr : felt*}(array : felt*, size : felt):
    if size == 0:
        return ()
    end
    let val = [array]
    serialize_word(val)

    return _output_values(array=array + 1, size=size - 1)
end

func main{output_ptr : felt*, range_check_ptr}():
    alloc_locals

    let (__fp__, _) = get_fp_and_pc()

    let (local array_row : Row*) = alloc()

    local list : (felt, felt, felt) = (2, 7, 6)

    local list1 : (felt, felt, felt) = (9, 5, 1)

    local list2 : (felt, felt, felt) = (4, 3, 8)

    assert [array_row] = Row(row_size=3, row=cast(&list, felt*))
    assert [array_row + Row.SIZE] = Row(row_size=3, row=cast(&list1, felt*))
    assert [array_row + 2 * Row.SIZE] = Row(row_size=3, row=cast(&list2, felt*))

    let (local array_col : Col*) = alloc()

    local list3 : (felt, felt, felt) = (2, 9, 4)

    local list4 : (felt, felt, felt) = (7, 5, 3)

    local list5 : (felt, felt, felt) = (6, 1, 8)

    assert [array_col] = Col(col_size=3, col=cast(&list3, felt*))
    assert [array_col + Col.SIZE] = Col(col_size=3, col=cast(&list4, felt*))
    assert [array_col + 2 * Col.SIZE] = Col(col_size=3, col=cast(&list5, felt*))

    local count_start = 0
    let (res : felt) = wizard{
        output_ptr=output_ptr, range_check_ptr=range_check_ptr, count=count_start
    }(array_len=3, array_row=array_row, array_col=array_col)

    serialize_word(res)
    return ()
end
