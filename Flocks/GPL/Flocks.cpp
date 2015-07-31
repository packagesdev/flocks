/*
 * Copyright (C) 2002  Terence M. Welsh
 *
 * Flocks is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as 
 * published by the Free Software Foundation.
 *
 * Flocks is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */


// Flocks screensaver

// 07/2015 (S.Sudre): objectified the code a bit more.

#include "Flocks.h"

#include <stdio.h>
#include <math.h>
#include <OpenGL/gl.h>
#include <OpenGL/glu.h>
#include <sys/time.h>
#include "rgbhsl.h"
#include <stdlib.h>


#define R2D 57.2957795131f

// useful random functions
static int myRandi(int x)
{
    return ((rand() * x) / RAND_MAX);
}

static float myRandf(float x)
{
    return ((rand() *x*((double) 1.0)) / RAND_MAX);
}

scene::scene()
{
	srand((unsigned)time(NULL));
	rand(); rand(); rand(); rand(); rand();
	rand(); rand(); rand(); rand(); rand();
	rand(); rand(); rand(); rand(); rand();
	rand(); rand(); rand(); rand(); rand();
}

scene::~scene()
{
	if (glIsList(1))
		glDeleteLists(1, 1);
	
	if (_leaderBugs!=NULL)
	{
		delete[] _leaderBugs;
		_leaderBugs=NULL;
	}
	
	if (_followerBugs!=NULL)
	{
		delete[] _followerBugs;
		_followerBugs=NULL;
	}
}

#pragma mark -

void scene::create()
{
	// Window initialization
	
	glEnable(GL_DEPTH_TEST);
	glFrontFace(GL_CCW);
	glEnable(GL_CULL_FACE);
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
	glEnable(GL_LINE_SMOOTH);
	glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
	
	if(geometryType==GeometryTypeBlob)  // Setup lights and build blobs
	{
		glEnable(GL_LIGHTING);
		glEnable(GL_LIGHT0);
		float ambient[4] = {0.25f, 0.25f, 0.25f, 0.0f};
		float diffuse[4] = {1.0f, 1.0f, 1.0f, 0.0f};
		float specular[4] = {1.0f, 1.0f, 1.0f, 0.0f};
		float position[4] = {500.0f, 500.0f, 500.0f, 0.0f};
		glLightfv(GL_LIGHT0, GL_AMBIENT, ambient);
		glLightfv(GL_LIGHT0, GL_DIFFUSE, diffuse);
		glLightfv(GL_LIGHT0, GL_SPECULAR, specular);
		glLightfv(GL_LIGHT0, GL_POSITION, position);
		glEnable(GL_COLOR_MATERIAL);
		glMaterialf(GL_FRONT, GL_SHININESS, 10.0f);
		glColorMaterial(GL_FRONT, GL_SPECULAR);
		glColor3f(0.7f, 0.7f, 0.7f);
		glColorMaterial(GL_FRONT, GL_AMBIENT_AND_DIFFUSE);
		
		glNewList(1, GL_COMPILE);
		GLUquadricObj *qobj = gluNewQuadric();
		gluSphere(qobj, bugSize * 0.5f, blobComplexity + 2, blobComplexity + 1);
		gluDeleteQuadric(qobj);
		glEndList();
	}
	else
	{
		glDisable(GL_LIGHTING);
		glDisable(GL_COLOR_MATERIAL);
		
		if (glIsList(1))
			glDeleteLists(1, 1);
	}
	
	_leaderBugs = new bug[leadersCount];
	
	for(int i=0; i<leadersCount; i++)
		_leaderBugs[i].initLeader(this);
	
	_followerBugs = new bug[followersCount];
	
	for(int i=0; i<followersCount; i++)
		_followerBugs[i].initFollower(this);
	
	struct timeval tTime;
	gettimeofday(&tTime, NULL);
	
	_lastRefresh=(tTime.tv_sec*1000+tTime.tv_usec/1000);
}

void scene::resize(int inWidth,int inHeight)
{
	_aspectRatio = (1.0*inWidth) / inHeight;
	glViewport(0, 0, inWidth, inHeight);
	
	// calculate boundaries
	if (inWidth > inHeight)
	{
		height = deep = 160;
		width = (height * inWidth) / inHeight;
	}
	else
	{
		width = deep = 160;
		height = (width * inHeight) / inWidth;
	}
}

void scene::draw()
{
	struct timeval tTime;
	unsigned long long tCurentTime;
	
	gettimeofday(&tTime, NULL);
	
	tCurentTime=(tTime.tv_sec*1000+tTime.tv_usec/1000);
	
	float tElapsedTime=(tCurentTime-_lastRefresh)*0.001;
	_lastRefresh=tCurentTime;
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective(80.0, _aspectRatio, 50, 2000);
	glTranslatef(0.0, 0.0, -width * 2.0);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	// Update and draw leaders
	
	for(int i=0; i<leadersCount; i++)
		_leaderBugs[i].update(tElapsedTime,_leaderBugs,this);
	
	// Update and draw followers
	for(int i=0; i<followersCount; i++)
		_followerBugs[i].update(tElapsedTime,_leaderBugs,this);
	
	glFinish();
}

