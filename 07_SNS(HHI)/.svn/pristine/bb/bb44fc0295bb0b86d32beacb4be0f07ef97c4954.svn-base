//
//  PostModifyViewController.m
//  mfinity_sns
//
//  Created by hilee on 2017. 8. 18..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "PostModifyViewController.h"
#import "MFStyle.h"
#import "SDImageCache.h"
#import "PostModifyViewController2.h"
#import "MFDBHelper.h"

@interface PostModifyViewController () {
    NSMutableArray *postArr;
    SDImageCache *imgCache;
    NSDictionary *postDict;
    NSArray *contentArr;
    NSMutableArray *elementArr;
    BOOL isOrder;
    AppDelegate *appDelegate;
}

@end

@implementation PostModifyViewController
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAnimate:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAnimate:) name:UIKeyboardWillHideNotification object:nil];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_PostOrderModify:) name:@"noti_PostOrderModify" object:nil];
    
    self.navigationController.navigationBar.barTintColor = [MFUtil myRGBfromHex:@"1D4696"];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"msg25", @"")
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(rightSideMenuButtonPressed:)];
    
    self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"msg24", @"")
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(leftBackButtonPressed:)];
    
    if([self.isEdit isEqualToString:@"COMMENT"]){
        self.navigationItem.titleView = [MFStyle navigationTitleStyle1:NSLocalizedString(@"댓글 수정", @"댓글 수정")];
        NSString *comment = [NSString urlDecodeString:[self.commDic objectForKey:@"CONTENT"]];
        self.textView.text = comment;
        
    } else if([self.isEdit isEqualToString:@"POST"]){
        self.navigationItem.titleView = [MFStyle navigationTitleStyle1:NSLocalizedString(@"글 수정", @"글 수정")];
        UIButton *right1 = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 35, 35)];
        [right1 setImage:[self getScaledImage:[UIImage imageNamed:@"menu_camera.png"] scaledToMaxWidth:35] forState:UIControlStateNormal];
        [right1 addTarget:self action:@selector(photo:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightBtn1 = [[UIBarButtonItem alloc]initWithCustomView:right1];
        
        //        UIButton *right2 = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 35, 35)];
        //        [right2 setImage:[self getScaledImage:[UIImage imageNamed:@"menu_movie.png"] scaledToMaxWidth:35] forState:UIControlStateNormal];
        //        [right2 addTarget:self action:@selector(video:) forControlEvents:UIControlEventTouchUpInside];
        //        UIBarButtonItem *rightBtn2 = [[UIBarButtonItem alloc]initWithCustomView:right2];
        //        NSArray *barButtonArr = [[NSArray alloc]initWithObjects:rightBtn1, rightBtn2, nil];
        
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        NSArray *barButtonArr = [[NSArray alloc] initWithObjects:rightBtn1, flexibleSpace, flexibleSpace, nil];
        
        self.toolBar.items = barButtonArr;
        
        self.imageArray = [NSMutableArray array];
        self.imageIndexArray = [NSMutableArray array];
        self.imageFileNameArray = [NSMutableArray array];
        self.contentImageArray = [NSMutableArray array];
        
        contentArr = [NSArray array];
        
        elementArr = [NSMutableArray array];
        uploadCount = 0;
        
        isOrder = NO;
        
        //NSLog(@"postDict : %@", self.postDic);
        
        imgCache = [SDImageCache sharedImageCache];
        NSString *tmpPath = NSTemporaryDirectory();
        NSString *imgPath = [tmpPath stringByAppendingPathComponent:@"cache"];
        [imgCache makeDiskCachePath:imgPath];
        
        contentArr = [self.postDic objectForKey:@"CONTENT"];
        NSLog(@"contentArr : %@", contentArr);
        [self imageViewInTextView:contentArr];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //[self.textView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    //선택 팝업(복사, 붙여넣기 등)
    BOOL isDisableCopyAndPaste;
    
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0) { // iOS 6 이전
        if (action == @selector(paste:))
            return NO;
        if (action == @selector(select:))
            return NO;
        if (action == @selector(selectAll:))
            return NO;
        isDisableCopyAndPaste = [super canPerformAction:action withSender:sender];
    } else {    // iOS 7 이후
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [[UIMenuController sharedMenuController] setMenuVisible:NO animated:NO];
        }];
        isDisableCopyAndPaste = [super canPerformAction:action withSender:sender];
    }
    return isDisableCopyAndPaste;
}

- (void)leftBackButtonPressed:(id)sender {
    [self.textView resignFirstResponder];
    
    NSString *msg;
    if([self.isEdit isEqualToString:@"COMMENT"]){
        msg = NSLocalizedString(@"댓글 수정을 취소하시겠습니까?", @"댓글 수정을 취소하시겠습니까?");
    } else if([self.isEdit isEqualToString:@"POST"]){
        msg = NSLocalizedString(@"글 수정을 취소하시겠습니까?", @"글 수정을 취소하시겠습니까?");
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                         [self dismissViewControllerAnimated:YES completion:nil];
                                                     }];
    
    UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
    [alert addAction:okButton];
    [alert addAction:cancelButton];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)rightSideMenuButtonPressed:(id)sender {
    [self.textView resignFirstResponder];
    
    NSString *textStr = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if(self.textView.attributedText.length==0 && [textStr isEqualToString:@""]){
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"" message:@"저장된 내용이 없습니다." preferredStyle:UIAlertControllerStyleAlert];
        
        [self presentViewController:alert animated:YES completion:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alert dismissViewControllerAnimated:YES completion:nil];
        });
    }else{
        self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"저장", @"저장")
                                                                                style:UIBarButtonItemStylePlain
                                                                               target:self
                                                                               action:@selector(saveButtonPressed:)];
    }
}

- (void)saveButtonPressed:(id)sender {
    [self.view endEditing:YES];
    
    @try{
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *myUserNo = [prefs objectForKey:@"CUSER_NO"];
        
        NSLog(@"self.isEdit : %@", self.isEdit);
        if([self.isEdit isEqualToString:@"COMMENT"]){
            if([self.fromSegue isEqualToString:@"MODIFY_TASK_COMMENT"]){
                NSString *commentNo = [self.commDic objectForKey:@"DATA_NO"];
                NSString *content = self.textView.text;
                NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&snsNo=%@&taskNo=%@&commentNo=%@&content=%@&isNewComment=false", myUserNo, self.snsNo, self.taskNo, commentNo, content];
                
                [self callWebService:@"saveTaskComment" WithParameter:paramString];
                
            } else {
                NSString *commentNo = [self.commDic objectForKey:@"COMMENT_NO"];
                NSString *content = self.textView.text;
                NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&snsNo=%@&postNo=%@&commentNo=%@&content=%@&isNewComment=false", myUserNo, self.snsNo, self.postNo, commentNo, content];
                
                [self callWebService:@"savePostComment" WithParameter:paramString];
            }
            
        } else if([self.isEdit isEqualToString:@"POST"]){
            NSArray *imageIndexArray = [self getImageFilesInTextView];
            NSLog(@"imageIndexArray : %@", imageIndexArray);
            if (imageIndexArray.count>0) {
                [self saveAttachedFile];
            }else{
                NSString *content = [self createContentJSONArray];
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                NSString *myUserNo = [prefs objectForKey:@"CUSER_NO"];
                
                NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&snsNo=%@&postNo=%@&content=%@",myUserNo, self.snsNo, self.postNo, content];
                [self callWebService:@"savePost" WithParameter:paramString];
            }
        }
    } @catch (NSException *exception) {
        //[self sendToHilee:[NSString stringWithFormat:@"%s", __func__] :exception];
    }
}

