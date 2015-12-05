import sys, pygame
from pygame.locals import *

import pygame.mixer


	
pygame.display.set_mode((120, 120), DOUBLEBUF | HWSURFACE)

pygame.init()

sound1 = pygame.mixer.Sound('sound1.wav')
sound2 = pygame.mixer.Sound('sound2.mp3')
sound3 = pygame.mixer.Sound('sound3.mp3')
sound4 = pygame.mixer.Sound('sound4.mp3')
sound5 = pygame.mixer.Sound('sound5.wav')
sound6 = pygame.mixer.Sound('sound6.wav')
sound7 = pygame.mixer.Sound('sound7.wav')
sound8 = pygame.mixer.Sound('sound8.wav')
#pygame.mixer.music.load('68448__pinkyfinger__piano-g.wav')

#pygame.mixer.Sound.play(crash_sound)

#time.sleep(4)
#print 'Music stops'

    
    
    
pygame.init()

display_width = 800
display_height = 600

gameDisplay = pygame.display.set_mode((display_width,display_height))
pygame.display.set_caption('MniBlip sound player')

black = (0,0,0)
white = (255,255,255)

clock = pygame.time.Clock()
crashed = False
carImg = pygame.image.load('car.png')

def car(x,y):
    gameDisplay.blit(carImg, (x,y))

x =  (display_width * 0.45)
y = (display_height * 0.8)
x_change = 0
car_speed = 0

while not crashed:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            crashed = True

        ############################
        if event.type == pygame.KEYDOWN:
            if event.key == pygame.K_LEFT:
                x_change = -5
                pygame.mixer.Sound.play(sound1)
            elif event.key == pygame.K_RIGHT:
				#x_change = + 5
                pygame.mixer.Sound.play(sound2)
            elif event.key == pygame.K_RIGHT:
                pygame.mixer.Sound.play(sound3)
            elif event.key == pygame.K_RIGHT:
                pygame.mixer.Sound.play(sound4)
            elif event.key == pygame.K_RIGHT:
				pygame.mixer.Sound.play(sound5)
            elif event.key == pygame.K_RIGHT:
                pygame.mixer.Sound.play(sound6)
            elif event.key == pygame.K_RIGHT:
                pygame.mixer.Sound.play(sound7)
            elif event.key == pygame.K_RIGHT:
                pygame.mixer.Sound.play(sound8)
                
                
        if event.type == pygame.KEYUP:
            if event.key == pygame.K_LEFT or event.key == pygame.K_RIGHT:
                x_change = 0
        ######################
    ##
    x += x_change
   ##         
    gameDisplay.fill(white)
    car(x,y)
        
    pygame.display.update()
    clock.tick(60)

pygame.quit()
quit()
