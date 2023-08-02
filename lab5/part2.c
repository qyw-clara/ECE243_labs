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
//#include <stdbool.h>

// Begin part2.s for Lab 7
volatile int pixel_buffer_start; // global variable

void plot_pixel(int x1,int y1, short int pixel_colour);
void draw_line(int x0, int y0, int x1, int y1, short int line_colour);
void clear_screen();
void swap(int * a, int * b);
void wait();

int main(void)
{
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
    /* Read location of the pixel buffer from the pixel buffer controller */
    pixel_buffer_start = *pixel_ctrl_ptr;
	
	int x0 = 30;
	int x1 = 300;
	int ypos = 0;
	int increment = 1;
	
    clear_screen();
	
	while(1){
    	draw_line(x0, ypos, x1, ypos, YELLOW);   // draw a yellow line
		
		wait();
		
		draw_line(x0, ypos, x1, ypos, 0x0000); //erase the line
		
		if(ypos == 0) // if the line reaches the top, moves downward
			increment = 1;
		if(ypos == 239)// if the line reaches the bottom, moves upward
			increment = -1;
		ypos += increment;
		
	}
	return 0;
}

void wait(){
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
	volatile int * status = (int*)0xFF20302C;
	
	*pixel_ctrl_ptr = 1;
	
	// when S bit is 1, keep reading. wait for synchronization time, until S = 0
	while((*status & 0x01) == 1)
		status = status;
	
	return;

}

void draw_line(int x0, int y0, int x1, int y1, short int line_colour){

	//initialize is_steep
    int is_steep = FALSE; 
	
	//figure out if the line is steep
    if (ABS(y1 - y0) > ABS(x1 - x0)) is_steep = TRUE;
	
	if(is_steep){// swap x and y if the line is steep
		swap(&x1, &y1);
		swap(&x0, &y0);
	}
	
	if(x0 > x1){ //swap pos of the two points if point2 is before point1
		swap(&x0, &x1);
		swap(&y0, &y1);
	}
	
	int deltax = x1-x0;
	int deltay = ABS(y1-y0);//make delta y postive 
	
	int error = -(deltax / 2);
	int y_draw = y0;
	int y_step;
	
	// determine the line goes up or down
	if(y0 < y1) 
		y_step = 1;
	else
		y_step = -1;
	
	for(int x_draw = x0; x_draw <= x1; x_draw++){
		if(is_steep)
			plot_pixel(y_draw,x_draw, line_colour);
		else
			plot_pixel(x_draw, y_draw, line_colour);
		
		error += deltay;
		
		if(error >= 0){ //position is closer to the upper or lower pixal
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