-(void)callWebService:(NSString *)serviceName WithParameter:(NSString *)paramString{
    NSString *urlString = appDelegate.main_url;
    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:serviceName]];
    MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
    session.delegate = self;
    if ([session start]) {
        [SVProgressHUD show];
    }
}


- (NSArray *)getImageFilesInTextView{
    @try{
        NSMutableArray *imagesArray = [[NSMutableArray alloc] init];
        [self.textView.attributedText enumerateAttribute:NSAttachmentAttributeName
                                                 inRange:NSMakeRange(0, [self.textView.attributedText length])
                                                 options:0
                                              usingBlock:^(id value, NSRange range, BOOL *stop)
         {
             if ([value isKindOfClass:[NSTextAttachment class]]) {
                 NSTextAttachment *attachment = (NSTextAttachment *)value;
                 UIImage *image = nil;
                 
                 if ([attachment image]) image = [attachment image];
                 else image = [attachment imageForBounds:[attachment bounds] textContainer:nil characterIndex:range.location];
                 
                 if (image) [imagesArray addObject:image];
             }
         }];
        
        NSLog(@"self.contentImageArray : %@", self.contentImageArray);
        
        for (int i=0; i<self.contentImageArray.count; i++) {
            for (int j=0; j<imagesArray.count; j++) {
                if ([self.contentImageArray[i] isEqual:imagesArray[j]]) {
                    [self.imageIndexArray addObject:[NSNumber numberWithInt:i]];
                }
            }
        }
        return self.imageIndexArray;
        
    } @catch (NSException *exception) {
        //[self sendToHilee:[NSString stringWithFormat:@"%s", __func__] :exception];
    }
}

- (void)saveAttachedFile{
    //NSLog(@"self.imageIndexArray : %@", self.imageIndexArray);
    NSLog(@"4=================================");
    @try{
        for (int i=0; i<self.imageIndexArray.count; i++) {
            //NSString *fileName = [NSString stringWithFormat:@"%d.png",i];
            NSString *fileName = [self createFileName];
            UIImage *image =[self.imageArray objectAtIndex:[[self.imageIndexArray objectAtIndex:i] intValue]];
            //NSLog(@"imageArray : %@", self.imageArray);
            //NSData * data = UIImagePNGRepresentation(image);
            NSData * data = UIImageJPEGRepresentation(image, 0.1);
            NSLog(@"File size is : %.2f MB",(float)data.length/1024.0f/1024.0f);
            
            //NSLog(@"self.imageIndexArray : %@", [self.imageIndexArray objectAtIndex:i]);
            [self saveAttachedFile:data AndFileName:fileName];
        }
        
    } @catch (NSException *exception) {
        //[self sendToHilee:[NSString stringWithFormat:@"%s", __func__] :exception];
    }
}

- (void)saveAttachedFile:(NSData *)data AndFileName:(NSString *)fileName{
    @try{
        if (self.postNo==nil) {
            NSLog(@"postNo is nil");
        }else{
            //ADIT_INFO : {"TMP_NO":Long,"LOCAL_CONTENT":String}
            NSMutableDictionary *aditDic = [NSMutableDictionary dictionary];
            [aditDic setObject:@"1" forKey:@"TMP_NO"];
            [aditDic setObject:@"" forKey:@"LOCAL_CONTENT"];
            
            NSData* aditData = [NSJSONSerialization dataWithJSONObject:aditDic options:0 error:nil];
            NSString* aditJsonData = [[NSString alloc] initWithData:aditData encoding:NSUTF8StringEncoding];
            
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSString *myUserNo = [prefs objectForKey:@"CUSER_NO"];
            
            NSMutableDictionary *sendFileParam = [NSMutableDictionary dictionary];
            [sendFileParam setObject:self.snsNo forKey:@"snsNo"];
            [sendFileParam setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"USER_ID"] forKey:@"usrId"];
            [sendFileParam setObject:myUserNo forKey:@"usrNo"];
            [sendFileParam setObject:@"1" forKey:@"refTy"];
            [sendFileParam setObject:self.postNo forKey:@"refNo"];
            [sendFileParam setObject:aditJsonData forKey:@"aditInfo"];
            
            NSString *urlString = appDelegate.main_url;
            urlString = [urlString stringByAppendingPathComponent:@"saveAttachedFile"];
            
            //NSLog(@"fileName : %@", fileName);
            
            MFURLSessionUpload *sessionUpload = [[MFURLSessionUpload alloc]initWithURL:[NSURL URLWithString:urlString] option:sendFileParam WithData:data AndFileName:fileName];
            sessionUpload.delegate = self;
            if ([sessionUpload start]) {
                [SVProgressHUD show];
            }
        }
        
    } @catch (NSException *exception) {
        //[self sendToHilee:[NSString stringWithFormat:@"%s", __func__] :exception];
    }
}

- (NSString *)createFileName{
    @try{
        NSString *fileName = nil;
        NSDate *today = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyMMdd-HHmmss"];
        NSString *currentTime = [dateFormatter stringFromDate:today];
        NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"USER_ID"];
        fileName = [NSString stringWithFormat:@"%@(%@).png",userID,currentTime];
        return fileName;
        
    } @catch (NSException *exception) {
        //[self sendToHilee:[NSString stringWithFormat:@"%s", __func__] :exception];
    }
}

