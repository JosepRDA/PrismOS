#ifndef RENDERING_H
#define RENDERING_H

#include <limine.h>
#include <stdint.h>

struct color {
    uint32_t rgb[3];
};

void print_pixel(uint32_t posX, uint32_t posY, struct color col);

#endif
