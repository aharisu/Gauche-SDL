/*
    SDL_Collide:  A 2D collision detection library for use with SDL
    
    MIT License
    Copyright 2005-2006 SDL_collide Team
    http://sdl-collide.sourceforge.net
    All rights reserved.
    
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
    
    Amir Taaki
    genjix@gmail.com
    
    Rob Loach
    http://robloach.net
*/

#include "SDL_collide.h"

/*returns maximum or minimum of number*/
#define SDL_COLLIDE_MAX(a,b)	((a > b) ? a : b)
#define SDL_COLLIDE_MIN(a,b)	((a < b) ? a : b)

/*
	SDL surface test if offset (u,v) is a transparent pixel
*/
int SDL_CollideTransparentPixel(SDL_Surface *surface , int u , int v)
{
	if(SDL_MUSTLOCK(surface))
		SDL_LockSurface(surface);

	int bpp = surface->format->BytesPerPixel;
	/*here p is the address to the pixel we want to retrieve*/
	Uint8 *p = (Uint8 *)surface->pixels + v * surface->pitch + u * bpp;

	Uint32 pixelcolor;

	switch(bpp)
	{
		case(1):
			pixelcolor = *p;
		break;

		case(2):
			pixelcolor = *(Uint16 *)p;
		break;

		case(3):
			if(SDL_BYTEORDER == SDL_BIG_ENDIAN)
				pixelcolor = p[0] << 16 | p[1] << 8 | p[2];
			else
				pixelcolor = p[0] | p[1] << 8 | p[2] << 16;
		break;

		case(4):
			pixelcolor = *(Uint32 *)p;
		break;
	}

	if(SDL_MUSTLOCK(surface))
		SDL_UnlockSurface(surface);
	/*test whether pixels color == color of transparent pixels for that surface*/
	return (pixelcolor == surface->format->colorkey);
}

/*
	SDL pixel perfect collision test
*/
int SDL_CollidePixel(SDL_Surface *as , int ax , int ay ,
                       SDL_Surface *bs , int bx , int by, int skip)
{
	/*a - bottom right co-ordinates in world space*/
	int ax1 = ax + as->w - 1;
	int ay1 = ay + as->h - 1;

	/*b - bottom right co-ordinates in world space*/
	int bx1 = bx + bs->w - 1;
	int by1 = by + bs->h - 1;

	/*check if bounding boxes intersect*/
	if((bx1 < ax) || (ax1 < bx))
		return 0;
	if((by1 < ay) || (ay1 < by))
		return 0;

/*Now lets make the bouding box for which we check for a pixel collision*/

	/*To get the bounding box we do
            Ax1,Ay1______________
                |                |
                |                |
                |                |
                |    Bx1,By1____________
                |        |       |      |
                |        |       |      |
                |________|_______|      |
                         |    Ax2,Ay2   |
                         |              |
                         |              |
                         |___________Bx2,By2

	To find that overlap we find the biggest left hand cordinate
	AND the smallest right hand co-ordinate

	To find it for y we do the biggest top y value
	AND the smallest bottom y value

	Therefore the overlap here is Bx1,By1 --> Ax2,Ay2

	Remember	Ax2 = Ax1 + SA->w
			Bx2 = Bx1 + SB->w

			Ay2 = Ay1 + SA->h
			By2 = By1 + SB->h
	*/

	/*now we loop round every pixel in area of
	intersection
		if 2 pixels alpha values on 2 surfaces at the
		same place != 0 then we have a collision*/
	int xstart = SDL_COLLIDE_MAX(ax,bx);
	int xend = SDL_COLLIDE_MIN(ax1,bx1);

	int ystart = SDL_COLLIDE_MAX(ay,by);
	int yend = SDL_COLLIDE_MIN(ay1,by1);

  if(SDL_MUSTLOCK(as))
   SDL_LockSurface(as);
  if(SDL_MUSTLOCK(bs))
   SDL_LockSurface(bs);

  int a_bpp = as->format->BytesPerPixel;
  int b_bpp = bs->format->BytesPerPixel;

  int ret = 0;
	for(int y = ystart ; y <= yend ; y += skip)
	{
		for(int x = xstart ; x <= xend ; x += skip)
		{
      Uint8* a_p = (Uint8*)as->pixels + (y-ay) * as->pitch + (x-ax) * a_bpp;
      Uint8* b_p = (Uint8*)bs->pixels + (y-by) * bs->pitch + (x-bx) * b_bpp;

      Uint32 a_pixelcolor;
      Uint32 b_pixelcolor;
      switch(a_bpp)
      {
        case 1:
          a_pixelcolor = *a_p;
          break;
        case 2:
          a_pixelcolor = *(Uint16*)a_p;
          break;
        case 3:
          if(SDL_BYTEORDER == SDL_BIG_ENDIAN)
            a_pixelcolor = a_p[0] << 16 | a_p[1] << 8 | a_p[2];
          else
            a_pixelcolor = a_p[0] | a_p[1] << 8 | a_p[2] << 16;
          break;
        case 4:
          a_pixelcolor = *(Uint32*)a_p;
          break;
      }
      switch(b_bpp)
      {
        case 1:
          b_pixelcolor = *b_p;
          break;
        case 2:
          b_pixelcolor = *(Uint16*)b_p;
          break;
        case 3:
          if(SDL_BYTEORDER == SDL_BIG_ENDIAN)
            b_pixelcolor = b_p[0] << 16 | b_p[1] << 8 | b_p[2];
          else
            b_pixelcolor = b_p[0] | b_p[1] << 8 | b_p[2] << 16;
          break;
        case 4:
          b_pixelcolor = *(Uint32*)b_p;
          break;
      }

      if(a_pixelcolor != as->format->colorkey &&
          b_pixelcolor != bs->format->colorkey)
      {
        ret = 1;
        goto FINISH;
      }
		}
	}
FINISH:

  if(SDL_MUSTLOCK(as))
   SDL_UnlockSurface(as);
  if(SDL_MUSTLOCK(bs))
   SDL_UnlockSurface(bs);

	return ret;
}

