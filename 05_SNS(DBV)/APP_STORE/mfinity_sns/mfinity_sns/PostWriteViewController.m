//
//  PostEditViewController.m
//  mfinity_sns
//
//  Created by hilee on 2017. 3. 8..
//  Copyright © 2017년 com.dbvalley. All rights reserved.
//

#import "PostWriteViewController.h"
#import "PHLibListViewController.h"
#import "TeamListViewController.h"
#import "PostDetailViewController.h"
#import "MFStyle.h"
#import "SDImageCache.h"


@interface PostWriteViewController () {
    UIImage *thumImage;
    NSMutableArray *elementArr;
    AppDelegate *appDelegate;
}

@end

@implementation PostWriteViewController
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSLog(@"PostWriteViewController fromSegue : %@", self.fromSegue);
    
    self.navigationController.navigationBar.barTintColor = [MFUtil myRGBfromHex:@"1D4696"];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.titleView = [MFStyle navigationTitleStyle1:self.snsName];
    
    if (self.navigationController.childViewControllers.count==1) {
        self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"msg24", @"")
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:self
                                                                              action:@selector(leftSideMenuButtonPressed:)];
    }
    
    self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"msg25", @"")
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(rightSideMenuButtonPressed:)];
    
    self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"msg24", @"")
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(leftBackButtonPressed:)];
    
    [self.textView becomeFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAnimate:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAnimate:) name:UIKeyboardWillHideNotification object:nil];
    
    NSArray *subViews = [self.navigationController.navigationBar subviews];
    for (UIView *subview in subViews) {
        NSString *viewName = [NSString stringWithFormat:@"%@",[subview class]];
        if ([viewName isEqualToString:@"UITextField"]) {
            [subview removeFromSuperview];
        }
    }
    
    self.textView.placeholder = NSLocalizedString(@"글을 작성하세요.", @"글을 작성하세요.");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_NewPostPush:) name:@"noti_NewPostPush" object:nil];
    
    
    UIButton *right1 = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 35, 35)];
    [right1 setImage:[self getScaledImage:[UIImage imageNamed:@"menu_camera.png"] scaledToMaxWidth:35] forState:UIControlStateNormal];
    [right1 addTarget:self action:@selector(photo:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBtn1 = [[UIBarButtonItem alloc]initWithCustomView:right1];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray *barButtonArr = [[NSArray alloc] initWithObjects:rightBtn1, flexibleSpace, flexibleSpace, nil];
    self.toolBar.items = barButtonArr;
    
    //    [self.photoButton setImage:[self getScaledImage:[UIImage imageNamed:@"menu_album.png"] scaledToMaxWidth:35]];
    //    [self.photoButton setTintColor:[UIColor clearColor]];
    //    [self.videoButton setImage:[self getScaledImage:[UIImage imageNamed:@"menu_movie.png"] scaledToMaxWidth:35]];
    
    //[self.photoButton setImage:[UIImage imageNamed:@"menu_album.png"]];
    //[self.videoButton setImage:[UIImage imageNamed:@"menu_movie.png"]];
    
    self.contentImageArray = [NSMutableArray array];
    self.imageArray = [NSMutableArray array];
    self.imageIndexArray = [NSMutableArray array];
    self.imageFileNameArray = [NSMutableArray array];
    
    elementArr = [NSMutableArray array];
    uploadCount = 0;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.isMovingFromParentViewController || self.isBeingDismissed) {
        
    }
}