- (NSString *)createContentJSONArray{
    NSDictionary *documentAttributes = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
    //NSLog(@"documentAttributes : %@", documentAttributes);
    //NSLog(@"self.textView.attributedText : %@", self.textView.attributedText);
    NSData *htmlData = [self.textView.attributedText dataFromRange:NSMakeRange(0, self.textView.attributedText.length) documentAttributes:documentAttributes error:NULL];
    NSString *htmlString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    //printf("htmlString : %s",htmlString.UTF8String);
    HTMLParser *parser = [[HTMLParser alloc]initWithString:htmlString];
    HTMLDocument *doc = [parser parseDocument];
    
    //    HTMLElement *styleElement = [doc querySelector:@"style"];
    //    NSArray *styleArray = [styleElement.textContent componentsSeparatedByString:@"\n"];
    
    HTMLNode *bodyNode = [doc body];
    NSString *bodyStr = [bodyNode innerHTML];
    
    NSLog(@"bodyStr : %@", bodyStr);
    
    NSArray *bodyArray = [bodyStr componentsSeparatedByString:@"\n"];
    NSMutableArray *bodyArr = [[NSMutableArray alloc]init];
    
    for(int i=0; i<bodyArray.count; i++){
        if(![bodyArray[i] isEqualToString:@""]){
            [bodyArr addObject:bodyArray[i]];
        }
    }
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [self.imageFileNameArray sortUsingDescriptors:sortDescriptors];
    //NSLog(@"imageFileNameArray : %@", self.imageFileNameArray);
    
    int imageCount = 0;
    //NSMutableArray *contentArray = [NSMutableArray array];
    NSArray *paragraphs = [doc querySelectorAll:@"p"];
    //NSLog(@"paragraphs : %@",paragraphs);
    
    //NSLog(@"bodyArr : %@", bodyArr);
    
    NSMutableArray *tmpArr = [NSMutableArray array];
    //NSString *contentStr=@"";
    
    @try {
        for (int i=0; i<paragraphs.count; i++) {
            HTMLElement *p = [paragraphs objectAtIndex:i];
            
            [self findChildNode:p];
            
            /*
             if([bodyArr[i] rangeOfString:@"<br>"].location!=NSNotFound){
             [tmpArr addObject:@"%5Cn"];
             
             } else if([bodyArr[i] rangeOfString:@"<img src="].location!=NSNotFound){
             if (self.imageFileNameArray.count==0) {
             HTMLNode *node = [p firstChild];
             NSString *textContent = [[node textContent]urlEncodeUsingEncoding:NSUTF8StringEncoding];
             textContent = [textContent stringByReplacingOccurrencesOfString:@"%22" withString:@"%5C%22"];
             textContent = [textContent stringByReplacingOccurrencesOfString:@"%27" withString:@"%5C%27"];
             [tmpArr addObject:textContent];
             
             }else{
             NSString *imagePath = [self.imageFileNameArray objectAtIndex:imageCount++];
             //NSLog(@"imagePath : %@", imagePath);
             
             NSString *textContent=@"";
             NSOrderedSet *nodes = [p childNodes];
             for (int i=0; i<nodes.count; i++) {
             HTMLNode *node = [nodes objectAtIndex:i];
             textContent = [textContent stringByAppendingFormat:@"%@",[node textContent]];
             }
             textContent = [textContent urlEncodeUsingEncoding:NSUTF8StringEncoding];
             textContent = [textContent stringByReplacingOccurrencesOfString:@"%22" withString:@"%5C%22"];
             textContent = [textContent stringByReplacingOccurrencesOfString:@"%27" withString:@"%5C%27"];
             
             if (imagePath!=nil && textContent!=nil) {
             if(![textContent isEqual:@""]){
             [tmpArr addObject:textContent];
             }
             [tmpArr addObject:imagePath];
             
             }else{
             NSString *textContent=@"";
             NSOrderedSet *nodes = [p childNodes];
             for (int i=0; i<nodes.count; i++) {
             HTMLNode *node = [nodes objectAtIndex:i];
             textContent = [textContent stringByAppendingFormat:@"%@",[node textContent]];
             }
             textContent = [textContent urlEncodeUsingEncoding:NSUTF8StringEncoding];
             textContent = [textContent stringByReplacingOccurrencesOfString:@"%22" withString:@"%5C%22"];
             textContent = [textContent stringByReplacingOccurrencesOfString:@"%27" withString:@"%5C%27"];
             [tmpArr addObject:textContent];
             }
             }
             
             } else {
             NSString *textContent=@"";
             NSOrderedSet *nodes = [p childNodes];
             for (int i=0; i<nodes.count; i++) {
             HTMLNode *node = [nodes objectAtIndex:i];
             textContent = [textContent stringByAppendingFormat:@"%@",[node textContent]];
             }
             textContent = [textContent urlEncodeUsingEncoding:NSUTF8StringEncoding];
             textContent = [textContent stringByReplacingOccurrencesOfString:@"%22" withString:@"%5C%22"];
             textContent = [textContent stringByReplacingOccurrencesOfString:@"%27" withString:@"%5C%27"];
             [tmpArr addObject:textContent];
             [tmpArr addObject:@"%5Cn"];
             }*/
        }
        
        NSLog(@"elementARr: %@", elementArr);
        for(int i=0; i<elementArr.count; i++){
            if([[NSString stringWithFormat:@"%@", elementArr[i]] hasPrefix:@"<HTMLText:"]){
                //if([[elementArr[i] className] isEqualToString:@"HTMLText"]){
                NSString *textContent=@"";
                
                textContent = [elementArr[i] textContent];
                
                textContent = [textContent urlEncodeUsingEncoding:NSUTF8StringEncoding];
                textContent = [textContent stringByReplacingOccurrencesOfString:@"%22" withString:@"%5C%22"];
                textContent = [textContent stringByReplacingOccurrencesOfString:@"%27" withString:@"%5C%27"];
                
                [tmpArr addObject:textContent];
                //[tmpArr addObject:@"%5Cn"];
                
            } else if([[NSString stringWithFormat:@"%@", elementArr[i]] hasPrefix:@"<HTMLElement:"]){
                if([[elementArr[i] tagName] isEqualToString:@"img"]){
                    //NSLog(@"self.imageFileNameArray : %@", self.imageFileNameArray);
                    if (self.imageFileNameArray.count==0) {
                        NSString *textContent = [elementArr[i] textContent];
                        textContent = [textContent stringByReplacingOccurrencesOfString:@"%22" withString:@"%5C%22"];
                        textContent = [textContent stringByReplacingOccurrencesOfString:@"%27" withString:@"%5C%27"];
                        
                        [tmpArr addObject:textContent];
                        
                    } else {
                        NSString *imagePath = [self.imageFileNameArray objectAtIndex:imageCount++];
                        NSLog(@"imagePath : %@", imagePath);
                        
                        NSString *textContent=@"";
                        textContent = [elementArr[i] textContent];
                        textContent = [textContent urlEncodeUsingEncoding:NSUTF8StringEncoding];
                        textContent = [textContent stringByReplacingOccurrencesOfString:@"%22" withString:@"%5C%22"];
                        textContent = [textContent stringByReplacingOccurrencesOfString:@"%27" withString:@"%5C%27"];
                        
                        if (imagePath!=nil && textContent!=nil) {
                            if(![textContent isEqualToString:@""]){
                                [tmpArr addObject:textContent];
                            }
                            [tmpArr addObject:imagePath];
                            
                        }else{
                            NSString *textContent=@"";
                            textContent = [elementArr[i] textContent];
                            textContent = [textContent urlEncodeUsingEncoding:NSUTF8StringEncoding];
                            textContent = [textContent stringByReplacingOccurrencesOfString:@"%22" withString:@"%5C%22"];
                            textContent = [textContent stringByReplacingOccurrencesOfString:@"%27" withString:@"%5C%27"];
                            
                            [tmpArr addObject:textContent];
                        }
                    }
                    
                    
                } else if([[elementArr[i] tagName] isEqualToString:@"br"]){
                    [tmpArr addObject:@"%5Cn"];
                }
                
            } else {
                [tmpArr addObject:@"%5Cn"];
            }
        }
        
        NSLog(@"tmpArr : %@", tmpArr);
        NSMutableArray *arr = [NSMutableArray array];
        NSString *textStr=@"";
        for(int i=0; i<tmpArr.count; i++){
            if([tmpArr[i] rangeOfString:@"https://"].location!=NSNotFound || [tmpArr[i] rangeOfString:@"http://"].location!=NSNotFound){
                if(![textStr isEqualToString:@""]){
                    NSMutableDictionary *textDic = [NSMutableDictionary dictionary];
                    [textDic setObject:textStr forKey:@"VALUE"];
                    [textDic setObject:@"TEXT" forKey:@"TYPE"];
                    [arr addObject:textDic];
                }
                NSMutableDictionary *imgDic = [NSMutableDictionary dictionary];
                [imgDic setObject:[tmpArr objectAtIndex:i] forKey:@"VALUE"];
                [imgDic setObject:@"IMG" forKey:@"TYPE"];
                NSLog(@"[tmpArr objectAtIndex:i] : %@", [tmpArr objectAtIndex:i]);
                [arr addObject:imgDic];
                
                textStr=@"";
            } else {
                textStr = [textStr stringByAppendingString:[tmpArr objectAtIndex:i]];
            }
        }
        if(![textStr isEqualToString:@""]){
            NSMutableDictionary *textDic = [NSMutableDictionary dictionary];
            [textDic setObject:textStr forKey:@"VALUE"];
            [textDic setObject:@"TEXT" forKey:@"TYPE"];
            [arr addObject:textDic];
        }
        //NSLog(@"arr : %@", arr);
        
        NSError *error;//NSJSONWritingPrettyPrinted
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arr options:0 error:&error];
        NSString *returnString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"returnString : %@",returnString);
        return returnString;
        
    } @catch (NSException *exception) {
        //[self sendToHilee:[NSString stringWithFormat:@"%s", __func__] :exception];
    }
}

