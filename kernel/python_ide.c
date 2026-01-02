#include <stdint.h>
#include <stddef.h>

// GUI window structure
typedef struct
{
    uint32_t x, y;
    uint32_t width, height;
    char title[64];
    char *content;
    uint32_t content_size;
    uint32_t content_capacity;
} gui_window_t;

// Create IDE editor window
gui_window_t *ide_create_window(const char *title)
{
    gui_window_t *window = (gui_window_t *)malloc(sizeof(gui_window_t));
    if (!window)
        return NULL;

    window->x = 10;
    window->y = 10;
    window->width = 800;
    window->height = 600;
    window->content_size = 0;
    window->content_capacity = 4096;

    // Copy title
    int i = 0;
    while (i < 63 && title[i])
    {
        window->title[i] = title[i];
        i++;
    }
    window->title[i] = '\0';

    window->content = (char *)malloc(window->content_capacity);
    return window;
}

// Append text to editor
void ide_append_text(gui_window_t *window, const char *text)
{
    uint32_t len = 0;
    while (text[len])
        len++;

    if (window->content_size + len >= window->content_capacity)
    {
        return; // Buffer full
    }

    for (uint32_t i = 0; i < len; i++)
    {
        window->content[window->content_size + i] = text[i];
    }
    window->content_size += len;
    window->content[window->content_size] = '\0';
}

// Save app code
uint32_t ide_save_app(gui_window_t *window, const char *app_name)
{
    return create_app(app_name, window->content);
}

// Display editor
void ide_display(gui_window_t *window)
{
    uart_puts("\n╔════════════════════════════════════════════╗\n");
    uart_puts("║  Create App - Python IDE                 ║\n");
    uart_puts("╚════════════════════════════════════════════╝\n\n");
    uart_puts("Current App Name: ");
    uart_puts(window->title);
    uart_puts("\n\n--- Code Editor ---\n");
    uart_puts(window->content);
    uart_puts("\n\n--- Commands ---\n");
    uart_puts("save - Save and create app\n");
    uart_puts("clear - Clear editor\n");
    uart_puts("exit - Exit editor\n\n");
}