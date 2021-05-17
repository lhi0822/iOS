
#import <UIKit/UIKit.h>

#import <Foundation/Foundation.h>


@interface MySmallZoomView : UIScrollView <UIScrollViewDelegate> 
{

	UIImageView *imageView;
	//UIImage     *image;
	
	
	float imageWidth;
	float imageHeight;
	
	float diffH;
	float diffW;
	
	float firstscale;
	
	
	float zoom_x;
	float zoom_y;
	
	float mydeltaScale;
	
	float firstTopinset;
	float firstSideinset;

    float fxPos;
    float fyPos;
    float fdrawWidth;
    float fdrawHeight;
//	float myfirstTopinset;
//	float myfirstSideinset;
}

-(void) setImageData:(NSMutableData *) tmpimage;
-(void) setImageDataCenter:(NSMutableData *) tmpimage;


-(void) invalidate:(float)x ypos:(float) y parent_width:(float) w parent_height:(float) h deltaScale:(float) delta;



@property(nonatomic,retain) 	UIImageView *imageView;


//@property(nonatomic,retain) UIImage *lpImage;
@end
