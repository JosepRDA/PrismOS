#include "rendering.h"
#include <stdint.h>

static volatile Framebuffer fb = 
{
    .address = (void*)1, 
};

void Framebuffer_init(struct limine_framebuffer* framebuffer) 
{
    fb.address = framebuffer->address;
    fb.width = framebuffer->width;
    fb.height = framebuffer->height;
    fb.pitch = framebuffer->pitch;
}

void putPixel(size_t x, size_t y, uint32_t color) 
{
    size_t pixel = y * (fb.pitch / sizeof(uint32_t)) + x;
    ((uint32_t*)fb.address)[pixel] = color;
    // volatile uint32_t *ptr = fb.address;
    // (void)ptr;
}
