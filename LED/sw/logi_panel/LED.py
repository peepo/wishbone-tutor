#!/usr/bin/env python

import pygame, sys, random, os , time
'''import constants used by pygame such as event type = QUIT'''
from pygame.locals import * 
# to use logiRead from wishbone
from logi import *

#DEFINES
SLEEP_TIME = .001

backgroundfile = "./img/brd/breadboard_800x293.png"
#LED VARIALBES
led_file_0 = "./img/led/led_clear_final.png"	#led image for logic 0
led_file_1 = "./img/led/led_blue_final.png"		#led image for logic 1
#LED LOCATIONS
#location of the virtual peripherals
LED_Y = 20
LEDX_SPACING = 50
LED1_X = 375
LED2_X = LED1_X + LEDX_SPACING
LED3_X = LED2_X + LEDX_SPACING
LED4_X = LED3_X + LEDX_SPACING
LED5_X = LED4_X + LEDX_SPACING
LED6_X = LED5_X + LEDX_SPACING
LED7_X = LED6_X + LEDX_SPACING
LED8_X = LED7_X + LEDX_SPACING

count = 0

'''Initialize pygame components'''
pygame.init()
'''Centres the pygame window. '''
os.environ['SDL_VIDEO_WINDOW_POS'] = 'center'
'''Set the window title'''
pygame.display.set_caption("LED Panel")
'''Initialize a display with width 370 and height 542 with 32 bit colour'''
screen = pygame.display.set_mode((800, 293), 0, 32)

#CONVERT IMAGES *********************************************
'''Convert images to a format that pygame understands'''
background = pygame.image.load(backgroundfile).convert()
led_high= pygame.image.load(led_file_1).convert_alpha()
led_low = pygame.image.load(led_file_0).convert_alpha()

while True:
	
	screen.blit(background, (0,0))

	#UPDATE THE LED DATA
	if (count & 0x80) :
		screen.blit(led_high, (LED1_X ,LED_Y))
	else :
		screen.blit(led_low, (LED1_X ,LED_Y))	
	if (count & 0x40) :
		screen.blit(led_high, (LED2_X ,LED_Y))
	else :
		screen.blit(led_low, (LED2_X ,LED_Y))
	if (count & 0x20) :
		screen.blit(led_high, (LED3_X ,LED_Y))
	else :
		screen.blit(led_low, (LED3_X ,LED_Y))
	if (count & 0x10) :
		screen.blit(led_high, (LED4_X ,LED_Y))
	else :
		screen.blit(led_low, (LED4_X ,LED_Y))
	if (count & 0x08) :
		screen.blit(led_high, (LED5_X ,LED_Y))
	else :
		screen.blit(led_low, (LED5_X ,LED_Y))
	if (count & 0x04) :
		screen.blit(led_high, (LED6_X ,LED_Y))
	else :
		screen.blit(led_low, (LED6_X ,LED_Y))
	if (count & 0x02) :
		screen.blit(led_high, (LED7_X ,LED_Y))
	else :
		screen.blit(led_low, (LED7_X ,LED_Y))
	if (count & 0x01) :
		screen.blit(led_high, (LED8_X ,LED_Y))
	else :
		screen.blit(led_low, (LED8_X ,LED_Y))

	#UPDATE THE DISPLAY
	pygame.display.update()

	count = logiRead(0x00, 2)[0]
	
	time.sleep(SLEEP_TIME)	#SLOW DOWN THE LOOP
