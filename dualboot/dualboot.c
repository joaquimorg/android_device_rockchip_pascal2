/*
 * Copyright (C) 2013 joaquim.org
 *
 */

#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <linux/input.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/poll.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/un.h>
#include <time.h>
#include <unistd.h>
#include <pthread.h>

#include <sys/socket.h>
#include <linux/netlink.h>

#include <cutils/android_reboot.h>
#include <cutils/klog.h>
#include <cutils/list.h>
#include <cutils/misc.h>
#include <cutils/uevent.h>

#include "minui/minui.h"



#if 1
#define LOGE(x...) do { KLOG_ERROR("dualboot", x); } while (0)
#define LOGI(x...) do { KLOG_INFO("dualboot", x); } while (0)
#define LOGV(x...) do { KLOG_DEBUG("dualboot", x); } while (0)
#else
#define LOG_NDEBUG 0
#define LOG_TAG "dualboot"
#include <cutils/log.h>
#endif

#define UI_WAIT_KEY_TIMEOUT_SEC    3600

int __system(const char *command);

static int char_width;
static int char_height;

static int bootoption = 0;

static pthread_mutex_t gUpdateMutex = PTHREAD_MUTEX_INITIALIZER;

// Key event input queue
static pthread_mutex_t key_queue_mutex = PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t key_queue_cond = PTHREAD_COND_INITIALIZER;
static int key_queue[256], key_queue_len = 0;
static volatile char key_pressed[KEY_MAX + 1];


// Bitmaps
static gr_surface gBackground;
static gr_surface gbt1Selected;
static gr_surface gbt2Selected;
static const struct { gr_surface* surface; const char *name; } BITMAPS[] = {
    { &gBackground,		"dualboot" },
	{ &gbt1Selected,	"bt1_selected" },
	{ &gbt2Selected,	"bt2_selected" },
    { NULL,				NULL },
};

static int draw_text(const char *str, int x, int y)
{
    int str_len_px = gr_measure(str);

    if (x < 0)
        x = (gr_fb_width() - str_len_px) / 2;
    if (y < 0)
        y = (gr_fb_height() - char_height) / 2;
    
    gr_color(0xff, 0xff, 0xff, 255);
    gr_text(x, y, str);

    return y + char_height;
}

static void android_green(void)
{
    gr_color(0xa4, 0xc6, 0x39, 255);
}


static void draw_surface(int x, int y, gr_surface surface)
{
    int w;
    int h;

    w = gr_get_width(surface);
    h = gr_get_height(surface);
   
    //LOGV("drawing surface %dx%d+%d+%d\n", w, h, x, y);
    gr_blit(surface, 0, 0, w, h, x, y);
    
}

static void clear_screen(void)
{
    gr_color(0, 0, 0, 255);
    //gr_color(0xa4, 0xc6, 0x39, 255);
    //gr_fill(0, 0, gr_fb_width(), gr_fb_height());
	draw_surface(0, 0, gBackground);
};

// ---------------------------------------------------------------------------------------------

static int btAction(int x, int y) {
	if ( (x > 150) && (x < 270) && (y > 125) && (y < 215) ) {
		return 1;
	}
	
	if ( (x > 150) && (x < 270) && (y > 250) && (y < 340) ) {
		return 2;
	}
	
	if ( (x > 560) && (x < 750) && (y > 400) && (y < 450) ) {
		return 3;
	}
	
	return 0;
}


// ---------------------------------------------------------------------------------------------

static int rel_sum = 0;
static int in_touch = 0; //1 = in a touch
static int slide_right = 0;
static int slide_left = 0;
static int touch_x = 0;
static int touch_y = 0;
static int old_x = 0;
static int old_y = 0;
static int diff_x = 0;
static int diff_y = 0;

static void reset_gestures() {
    diff_x = 0;
    diff_y = 0;
    old_x  = 0;
    old_y = 0;
    touch_x = 0;
    touch_y = 0;
}

