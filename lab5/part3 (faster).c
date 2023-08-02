/* This files provides address values that exist in the system */

#define SDRAM_BASE            0xC0000000
#define FPGA_ONCHIP_BASE      0xC8000000
#define FPGA_CHAR_BASE        0xC9000000

/* Cyclone V FPGA devices */
#define LEDR_BASE             0xFF200000
#define HEX3_HEX0_BASE        0xFF200020
#define HEX5_HEX4_BASE        0xFF200030
#define SW_BASE               0xFF200040
#define KEY_BASE              0xFF200050
#define TIMER_BASE            0xFF202000
#define PIXEL_BUF_CTRL_BASE   0xFF203020
#define CHAR_BUF_CTRL_BASE    0xFF203030

/* VGA colors */
#define WHITE 0xFFFF
#define YELLOW 0xFFE0
#define RED 0xF800
#define GREEN 0x07E0
#define BLUE 0x001F
#define CYAN 0x07FF
#define MAGENTA 0xF81F
#define GREY 0xC618
#define PINK 0xFC18
#define ORANGE 0xFC00

#define ABS(x) (((x) > 0) ? (x) : -(x))

/* Screen size. */
#define RESOLUTION_X 320
#define RESOLUTION_Y 240

/* Constants for animation */
#define BOX_LEN 2
#define NUM_BOXES 8

#define FALSE 0
#define TRUE 1

#include <stdlib.h>
#include <stdio.h>

// Begin part3.c code for Lab 7
volatile int pixel_buffer_start; // global variable
volatile int * pixel_ctrl_ptr = (int *)0xFF203020;

int x_pos [8];
int y_pos [8];

int x_inc [8];
int y_inc [8];
short int colour [10] ={WHITE,YELLOW,RED,GREEN,BLUE,CYAN,MAGENTA,GREY,PINK,ORANGE};
int x_pre_pos [8] = {0};
int y_pre_pos [8] = {0};
int x_two_frame [8] = {0};
int y_two_frame [8] = {0};

void plot_pixel(int x1,int y1, short int pixel_colour);
void draw_rectangle(int x_pos,int y_pos,short int colour);
void draw_line(int x0, int y0, int x1, int y1, short int line_colour);
void clear_line(int x0, int y0, int x1, int y1);
void clear_screen();
void swap(int * a, int * b);
void wait_for_vsync();
void randomize(int *x_pos,int *y_pos,int *x_inc,int *y_inc, short int *colour);

int main(void)
{
	srand(time(NULL));
    // initialize location and direction of rectangles(not shown)
	randomize(x_pos, y_pos, x_inc, y_inc,colour);
    /* set front pixel buffer to start of FPGA On-chip memory */
    *(pixel_ctrl_ptr + 1) = 0xC8000000; // first store the address in the 
                                        // back buffer
    /* now, swap the front/back buffers, to set the front buffer location */
    wait_for_vsync();
    /* initialize a pointer to the pixel buffer, used by drawing functions */
    pixel_buffer_start = *pixel_ctrl_ptr;
    clear_screen(); // pixel_buffer_start points to the pixel buffer
    /* set back pixel buffer to start of SDRAM memory */
    *(pixel_ctrl_ptr + 1) = 0xC0000000;
    pixel_buffer_start = *(pixel_ctrl_ptr + 1); // we draw on the back buffer
    clear_screen(); // pixel_buffer_start points to the pixel buffer

    while (1)
    {
        /* Erase any boxes and lines that were drawn in the last iteration */
		for(int i = 0; i < 8; i++){
			draw_rectangle(x_two_frame[i], y_two_frame[i], 0x0);
			if(i==7)
				clear_line(x_two_frame[i], y_two_frame[i], x_two_frame[0], y_two_frame[0]);
			else
				clear_line(x_two_frame[i], y_two_frame[i], x_two_frame[i+1], y_two_frame[i+1]);
		}
        // code for drawing the boxes and lines
		for(int i = 0; i < 8; i++){
			draw_rectangle(x_pos[i], y_pos[i], WHITE);
			if(i==7)
				draw_line(x_pos[i], y_pos[i], x_pos[0], y_pos[0], colour[i]);
			else
				draw_line(x_pos[i], y_pos[i], x_pos[i+1], y_pos[i+1], colour[i]);
		}
        // code for updating the locations of boxes
		for(int i = 0; i < 8; i++){
			if(x_pos[i] == 319)
				x_inc[i] = -1;
			if(x_pos[i] == 0)
				x_inc[i] = 1;
			if(y_pos[i] == 239)
				y_inc[i] = -1;
			if(y_pos[i] == 0)
				y_inc[i] = 1;
			
			x_two_frame[i] = x_pre_pos[i];
			y_two_frame[i] = y_pre_pos[i];
			x_pre_pos[i] = x_pos[i];
			y_pre_pos[i] = y_pos[i];
			x_pos[i] += x_inc[i];
			y_pos[i] += y_inc[i];
		}
        wait_for_vsync(); // swap front and back buffers on VGA vertical sync
        pixel_buffer_start = *(pixel_ctrl_ptr + 1); // new back buffer
    }
	return 0;
}

