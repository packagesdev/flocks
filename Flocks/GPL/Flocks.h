#ifndef __FLOCKS__
#define __FLOCKS__

class bug;

enum
{
	GeometryTypeDot=0,
	GeometryTypeBlob=1
} FlocksBugGeometryType;

class scene
{
	private:
		
		unsigned long long _lastRefresh;
		float _aspectRatio;
	
		bug * _leaderBugs;
		bug * _followerBugs;
		
	public:
	
		int leadersCount;
		int followersCount;
	
		int geometryType;
		int blobComplexity;
	
		int bugSize;
		int bugSpeed;

		int stretch;
	
		float colorFade;
	
		bool stereoscopicRendering;
		bool showConnections;
	
		int width;
		int height;
		int deep;
	
	
		scene();
		virtual ~scene();
		
		void create();
		void resize(int inWidth,int inHeight);
		void draw(void);
};

enum
{
	TypeLeader=0,
	TypeFollower=1
} FlocksBugType;

class bug
{
	private:
	
        int _type;  // 0 = leader   1 = follower
        float _h, _s, _l;
        
        float _halfr, _halfg, _halfb;
        float _x, _y, _z;
        float _xSpeed, _ySpeed, _zSpeed, _maxSpeed;
        float _accel;
        int _right, _up, _forward;
        int _leaderIndex;
        float _craziness;  // How prone to switching direction is this leader
        float _nextChange;  // Time until this leader's next direction change
	
	public:
	
        bug();
	
        void initLeader(scene * inScene);
        void initFollower(scene * inScene);
	
        void update(float inElapsedTime,bug *bugs,scene * inScene);
};

#endif