- (void)noti_NewPostPush:(NSNotification *)notification {
    @try{
        if(notification.userInfo!=nil){
            NSString *message = [notification.userInfo objectForKey:@"MESSAGE"];
            NSDictionary *dict = [NSDictionary dictionary];
            if(message!=nil){
                NSData *jsonData = [message dataUsingEncoding:NSUTF8StringEncoding];
                NSError *error;
                dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
            } else {
                dict = notification.userInfo;
            }
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            PostDetailViewController *vc = (PostDetailViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PostDetailViewController"];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            
            vc.fromSegue = @"NOTI_POST_DETAIL";
            vc.notiPostDic = dict;
            [self presentViewController:nav animated:YES completion:nil];
        }
        
    } @catch (NSException *exception) {
        //[self sendToHilee:[NSString stringWithFormat:@"%s", __func__] :exception];
    }
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
    //NSLog(@"kbSize : %f, %f",kbSize.width, kbSize.height);
    
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
        
    }else if([notification name]==UIKeyboardWillHideNotification){
        self.keyboardHeight.constant = 0;
        [self.view layoutIfNeeded];
        
    }
    [UIView commitAnimations];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Post Edit Utils
- (void)callWebService:(NSString *)serviceName WithParameter:(NSString *)paramString{
    NSString *urlString = appDelegate.main_url;
    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:serviceName]];
    MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
    session.delegate = self;
    
    if ([session start]) {
        [SVProgressHUD show];
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
            NSLog(@"fileName : %@", fileName);
            
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
        //[dateFormatter setDateFormat:@"yyMMdd-HHmmss.SSS"];
        [dateFormatter setDateFormat:@"yyMMdd-HHmmss"];
        NSString *currentTime = [dateFormatter stringFromDate:today];
        NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"USER_ID"];
        fileName = [NSString stringWithFormat:@"%@(%@).png",userID,currentTime];
        return fileName;
        
    } @catch (NSException *exception) {
        //[self sendToHilee:[NSString stringWithFormat:@"%s", __func__] :exception];
    }
}

- (NSArray *)getImageFilesInTextView{
    NSMutableArray *imagesArray = [[NSMutableArray alloc] init];
    
    @try{
        [self.textView.attributedText enumerateAttribute:NSAttachmentAttributeName
                                                 inRange:NSMakeRange(0, [self.textView.attributedText length])
                                                 options:0
                                              usingBlock:^(id value, NSRange range, BOOL *stop)
         {
             if ([value isKindOfClass:[NSTextAttachment class]])
             {
                 NSTextAttachment *attachment = (NSTextAttachment *)value;
                 UIImage *image = nil;
                 if ([attachment image])
                     image = [attachment image];
                 else
                     image = [attachment imageForBounds:[attachment bounds]
                                          textContainer:nil
                                         characterIndex:range.location];
                 
                 if (image)
                     [imagesArray addObject:image];
             }
         }];
        
        //NSLog(@"self.contentImageArray : %@", self.contentImageArray);
        
        for (int i=0; i<self.contentImageArray.count; i++) {
            for (int j=0; j<imagesArray.count; j++) {
                if ([self.contentImageArray[i] isEqual:imagesArray[j]]) {
                    [self.imageIndexArray addObject:[NSNumber numberWithInt:i]];
                    //NSLog(@"imageIndexArray1 : %@", self.imageIndexArray);
                }
            }
        }
        
        return self.imageIndexArray;
        
    } @catch (NSException *exception) {
        //[self sendToHilee:[NSString stringWithFormat:@"%s", __func__] :exception];
    }
}

- (void)saveAttachedFile{
    NSLog(@"self.imageIndexArray : %@", self.imageIndexArray);
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
        ///[self sendToHilee:[NSString stringWithFormat:@"%s", __func__] :exception];
    }
}