/*
	SDL bounding box collision test
*/
int SDL_CollideBoundingBoxSurface(SDL_Surface *sa , int ax , int ay ,
                             SDL_Surface *sb , int bx , int by)
{
	if(bx + sb->w < ax)	return 0;	//just checking if their
	if(bx > ax + sa->w)	return 0;	//bounding boxes even touch

	if(by + sb->h < ay)	return 0;
	if(by > ay + sa->h)	return 0;

	return 1;				//bounding boxes intersect
}

/*
	SDL bounding box collision tests (works on SDL_Rect's)
*/
int SDL_CollideBoundingBoxRect(SDL_Rect a , SDL_Rect b)
{
	if(b.x + b.w < a.x)	return 0;	//just checking if their
	if(b.x > a.x + a.w)	return 0;	//bounding boxes even touch

	if(b.y + b.h < a.y)	return 0;
	if(b.y > a.y + a.h)	return 0;

	return 1;				//bounding boxes intersect
}

/*
	tests whether 2 circles intersect

	circle1 : centre (x1,y1) with radius r1
	circle2 : centre (x2,y2) with radius r2
	
	(allow distance between circles of offset)
*/
int SDL_CollideBoundingCircle(int x1 , int y1 , int r1 ,
                                 int x2 , int y2 , int r2 , int offset)
{
	int xdiff = x2 - x1;	// x plane difference
	int ydiff = y2 - y1;	// y plane difference
	
	/* distance between the circles centres squared */
	int dcentre_sq = (ydiff*ydiff) + (xdiff*xdiff);
	
	/* calculate sum of radiuses squared */
	int r_sum_sq = r1 + r2;	// square on seperate line, so
	r_sum_sq *= r_sum_sq;	// dont recompute r1 + r2

	return (dcentre_sq - r_sum_sq <= (offset*offset));
}

/*
	a circle intersection detection algorithm that will use
	the position of the centre of the surface as the centre of
	the circle and approximate the radius using the width and height
	of the surface (for example a rect of 4x6 would have r = 2.5).
*/
int SDL_CollideBoundingCircleSurface(SDL_Surface *a , int x1 , int y1 ,
                                 SDL_Surface *b , int x2 , int y2 ,
                                   int offset)
{
	/* if radius is not specified
	we approximate them using SDL_Surface's
	width and height average and divide by 2*/
	int r1 = (a->w + a->h) / 4;	// same as / 2) / 2;
	int r2 = (b->w + b->h) / 4;

	x1 += a->w / 2;		// offset x and y
	y1 += a->h / 2;		// co-ordinates into
				// centre of image
	x2 += b->w / 2;
	y2 += b->h / 2;

	return SDL_CollideBoundingCircle(x1,y1,r1,x2,y2,r2,offset);
}


typedef struct _SDL_CollideMaskRec {
  int w;
  int h;
  Uint8* mask;
}_SDL_CollideMask;

