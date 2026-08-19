#ifndef RENDERING_H
#define RENDERING_H

#include <limine.h>
#include <stdint.h>

struct color {
    uint8_t rgb[3];
};

void draw_pixel(struct limine_framebuffer* fb);

#endif