#pragma mark -

bug::bug()
{
	_h = myRandf(1.0);
	_s = 1.0f;
	_l = 1.0f;
	
	_xSpeed = _ySpeed = _zSpeed = 0.0f;
}

void bug::initLeader(scene * inScene)
{
	_type = TypeLeader;
	
	_x = myRandf(inScene->width * 2) - inScene->width;
	_y = myRandf(inScene->height * 2) - inScene->height;
	_z = myRandf(inScene->width * 2) + inScene->width * 2;
	_right = _up = _forward = 1;
	
	_maxSpeed = 8.0f * inScene->bugSpeed;
	_accel = 13.0f * inScene->bugSpeed;
	_craziness = myRandf(4.0f) + 0.05f;
	_nextChange = 1.0f;
}

void bug::initFollower(scene * inScene)
{
	_type = TypeFollower;
	_leaderIndex = 0;
	
	_x = myRandf((inScene->width * 2)) - inScene->width;
	_y = myRandf((inScene->height * 2)) - inScene->height;
	_z = myRandf((inScene->width * 5)) + inScene->width * 2;
	_right = _up = _forward = 0;
	
	_maxSpeed = (myRandf(6.0f) + 4.0f) * inScene->bugSpeed;
	_accel = (myRandf(4.0f) + 9.0f) * inScene->bugSpeed;
}