- (NSString *)createContentJSONArray{
    //[NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.html]
    NSDictionary *documentAttributes = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)};
    
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
    
    NSLog(@"bodyArr : %@", bodyArr);
    
    NSMutableArray *tmpArr = [NSMutableArray array];
    //NSString *contentStr=@"";
    
    @try {
        for (int i=0; i<paragraphs.count; i++) {
            //NSMutableDictionary *content = [NSMutableDictionary dictionary];
            //NSMutableDictionary *content2 = [NSMutableDictionary dictionary];
            HTMLElement *p = [paragraphs objectAtIndex:i];
            //            NSLog(@"p : %@", p);
            //            NSLog(@"p child : %@", [p childNodes]);
            //            NSLog(@"p child2 : %@", [[[p childNodes] objectAtIndex:0] childNodes]);
            
            
            //수정
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
             //NSLog(@"textContent : %@", textContent);
             
             textContent = [textContent urlEncodeUsingEncoding:NSUTF8StringEncoding];
             textContent = [textContent stringByReplacingOccurrencesOfString:@"%22" withString:@"%5C%22"];
             textContent = [textContent stringByReplacingOccurrencesOfString:@"%27" withString:@"%5C%27"];
             
             [tmpArr addObject:textContent];
             [tmpArr addObject:@"%5Cn"];
             }*/
            
            
        }
        
        NSLog(@"elementArr : %@", elementArr);
        for(int i=0; i<elementArr.count; i++){
            if([[NSString stringWithFormat:@"%@",elementArr[i]] hasPrefix:@"<HTMLText:"]){
                //if([[elementArr[i] className] isEqualToString:@"HTMLText"]){
                NSString *textContent=@"";
                
                textContent = [elementArr[i] textContent];
                
                textContent = [textContent urlEncodeUsingEncoding:NSUTF8StringEncoding];
                textContent = [textContent stringByReplacingOccurrencesOfString:@"%22" withString:@"%5C%22"];
                textContent = [textContent stringByReplacingOccurrencesOfString:@"%27" withString:@"%5C%27"];
                
                //NSLog(@"textContent : %@", textContent);
                
                [tmpArr addObject:textContent];
                //[tmpArr addObject:@"%5Cn"];
                
            } else if([[NSString stringWithFormat:@"%@",elementArr[i]] hasPrefix:@"<HTMLElement:"]){
                if([[elementArr[i] tagName] isEqualToString:@"img"]){
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
                            if(![textContent isEqual:@""]){
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
        
        
        //NSLog(@"tmpArr : %@", tmpArr);
        NSMutableArray *arr = [NSMutableArray array];
        NSString *textStr=@"";
        for(int i=0; i<tmpArr.count; i++){
            if([tmpArr[i] rangeOfString:@"https://"].location!=NSNotFound || [tmpArr[i] rangeOfString:@"http://"].location != NSNotFound){
                if(![textStr isEqualToString:@""]){
                    NSMutableDictionary *textDic = [NSMutableDictionary dictionary];
                    [textDic setObject:textStr forKey:@"VALUE"];
                    [textDic setObject:@"TEXT" forKey:@"TYPE"];
                    [arr addObject:textDic];
                }
                NSMutableDictionary *imgDic = [NSMutableDictionary dictionary];
                [imgDic setObject:[tmpArr objectAtIndex:i] forKey:@"VALUE"];
                [imgDic setObject:@"IMG" forKey:@"TYPE"];
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
        //NSLog(@"[element className]1 : %@", [element className]);
        for(int i=0; i<[element childNodesCount]; i++){
            [self findChildNode:[[element childNodes] objectAtIndex:i]];
        }
        
        if([[[element className] substringToIndex:1] isEqualToString:@"p"]){
            [elementArr addObject:@"br"];
        }
        
    } else {
        NSLog(@"element : %@", [NSString stringWithFormat:@"%@", element]);
        //NSLog(@"element className : %@", [element className]);
        
        if([[element className] isEqualToString:@"HTMLText"]){
            //NSLog(@"text : %@", [element textContent]);
            [elementArr addObject:element];
            
            
        } else {
            //NSLog(@"element tag : %@", [element tagName]);
            if([[element tagName] isEqualToString:@"img"]){
                [elementArr addObject:element];
                
            } /*else if([[element tagName] isEqualToString:@"br"]){
               [elementArr addObject:element];
               }*/
        }
    }
    //NSLog(@"elementArr : %@", elementArr);
}

#pragma mark - UITextView Delegate
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    //backspace event
    if (range.length == 1 && [text length] == 0) {
        
    }
    return YES;
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
            NSLog(@"dictionary : %@", dictionary);
            //[self.imageFileNameArray addObject:[dictionary objectForKey:@"FILE_URL"]];
            //NSLog(@"uploadCount : %d",uploadCount);
            //NSLog(@"self.imageIndexArray.count : %lu",(unsigned long)self.imageIndexArray.count);
            //NSLog(@"self.imageFileNameArray.count : %lu",self.imageFileNameArray.count);
            //NSLog(@"[dictionary objectForKey:@\"FILE_URL\"] : %@",[dictionary objectForKey:@"FILE_URL"]);
            
            NSString *result = [dictionary objectForKey:@"RESULT"];
            if ([result isEqualToString:@"SUCCESS"]) {
                if ([dictionary objectForKey:@"FILE_URL"]==nil) {
                    NSLog(@"error");
                    
                }else{
                    [self.imageFileNameArray addObject:[dictionary objectForKey:@"FILE_URL"]];
                    NSLog(@"self.imageFileNameArray : %@", _imageFileNameArray);
                    NSLog(@"uploadCount : %d, imageIndexArray.count : %lu", uploadCount, (unsigned long)self.imageIndexArray.count);
                    if (uploadCount==self.imageIndexArray.count) {
                        NSString *content = [self createContentJSONArray];
                        NSLog(@"content : %@", content);
                        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                        NSString *myUserNo = [prefs objectForKey:@"CUSER_NO"];
                        
                        [SVProgressHUD dismiss];
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

#pragma mark - MFURLSession Delegate
- (void)returnDataWithObject:(MFURLSession *)session error:(NSString *)error{
    if (error != nil) {
        NSString *errorMsg = [NSString stringWithFormat:@"%@\n%@",session.url,error];
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"msg18", @"") message:errorMsg delegate:self cancelButtonTitle:NSLocalizedString(@"msg3", @"") otherButtonTitles:nil, nil];
        [alert show];
    }else{
        NSLog(@"dic : %@",session.returnDictionary);
        NSString *wsName = [[session.url absoluteString] lastPathComponent];
        NSString *result = [session.returnDictionary objectForKey:@"RESULT"];
        //NSLog(@"wsName : %@",wsName);
        if ([result isEqualToString:@"SUCCESS"]) {
            if ([wsName isEqualToString:@"getPostNo"]) {
                self.postNo = [[[session.returnDictionary objectForKey:@"DATASET"] objectAtIndex:0] objectForKey:@"SEQ"];
                
                NSArray *imageIndexArray = [self getImageFilesInTextView];
                if (imageIndexArray.count>0) {
                    [self saveAttachedFile];
                }else{
                    NSString *content = [self createContentJSONArray];
                    NSLog(@"content : %@", content);
                    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                    NSString *myUserNo = [prefs objectForKey:@"CUSER_NO"];
                    
                    NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&snsNo=%@&postNo=%@&content=%@",myUserNo, self.snsNo, self.postNo, content];
                    [self callWebService:@"savePost" WithParameter:paramString];
                }
                
            }else if ([wsName isEqualToString:@"savePost"]) {
                NSString *affected = [session.returnDictionary objectForKey:@"AFFECTED"];
                if ([affected intValue]>0) {
                    [self dismissViewControllerAnimated:YES completion:^(void){
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_SavePost"
                                                                            object:nil
                                                                          userInfo:@{@"RESULT":@"SUCCESS"}];
                    }];
                    
                }
            }
        }else{
            NSString *errorMsg = [NSString stringWithFormat:@"%@\n%@",session.url,error];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"msg18", @"") message:errorMsg delegate:self cancelButtonTitle:NSLocalizedString(@"msg3", @"") otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    [SVProgressHUD dismiss];
}

- (void)returnError:(MFURLSession *)session error:(NSError *)error{
    NSLog(@"error : %@", error);
}


#pragma mark - UINavigationBar Button Action
- (void)leftSideMenuButtonPressed:(id)sender {
    NSLog(@"%s", __func__);
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)leftBackButtonPressed:(id)sender {
    NSLog(@"%s", __func__);
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"UIKeyboardWillHideNotification" object:nil userInfo:nil];
    [self.textView resignFirstResponder];
    
    @try{
        NSString *textStr = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        //NSLog(@"textStr : %@", textStr);
        //NSLog(@"self.textView.attributedText.length : %lu", (unsigned long)self.textView.attributedText.length);
        
        if(self.textView.attributedText.length==0 && [textStr isEqualToString:@""]){
            NSLog(@"fromSegue : %@", self.fromSegue);
            if([self.fromSegue isEqualToString:@"POST_WRITE_MODAL"] || [self.fromSegue isEqualToString:@"POST_WRITE_PUSH"] || [self.fromSegue isEqualToString:@"BOARD_POST_WRITE_MODAL"]){
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"이 화면을 나가시겠습니까?\n작성중인 내용은 모두 삭제됩니다." delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"확인", nil];
            alert.tag = 3;
            [alert show];
        }
        
        //    NSArray *imgArray = [self getImageFilesInTextView];
        //    NSString *textStr = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        //    //NSLog(@"imgArray : %@", imgArray);
        //    //NSLog(@"textStr : %@", textStr);
        //
        //    if (imgArray.count < 1 && [textStr isEqualToString:@""]) {
        //        if([self.fromSegue isEqualToString:@"POST_WRITE_MODAL"]){
        //            [self dismissViewControllerAnimated:YES completion:nil];
        //        } else {
        //            [self.navigationController popViewControllerAnimated:YES];
        //        }
        //    }else{
        //        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"이 화면을 나가시겠습니까?\n작성중인 내용은 모두 삭제됩니다." delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"확인", nil];
        //        alert.tag = 3;
        //        [alert show];
        //    }
        
    } @catch (NSException *exception) {
        //[self sendToHilee:[NSString stringWithFormat:@"%s", __func__] :exception];
    }
}

- (void)rightSideMenuButtonPressed:(id)sender {
    [self.textView resignFirstResponder];
    
    @try{
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
        
        //    NSArray *imgArray = [self getImageFilesInTextView];
        //    NSString *textStr = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        //    //NSLog(@"imgArray : %@", imgArray);
        //    //NSLog(@"textStr : %@", textStr);
        //
        //    if (imgArray.count < 1 && [textStr isEqualToString:@""]) {
        //
        //    } else{
        //        self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"저장", @"저장")
        //                                                                                style:UIBarButtonItemStylePlain
        //                                                                               target:self
        //                                                                               action:@selector(saveButtonPressed:)];
        //    }
        
    } @catch (NSException *exception) {
        [self sendToHilee:[NSString stringWithFormat:@"%s", __func__] :exception];
    }
}

- (void)saveButtonPressed:(id)sender {
    NSLog(@"snsNo : %@", self.snsNo);
    NSLog(@"postNo : %@", self.postNo);
    
    @try{
        [self callWebService:@"getPostNo" WithParameter:nil];
        
        //        NSArray *imageIndexArray = [self getImageFilesInTextView];
        //        //NSLog(@"imageIndexArray : %@", imageIndexArray);
        //        if (imageIndexArray.count>0) {
        //            [self saveAttachedFile];
        //        }else{
        //            NSString *content = [self createContentJSONArray];
        //            //NSString *usrID = [[NSUserDefaults standardUserDefaults] objectForKey:@"USER_ID"];
        //            //NSString *dvcID = [MFUtil getUUID];
        //            //NSString *senderID = [NSString stringWithFormat:@"USER.%@.%@",usrID, dvcID];
        //            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        //            NSString *myUserNo = [prefs objectForKey:@"CUSER_NO"];
        //
        //            NSString *paramString = [NSString stringWithFormat:@"usrNo=%@&snsNo=%@&postNo=%@&content=%@",myUserNo, self.snsNo, self.postNo, content];
        //            [self callWebService:@"savePost" WithParameter:paramString];
        //        }
        
    } @catch (NSException *exception) {
        //[self sendToHilee:[NSString stringWithFormat:@"%s", __func__] :exception];
    }
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
                [self performSegueWithIdentifier:@"POST_PHLIB_MODAL" sender:@"PHOTO"];
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
                            [self performSegueWithIdentifier:@"POST_PHLIB_MODAL" sender:@"PHOTO"];
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



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1 && alertView.tag != 3){
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
    } else if(buttonIndex == 1 && alertView.tag == 3) {
        NSLog(@"### fromSegue : %@", self.fromSegue);
        if([self.fromSegue isEqualToString:@"POST_WRITE_PUSH"] || [self.fromSegue isEqualToString:@"BOARD_POST_WRITE_MODAL"]){
            [self dismissViewControllerAnimated:YES completion:nil];
        } else{
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    } else {
        
    }
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
    
    /*
     NSLog(@"[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera] : %@",[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera]);
     UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
     UIAlertAction *takePictureAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"영상촬영", @"영상촬영")
     style:UIAlertActionStyleDefault
     handler:^(UIAlertAction * action){
     if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
     self.picker = [[UIImagePickerController alloc] init];
     self.picker.delegate = self;
     self.picker.allowsEditing = NO;
     self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
     self.picker.mediaTypes =[[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
     self.picker.videoQuality = UIImagePickerControllerQualityTypeIFrame1280x720;
     
     [self presentViewController:self.picker animated:YES completion:NULL];
     }else{
     [actionSheet dismissViewControllerAnimated:YES completion:nil];
     }
     
     }];
     UIAlertAction *selectPhotoAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"영상선택", @"영상선택")
     style:UIAlertActionStyleDefault
     handler:^(UIAlertAction * action){
     //[self performSegueWithIdentifier:@"POST_PHLIB_MODAL" sender:@"VIDEO"];
     //[actionSheet dismissViewControllerAnimated:YES completion:nil];
     
     UIImagePickerController *videoPicker = [[UIImagePickerController alloc] init];
     videoPicker.delegate = self;
     videoPicker.modalPresentationStyle = UIModalPresentationCurrentContext;
     videoPicker.mediaTypes = [UIImagePickerController
     availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
     videoPicker.mediaTypes = @[(NSString*)kUTTypeMovie, (NSString*)kUTTypeAVIMovie, (NSString*)kUTTypeVideo, (NSString*)kUTTypeMPEG4];
     videoPicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
     [self presentViewController:videoPicker animated:YES completion:nil];
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
     */
}

- (IBAction)otherFile:(id)sender{
    //PUSH_TEMP
    //[self performSegueWithIdentifier:@"PUSH_TEMP" sender:nil];
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
        
        thumImage = [self imageFromMovie:mediaUrl atTime:0.0];
        
        UISaveVideoAtPathToSavedPhotosAlbum([mediaUrl path], self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        
    }else{
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
        [self imageViewInTextView:YES :thumImage];
    }
}

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    NSLog(@"%s : %f %f",__FUNCTION__,image.size.width,image.size.height);
    if (error) {
        NSLog(@"error: %@", [error localizedDescription]);
    } else {
        NSLog(@"photo saved");
        //[self.imageArray addObject:image];
        [self imageViewInTextView:YES :image];
        
        /*
         NSRange cursorPosition = [self.textView selectedRange];
         
         NSDictionary *attrs = @{ NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName : [UIFont systemFontOfSize:17] };
         NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]init];
         
         [attributedString appendAttributedString:self.textView.attributedText];
         NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
         textAttachment.image = [self rotateImage90:image];
         
         CGFloat oldWidth = textAttachment.image.size.width;
         CGFloat scaleFactor = oldWidth / (self.textView.frame.size.width - 10);
         textAttachment.image = [UIImage imageWithCGImage:textAttachment.image.CGImage scale:scaleFactor orientation:UIImageOrientationUp];
         NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
         [attributedString replaceCharactersInRange:cursorPosition withAttributedString:attrStringWithImage];
         [attributedString addAttributes:attrs range:cursorPosition];
         
         self.textView.attributedText = attributedString;
         [self.textView setFont:[UIFont systemFontOfSize:17]];
         */
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
    NSLog(@"postwrite getImageNotification userInfo : %@", notification.userInfo);
    NSArray *imageArray = [notification.userInfo objectForKey:@"IMG_LIST"];
    for(int i=0; i<imageArray.count; i++){
        [self imageViewInTextView:NO :imageArray[i]];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getImageNotification" object:nil];
}
- (void)imageViewInTextView:(BOOL)isCamera :(UIImage *)image{
    //NSLog(@"image : %@", image);
    
    @try{
        NSRange cursorPosition = [self.textView selectedRange];
        
        NSDictionary *attrs = @{NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName:[UIFont systemFontOfSize:17]};
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]init];
        //NSMutableAttributedString *newLineString = [[NSMutableAttributedString alloc]initWithString:@"\n\n" attributes:attrs];
        [attributedString appendAttributedString:self.textView.attributedText];
        NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
        
        //if (isCamera) {
        //    textAttachment.image = [self rotateImage:image byOrientationFlag:image.imageOrientation];
        //}else{
        textAttachment.image = [self rotateImage:image byOrientationFlag:image.imageOrientation];
        //}
        
        textAttachment.image = [self getScaledImage:textAttachment.image scaledToMaxWidth:self.textView.frame.size.width-10];
        
        //CGFloat oldWidth = textAttachment.image.size.width;
        //CGFloat scaleFactor = oldWidth / (self.textView.frame.size.width - 10);
        //textAttachment.image = [UIImage imageWithCGImage:textAttachment.image.CGImage scale:scaleFactor orientation:UIImageOrientationUp]; //느려짐
        
        textAttachment.bounds = CGRectMake(10, 20, textAttachment.image.size.width, textAttachment.image.size.height);
        
        NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
        [attributedString replaceCharactersInRange:cursorPosition withAttributedString:attrStringWithImage];
        [attributedString addAttributes:attrs range:cursorPosition];
        //[attributedString appendAttributedString:newLineString];
        self.textView.attributedText = attributedString;
        
        [self.contentImageArray addObject:textAttachment.image];
        [self.imageArray addObject:image];
        [self.textView setFont:[UIFont systemFontOfSize:17]];
        
        [self.textView scrollRangeToVisible:cursorPosition];
        
        NSLog(@"self.textView.attributedText : %@", self.textView.attributedText);
        
    } @catch (NSException *exception) {
        //[self sendToHilee:[NSString stringWithFormat:@"%s", __func__] :exception];
    }
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getImageNotification:)
                                                 name:@"getImageNotification"
                                               object:nil];
    
    if ([[segue identifier] isEqualToString:@"POST_PHLIB_MODAL"]) {
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