void randomize(int *x_pos,int *y_pos,int *x_inc,int *y_inc, short int *colour){
	for(int i = 0; i < 8; i++){
		x_pos[i] = rand() % (319 + 1 + 0) - 0;
		y_pos[i] = rand() % (239 +1 + 0) - 0;
		x_inc[i] = rand() % 2 * 2 - 1;
		y_inc[i] = rand() % 2 * 2 - 1;
	}
	for(int i = 0; i < 10; i++)
		colour[i] = colour[rand() %10];
}

void wait_for_vsync(){
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
	volatile int * status = (int*)0xFF20302C;
	
	*pixel_ctrl_ptr = 1;
	
	// when S bit is 1, keep reading. wait for synchronization time, until S = 0
	while((*status & 0x01) == 1)
		status = status;
	
	return ;

}

void draw_rectangle(int x_pos,int y_pos,short int colour){
	for(int i = 0; i < 2; i++){
		for(int j = 0; j < 2; j++){
			plot_pixel(x_pos,y_pos, colour);
			j++;
		}
		i++;
	}
}

void clear_line(int x0, int y0, int x1, int y1){
	draw_line(x0, y0, x1, y1, 0x0); //draw the line black
}

void draw_line(int x0, int y0, int x1, int y1, short int line_colour) {

	//initialize is_steep
	int is_steep = FALSE;

	//figure out if the line is steep
	if (ABS(y1 - y0) > ABS(x1 - x0)) is_steep = TRUE;

	if (is_steep) {// swap x and y if the line is steep
		swap(&x1, &y1);
		swap(&x0, &y0);
	}

	if (x0 > x1) { //swap pos of the two points if point2 is before point1
		swap(&x0, &x1);
		swap(&y0, &y1);
	}

	int deltax = x1 - x0;
	int deltay = ABS(y1 - y0);//make delta y postive 

	int error = -(deltax / 2);
	int y_draw = y0;
	int y_step;

	// determine the line goes up or down
	if (y0 < y1)
		y_step = 1;
	else
		y_step = -1;

	for (int x_draw = x0; x_draw <= x1; x_draw++) {
		if (is_steep)
			plot_pixel(y_draw, x_draw, line_colour);
		else
			plot_pixel(x_draw, y_draw, line_colour);

		error += deltay;

		if (error >= 0) { //position is closer to the upper or lower pixal
			y_draw += y_step;
			error -= deltax;
		}
	}

}

void clear_screen(){
//set the colour of each pixel to black	
	for(int x = 0; x<320; x++){
		for(int y = 0; y < 240; y++)
			plot_pixel(x, y, 0x0000);
	}
} 

void plot_pixel(int x, int y, short int line_color)
{
    *(short int *)(pixel_buffer_start + (y << 10) + (x << 1)) = line_color;
}

void swap(int *a, int *b){
	int temp = *a;
	*a = *b;
	*b = temp;
}