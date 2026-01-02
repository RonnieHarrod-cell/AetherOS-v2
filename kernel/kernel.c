#include <stdint.h>
#include <stddef.h>

// Memory definitions
#define UART_BASE 0x09000000

typedef struct
{
    uint32_t dr;  // Data Register
    uint32_t rsr; // Receive Status Register
    uint32_t reserved[4];
    uint32_t fr; // Flag Register
} uart_t;

volatile uart_t *uart = (uart_t *)UART_BASE;

void uart_putc(char c)
{
    while (uart->fr & (1 << 5))
        ; // Wait while transmit FIFO full
    uart->dr = (uint32_t)c;
}

void uart_puts(const char *str)
{
    while (*str)
    {
        uart_putc(*str);
        if (*str == '\n')
            uart_putc('\r');
        str++;
    }
}

// Simple malloc implementation
#define HEAP_SIZE 1024 * 1024 // 1MB heap
uint8_t kernel_heap[HEAP_SIZE];
uint32_t heap_ptr = 0;

void *malloc(size_t size)
{
    if (heap_ptr + size > HEAP_SIZE)
        return NULL;
    void *ptr = (void *)(&kernel_heap[heap_ptr]);
    heap_ptr += size;
    return ptr;
}

void free(void *ptr)
{
    // Simple implementation - no deallocation
    (void)ptr;
}

// Application structure
typedef struct
{
    char name[64];
    char *python_code;
    uint32_t code_size;
    uint8_t active;
} app_t;

#define MAX_APPS 100
app_t apps[MAX_APPS];
uint32_t app_count = 0;

// Create a new app
uint32_t create_app(const char *name, const char *code)
{
    if (app_count >= MAX_APPS)
        return 0;

    app_t *app = &apps[app_count];

    // Copy name
    int i = 0;
    while (i < 63 && name[i])
    {
        app->name[i] = name[i];
        i++;
    }
    app->name[i] = '\0';

    // Allocate and copy code
    app->code_size = 0;
    while (code[app->code_size])
        app->code_size++;

    app->python_code = (char *)malloc(app->code_size + 1);
    if (!app->python_code)
        return 0;

    for (uint32_t j = 0; j <= app->code_size; j++)
    {
        app->python_code[j] = code[j];
    }

    app->active = 1;
    return app_count++;
}

// List all apps
void list_apps()
{
    uart_puts("\n=== Installed Apps ===\n");
    for (uint32_t i = 0; i < app_count; i++)
    {
        uart_puts("App ");
        uart_puts(apps[i].name);
        uart_puts(" - Code size: ");

        // Print number
        uint32_t size = apps[i].code_size;
        char num[20];
        int idx = 0;
        if (size == 0)
        {
            num[idx++] = '0';
        }
        else
        {
            uint32_t temp = size;
            while (temp)
            {
                num[19 - idx] = (temp % 10) + '0';
                temp /= 10;
                idx++;
            }
            for (int j = 0; j < idx; j++)
            {
                uart_putc(num[20 - idx + j]);
            }
        }
        uart_puts(" bytes\n");
    }
}

// Main kernel function
void kernel_main()
{
    uart_puts("========================================\n");
    uart_puts("ARM64 OS with Python IDE - Booting...\n");
    uart_puts("========================================\n\n");

    uart_puts("[*] System initialized\n");
    uart_puts("[*] Kernel loaded\n");
    uart_puts("[*] Python IDE ready\n\n");

    // Create default app
    const char *hello_app = "import sys\nprint('Hello from ARM64 OS!')";
    create_app("HelloApp", hello_app);

    list_apps();

    uart_puts("\n[*] System ready for input\n");
    uart_puts("[*] Commands:  list, create <name>, run <name>\n\n");
}