-(void)findChildNode :(HTMLElement *)element{
    if([element childNodesCount]>0){
        for(int i=0; i<[element childNodesCount]; i++){
            [self findChildNode:[[element childNodes] objectAtIndex:i]];
        }
        
        if([[[element className] substringToIndex:1] isEqualToString:@"p"]){
            [elementArr addObject:@"br"];
        }
        
    } else {
        if([[element className] isEqualToString:@"HTMLText"]){
            //NSLog(@"text : %@", [element textContent]);
            [elementArr addObject:element];
            
        } else {
            if([[element tagName] isEqualToString:@"img"]){
                [elementArr addObject:element];
            }
        }
    }
    //NSLog(@"elementArr : %@", elementArr);
}

#pragma mark - UIToolbar Button Action
- (IBAction)photo:(id)sender{
    [self.textView resignFirstResponder];
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *takePictureAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"사진촬영", @"사진촬영")
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action){
                                                                  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                                                                      [self cameraAccessCheck];
                                                                  }else{
                                                                      [actionSheet dismissViewControllerAnimated:YES completion:nil];
                                                                  }
                                                              }];
    UIAlertAction *selectPhotoAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"사진선택", @"사진선택")
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action){
                                                                  [self photoAccessCheck:@"PHOTO"];
                                                                  [actionSheet dismissViewControllerAnimated:YES completion:nil];
                                                              }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"취소", @"취소")
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action){
                                                             
                                                             [actionSheet dismissViewControllerAnimated:YES completion:nil];
                                                         }];
    
    [actionSheet addAction:takePictureAction];
    [actionSheet addAction:selectPhotoAction];
    [actionSheet addAction:cancelAction];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}


- (IBAction)video:(id)sender{
    [self.textView resignFirstResponder];
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"" message:@"개발중인 기능입니다." preferredStyle:UIAlertControllerStyleAlert];
    
    [self presentViewController:alert animated:YES completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alert dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)cameraAccessCheck {
    //NSLog(@"%s", __func__);
    @try{
        int osVer = [[UIDevice currentDevice].systemVersion floatValue];
        //NSLog(@"OS VER : %d", osVer);
        [self photoAccessCheck:@"CAMERA"];
        
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if(status == AVAuthorizationStatusAuthorized) {
            //NSLog(@"AVAuthorizationStatusAuthorized status : %ld", (long)status);
            NSLog(@"카메라 접근 허용일 경우");
            dispatch_async(dispatch_get_main_queue(), ^{
                self.picker = [[UIImagePickerController alloc] init];
                self.picker.delegate = self;
                self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:self.picker animated:YES completion:nil];
            });
            
        } else if(status == AVAuthorizationStatusDenied) {
            //NSLog(@"AVAuthorizationStatusDenied status : %ld", (long)status);
            NSLog(@"카메라 접근 허용되지않았을 경우");
            if(osVer >= 8){
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"기기의 [설정 > 개인정보보호 > 카메라]에서 MFINITY_SNS 앱을 켜주세요." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                     [[UIApplication sharedApplication] openURL:url];
                                                                     
                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                                 }];
                
                UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                                     }];
                [alert addAction:okButton];
                [alert addAction:cancelButton];
                [self presentViewController:alert animated:YES completion:nil];
                
            } else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"기기의 [설정 > 개인정보보호 > 카메라]에서 MFINITY_SNS 앱을 켜주세요." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                     [[UIApplication sharedApplication] openURL:url];
                                                                     
                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                                 }];
                
                UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                                     }];
                [alert addAction:okButton];
                [alert addAction:cancelButton];
                [self presentViewController:alert animated:YES completion:nil];
            }
            
        } else if(status == AVAuthorizationStatusNotDetermined){ // not determined
            //NSLog(@"AVAuthorizationStatusNotDetermined status : %ld", (long)status);
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if(granted){ // Access has been granted ..do something
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.picker = [[UIImagePickerController alloc] init];
                        self.picker.delegate = self;
                        self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                        [self presentViewController:self.picker animated:YES completion:nil];
                    });
                    
                } else { // Access denied ..do something
                    if(osVer >= 8){
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"기기의 [설정 > 개인정보보호 > 카메라]에서 MFINITY_SNS 앱을 켜주세요." preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
                                                                         handler:^(UIAlertAction * action) {
                                                                             NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                             [[UIApplication sharedApplication] openURL:url];
                                                                             
                                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                                         }];
                        
                        UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault
                                                                             handler:^(UIAlertAction * action) {
                                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                                             }];
                        [alert addAction:okButton];
                        [alert addAction:cancelButton];
                        [self presentViewController:alert animated:YES completion:nil];
                        
                    } else {
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"기기의 [설정 > 개인정보보호 > 카메라]에서 MFINITY_SNS 앱을 켜주세요." preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
                                                                         handler:^(UIAlertAction * action) {
                                                                             NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                             [[UIApplication sharedApplication] openURL:url];
                                                                             
                                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                                         }];
                        
                        UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault
                                                                             handler:^(UIAlertAction * action) {
                                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                                             }];
                        [alert addAction:okButton];
                        [alert addAction:cancelButton];
                        [self presentViewController:alert animated:YES completion:nil];
                    }
                    
                }
            }];
        } else {
            NSLog(@"status : %ld", (long)status);
        }
        
    } @catch (NSException *exception) {
        //[self sendToHilee:[NSString stringWithFormat:@"%s", __func__] :exception];
    }
}

