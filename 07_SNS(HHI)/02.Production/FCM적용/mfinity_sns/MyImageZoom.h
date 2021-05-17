#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "MySmallZoomView.h"


@class HISImageViewer ;


@interface MyImageZoom : UIScrollView <UIScrollViewDelegate> 
{
	UIImageView *imageView;
	
	MySmallZoomView *mysmallview;
	
//	float imageWidth;
//	float imageHeight;
	
	float diffH;
	float diffW;
	
	float firstscale;
	
	float firstTopinset;
	float firstSideinset;
	
	float imageSizeWidth;
	float imageSizeHeight;
	
	HISImageViewer *parentViewer;
	
	
    float beingdDagXpos;
    
	CGFloat initalZoom;
	
	BOOL hiddenTimerFired;
	int smallViewGate;
}

-(void) setImageData:(NSMutableData *) tmpimage;
-(void) setImageDataCenter:(NSMutableData *) tmpimage;

-(void) setZoomIn;
-(void) setZoomOut;
-(void) setZoomOrgin;

-(void) startHiddenTimer;
-(void) handlerTimer:(NSTimer *)timer;

@property(nonatomic,retain) 	UIImageView *imageView;
@property(nonatomic,retain) MySmallZoomView *mysmallview;
@property(nonatomic,retain) HISImageViewer *parentViewer;


@end 
