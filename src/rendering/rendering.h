#pragma once

#include <limine.h>
#include <stddef.h>
#include <stdint.h>

typedef struct {
    void* address;
    size_t width;
    size_t height;
    size_t pitch;
} Framebuffer ;

void Framebuffer_init(struct limine_framebuffer* fb);
void putPixel(size_t x, size_t y, uint32_t color);

