#pragma once

#define GET_FIELD(reg, field) ((reg & (field ## _Msk)) >> (field ## _Pos))

#define SET_FIELD(reg, field, val) do { \
    reg = (reg & ~(field ## _Msk)) | ((val) << (field ## _Pos)); \
} while(0)

#define CAST_REG(reg, type) (*((type *) &(reg)))

#define SPIN_WHILE(cond) do { } while((cond) != 0)
#define SPIN_UNTIL(cond) do { } while((cond) == 0)
