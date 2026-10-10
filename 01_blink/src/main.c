#include <stdio.h>
#include <zephyr/kernel.h>
// #include <zephyr/device.h>
#include <zephyr/drivers/gpio.h>
// #include <zephyr/drivers/watchdog.h>

// Feather ESP32: 
// - JTAG Debugging uses pins 12, 13, 14 & 15
// - Do not use built-in LED, which is on pin 13!

// Settings
static const int32_t sleep_time_ms = 1000;
// static const struct gpio_dt_spec led = GPIO_DT_SPEC_GET(DT_ALIAS(my_led), gpios);

// static void disable_watchdogs(void)
// {
// #if defined(CONFIG_WATCHDOG) && DT_NODE_HAS_STATUS(DT_NODELABEL(wdt0), okay)
// 	{
// 		const struct device *wdt = DEVICE_DT_GET(DT_NODELABEL(wdt0));
// 		if (device_is_ready(wdt)) {
// 			int ret = wdt_disable(wdt);
// 			printk("wdt0 disable: %d\n", ret);
// 		} else {
// 			printk("wdt0 not ready\n");
// 		}
// 	}
// #endif

// #if defined(CONFIG_WATCHDOG) && DT_NODE_HAS_STATUS(DT_NODELABEL(wdt1), okay)
// 	{
// 		const struct device *wdt = DEVICE_DT_GET(DT_NODELABEL(wdt1));
// 		if (device_is_ready(wdt)) {
// 			int ret = wdt_disable(wdt);
// 			printk("wdt1 disable: %d\n", ret);
// 		} else {
// 			printk("wdt1 not ready\n");
// 		}
// 	}
// #endif
// }

int main(void)
{
	printk(">>> main() entered\n");
	int state = 0;

	// disable_watchdogs();

	// Make sure that the GPIO was initialized
	// if (!gpio_is_ready_dt(&led)) {
	// 	return 0;
	// }

	// Set the GPIO as output
	// ret = gpio_pin_configure_dt(&led, GPIO_OUTPUT);
	// if (ret < 0) {
	// 	return 0;
	// }

	// Do forever
	while (1) {

		// Change the state of the pin and print
		state = !state;
		printk("LED state: %d\r\n", state);
		
		// Set pin state
		// ret = gpio_pin_set_dt(&led, state);
		// if (ret < 0) {
		// 	return 0;
		// }

		// Sleep
		k_msleep(sleep_time_ms);
	}

	return 0;
}
