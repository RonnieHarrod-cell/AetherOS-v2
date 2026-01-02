#include <stdint.h>
#include <stddef.h>

// Forward declarations
extern void uart_puts(const char *str);
extern void uart_putc(char c);
extern uint32_t create_app(const char *name, const char *code);
extern void list_apps();
extern gui_window_t *ide_create_window(const char *title);
extern void ide_append_text(gui_window_t *window, const char *text);
extern uint32_t ide_save_app(gui_window_t *window, const char *app_name);
extern void ide_display(gui_window_t *window);

char input_buffer[1024];
uint32_t input_idx = 0;

void read_line()
{
    input_idx = 0;
    while (1)
    {
        // Read character (simulated)
        char c = '\n'; // Placeholder

        if (c == '\n' || c == '\r')
        {
            input_buffer[input_idx] = '\0';
            uart_putc('\n');
            break;
        }
        else if (c == '\b')
        {
            if (input_idx > 0)
            {
                input_idx--;
                uart_putc('\b');
                uart_putc(' ');
                uart_putc('\b');
            }
        }
        else
        {
            if (input_idx < 1023)
            {
                input_buffer[input_idx++] = c;
                uart_putc(c);
            }
        }
    }
}

void handle_command()
{
    if (input_buffer[0] == 'l' && input_buffer[1] == 'i')
    {
        list_apps();
    }
    else if (input_buffer[0] == 'c' && input_buffer[1] == 'r')
    {
        uart_puts("\n[*] Opening Create App IDE...\n");

        gui_window_t *editor = ide_create_window("NewApp");
        if (editor)
        {
            ide_append_text(editor, "# Your Python code here\nprint('Hello World')");
            ide_display(editor);
        }
    }
    else if (input_buffer[0] == 'h' && input_buffer[1] == 'e')
    {
        uart_puts("\n=== Available Commands ===\n");
        uart_puts("list   - List all apps\n");
        uart_puts("create - Open Create App IDE\n");
        uart_puts("help   - Show this help\n");
        uart_puts("exit   - Shutdown system\n\n");
    }
}

void main_loop()
{
    uart_puts("root@arm64-os:~# ");
}