- (void)photoAccessCheck :(NSString *)mediaType{
    //NSLog(@"%s", __func__);
    
    @try{
        int osVer = [[UIDevice currentDevice].systemVersion floatValue];
        PHAuthorizationStatus photoStatus = [PHPhotoLibrary authorizationStatus];
        
        if (photoStatus == PHAuthorizationStatusAuthorized) {
            //NSLog(@"Access has been granted.");
            if([mediaType isEqualToString:@"PHOTO"]){
                [self performSegueWithIdentifier:@"POST_MODIFY_PHLIB_MODAL" sender:@"PHOTO"];
            }
            
        } else if (photoStatus == PHAuthorizationStatusDenied) {
            //NSLog(@"Access has been denied.");
            if(osVer >= 8){
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"기기의 [설정 > 개인정보보호 > 사진]에서 MFINITY_SNS 앱을 켜주세요." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                     [[UIApplication sharedApplication] openURL:url];
                                                                     
                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                                 }];
                
                UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                                     }];
                [alert addAction:okButton];
                [alert addAction:cancelButton];
                [self presentViewController:alert animated:YES completion:nil];
                
            } else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"기기의 [설정 > 개인정보보호 > 사진]에서 MFINITY_SNS 앱을 켜주세요." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                     [[UIApplication sharedApplication] openURL:url];
                                                                     
                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                                 }];
                
                UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                                     }];
                [alert addAction:okButton];
                [alert addAction:cancelButton];
                [self presentViewController:alert animated:YES completion:nil];
            }
            
        } else if (photoStatus == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    NSLog(@"1 StatusNotDetermined Access has been granted.");
                    if([mediaType isEqualToString:@"PHOTO"]){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self performSegueWithIdentifier:@"POST_MODIFY_PHLIB_MODAL" sender:@"PHOTO"];
                        });
                    }
                    
                } else {
                    NSLog(@"2 StatusNotDetermined Access has been granted.");
                }
            }];
        } else if (photoStatus == PHAuthorizationStatusRestricted) {
            NSLog(@"Restricted access - normally won't happen.");
        }
        
        return;
    } @catch (NSException *exception) {
        //[self sendToHilee:[NSString stringWithFormat:@"%s", __func__] :exception];
    }
}



#pragma mark - MFURLSession Delegate
-(void)returnDataWithObject:(MFURLSession *)session error:(NSString *)error{
    [SVProgressHUD dismiss];
    if (error!=nil) {
        NSLog(@"return error : %@",error);
        NSString *errorMsg = [NSString stringWithFormat:@"%@\n%@",session.url,error];
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"msg18", @"") message:errorMsg delegate:self cancelButtonTitle:NSLocalizedString(@"msg3", @"") otherButtonTitles:nil, nil];
        [alert show];
        
    } else{
        NSString *wsName = [[session.url absoluteString] lastPathComponent];
        if ([wsName isEqualToString:@"savePostComment"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_CommentEdit" object:nil userInfo:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
            
        } else if([wsName isEqualToString:@"savePost"]) {
            NSString *affected = [session.returnDictionary objectForKey:@"AFFECTED"];
            if ([affected intValue]>0) {
                [self dismissViewControllerAnimated:YES completion:^(void){
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_PostModify" object:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_SavePost" object:nil];
                }];
            }
            
        } else if([wsName isEqualToString:@"saveTaskComment"]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_TaskCommentEdit" object:nil userInfo:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

#pragma mark - MFURLSession Upload Delegate
-(void)returnDictionary:(NSDictionary *)dictionary WithError:(NSString *)error{
    @try{
        uploadCount++;
        if (error != nil) {
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            [alert showError:self title:NSLocalizedString(@"오류", @"오류")
                    subTitle:error
            closeButtonTitle:NSLocalizedString(@"확인", @"확인") duration:0.0f];
        }else{
            [SVProgressHUD show];
            NSLog(@"6=================================");
            NSLog(@"dictionary : %@", dictionary);
            
            NSString *result = [dictionary objectForKey:@"RESULT"];
            if ([result isEqualToString:@"SUCCESS"]) {
                if ([dictionary objectForKey:@"FILE_URL"]==nil) {
                    NSLog(@"error");
                    
                }else{
                    NSLog(@"7================================= 여기서 잘못됐나");
                    if(!isOrder) [self.imageFileNameArray addObject:[dictionary objectForKey:@"FILE_URL"]];
                    NSLog(@"uploadCount : %d, imageIndexArray.count : %lu", uploadCount, (unsigned long)self.imageIndexArray.count);
                    
                    if (uploadCount==self.imageIndexArray.count) {
                        NSString *content = [self createContentJSONArray];
                        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                        NSString *myUserNo = [prefs objectForKey:@"CUSER_NO"];
                        
                        [SVProgressHUD dismiss];
                        
                        NSLog(@"content : %@", content);
                        NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&snsNo=%@&postNo=%@&content=%@", myUserNo, self.snsNo, self.postNo, content];
                        [self callWebService:@"savePost" WithParameter:paramString];
                    }
                }
                
            } else {
                NSLog(@"업로드실패");
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"업로드실패" message:@"재시도 하시겠습니까?" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                                     
                                                                     self.imageIndexArray = [NSMutableArray array];
                                                                     [self saveButtonPressed:nil];
                                                                 }];
                
                UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                                     }];
                
                [alert addAction:okButton];
                [alert addAction:cancelButton];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
        
    } @catch (NSException *exception) {
        //[self sendToHilee:[NSString stringWithFormat:@"%s", __func__] :exception];
    }
    [SVProgressHUD dismiss];
}

- (void)returnResponse:(NSURLResponse *)response WithError:(NSString *)error{
    NSLog(@"%s, %@", __func__, error);
}