SDL_CollideMask SDL_CollideCreateMask(SDL_Surface* s)
{
  int x,y;
  SDL_CollideMask mask = (SDL_CollideMask)SDL_malloc(sizeof(_SDL_CollideMask));
  mask->w = s->w;
  mask->h = s->h;
  mask->mask = (Uint8*)SDL_malloc(mask->h * mask->w);

  for(y = 0;y < s->h;++y) {
    for(x = 0;x < s->w;++x) {
      Uint8* pixel = (Uint8*)s->pixels + y * s->pitch + x * s->format->BytesPerPixel;
      Uint32 color;

      switch(s->format->BytesPerPixel) {
        case 1:
          color = *pixel;
          break;
        case 2:
          color = *(Uint16*)pixel;
          break;
        case 3:
          if(SDL_BYTEORDER == SDL_BIG_ENDIAN)
            color = pixel[0] << 16 | pixel[1] << 8 | pixel[2];
          else
            color = pixel[0] | pixel[1] << 8 | pixel[2] << 16;
          break;
        case 4:
          color = *(Uint32*)pixel;
          break;
      }

      mask->mask[y * s->w + x] = color != s->format->colorkey;
    }
  }

  return mask;
}

void SDL_CollideFreeMask(SDL_CollideMask mask)
{
  if(mask != NULL) {
    if(mask->mask != NULL) {
      SDL_free(mask->mask);
      mask->mask = NULL;
    }
    SDL_free(mask);
  }
}

int SDL_CollidePixelMask(SDL_CollideMask am, int ax, int ay,
                SDL_CollideMask bm, int bx, int by, int skip)
{
  /*a - bottom right co-ordinates in world space*/
  int ax1 = ax + am->w - 1;
  int ay1 = ay + am->h - 1;

  /*b - bottom right co-ordinates in world space*/
  int bx1 = bx + bm->w - 1;
  int by1 = by + bm->h - 1;

  /*check if bounding boxes intersect*/
  if((bx1 < ax) || (ax1 < bx))
          return 0;
  if((by1 < ay) || (ay1 < by))
          return 0;

  int xstart = SDL_COLLIDE_MAX(ax,bx);
  int xend = SDL_COLLIDE_MIN(ax1,bx1);

  int ystart = SDL_COLLIDE_MAX(ay,by);
  int yend = SDL_COLLIDE_MIN(ay1,by1);

  for(int y = ystart ; y <= yend ; y += skip) {
    for(int x = xstart ; x <= xend ; x += skip) {
      if(am->mask[(y - ay) * am->w + (x - ax)] && bm->mask[(y - by) * bm->w + (x - bx)])
        return 1;
    }
  }

  return 0;
}

int SDL_CollidePixelSurfaceAndMask(SDL_Surface* as, int ax, int ay,
                                    SDL_CollideMask bm, int bx, int by, int skip)
{
  /*a - bottom right co-ordinates in world space*/
  int ax1 = ax + as->w - 1;
  int ay1 = ay + as->h - 1;

  /*b - bottom right co-ordinates in world space*/
  int bx1 = bx + bm->w - 1;
  int by1 = by + bm->h - 1;

  /*check if bounding boxes intersect*/
  if((bx1 < ax) || (ax1 < bx))
          return 0;
  if((by1 < ay) || (ay1 < by))
          return 0;

  int xstart = SDL_COLLIDE_MAX(ax,bx);
  int xend = SDL_COLLIDE_MIN(ax1,bx1);

  int ystart = SDL_COLLIDE_MAX(ay,by);
  int yend = SDL_COLLIDE_MIN(ay1,by1);

  if(SDL_MUSTLOCK(as))
   SDL_LockSurface(as);

  int a_bpp = as->format->BytesPerPixel;
  int ret = 0;
  for(int y = ystart ; y <= yend ; y += skip) {
    for(int x = xstart ; x <= xend ; x += skip) {
      Uint8* a_p = (Uint8*)as->pixels + (y-ay) * as->pitch + (x-ax) * a_bpp;
      Uint32 a_pixelcolor;
      switch(a_bpp)
      {
        case 1:
          a_pixelcolor = *a_p;
          break;
        case 2:
          a_pixelcolor = *(Uint16*)a_p;
          break;
        case 3:
          if(SDL_BYTEORDER == SDL_BIG_ENDIAN)
            a_pixelcolor = a_p[0] << 16 | a_p[1] << 8 | a_p[2];
          else
            a_pixelcolor = a_p[0] | a_p[1] << 8 | a_p[2] << 16;
          break;
        case 4:
          a_pixelcolor = *(Uint32*)a_p;
          break;
      }

      if(a_pixelcolor != as->format->colorkey && 
          bm->mask[(y - by) * bm->w + (x - bx)]) {
        ret = 1;
        goto FINISH;
      }
    }
  }
FINISH:

  if(SDL_MUSTLOCK(as))
   SDL_UnlockSurface(as);

  return ret;
}

