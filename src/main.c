#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>
#include <limine.h>
#include "rendering/rendering.h"
#include "lib/stdlib.h"
#include "arch/gdt.h"

__attribute__((used, section(".limine_requests_start")))
static volatile uint64_t limine_requests_start_marker[] = LIMINE_REQUESTS_START_MARKER;

__attribute__((used, section(".limine_requests")))
static volatile uint64_t limine_base_revision[] = LIMINE_BASE_REVISION(6);

__attribute__((used, section(".limine_requests")))
static volatile struct limine_framebuffer_request framebuffer_request = {
    .id = LIMINE_FRAMEBUFFER_REQUEST_ID,
    .revision = 0
};

__attribute__((used, section(".limine_requests_end")))
static volatile uint64_t limine_requests_end_marker[] = LIMINE_REQUESTS_END_MARKER;

void kmain(void)
{
    if (LIMINE_BASE_REVISION_SUPPORTED(limine_base_revision) == false) {
        hcf();
    }
    
    if (framebuffer_request.response == NULL
        || framebuffer_request.response->framebuffer_count < 1) {
        hcf();
    }

    x86_64_GDTInitialize();

    // Framebuffer comes last
    struct limine_framebuffer* framebuffer = 
        framebuffer_request.response->framebuffers[0];
    Framebuffer_init(framebuffer);

    // OS main loop
    while (true) 
    {
        for (size_t y = 0; y < framebuffer->height; y++) {
            for (size_t x = 0; x < framebuffer->width; x++) {
                uint32_t nX = (uint32_t)(x * 255 / framebuffer->width);
                uint32_t nY = (uint32_t)(y * 255 / framebuffer->height);
                putPixel(x, y,  (nY << 8) | nX);
            }
        }
    }

    // once done drawing, hang
    hcf();
}