- (void)imageViewInTextView:(NSArray *)array{
    //NSLog(@"image : %@", image);
    NSLog(@"array : %@",array);
    
    @try{
        NSRange cursorPosition = [self.textView selectedRange];
        cursorPosition = NSMakeRange(0, 0); //이렇게 하는게 맞나?
        
        //NSMutableAttributedString *resultStr = [[NSMutableAttributedString alloc] initWithString:@"" attributes:@{ @"myCustomTag" : @(YES) }];
        NSMutableAttributedString *resultStr = [[NSMutableAttributedString alloc] init];
        NSString *textContent;
        NSString *originImg;
        NSString *thumbImg;
        
        MFDBHelper *dbHelper = [[MFDBHelper alloc] init];
        
        for(int i=0; i<array.count; i++){
            NSString *type = [[array objectAtIndex:i] objectForKey:@"TYPE"];
            
            if([type isEqualToString:@"TEXT"]){
                textContent = [[array objectAtIndex:i] objectForKey:@"VALUE"];
                
                NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:[NSString urlDecodeString:textContent]];
                [resultStr appendAttributedString:attributedString];
                
                //NSAttributedString *newLine = [[NSAttributedString alloc] initWithString:@"\n"];
                //[resultStr appendAttributedString:newLine];
                
            } else {
                originImg = [[[array objectAtIndex:i] objectForKey:@"VALUE"] objectForKey:@"ORIGIN"];
                thumbImg = [[[array objectAtIndex:i] objectForKey:@"VALUE"] objectForKey:@"THUMB"];
                
                NSDictionary *attrs = @{NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName:[UIFont systemFontOfSize:17]};
                NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]init];
                NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
                
                UIImage *img = [dbHelper saveThumbImage:@"cache" :[NSString urlDecodeString:originImg]];
                //NSLog(@"img : %@", img);
                
                
                if(img!=nil){
                    [imgCache storeImage:img forKey:[NSString urlDecodeString:originImg] toDisk:YES];
                }
                
                [imgCache queryDiskCacheForKey:[NSString urlDecodeString:originImg] done:^(UIImage *image, SDImageCacheType cacheType) {
                    if(image!=nil){
                        NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
                        [attributedString replaceCharactersInRange:cursorPosition withAttributedString:attrStringWithImage];
                        [attributedString addAttributes:attrs range:cursorPosition];
                        [resultStr appendAttributedString:attributedString];
                        
                        textAttachment.image = [self getScaledImage:image scaledToMaxWidth:self.textView.frame.size.width-10];
                        //textAttachment.image = image;
                        textAttachment.bounds = CGRectMake(10, 20, textAttachment.image.size.width, textAttachment.image.size.height);
                        
                        [self.contentImageArray addObject:textAttachment.image];
                        [self.imageArray addObject:textAttachment.image];
                        
                        //NSLog(@"self.contentImageArray : %@", self.contentImageArray);
                        //NSLog(@"self.imageArray : %@", self.imageArray);
                    }
                }];
                
                /*
                 SDWebImageManager *manager = [SDWebImageManager sharedManager];
                 [manager downloadImageWithURL:[NSURL URLWithString:[NSString urlDecodeString:originImg]] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                 
                 } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                 if (image){
                 //NSLog(@"image : %@", image);
                 CGSize size;
                 
                 size.width = self.view.frame.size.width-30;
                 float scale = (self.view.frame.size.width-30)/image.size.width;
                 
                 size.height = image.size.height * scale; // cell.ImageView.frame.size.height;
                 UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
                 
                 //draw
                 [image drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
                 
                 UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
                 UIGraphicsEndImageContext();
                 
                 
                 NSDictionary *attrs = @{ NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName : [UIFont systemFontOfSize:17] };
                 NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]init];
                 //[attributedString appendAttributedString:self.textView.attributedText];
                 NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
                 
                 textAttachment.image = [self getScaledImage:scaledImage scaledToMaxWidth:self.textView.frame.size.width-10];
                 textAttachment.bounds = CGRectMake(10, 20, textAttachment.image.size.width, textAttachment.image.size.height);
                 
                 NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
                 [attributedString replaceCharactersInRange:cursorPosition withAttributedString:attrStringWithImage];
                 [attributedString addAttributes:attrs range:cursorPosition];
                 //self.textView.attributedText = attributedString;
                 [resultStr appendAttributedString:attributedString];
                 
                 [self.contentImageArray addObject:textAttachment.image];
                 [self.imageArray addObject:textAttachment.image];
                 
                 //                        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]init];
                 //                        //NSMutableAttributedString *newLineString = [[NSMutableAttributedString alloc]initWithString:@"\n\n" attributes:nil];
                 //                        [attributedString appendAttributedString:self.textView.attributedText];
                 //                        NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
                 //                        textAttachment.image = scaledImage;
                 //
                 //                        NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
                 //                        [attributedString replaceCharactersInRange:cursorPosition withAttributedString:attrStringWithImage];
                 //                        //[attributedString addAttributes:attrs range:cursorPosition];
                 //                        //[attributedString appendAttributedString:newLineString];
                 //                        [resultStr appendAttributedString:attributedString];
                 //
                 //                        [self.contentImageArray addObject:textAttachment.image];
                 //                        [self.imageArray addObject:scaledImage];
                 }
                 }];
                 */
            }
        }
        
        self.textView.attributedText = resultStr;
        //NSLog(@"resultStr : %@", resultStr);
        
        [self.textView setFont:[UIFont systemFontOfSize:17]];
        [self.textView scrollRangeToVisible:cursorPosition];
        
        
    } @catch (NSException *exception) {
        NSLog(@"exception : %@", exception);
        //[self sendToHilee:[NSString stringWithFormat:@"%s", __func__] :exception];
    }
}

- (void)imageViewInTextView:(BOOL)isCamera :(UIImage *)image{
    NSLog(@"image : %@", image);
    @try{
        NSRange cursorPosition = [self.textView selectedRange];
        
        NSDictionary *attrs = @{ NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName : [UIFont systemFontOfSize:17] };
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]init];
        //        NSMutableAttributedString *newLineString = [[NSMutableAttributedString alloc]initWithString:@"\n\n" attributes:attrs];
        [attributedString appendAttributedString:self.textView.attributedText];
        NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
        
        textAttachment.image = [self rotateImage:image byOrientationFlag:image.imageOrientation];
        
        //        CGFloat oldWidth = textAttachment.image.size.width;
        //        CGFloat scaleFactor = oldWidth / (self.textView.frame.size.width - 10);
        //        textAttachment.image = [UIImage imageWithCGImage:textAttachment.image.CGImage scale:scaleFactor orientation:UIImageOrientationUp];
        
        
        textAttachment.image = [self getScaledImage:textAttachment.image scaledToMaxWidth:self.textView.frame.size.width-10];
        textAttachment.bounds = CGRectMake(10, 20, textAttachment.image.size.width, textAttachment.image.size.height);
        
        NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
        [attributedString replaceCharactersInRange:cursorPosition withAttributedString:attrStringWithImage];
        [attributedString addAttributes:attrs range:cursorPosition];
        //        [attributedString appendAttributedString:newLineString];
        self.textView.attributedText = attributedString;
        
        [self.contentImageArray addObject:textAttachment.image];
        [self.imageArray addObject:image];
        
        NSLog(@"self.contentImageArray : %@", self.contentImageArray);
        
        [self.textView setFont:[UIFont systemFontOfSize:17]];
        [self.textView scrollRangeToVisible:cursorPosition];
        
    } @catch (NSException *exception) {
        //[self sendToHilee:[NSString stringWithFormat:@"%s", __func__] :exception];
    }
}