void bug::update(float inElapsedTime,bug *inLeaderbugs,scene * inScene)
{
	float scale[4]={0.0f,0.0f,0.0f,0.0f};
    
	if(_type==TypeLeader)
    {  // leader
		_nextChange -= inElapsedTime;
        
		if(_nextChange <= 0.0f)
        {
			if(myRandi(2))
				_right ++;
			if(myRandi(2))
				_up ++;
			if(myRandi(2))
				_forward ++;
			if(_right >= 2)
				_right = 0;
			if(_up >= 2)
				_up = 0;
			if(_forward >= 2)
				_forward = 0;
			_nextChange = myRandf(_craziness);
		}
        
		if(_right)
			_xSpeed += _accel * inElapsedTime;
		else
			_xSpeed -= _accel * inElapsedTime;
		if(_up)
			_ySpeed += _accel * inElapsedTime;
		else
			_ySpeed -= _accel * inElapsedTime;
		if(_forward)
			_zSpeed -= _accel * inElapsedTime;
		else
			_zSpeed += _accel * inElapsedTime;
		if(_x < (-inScene->width))
			_right = 1;
		if(_x > inScene->width)
			_right = 0;
		if(_y < (-inScene->height))
			_up = 1;
		if(_y > inScene->height)
			_up = 0;
		if(_z < (-inScene->deep))
			_forward = 0;
		if(_z > inScene->deep)
			_forward = 1;
		// Even leaders change color from Chromatek 3D
		if(inScene->stereoscopicRendering==true)
        {
			_h = 0.666667f * ((inScene->width - _z) / (inScene->width + inScene->width));
			if(_h > 0.666667f)
				_h = 0.666667f;
			if(_h < 0.0f)
				_h = 0.0f;
		}
	}
	else
    {  // follower
		if(!myRandi(10))
        {
			float oldDistance = 10000000.0f;
			
			for(int tIndex=0; tIndex<inScene->leadersCount; tIndex++)
            {
				bug tBug=inLeaderbugs[tIndex];
                
                float newDistance = (tBug._x - _x) * (tBug._x - _x) + (tBug._y - _y) * (tBug._y - _y) + (tBug._z - _z) * (tBug._z - _z);
                            
				if(newDistance < oldDistance)
                {
					oldDistance = newDistance;
					_leaderIndex = tIndex;
				}
			}
		}
		
		if((inLeaderbugs[_leaderIndex]._x - _x) > 0.0f)
			_xSpeed += _accel * inElapsedTime;
		else
			_xSpeed -= _accel * inElapsedTime;
            
		if((inLeaderbugs[_leaderIndex]._y - _y) > 0.0f)
			_ySpeed += _accel * inElapsedTime;
		else
			_ySpeed -= _accel * inElapsedTime;
            
		if((inLeaderbugs[_leaderIndex]._z - _z) > 0.0f)
			_zSpeed += _accel * inElapsedTime;
		else
			_zSpeed -= _accel * inElapsedTime;
            
		if(inScene->stereoscopicRendering==true)
        {
			_h = 0.666667f * ((inScene->width - _z) / (inScene->width + inScene->width));
            
			if(_h > 0.666667f)
            {
				_h = 0.666667f;
			}
            else
            {
                if(_h < 0.0f)
                    _h = 0.0f;
            }
        }
		else
        {
			if(fabs(_h - inLeaderbugs[_leaderIndex]._h) < (inScene->colorFade * inElapsedTime))
			{
				_h = inLeaderbugs[_leaderIndex]._h;
			}
			else
            {
				if(fabs(_h - inLeaderbugs[_leaderIndex]._h) < 0.5f)
                {
					if(_h > inLeaderbugs[_leaderIndex]._h)
						_h -= inScene->colorFade * inElapsedTime;
					else
						_h += inScene->colorFade * inElapsedTime;
				}
				else
                {
					if(_h > inLeaderbugs[_leaderIndex]._h)
						_h += inScene->colorFade * inElapsedTime;
					else
						_h -= inScene->colorFade * inElapsedTime;
					
					if(_h > 1.0f)
					{
						_h -= 1.0f;
					}
					else
                    {
                        if(_h < 0.0f)
                            _h += 1.0f;
                    }
                }
			}
		}
	}

	if(_xSpeed > _maxSpeed)
	{
		_xSpeed = _maxSpeed;
	}
    else
	{
        if(_xSpeed < -_maxSpeed)
            _xSpeed = -_maxSpeed;
	}
	
    if(_ySpeed > _maxSpeed)
	{
		_ySpeed = _maxSpeed;
	}
	else
    {
        if(_ySpeed < -_maxSpeed)
            _ySpeed = -_maxSpeed;
	}
    
    if(_zSpeed > _maxSpeed)
	{
		_zSpeed = _maxSpeed;
	}
	else
    {
        if(_zSpeed < -_maxSpeed)
            _zSpeed = -_maxSpeed;
	}
    
	_x += _xSpeed * inElapsedTime;
	_y += _ySpeed * inElapsedTime;
	_z += _zSpeed * inElapsedTime;
    
	if(inScene->stretch>0)
    {
		scale[0] = _xSpeed * 0.04f;
		scale[1] = _ySpeed * 0.04f;
		scale[2] = _zSpeed * 0.04f;
		scale[3] = scale[0] * scale[0] + scale[1] * scale[1] + scale[2] * scale[2];
        
		if(scale[3] > 0.0f)
        {
			scale[3] = sqrt(scale[3]);
			scale[0] /= scale[3];
			scale[1] /= scale[3];
			scale[2] /= scale[3];
		}
	}
	
	float red,green,blue;
	
	hsl2rgb(_h, _s, _l, red, green, blue);
	
	_halfr = red * 0.5f;
	_halfg = green * 0.5f;
	_halfb = blue * 0.5f;
    
	glColor3f(red, green, blue);
    
	if(inScene->geometryType==GeometryTypeBlob)	  // Draw blobs
    {
		glPushMatrix();
			glTranslatef(_x, _y, _z);
			if(inScene->stretch)
            {
				scale[3] *= inScene->stretch * 0.05f;
				if(scale[3] < 1.0f)
					scale[3] = 1.0f;
				glRotatef(atan2(-scale[0], -scale[2]) * R2D, 0.0f, 1.0f, 0.0f);
				glRotatef(asin(scale[1]) * R2D, 1.0f, 0.0f, 0.0f);
				glScalef(1.0f, 1.0f, scale[3]);
			}
			glCallList(1);
		glPopMatrix();
	}
	else	  // Draw dots
    {
		if(inScene->stretch>0)
        {
			glLineWidth(inScene->bugSize * (700 - _z) * 0.0002f);
			scale[0] *= inScene->stretch;
			scale[1] *= inScene->stretch;
			scale[2] *= inScene->stretch;
			glBegin(GL_LINES);
				glVertex3f(_x - scale[0], _y - scale[1], _z - scale[2]);
				glVertex3f(_x + scale[0], _y + scale[1], _z + scale[2]);
			glEnd();
		}
		else
        {
			glPointSize(inScene->bugSize * (700 - _z) * 0.001f);
			glBegin(GL_POINTS);
				glVertex3f(_x, _y, _z);
			glEnd();
		}
	}

	if (inScene->showConnections==true && _type==TypeFollower)	  // draw connections
    {
		glLineWidth(1.0f);
		glBegin(GL_LINES);
			glColor3f(_halfr, _halfg, _halfb);
			glVertex3f(_x, _y, _z);
			glColor3f(inLeaderbugs[_leaderIndex]._halfr, inLeaderbugs[_leaderIndex]._halfg, inLeaderbugs[_leaderIndex]._halfb);
			glVertex3f(inLeaderbugs[_leaderIndex]._x, inLeaderbugs[_leaderIndex]._y, inLeaderbugs[_leaderIndex]._z);
		glEnd();
	}
}
