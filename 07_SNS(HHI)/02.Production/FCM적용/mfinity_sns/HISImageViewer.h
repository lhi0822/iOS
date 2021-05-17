
#import <UIKit/UIKit.h>
#import "CustomURLConnection.h"

#import "MyImageZoom.h"
#import "MySmallZoomView.h"
#import "LayerNameController.h"

@interface HISImageViewer : UIViewController <UIActionSheetDelegate,UIPickerViewDelegate>
{
    
	UIActivityIndicatorView *myActivityView;
	
    NSMutableDictionary *receivedData;   // 이미지 데이터	
	NSMutableData *ImageData;
	NSMutableArray *hisimagelist; //이미지 목록에 대한 정보
    NSMutableDictionary *sendedData; // 이미지 변환 요청 데이터
    
	UIButton *btnNext;
	UIButton *btnPre;
	UIButton *btnClose;
	
	UIButton *btnZoomOut;
	UIButton *btnZoomIn;
	
	UIButton  *page_text;
    UIButton  *layerName_text;
	UILabel  *message;
    UIButton  *search_btn;
	
	MyImageZoom *myZoomView;  // Big imageViewer
	MySmallZoomView  *mySmallZoomView;
	
	int m_current_page;
	int m_total_page;
	int selectedPicker;  // 임시 선택한 페이지 
	int GET_LAST_ERROR;
	int selectedIndex;
	
	UIView *topView;
	UIView *bottomView;
	
	UIImageView *bottomImageView;
	UIImageView *topImageView;
    
    UIPopoverController *pickerPopover;
    LayerNameController *tbc; 
    BOOL    bCadMode;
    BOOL    bActLayerChange;
    BOOL    bShow;
    BOOL    bAutoOn;
}

// 2012.03.12 Added by K2Web
-(NSString *) makeResultUrl:(NSString *)imgFileName;

-(NSString *)getCurrentImageUrl:(int) page;
-(int) getTotalPage;
-(void) setTotalpage:(int) total;
-(void) setCurrentPage:(int) page;

-(IBAction) getNextImage;
-(IBAction) getPreImage;
-(IBAction) closeImageView:(id) sender;
-(void) closeImageView;

-(void) showMessageBox:(NSString *)str;
-(BOOL) isShow;

-(NSMutableArray *) getImageListArray;

// 2012.03.12 Added by K2Web
-(NSString *) makeConvertUrl:(NSMutableDictionary *)paramDict;

-(BOOL) getImageListByXml:(NSMutableDictionary *)param;

-(void) setImageViewer;
-(void) setImageToZoomView:(NSMutableData *)thumbnailImagedata;

-(void) startGetImageListThread:(NSMutableDictionary *)param;
-(void) endGetImageListThread;

-(void) startDownLoad;
-(void) goPreImage;
-(void) goNextImage;

-(void) processFirDownloadStart:(NSString *)imageurl;
-(void) processFirDownloadEnd:(NSMutableData *)imageData gubun:(NSString *)strGubun;

-(void) updateCtrlHidden:(BOOL)status :(BOOL)cadMode;

-(void) viewPagetext:(int) cur_page :(int )total;

-(void) setImageViewOrientation:(UIInterfaceOrientation)toInterfaceOrientation;

-(void) setOrientationPortrait;
-(void) OrientationLandscapeRight;

-(void) updateAutoCtrlView;
-(void) updateHiddenBar:(BOOL)status;

-(void) showDownMessage:(NSString *)fileName;

-(void) initValue;

-(int)getStatusCode;
-(NSString *)getStatusMsg;
-(void) setSmallViewResize;

-(void)viewWillAppear:(BOOL)animated;
//- (void)orientationChanged:(NSNotification *)notification;
//- (void) adjustViewsForOrientation:(UIInterfaceOrientation) orientation;
-(void)viewDidDisappear:(BOOL)animated;

/*
+ (NSIndexPath*) indexPathForRow:(NSUInteger)row inSection:(NSUInteger)section;
-(NSInteger)numberOfSelectionsInTableView:(UITableView *)tableView;
-(NSInteger)tableView:(UITableView *)tableView numberOfRowInSection:(NSInteger)section;
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
*/

-(IBAction) ZoomOut;
-(IBAction) ZoomIn;
-(IBAction) showPagelist;
-(IBAction) showLayerNamelist;

-(void) startAsyncLoad:(NSURL*)url tag:(NSString*)tag;
-(NSMutableData*)dataForConnection:(CustomURLConnection*)connection;

-(void) setBaseUrl:(NSString*)baseUrl;

//결제문서목록에서 목록 1개를 클릭할경우 전달 받은 값을분석->이미지 호출
-(NSMutableDictionary *) parseJavascriptParamDoc:(NSString *)arrSrc;

//웹뷰에서 최초에 호출될 함수
-(BOOL) setUrlinformation:(NSURLRequest *)request;
// 2012.03.12 Added by K2Web
-(BOOL) setParamInformation:(NSString *)params;


-(NSString*)hexFromStr:(NSString*)str;
-(IBAction) doOkBtnAction;
-(IBAction) doCancleBtnAction;
-(void) setEncoding:(NSString *)ivData;

- (BOOL)shouldAutorotate;
/*
- (void) onLandLeft:(BOOL)bAuto;
- (void) onPortrait:(BOOL)bAuto;
- (void) onLandRight:(BOOL)bAuto;
- (void) onPortraitUpsideDown:(BOOL)bAuto;

-(void) onChangeAutotRotate;

- (void) rotatePortrait;
- (void) rotateLandLeft;
- (void) rotatePortraitUpsideDown;
- (void) rotateLandRight;
*/


@property(nonatomic,retain) IBOutlet UIButton *btnNext;
@property(nonatomic,retain) IBOutlet UIButton *btnPre;
@property(nonatomic,retain) IBOutlet UIButton *btnClose;
@property(nonatomic,retain) IBOutlet UIButton  *page_text;
@property(nonatomic,retain) IBOutlet UIButton  *layerName_text;
@property(nonatomic,retain) UILabel  *message;
@property(nonatomic,retain) IBOutlet UIButton  *search_btn;

@property(nonatomic,retain) IBOutlet UIView *topView;
@property(nonatomic,retain) IBOutlet UIView *bottomView;
@property(nonatomic,retain) IBOutlet UIImageView *bottomImageView;
@property(nonatomic,retain) IBOutlet UIImageView *topImageView;

@property(nonatomic,retain) IBOutlet UIButton *btnZoomOut;
@property(nonatomic,retain) IBOutlet UIButton *btnZoomIn;

@property(nonatomic,retain) IBOutlet NSMutableArray *hisimagelist;
//@property(nonatomic,retain) IBOutlet 	UIImageView *bigImageViewer;
//@property(nonatomic,retain) IBOutlet UIImageView *smallimage;
//@property(nonatomic,retain) IBOutlet UIView *smallview;
//@property(nonatomic,retain) IBOutlet MySmallView *smallViewDelegate;

@property(nonatomic,retain)  UIActivityIndicatorView *myActivityView;
@property(nonatomic,retain)  MySmallZoomView *mySmallZoomView;
@property(nonatomic,retain)  LayerNameController *tbc;
//@property(retain)  NSDictionary *httpParamList;   //전송받을 이미지에 대한 정보 , 문서 목록을 클릭했을때 넘어 온다.



@end