-(void)textViewDidChangeSelection:(UITextView *)textView{
    //NSLog(@"%s",__func__);
    
    /*
     [self.textView.attributedText enumerateAttribute:NSAttachmentAttributeName
     inRange:NSMakeRange(0, [self.textView.attributedText length])
     options:0
     usingBlock:^(id value, NSRange range, BOOL *stop)
     {
     if ([value isKindOfClass:[NSTextAttachment class]]) {
     NSTextAttachment *attachment = (NSTextAttachment *)value;
     UIImage *image = nil;
     
     if ([attachment image]) image = [attachment image];
     else image = [attachment imageForBounds:[attachment bounds] textContainer:nil characterIndex:range.location];
     
     //NSLog(@"range : %lu", (unsigned long)range.location);
     
     NSRange range2 = textView.selectedRange;
     //NSLog(@"range2 : %lu", range2.location);
     
     if(range.location==range2.location-1){
     NSLog(@"사진입니다");
     UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
     UIAlertAction *editAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"순서 편집", @"순서 편집")
     style:UIAlertActionStyleDefault
     handler:^(UIAlertAction * action){
     [actionSheet dismissViewControllerAnimated:YES completion:nil];
     
     UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
     PostModifyViewController2 *vc = (PostModifyViewController2 *)[storyboard instantiateViewControllerWithIdentifier:@"PostModifyViewController2"];
     UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
     //vc.postDic = [self.postDic objectForKey:@"CONTENT"];
     vc.contentArr = contentArr;
     
     [self presentViewController:nav animated:YES completion:^{
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_PostOrderModify:) name:@"noti_PostOrderModify" object:nil];
     }];
     }];
     
     UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"취소", @"취소")
     style:UIAlertActionStyleCancel
     handler:^(UIAlertAction * action){
     [actionSheet dismissViewControllerAnimated:YES completion:nil];
     }];
     [actionSheet addAction:editAction];
     [actionSheet addAction:cancelAction];
     
     [self presentViewController:actionSheet animated:YES completion:nil];
     }
     
     }
     }];
     
     
     //UITextRange *range = [textView selectedTextRange];
     //NSLog(@"text : %@", [textView textInRange:range]);
     
     */
}

-(BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange{
    NSLog(@"%s",__func__);
    
    /*
     UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
     UIAlertAction *editAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"순서 편집", @"순서 편집")
     style:UIAlertActionStyleDefault
     handler:^(UIAlertAction * action){
     [actionSheet dismissViewControllerAnimated:YES completion:nil];
     
     UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
     PostModifyViewController2 *vc = (PostModifyViewController2 *)[storyboard instantiateViewControllerWithIdentifier:@"PostModifyViewController2"];
     UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
     //vc.postDic = [self.postDic objectForKey:@"CONTENT"];
     vc.contentArr = contentArr;
     
     [self presentViewController:nav animated:YES completion:^{
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_PostOrderModify:) name:@"noti_PostOrderModify" object:nil];
     }];
     }];
     
     UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"취소", @"취소")
     style:UIAlertActionStyleCancel
     handler:^(UIAlertAction * action){
     [actionSheet dismissViewControllerAnimated:YES completion:nil];
     }];
     [actionSheet addAction:editAction];
     [actionSheet addAction:cancelAction];
     
     [self presentViewController:actionSheet animated:YES completion:nil];
     */
    
    return NO;
}


- (void)keyboardWillAnimate:(NSNotification *)notification{
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    NSDictionary* info = [notification userInfo];
    //CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    NSLog(@"kbSize : %f, %f",kbSize.width, kbSize.height);
    if (@available(iOS 11.0, *)) {
        kbSize.height = kbSize.height - self.view.safeAreaInsets.bottom;
    } else {
        kbSize.height = kbSize.height;
    }
    
    //NSLog(@"[notification name] : %@",[notification name]);
    if ([notification name]==UIKeyboardWillShowNotification) {
        self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"msg25", @"")
                                                                                style:UIBarButtonItemStylePlain
                                                                               target:self
                                                                               action:@selector(rightSideMenuButtonPressed:)];
        self.keyboardHeight.constant = kbSize.height;
        [self.view layoutIfNeeded];
        
        NSDictionary *attrs = @{ NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName : [UIFont systemFontOfSize:17] };
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]init];
        NSRange cursorPosition = [self.textView selectedRange];
        [attributedString appendAttributedString:self.textView.attributedText];
        [attributedString addAttributes:attrs range:cursorPosition];
        self.textView.attributedText = attributedString;
        
    } else if([notification name]==UIKeyboardWillHideNotification){
        self.keyboardHeight.constant = 0;
        [self.view layoutIfNeeded];
        
    }
    [UIView commitAnimations];
}

#pragma mark - Push Notification
- (void)noti_PostOrderModify:(NSNotification *)notification {
    //NSLog(@"noti_PostOrderModify userInfo : %@", notification.userInfo);
    
    isOrder = YES;
    NSArray *dataSetArr = [notification.userInfo objectForKey:@"DATASET"];
    
    //NSDictionary *dataSetDict= [notification.userInfo objectForKey:@"DATASET"];
    
    self.imageArray = [NSMutableArray array];
    self.imageIndexArray = [NSMutableArray array];
    self.imageFileNameArray = [NSMutableArray array];
    self.contentImageArray = [NSMutableArray array];
    contentArr = [NSArray array];
    uploadCount = 0;
    
    contentArr = dataSetArr;
    NSLog(@"noti_PostOrderModify contentArr : %@", contentArr);
    
    for(int i=0; i<contentArr.count; i++){
        NSString *tmpType = [[contentArr objectAtIndex:i] objectForKey:@"TYPE"];
        NSString *tmpValue;
        if([tmpType isEqualToString:@"IMG"]){
            NSDictionary *valueDic = [[contentArr objectAtIndex:i] objectForKey:@"VALUE"];
            tmpValue = [NSString urlDecodeString:[valueDic objectForKey:@"ORIGIN"]];
            
            [self.imageFileNameArray addObject:tmpValue];
        }
    }
    NSLog(@"imageFileNameArray : %@", self.imageFileNameArray);
    
    [self imageViewInTextView:contentArr];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"noti_PostOrderModify" object:nil];
}


