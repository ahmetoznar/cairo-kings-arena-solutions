%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import FALSE, TRUE
from starkware.cairo.common.default_dict import default_dict_new
from starkware.cairo.common.dict import dict_read, dict_write
from starkware.cairo.common.dict_access import DictAccess
from starkware.cairo.common.math_cmp import is_le


@view
func sieve{range_check_ptr}(n: felt) -> (acc_len: felt, acc: felt*) {
    alloc_locals;

    let (acc) = alloc();
    let (d) = default_dict_new(TRUE);
    let (count) = sieve_loop{dict_ptr=d}(2, n, acc, 1);

    return (count, acc);
}

func sieve_loop{range_check_ptr, dict_ptr: DictAccess*}(p, n, acc: felt*, count) -> (count: felt) {
    alloc_locals;
    let res : felt = is_le(p, n);
    if (res == FALSE) {
        return (count - 1,);
    }

    let (v) = dict_read(p);
    if (v == TRUE) {
        assert [acc] = p;
        mark_not_prime_loop(p * p, n + 1, p);
        return sieve_loop(p + 1, n, acc + 1, count + 1);
    }

    return sieve_loop(p + 1, n, acc, count);
}

func mark_not_prime_loop{range_check_ptr, dict_ptr: DictAccess*}(start, stop, step) {
    let res : felt = is_le(start, stop); 
    if (res == FALSE) {
        return ();
    }

    dict_write(start, FALSE);
    return mark_not_prime_loop(start + step, stop, step);
}

