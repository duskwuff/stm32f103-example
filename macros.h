#pragma once
#include <assert.h>

/**
 * This returns a constant expression while determining if an argument is
 * a constant expression, most importantly without evaluating the argument.
 * Glory to Martin Uecker <Martin.Uecker@med.uni-goettingen.de>
 *
 * (from include/linux/kernel.h)
 */
#define __is_constexpr(x) \
    (sizeof(int) == sizeof(*(8 ? ((void *)((long)(x) * 0l)) : (int *)8)))


/**
 * `FIELD_VAL()` shifts a value into the position defined for a named field.
 *
 * This can be useful when assigning a group of values to a register at once.
 */
#define FIELD_VAL(field, val) ({ \
        static_assert(!__is_constexpr(val) || ((val) & ~(field ## _Msk >> field ## _Pos)) == 0, "value extends outside bounds of field"); \
        (((val) << field ## _Pos) & field ## _Msk); \
        })


/**
 * `GET_FIELD()` reads the value of a named field in a register.
 *
 * For example, `GET_FIELD(RCC->CFGR, RCC_CFGR_SW)` will evaluate to the value
 * of the `SW` field of `RCC->CFGR`.
 */
#define GET_FIELD(reg, field) (((reg) & field ## _Msk) >> field ## _Pos)


/**
 * `SET_FIELD()` sets a named field within a register.
 *
 * For example, `SET_FIELD(RCC->CFGR, RCC_CFGR_SW, 0b10)` will set the value
 * of the `SW` field of `RCC->CFGR` to `0b10`.
 *
 * Note that the value of `val` is shifted into position, allowing numeric
 * values to be written directly into registers. Some values defined in ST
 * headers (such as `RCC_CFGR_SW_HSE`) are defined with an already-shifted
 * value; using these values as arguments to this macro will **not** work
 * correctly (and will usually throw an assertion). Use `SET_FIELD_SHIFTED()`
 * to work with these values.
 */
#define SET_FIELD(reg, field, val) do { \
    static_assert(!__is_constexpr(val) || ((val) & ~(field ## _Msk >> field ## _Pos)) == 0, "value extends outside bounds of field"); \
    reg = (reg & ~field ## _Msk) | (((val) << field ## _Pos) & (field ## _Msk)); \
} while(0)


/**
 * `SET_FIELD_SHIFTED()` works similarly to `SET_FIELD()`, but does not shift
 * the value into position. See above for why this is useful.
 */
#define SET_FIELD_SHIFTED(reg, field, val) do { \
    static_assert(!__is_constexpr(val) || ((val) & ~(field ## _Msk)) == 0, "shifted value extends outside bounds of field"); \
    reg = (reg & ~field ## _Msk) | ((val) & (field ## _Msk)); \
} while(0)


/**
 * `CAST_REG()` reads a register as a specific type.
 *
 * For example, accessing `CAST_REG(reg, uint8_t)` will perform a byte-wide
 * read/write operation on `reg`. This can be important for some registers
 * which will behave differently depending on what type of access is used,
 * such as `SPI->DR` on some newer parts.
 */
#define CAST_REG(reg, type) (*((type *) &(reg)))


/**
 * `SPIN_WHILE()` spin-loops while a condition is true.
 */
#define SPIN_WHILE(cond) do { } while((cond) != 0)


/**
 * `SPIN_UNTIL()` spin-loops until a condition is true.
 */
#define SPIN_UNTIL(cond) do { } while((cond) == 0)