#pragma mark - UIImagePickerController Delegate
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    //NSLog(@"imagePickerController info : %@",info);
    //NSLog(@"UIImagePickerControllerMediaMetadata : %@",[info objectForKey:UIImagePickerControllerMediaMetadata]);
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.movie"]) {
        NSURL *mediaUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        [picker dismissViewControllerAnimated:YES completion:nil];
        
        //thumImage = [self imageFromMovie:mediaUrl atTime:0.0];
        
        UISaveVideoAtPathToSavedPhotosAlbum([mediaUrl path], self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        
    } else {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        [picker dismissViewControllerAnimated:YES completion:nil];
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (UIImage *)imageFromMovie:(NSURL *)movieURL atTime:(NSTimeInterval)time{
    MPMoviePlayerController *mp = [[MPMoviePlayerController alloc]initWithContentURL:movieURL];
    mp.shouldAutoplay = NO;
    mp.initialPlaybackTime = time;
    mp.currentPlaybackTime = time;
    UIImage *thumnail = [mp thumbnailImageAtTime:time timeOption:MPMovieTimeOptionNearestKeyFrame];
    [mp stop];
    
    return thumnail;
}

-(UIImage *) resizedImage:(UIImage *)img inRect:(CGRect)frameRect {
    UIGraphicsBeginImageContext(frameRect.size);
    [img drawInRect:frameRect];
    return UIGraphicsGetImageFromCurrentImageContext();
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        NSLog(@"error: %@", [error localizedDescription]);
    } else {
        NSLog(@"video saved");
        //[self imageViewInTextView:YES :thumImage];
    }
}

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    NSLog(@"%s : %f %f",__FUNCTION__,image.size.width,image.size.height);
    if (error) {
        NSLog(@"error: %@", [error localizedDescription]);
    } else {
        NSLog(@"photo saved");
        [self imageViewInTextView:YES :image];
    }
}
- (UIImage *)rotateImage90:(UIImage *)img
{
    NSLog(@"rotateImage90:");
    
    CGImageRef          imgRef = img.CGImage;
    CGFloat             width = CGImageGetWidth(imgRef);
    CGFloat             height = CGImageGetHeight(imgRef);
    CGRect              bounds = CGRectMake(0, 0, width, height);
    CGFloat             boundHeight;
    
    boundHeight = bounds.size.height;
    bounds.size.height = bounds.size.width;
    bounds.size.width = boundHeight;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * bounds.size.width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(nil, bounds.size.width, bounds.size.height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    
    CGContextRotateCTM (context, DEGREES_TO_RADIANS(270));
    CGContextTranslateCTM (context, -width, 0);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
    CGImageRef newImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    UIImage *imageCopy = [UIImage imageWithCGImage:newImage];
    CFRelease(newImage);
    return imageCopy;
}
- (UIImage *)rotateImageReverse90:(UIImage *)img
{
    NSLog(@"rotateImageReverse90:");
    
    CGImageRef          imgRef = img.CGImage;
    CGFloat             width = CGImageGetWidth(imgRef);
    CGFloat             height = CGImageGetHeight(imgRef);
    CGRect              bounds = CGRectMake(0, 0, width, height);
    CGFloat             boundHeight;
    
    boundHeight = bounds.size.height;
    bounds.size.height = bounds.size.width;
    bounds.size.width = boundHeight;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * bounds.size.width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(nil, bounds.size.width, bounds.size.height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextRotateCTM (context, DEGREES_TO_RADIANS(90));
    CGContextTranslateCTM (context, 0, -height);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
    CGImageRef newImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    UIImage *imageCopy = [UIImage imageWithCGImage:newImage];
    CFRelease(newImage);
    return imageCopy;
}

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
- (UIImage *)rotateImage:(UIImage *)img byOrientationFlag:(UIImageOrientation)orient
{
    NSLog(@"ImageProcessUtil rotateImage");
    
    CGImageRef          imgRef = img.CGImage;
    CGFloat             width = CGImageGetWidth(imgRef);
    CGFloat             height = CGImageGetHeight(imgRef);
    CGRect              bounds = CGRectMake(0, 0, width, height);
    CGFloat             boundHeight;
    NSLog(@"rotate image size width=%f, height=%f, orientation=%ld", width, height, (long)orient);
    
    switch(orient) {
            
        case UIImageOrientationUp:
            break;
            
        case UIImageOrientationDown:
            break;
            
        case UIImageOrientationLeft:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            break;
            
        case UIImageOrientationRight:
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            break;
            
        default:
            break;
    }
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * bounds.size.width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(nil, bounds.size.width, bounds.size.height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    if (orient == UIImageOrientationRight) {
        CGContextRotateCTM (context, DEGREES_TO_RADIANS(270));
        CGContextTranslateCTM (context, -width, 0);
    }
    else if (orient == UIImageOrientationLeft) {
        CGContextRotateCTM (context, DEGREES_TO_RADIANS(90));
        CGContextTranslateCTM (context, 0, -height);
    }
    else if (orient == UIImageOrientationDown) {
        CGContextRotateCTM (context, DEGREES_TO_RADIANS(180));
        CGContextTranslateCTM (context, -width, -height);
    }
    else if (orient == UIImageOrientationUp) {
        // NOTHING
    }
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
    CGImageRef newImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    UIImage *imageCopy = [UIImage imageWithCGImage:newImage];
    CFRelease(newImage);
    return imageCopy;
}

- (void)getImageNotification:(NSNotification *)notification {
    NSLog(@"getImageNotification userInfo : %@", notification.userInfo);
    NSArray *imageArray = [notification.userInfo objectForKey:@"IMG_LIST"];
    for(int i=0; i<imageArray.count; i++){
        [self imageViewInTextView:NO :imageArray[i]];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getImageNotification" object:nil];
}

- (UIImage *)getScaledImage:(UIImage *)image scaledToMaxWidth:(CGFloat)width {
    CGFloat oldWidth = image.size.width;
    CGFloat oldHeight = image.size.height;
    
    CGFloat scaleFactor=1;
    
    //if (oldWidth > width) {
    scaleFactor = width / oldWidth;
    //} else  //oldWidth<width and height==0이면, scale하지 않음.
    //    return image;
    
    CGFloat newHeight = oldHeight * scaleFactor;
    CGFloat newWidth = oldWidth * scaleFactor;
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    
    //NSLog(@"oldWidth : %f, oldHeight : %f", oldWidth, oldHeight);
    //NSLog(@"newWidth : %f, newHeight : %f", newWidth, newHeight);
    
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getImageNotification:) name:@"getImageNotification" object:nil];
    
    if ([[segue identifier] isEqualToString:@"POST_MODIFY_PHLIB_MODAL"]) {
        UINavigationController *destination = segue.destinationViewController;
        PHLibListViewController *vc = [[destination childViewControllers] objectAtIndex:0];
        vc.fromSegue = segue.identifier;
    }
}

-(void)sendToHilee:(NSString *)func :(NSException *)exception{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"exception_msg_exception", @"exception_msg_exception") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* sendButton = [UIAlertAction actionWithTitle:@"관리자에게 전송" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           [alert dismissViewControllerAnimated:YES completion:nil];
                                                           
                                                           UIDevice *device = [UIDevice currentDevice];
                                                           NSString *myUserNo = [[NSUserDefaults standardUserDefaults] objectForKey:@"CUSER_NO"];
                                                           NSString *dvcKind = [device modelName];
                                                           NSString *dvcVer = device.systemVersion;
                                                           
                                                           MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
                                                           if([MFMessageComposeViewController canSendText])
                                                           {
                                                               controller.body = [NSString stringWithFormat:@"%@ / %@ / %@ \n%@ \n\n%@", dvcKind, dvcVer, myUserNo, func, exception];
                                                               controller.recipients = [NSArray arrayWithObject:@"01093917822"];
                                                               controller.messageComposeDelegate = self;
                                                               [self presentViewController:controller animated:YES completion:nil];
                                                           }
                                                       }];
    
    UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                     }];
    
    [alert addAction:sendButton];
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)messageComposeViewController:(nonnull MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    NSString *resultString;
    switch (result) {
        case MessageComposeResultCancelled:
            resultString = NSLocalizedString(@"cancel", @"");
            break;
            
        case MessageComposeResultFailed:
        {
            resultString = NSLocalizedString(@"fail", @"");
            break;
        }
            
        case MessageComposeResultSent:
            resultString = NSLocalizedString(@"success", @"");
            break;
            
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"%s resultString : %@",__FUNCTION__,resultString);
    }];
}

@end