static int input_callback(int fd, short revents, void *data)
{

	struct input_event ev;
    int ret;
    int fake_key = 0;    

    ret = ev_get_input(fd, revents, &ev);
    if (ret)
        return -1;

 	if (ev.type == EV_SYN) {
        return 0;
    } else if (ev.type == EV_REL) {
        if (ev.code == REL_Y) {
            // accumulate the up or down motion reported by
            // the trackball.  When it exceeds a threshold
            // (positive or negative), fake an up/down
            // key event.
            rel_sum += ev.value;
            if (rel_sum > 3) {
                fake_key = 1;
                ev.type = EV_KEY;
                ev.code = KEY_DOWN;
                ev.value = 1;
                rel_sum = 0;
            } else if (rel_sum < -3) {
                fake_key = 1;
                ev.type = EV_KEY;
                ev.code = KEY_UP;
                ev.value = 1;
                rel_sum = 0;
            }
        }
    } else {
        rel_sum = 0;
    }

	if (ev.type == 3 && ev.code == 57 && ev.value != -1) {
        if (in_touch == 0) {
            in_touch = 1; //starting to track touch...
            reset_gestures();
        }
    } else if (ev.type == 3 && ev.code == 57 && ev.value == -1) {
            //finger lifted! lets run with this
            ev.type = EV_KEY; //touch panel support!!!

            ev.value = 1;
            in_touch = 0;
            //reset_gestures();
    } else if (ev.type == 3 && ev.code == 53) {
        old_x = touch_x;
        touch_x = ev.value;
        if (old_x != 0)
            diff_x += touch_x - old_x;

	 
    } else if (ev.type == 3 && ev.code == 54) {
        old_y = touch_y;
        touch_y = ev.value;
        if (old_y != 0)
            diff_y += touch_y - old_y;

    }

    if (ev.type != EV_KEY || ev.code > KEY_MAX)
        return 0;

    pthread_mutex_lock(&key_queue_mutex);
    if (!fake_key) {
        // our "fake" keys only report a key-down event (no
        // key-up), so don't record them in the key_pressed
        // table.
        key_pressed[ev.code] = ev.value;
    }
    const int queue_max = sizeof(key_queue) / sizeof(key_queue[0]);
    if (ev.value > 0 && key_queue_len < queue_max) {
        key_queue[key_queue_len++] = ev.code;

        pthread_cond_signal(&key_queue_cond);
    }
    pthread_mutex_unlock(&key_queue_mutex);

	return 0;
}


int ui_wait_key()
{
    pthread_mutex_lock(&key_queue_mutex);

    // Time out after UI_WAIT_KEY_TIMEOUT_SEC
    do {
        struct timeval now;
        struct timespec timeout;
        gettimeofday(&now, NULL);
        timeout.tv_sec = now.tv_sec;
        timeout.tv_nsec = now.tv_usec * 1000;
        timeout.tv_sec += UI_WAIT_KEY_TIMEOUT_SEC;

        int rc = 0;
        while (key_queue_len == 0 && rc != ETIMEDOUT) {
            rc = pthread_cond_timedwait(&key_queue_cond, &key_queue_mutex,
                                        &timeout);
        }
    } while (key_queue_len == 0);

    int key = -1;
    if (key_queue_len > 0) {
        key = key_queue[0];
        memcpy(&key_queue[0], &key_queue[1], sizeof(int) * --key_queue_len);
    }
    pthread_mutex_unlock(&key_queue_mutex);
    return key;
}

static void event_loop()
{

	//char text[40];
	int action;

    while (true) {
		int key = ui_wait_key();

		//sprintf(text, "Keydown %d %d:%d", key, touch_x, touch_y);        
		clear_screen();
		//draw_text(text, 140, 460); 
		//draw_text("*", touch_x, touch_y);		

        switch (key) {
			case 57:
				action = btAction(touch_x, touch_y);
				switch (action) {
					case 0 :
						bootoption = 0;
						break;
					case 1 :
						draw_surface(150, 125, gbt1Selected);
						bootoption = 1;
						break;
					case 2 :
						draw_surface(150, 250, gbt2Selected);
						bootoption = 2;
						break;
					case 3 :
						if ( bootoption != 0) {
							return;
						}
						break;
				}
				break;
			case 116:
                return;
                break;
		}
				
		gr_flip();

    }
}


// Reads input events, handles special hot keys, and adds to the key queue.
static void *input_thread(void *cookie)
{
    for (;;) {
        if (!ev_wait(-1))
            ev_dispatch();
    }
    return NULL;
}

int main(int argc, char **argv)
{

    LOGI("--------------- STARTING DUALBOOT MODE ---------------\n");

    gr_init();
    gr_font_size(&char_width, &char_height);	

	clear_screen();
    draw_text("RK2918 Dualboot - Loading...", 10, 40); 
    gr_flip();
	
	int i;
    for (i = 0; BITMAPS[i].name != NULL; ++i) {
        int result = res_create_surface(BITMAPS[i].name, BITMAPS[i].surface);
        if (result < 0) {
            printf("Missing bitmap %s\n(Code %d)\n", BITMAPS[i].name, result);
        }
    }

	clear_screen();    
    gr_flip();
	
	ev_init(input_callback, NULL);
	
	pthread_t t;
	pthread_create(&t, NULL, input_thread, NULL);

	event_loop();

	clear_screen();
	draw_text("Exit to boot....", 570, 380); 
	gr_flip();

	gr_exit();
	ev_exit();
	
    return bootoption;
}
