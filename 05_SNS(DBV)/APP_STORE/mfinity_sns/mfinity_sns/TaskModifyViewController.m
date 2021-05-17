//
//  TaskModifyViewController.m
//  mfinity_sns
//
//  Created by hilee on 10/12/2018.
//  Copyright © 2018 com.dbvalley. All rights reserved.
//

#import "TaskModifyViewController.h"
#import "BoardTypeViewController.h"

#import "TaskNameTableViewCell.h"
#import "TaskInfoTableViewCell.h"

#import "CreateTaskFileCell.h"

#import "MemberManageViewController.h"
#import "TaskCalendarViewController.h"

#import "UIViewController+MJPopupViewController.h"
#import "TaskFileCollectionViewCell.h"

#import "PHLibListViewController.h"

#import "MFDBHelper.h"
#import "SDImageCache.h"

@interface TaskModifyViewController () {
    NSString *taskNameVal;
    NSString *statusVal;
    NSString *managerVal;
    NSString *refUserVal;
    NSString *startDateVal;
    NSString *endDateVal;
    NSString *proceedVal1;
    NSString *proceedVal2;
    NSString *taskDescVal;
    
    NSString *editTaskNameVal;
    NSString *editStatusVal;
    NSString *editManagerVal;
    NSString *editRefUserVal;
    NSString *editStartDateVal;
    NSString *editEndDateVal;
    NSString *editProceedVal1;
    NSString *editProceedVal2;
    NSString *editTaskDescVal;
    
    NSString *editManagerNo;
    NSString *editRefUserNo;
    
    NSArray *mUserList;
    NSArray *rUserList;
    NSMutableArray *mUserNoArr;
    NSMutableArray *rUserNoArr;
    
    NSMutableArray *editImages;
    BOOL isHideKeyboard;
    
    NSMutableArray *imgNameArr;
    NSMutableArray *uploadImgArr;
    NSMutableArray *editImgNameArr;
    
    NSMutableArray *historyArr;
    
    float txtHeight;
    
    BOOL isManagerChange;
    BOOL isReferencerChange;
    
    AppDelegate *appDelegate;
    
    BOOL isSetScroll;
    SDImageCache *imgCache;
    
    int fileNameCnt;
}

@end

@implementation TaskModifyViewController

-(void)viewWillAppear:(BOOL)animated{
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 60;
    isSetScroll = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
 
    txtHeight = 50;
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationItem.titleView = [MFUtil navigationTitleStyle:[UIColor whiteColor] title:[NSString urlDecodeString:self.snsName]];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"done", @"done")
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(rightSideMenuButtonPressed:)];
    
    self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc]initWithImage:[MFUtil getScaledImage:[UIImage imageNamed:@"btn_close.png"] scaledToMaxWidth:20] style:UIBarButtonItemStylePlain target:self action:@selector(closeModal:)];
    
    isHideKeyboard = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAnimate:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAnimate:) name:UIKeyboardWillHideNotification object:nil];
    
    UIButton *right1 = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 35, 35)];
    [right1 setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"menu_camera.png"] scaledToMaxWidth:35] forState:UIControlStateNormal];
    [right1 addTarget:self action:@selector(photo:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBtn1 = [[UIBarButtonItem alloc]initWithCustomView:right1];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray *barButtonArr = [[NSArray alloc] initWithObjects:rightBtn1, flexibleSpace, flexibleSpace, nil];
    
    self.toolBar.items = barButtonArr;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_ChangeTaskDate:) name:@"noti_ChangeTaskDate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_ChangeSubInfo2:) name:@"noti_ChangeSubInfo2" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti_ChangeTaskUser:) name:@"noti_ChangeTaskUser" object:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnCollection:)];
    [self.view addGestureRecognizer:tap];
    
    imgNameArr = [NSMutableArray array];
    editImages = [NSMutableArray array];
    editImgNameArr = [NSMutableArray array];
    self.imageFilePathArray = [NSMutableArray array];
    
    uploadCount=0;
    uploadImgArr = [NSMutableArray array];
    
    imgCache = [SDImageCache sharedImageCache];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *cachePath = [NSString stringWithFormat:@"/%@/%@/%@/Cache", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], bundleIdentifier, [appDelegate.appPrefs objectForKey:@"COMP_NO"]];
    [imgCache makeDiskCachePath:cachePath];

    NSLog(@"fromSegue : %@", self.fromSegue);
    
    @try{
        if([self.fromSegue isEqualToString:@"TASK_MODIFY_MODAL"]){
            self.taskNo = [self.taskInfoDic objectForKey:@"TASK_NO"];
            self.snsNo = [self.taskInfoDic objectForKey:@"SNS_NO"];
            editTaskNameVal = [NSString urlDecodeString:[self.taskInfoDic objectForKey:@"TASK_TITLE"]];
            editStartDateVal = [NSString urlDecodeString:[self.taskInfoDic objectForKey:@"TASK_START_DATE"]];
            editEndDateVal = [NSString urlDecodeString:[self.taskInfoDic objectForKey:@"TASK_END_DATE"]];
            editStatusVal = [self.taskInfoDic objectForKey:@"STATUS"];
            editManagerVal = [NSString urlDecodeString:[self.taskInfoDic objectForKey:@"MANAGER_NAME_LIST"]];
            editRefUserVal = [NSString urlDecodeString:[self.taskInfoDic objectForKey:@"REFERENCER_NAME_LIST"]];
            editProceedVal2 = [self.taskInfoDic objectForKey:@"PROGRESS"];
            editTaskDescVal = [NSString urlDecodeString:[self.taskInfoDic objectForKey:@"TASK_CAPTION"]];
            NSArray *fileArray = [self.taskInfoDic objectForKey:@"TASK_ATTACHED_FILE"];
            uploadImgArr = [NSMutableArray arrayWithArray:[self.taskInfoDic objectForKey:@"TASK_ATTACHED_FILE"]];
            
            NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
            
            NSString *paramString = [NSString stringWithFormat:@"snsNo=%@&usrNo=%@&currentUserNos=", self.snsNo, myUserNo];
            [self callWebService:@"getSNSMemberList" WithParameter:paramString];
            
            NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
            [formatter1 setDateFormat:@"yyyy-MM-dd HH:mm:ss.s"];
            
            NSDate *sDate = [formatter1 dateFromString:editStartDateVal];
            NSDate *eDate = [formatter1 dateFromString:editEndDateVal];
            
            NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
            [formatter2 setDateFormat:@"yyyy-MM-dd"];
            editStartDateVal = [formatter2 stringFromDate:sDate];
            editEndDateVal = [formatter2 stringFromDate:eDate];
            
            for (NSDictionary *attachedFile in fileArray) {
                if ([[attachedFile objectForKey:@"TYPE"] isEqualToString:@"IMG"]) {
                    NSDictionary *value = [attachedFile objectForKey:@"VALUE"];
                    NSString *originImagePath = [NSString urlDecodeString:[value objectForKey:@"ORIGIN"]];
                    
                    [imgNameArr addObject:[originImagePath lastPathComponent]];
                }

                if ([[attachedFile objectForKey:@"TYPE"] isEqualToString:@"FILE"]) {
                    NSString *filePath = [NSString urlDecodeString:[attachedFile objectForKey:@"VALUE"]];
                    [imgNameArr addObject:[filePath lastPathComponent]];
                }
            }
            
            //이미지 캐시 저장
            int dataArrCnt = (int)uploadImgArr.count;
            for(int i=0; i<dataArrCnt; i++){
                if([[[uploadImgArr objectAtIndex:i] objectForKey:@"TYPE"] isEqualToString:@"IMG"]){
                    NSString *originImg = [[[uploadImgArr objectAtIndex:i] objectForKey:@"VALUE"] objectForKey:@"ORIGIN"];
                    UIImage *img = [MFUtil saveThumbImage:@"Cache" path:[NSString urlDecodeString:originImg] num:nil];
                    if(img!=nil){
                        [imgCache storeImage:[MFUtil imageByScalingAndCroppingForSize:CGSizeMake(100, 100) :img] forKey:[NSString urlDecodeString:originImg] toDisk:YES];
                    }
                }
            }
            
            taskNameVal = editTaskNameVal;
            statusVal = editStatusVal;
            managerVal = editManagerVal;
            refUserVal = editRefUserVal;
            startDateVal = editStartDateVal;
            endDateVal = editEndDateVal;
            proceedVal1 = @"진행률";
            proceedVal2 = editProceedVal2;
            taskDescVal = editTaskDescVal;
            
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - TextView Delegate
- (void)tapOnCollection:(UITapGestureRecognizer*)tap{
    [self.view endEditing:YES];
}

-(void)rightSideMenuButtonPressed:(id)sender{
    @try{
        
        if(taskNameVal==nil&&[taskNameVal isEqualToString:@""]){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"프로젝트 명을 입력해주세요." message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                             }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
            
        } else {
            if([statusVal isEqualToString:NSLocalizedString(@"task_status1", @"task_status1")]) statusVal = @"1";
            else if([statusVal isEqualToString:NSLocalizedString(@"task_status2", @"task_status2")]) statusVal = @"2";
            else if([statusVal isEqualToString:NSLocalizedString(@"task_status3", @"task_status3")]) statusVal = @"3";
            else if([statusVal isEqualToString:@"보류"]) statusVal = @"4";
            
            if([startDateVal isEqualToString:@"시작일"]) startDateVal = @"";
            if([endDateVal isEqualToString:@"종료일"]) endDateVal = @"";
            if(proceedVal2==nil) proceedVal2 = @"0";
            if(taskDescVal==nil) taskDescVal = @"";
            
            isManagerChange = false;
            isReferencerChange = false;
            
            historyArr = [NSMutableArray array];
            NSString *userName = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"USERNM"]];
            
            NSLog(@"editTaskNameVal : %@, taskNameVal : %@", editTaskNameVal, taskNameVal);
            NSLog(@"editStatusVal : %@, statusVal : %@", editStatusVal, statusVal);
            NSLog(@"editManagerVal : %@, managerVal : %@", editManagerVal, managerVal);
            NSLog(@"editRefUserVal : %@, refUserVal : %@", editRefUserVal, refUserVal);
            NSLog(@"editStartDateVal : %@, startDateVal : %@", editStartDateVal, startDateVal);
            NSLog(@"editEndDateVal : %@, endDateVal : %@", editEndDateVal, endDateVal);
            NSLog(@"editProceedVal2 : %@, proceedVal2 : %@", editProceedVal2, proceedVal2);
            NSLog(@"editTaskDescVal : %@, taskDescVal : %@", editTaskDescVal, taskDescVal);
            
            editManagerNo = [NSString urlDecodeString:[self.taskInfoDic objectForKey:@"MANAGER_LIST"]];
            editRefUserNo = [NSString urlDecodeString:[self.taskInfoDic objectForKey:@"REFERENCER_LIST"]];

            int count = (int)uploadImgArr.count;
            for(int i=0; i<count; i++){
                NSString *type = [[uploadImgArr objectAtIndex:i] objectForKey:@"TYPE"];
                
                if([type isEqualToString:@"IMG"]){
                    NSDictionary *valueDic = [[uploadImgArr objectAtIndex:i] objectForKey:@"VALUE"];
                    
                    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                    [dict setObject:@"IMG" forKey:@"TYPE"];
                    
                    if([valueDic objectForKey:@"TMP_IMG"]){
                        UIImage *imgValue = [valueDic objectForKey:@"TMP_IMG"];
                        [editImages addObject:imgValue];
                        
                        [dict setObject:[NSString stringWithFormat:@"%@",imgValue] forKey:@"VALUE"];
                        
                    } else if([valueDic objectForKey:@"ORIGIN"]){
                        [dict setObject:[valueDic objectForKey:@"ORIGIN"] forKey:@"VALUE"];
                    }
                    
                    [uploadImgArr replaceObjectAtIndex:i withObject:dict];
                }
            }
            
            if (![editTaskNameVal isEqualToString:taskNameVal]) {
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"TITLE",@"TYPE",userName,@"NAME",taskNameVal,@"CONTENT", nil];
                NSData* dictData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
                NSString* jsonData = [[NSString alloc] initWithData:dictData encoding:NSUTF8StringEncoding];
                [historyArr addObject:jsonData];
            }
            if (![[NSString stringWithFormat:@"%@",editStatusVal] isEqualToString:[NSString stringWithFormat:@"%@",statusVal]]) {
                NSString *status;
                if([statusVal isEqualToString:@"1"]) status = NSLocalizedString(@"task_status1", @"task_status1");
                else if([statusVal isEqualToString:@"2"]) status = @"진행";
                else if([statusVal isEqualToString:@"3"]) status = NSLocalizedString(@"task_status3", @"task_status3");
                else if([statusVal isEqualToString:@"4"]) status = @"보류";
                
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"STATUS",@"TYPE",userName,@"NAME",status,@"CONTENT", nil];
                NSData* dictData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
                NSString* jsonData = [[NSString alloc] initWithData:dictData encoding:NSUTF8StringEncoding];
                [historyArr addObject:jsonData];
            }
            if (![editManagerVal isEqualToString:managerVal]) {
                isManagerChange = true;
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"MANAGER",@"TYPE",userName,@"NAME",managerVal,@"CONTENT", nil];
                NSData* dictData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
                NSString* jsonData = [[NSString alloc] initWithData:dictData encoding:NSUTF8StringEncoding];
                [historyArr addObject:jsonData];
            }
            if (![editRefUserVal isEqualToString:refUserVal]) {
                isReferencerChange = true;
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"REFERENCER",@"TYPE",userName,@"NAME",refUserVal,@"CONTENT", nil];
                NSData* dictData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
                NSString* jsonData = [[NSString alloc] initWithData:dictData encoding:NSUTF8StringEncoding];
                [historyArr addObject:jsonData];
            }
            if (![editStartDateVal isEqualToString:startDateVal]) {
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"START_DATE",@"TYPE",userName,@"NAME",startDateVal,@"CONTENT", nil];
                NSData* dictData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
                NSString* jsonData = [[NSString alloc] initWithData:dictData encoding:NSUTF8StringEncoding];
                [historyArr addObject:jsonData];
            }
            if (![editEndDateVal isEqualToString:endDateVal]) {
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"END_DATE",@"TYPE",userName,@"NAME",endDateVal,@"CONTENT", nil];
                NSData* dictData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
                NSString* jsonData = [[NSString alloc] initWithData:dictData encoding:NSUTF8StringEncoding];
                [historyArr addObject:jsonData];
            }
            if (![[NSString stringWithFormat:@"%@",editProceedVal2] isEqualToString:[NSString stringWithFormat:@"%@",proceedVal2]]) {
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"PROGRESS",@"TYPE",userName,@"NAME",proceedVal2,@"CONTENT", nil];
                NSData* dictData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
                NSString* jsonData = [[NSString alloc] initWithData:dictData encoding:NSUTF8StringEncoding];
                [historyArr addObject:jsonData];
            }
            if (![editTaskDescVal isEqualToString:taskDescVal]) {
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"CAPTION",@"TYPE",userName,@"NAME",taskDescVal,@"CONTENT", nil];
                NSData* dictData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
                NSString* jsonData = [[NSString alloc] initWithData:dictData encoding:NSUTF8StringEncoding];
                [historyArr addObject:jsonData];
            }
            
            if(editImages.count>0) {
            //if (![editImages isEqual:images]) {
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"ATTACHED_FILE",@"TYPE",userName,@"NAME", nil];
                NSData* dictData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
                NSString* jsonData = [[NSString alloc] initWithData:dictData encoding:NSUTF8StringEncoding];
                [historyArr addObject:jsonData];
            }
            
            if(editImages.count>0) {
                [self saveAttachedFile];
            }
            else [self saveTask];
            
        }
        
        [self.view endEditing:YES];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

-(void)saveTask{
    @try{
        NSString *myUserNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
        
        NSString* mJsonData = nil;
        if(mUserNoArr.count>0){
            NSData* data = [NSJSONSerialization dataWithJSONObject:mUserNoArr options:NSJSONWritingPrettyPrinted error:nil];
            mJsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        } else {
            mJsonData = @"";
        }
        //if(editManagerNo!=nil&&![editManagerNo isEqualToString:@"[]"]) mJsonData = editManagerNo;
        
        NSString* rJsonData = nil;
        if(rUserNoArr.count>0){
            NSData* data = [NSJSONSerialization dataWithJSONObject:rUserNoArr options:NSJSONWritingPrettyPrinted error:nil];
            rJsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        } else {
            rJsonData = @"";
        }
        //if(editRefUserNo!=nil&&![editRefUserNo isEqualToString:@"[]"]) rJsonData = editRefUserNo;
        
        NSString* attachJson = nil;
        if(uploadImgArr!=nil){
            NSData* data = [NSJSONSerialization dataWithJSONObject:uploadImgArr options:NSJSONWritingPrettyPrinted error:nil];
            attachJson = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        } else {
            attachJson = @"";
        }
        
        NSString *paramString;
        paramString = [NSString stringWithFormat:@"ownerNo=%@&usrNo=%@&snsNo=%@&taskNo=%@&progress=%@&status=%@&title=%@&caption=%@&attachedFile=%@&startDate=%@&endDate=%@&importance=&manager=%@&referencer=%@", myUserNo, myUserNo, self.snsNo, self.taskNo, proceedVal2, statusVal, taskNameVal, taskDescVal, attachJson, startDateVal, endDateVal, mJsonData, rJsonData];
        
        NSString *mChange = isManagerChange? @"true":@"false";
        NSString *rChange = isReferencerChange? @"true":@"false";
        
        NSData* data = [NSJSONSerialization dataWithJSONObject:historyArr options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        paramString = [paramString stringByAppendingString:[NSString stringWithFormat:@"&isManagerChange=%@&isReferencerChange=%@&history=%@", mChange, rChange, jsonData]];
        
        [self callWebService:@"saveTask" WithParameter:paramString];
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
    
}

-(void)closeModal:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)callWebService:(NSString *)serviceName WithParameter:(NSString *)paramString{
    NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:serviceName]];
    MFURLSession *session = [[MFURLSession alloc]initWithURL:url option:paramString];
    session.delegate = self;
    
    if ([session start]) {
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
        [SVProgressHUD show];
    }
}

#pragma mark - UITableViewDelegate UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
    //    return 70;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TaskNameTableViewCell *nameCell = (TaskNameTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"TaskNameTableViewCell"];
    if (nameCell == nil) {
        NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"TaskNameTableViewCell" owner:self options:nil];
        
        for (id currentObject in topLevelObject) {
            if ([currentObject isKindOfClass:[TaskNameTableViewCell class]]) {
                nameCell = (TaskNameTableViewCell *) currentObject;
                [nameCell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
        }
    }
    
    TaskInfoTableViewCell *infoCell = (TaskInfoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"TaskInfoTableViewCell"];
    if (infoCell == nil) {
        NSArray *topLevelObject = [[NSBundle mainBundle] loadNibNamed:@"TaskInfoTableViewCell" owner:self options:nil];
        
        for (id currentObject in topLevelObject) {
            if ([currentObject isKindOfClass:[TaskInfoTableViewCell class]]) {
                infoCell = (TaskInfoTableViewCell *) currentObject;
                [infoCell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
        }
    }
    
    [infoCell.arrowBtn addTarget:self action:@selector(arrowBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    @try{
        if(indexPath.item==0){
            nameCell.nameTxtView.pasteDelegate = self;
            nameCell.nameTxtView.tag=1;
            
            if([taskNameVal isEqualToString:@""]) nameCell.nameTxtView.placeHolder = @"프로젝트명을 입력하세요.";
            else nameCell.nameTxtView.text = taskNameVal;
            
            return nameCell;
            
        } else if(indexPath.item==1){
            infoCell.valueLbl.hidden=NO;
            infoCell.arrowBtn.hidden=NO;
            infoCell.slider.hidden=YES;
            infoCell.descTxtView.hidden=YES;
            
            [infoCell.iconBtn setBackgroundColor:[UIColor clearColor]];
            [infoCell.iconBtn setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"project_progress.png"] scaledToMaxWidth:13.0f] forState:UIControlStateNormal];
            [infoCell.iconBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
            //[infoCell.iconBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 0.0)];
            [infoCell.iconBtn setTitle:@"" forState:UIControlStateNormal];
            
            [infoCell.arrowBtn setImage:nil forState:UIControlStateNormal];
            [infoCell.arrowBtn setTitle:@"변경" forState:UIControlStateNormal];
            [infoCell.arrowBtn setTitleColor:[MFUtil myRGBfromHex:[[MFSingleton sharedInstance] mainThemeColor]] forState:UIControlStateNormal];
            infoCell.arrowBtn.titleLabel.font = [UIFont systemFontOfSize:11];
            //[infoCell.arrowBtn addTarget:self action:@selector(statusBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            infoCell.arrowBtn.tag = 1;
            
            if([statusVal isEqualToString:@"1"]) statusVal = NSLocalizedString(@"task_status1", @"task_status1");
            else if([statusVal isEqualToString:@"2"]) statusVal = @"진행";
            else if([statusVal isEqualToString:@"3"]) statusVal = NSLocalizedString(@"task_status3", @"task_status3");
            else if([statusVal isEqualToString:@"4"]) statusVal = @"보류";
            
            infoCell.valueLbl.text = statusVal;
            
            return infoCell;
            
        } else if(indexPath.item==2){
            infoCell.valueLbl.hidden=NO;
            infoCell.arrowBtn.hidden=NO;
            infoCell.slider.hidden=YES;
            infoCell.descTxtView.hidden=YES;
            
            [infoCell.iconBtn setBackgroundColor:[UIColor clearColor]];
            [infoCell.iconBtn setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"project_member.png"] scaledToMaxWidth:13.0f] forState:UIControlStateNormal];
            [infoCell.iconBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
            //[infoCell.iconBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 0.0)];
            [infoCell.iconBtn setTitle:@"" forState:UIControlStateNormal];
            
            [infoCell.arrowBtn setTitle:@"" forState:UIControlStateNormal];
            [infoCell.arrowBtn setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"btn_tree_close.png"] scaledToMaxWidth:13.0f] forState:UIControlStateNormal];
            //[infoCell.arrowBtn addTarget:self action:@selector(taskUserBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            //infoCell.arrowBtn.tag = 1;
            infoCell.arrowBtn.tag = 2;
            
            infoCell.valueLbl.text = managerVal;
            
            return infoCell;
            
        } else if(indexPath.item==3){
            infoCell.valueLbl.hidden=NO;
            infoCell.arrowBtn.hidden=NO;
            infoCell.slider.hidden=YES;
            infoCell.descTxtView.hidden=YES;
            
            [infoCell.iconBtn setBackgroundColor:[UIColor clearColor]];
            [infoCell.iconBtn setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"project_cc.png"] scaledToMaxWidth:13.0f] forState:UIControlStateNormal];
            [infoCell.iconBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
            [infoCell.iconBtn setTitle:@"" forState:UIControlStateNormal];
            
            [infoCell.arrowBtn setTitle:@"" forState:UIControlStateNormal];
            [infoCell.arrowBtn setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"btn_tree_close.png"] scaledToMaxWidth:13.0f] forState:UIControlStateNormal];
            //[infoCell.arrowBtn addTarget:self action:@selector(taskUserBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            //infoCell.arrowBtn.tag = 2;
            infoCell.arrowBtn.tag = 3;
            
            infoCell.valueLbl.text = refUserVal;
            
            return infoCell;
            
        } else if(indexPath.item==4){
            infoCell.valueLbl.hidden=NO;
            infoCell.arrowBtn.hidden=NO;
            infoCell.slider.hidden=YES;
            infoCell.descTxtView.hidden=YES;
            
            [infoCell.iconBtn setBackgroundColor:[UIColor clearColor]];
            [infoCell.iconBtn setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"project_schedule.png"] scaledToMaxWidth:13.0f] forState:UIControlStateNormal];
            [infoCell.iconBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
            //[infoCell.iconBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 0.0)];
            [infoCell.iconBtn setTitle:@"" forState:UIControlStateNormal];
            
            [infoCell.arrowBtn setTitle:@"" forState:UIControlStateNormal];
            [infoCell.arrowBtn setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"btn_tree_close.png"] scaledToMaxWidth:13.0f] forState:UIControlStateNormal];
            //[infoCell.arrowBtn addTarget:self action:@selector(taskDateBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            //infoCell.arrowBtn.tag = 1;
            infoCell.arrowBtn.tag = 4;
            
            infoCell.valueLbl.text = startDateVal;
            
            return infoCell;
            
        } else if(indexPath.item==5){
            infoCell.valueLbl.hidden=NO;
            infoCell.arrowBtn.hidden=NO;
            infoCell.slider.hidden=YES;
            infoCell.descTxtView.hidden=YES;
            
            [infoCell.iconBtn setBackgroundColor:[UIColor clearColor]];
            [infoCell.iconBtn setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"project_schedule.png"] scaledToMaxWidth:13.0f] forState:UIControlStateNormal];
            [infoCell.iconBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
            //[infoCell.iconBtn setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 5.0, 0.0, 0.0)];
            [infoCell.iconBtn setTitle:@"" forState:UIControlStateNormal];
            
            [infoCell.arrowBtn setTitle:@"" forState:UIControlStateNormal];
            [infoCell.arrowBtn setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"btn_tree_close.png"] scaledToMaxWidth:13.0f] forState:UIControlStateNormal];
            //[infoCell.arrowBtn addTarget:self action:@selector(taskDateBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            //infoCell.arrowBtn.tag = 2;
            infoCell.arrowBtn.tag = 5;
            
            infoCell.valueLbl.text = endDateVal;
            
            return infoCell;
            
        } else if(indexPath.item==6){
            infoCell.valueLbl.hidden=NO;
            infoCell.arrowBtn.hidden=NO;
            infoCell.slider.hidden=NO;
            infoCell.descTxtView.hidden=YES;
            
            infoCell.delegate = self;
            
            [infoCell.iconBtn setBackgroundColor:[UIColor clearColor]];
            [infoCell.iconBtn setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"project_graph.png"] scaledToMaxWidth:13.0f] forState:UIControlStateNormal];
            //[infoCell.iconBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
            [infoCell.iconBtn setTitle:@"" forState:UIControlStateNormal];
            
            [infoCell.arrowBtn setTitle:[NSString stringWithFormat:@"%@%%",proceedVal2] forState:UIControlStateNormal];
            infoCell.slider.value = [proceedVal2 intValue];
            
            infoCell.valueLbl.text = proceedVal1;
            
            return infoCell;
            
        } else if(indexPath.item==7){
            infoCell.valueLbl.hidden=YES;
            infoCell.arrowBtn.hidden=YES;
            infoCell.slider.hidden=YES;
            infoCell.descTxtView.hidden=NO;
            
            [infoCell.iconBtn setBackgroundColor:[UIColor clearColor]];
            [infoCell.iconBtn setImage:[MFUtil getScaledImage:[UIImage imageNamed:@"project_caption.png"] scaledToMaxWidth:13.0f] forState:UIControlStateNormal];
            [infoCell.iconBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
            [infoCell.iconBtn setTitle:@"" forState:UIControlStateNormal];
            
            infoCell.descTxtView.textContainer.maximumNumberOfLines = 0;
            //infoCell.descTxtView.delegate = self;
            infoCell.descTxtView.pasteDelegate = self;
            infoCell.descTxtView.tag=2;
            [infoCell.descTxtView setFont:[UIFont systemFontOfSize:14]];
            
            if([taskDescVal isEqualToString:@""]) infoCell.descTxtView.placeHolder = @"프로젝트 설명 입력";
            else infoCell.descTxtView.text = taskDescVal;
            
            [self setTextView:infoCell.descTxtView];
            
            return infoCell;
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
    
    return nil;
}

-(void)arrowBtnClick:(UIButton *)sender{
    if(sender.tag==1){
        [self.view endEditing:YES];
        BoardTypeViewController *vc = [[BoardTypeViewController alloc] init];
        vc.fromSegue = @"SELECT_TASK_STATUS";
        
        if([statusVal isEqualToString:NSLocalizedString(@"task_status1", @"task_status1")]) statusVal = @"1";
        else if([statusVal isEqualToString:@"진행"]) statusVal = @"2";
        else if([statusVal isEqualToString:NSLocalizedString(@"task_status3", @"task_status3")]) statusVal = @"3";
        else if([statusVal isEqualToString:@"보류"]) statusVal = @"4";
        
        vc.codeNo = [NSString stringWithFormat:@"%d",[statusVal intValue]-1];
        [self presentPopupViewController:vc animationType:MJPopupViewAnimationFade];
        
    } else if(sender.tag==2){
        [self.view endEditing:YES];
        if(isHideKeyboard){
            [self performSegueWithIdentifier:@"TASK_MODIFY_MEMBER_PUSH" sender:@"TASK_MANAGER"];
        }
        
    } else if(sender.tag==3){
        [self.view endEditing:YES];
        if(isHideKeyboard){
            [self performSegueWithIdentifier:@"TASK_MODIFY_MEMBER_PUSH" sender:@"TASK_REFERENCE"];
        }
        
    } else if(sender.tag==4){
        [self.view endEditing:YES];
        if(isHideKeyboard){
            TaskCalendarViewController *vc = [[TaskCalendarViewController alloc] init];
            vc.dateType = sender.tag;
            [self presentPopupViewController:vc animationType:MJPopupViewAnimationFade];
        }
        
    } else if(sender.tag==5){
        [self.view endEditing:YES];
        if(isHideKeyboard){
            TaskCalendarViewController *vc = [[TaskCalendarViewController alloc] init];
            vc.dateType = sender.tag;
            [self presentPopupViewController:vc animationType:MJPopupViewAnimationFade];
        }
    }
}

-(void)textViewDidChange:(MFTextView *)textView{
    @try {
        if(textView.tag==1){
            taskNameVal = textView.text;
            
        } else if(textView.tag==2){
            taskDescVal = textView.text;
            
            //텍스트 뷰 커서에 따라 스크롤 위치 변경해주기 위해.
            NSIndexPath *currentCell = [NSIndexPath indexPathForItem:textView.tag inSection:0];
            CGPoint cursorPosition2 = [textView caretRectForPosition:textView.selectedTextRange.start].origin;
            //float scrollPosition = cursorPosition2.y+[self.tableView rectForRowAtIndexPath:currentCell].origin.y+50;
            float scrollPosition = cursorPosition2.y+[self.tableView rectForRowAtIndexPath:currentCell].origin.y;
            
            //NSLog(@"[self.tableView rectForRowAtIndexPath:currentCell].origin.y : %f", [self.tableView rectForRowAtIndexPath:currentCell].origin.y);
            //NSLog(@"cusorposition : %f", cursorPosition2.y);
            
            [self.tableView scrollRectToVisible:CGRectMake(0, scrollPosition, 1, 1) animated:NO];
            
            [self setTextView:textView];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

-(BOOL)textView:(MFTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    isSetScroll = YES;
}

/*
 -(void)textViewDidChange:(UITextView *)textView{
 //텍스트 뷰 커서에 따라 스크롤 위치 변경해주기 위해.
 NSIndexPath *currentCell = [NSIndexPath indexPathForItem:textView.tag inSection:0];
 CGPoint cursorPosition2 = [textView caretRectForPosition:textView.selectedTextRange.start].origin;
 NSLog(@"결론 스크롤 위치 : %f", cursorPosition2.y+[self.tableView rectForRowAtIndexPath:currentCell].origin.y);
 //float scrollPosition = cursorPosition2.y+[self.tableView rectForRowAtIndexPath:currentCell].origin.y+50;
 float scrollPosition = cursorPosition2.y+50;
 [self.tableView scrollRectToVisible:CGRectMake(0, scrollPosition, 1, 1) animated:NO];
 
 [self setTextView:textView];
 }
 */
-(void)setTextView:(MFTextView *)textView {
    @try {
        CGFloat fixedWidth = textView.frame.size.width;
        CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
        CGRect newFrame = textView.frame;
        newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
        textView.frame = newFrame;
        textView.scrollEnabled = NO;
        
        if(isSetScroll){
            //int height = self.tableView.contentSize.height-_keyboardHeight.constant-self.tableView.contentOffset.y;
            
            int height1 = self.tableView.contentSize.height-_keyboardHeight.constant-self.tableView.contentOffset.y;
            int height2 = self.tableView.frame.size.height-_keyboardHeight.constant;
            
            if((height1-height2)>-10&&(height1-height2)<20){
                NSLog(@"스크롤이 하단에 있다");
                //스크롤이 하단에 있을 때만. 텍스트뷰에 맞춰서 스크롤을 내려주기 위해.
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    NSIndexPath *lastCell = [NSIndexPath indexPathForItem:7 inSection:0];
                    [self.tableView scrollToRowAtIndexPath:lastCell atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                });
            }
        }
        
        [UIView performWithoutAnimation:^{
            [self.tableView beginUpdates];
            [self.tableView endUpdates];
        }];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

-(void)proceedValChange:(NSString *)val{
    proceedVal2 = val;
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

// 컬렉션 크기 설정
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    @try{
        return CGSizeMake(100, 100);
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

// 컬렉션 뷰 셀 갯수
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    @try{
        return uploadImgArr.count;
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

// 컬렉션과 컬렉션 height 간격
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
//    return 0;
//}

// 컬렉션 뷰 셀 설정
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    @try{
        [self.collectionView registerNib:[UINib nibWithNibName:@"CreateTaskFileCell" bundle:nil] forCellWithReuseIdentifier:@"CreateTaskFileCell"];
        CreateTaskFileCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CreateTaskFileCell" forIndexPath:indexPath];
        
        NSString *type = [[uploadImgArr objectAtIndex:indexPath.row] objectForKey:@"TYPE"];
        if([type isEqualToString:@"IMG"]){
            cell.fileImgView.image = nil;
            NSDictionary *valueDic = [[uploadImgArr objectAtIndex:indexPath.row] objectForKey:@"VALUE"];
            
            if([valueDic objectForKey:@"TMP_IMG"]){
                UIImage *imgValue = [valueDic objectForKey:@"TMP_IMG"];
                cell.fileImgView.image = imgValue;
                
            } else{
                NSString *originImg = [valueDic objectForKey:@"ORIGIN"];
                [imgCache queryDiskCacheForKey:[NSString urlDecodeString:originImg] done:^(UIImage *image, SDImageCacheType cacheType) {
                    if(image!=nil){
                        cell.fileImgView.image = image;
                    }
                }];
            }
        } else {
            
        }
        
        cell.fileImgView.tag = indexPath.item;
        cell.deleteBtn.tag = indexPath.item;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDeleteImage:)];
        [cell.fileImgView setUserInteractionEnabled:YES];
        [cell.fileImgView addGestureRecognizer:tap];
        
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDeleteImage:)];
        [cell.deleteBtn setUserInteractionEnabled:YES];
        [cell.deleteBtn addGestureRecognizer:tap2];
        
        return cell;
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    NSLog(@"%s, indexPath : %ld", __func__, (long)indexPath.item);
}

#pragma mark - MFURLSession Upload Delegate
-(void)returnDictionary:(NSDictionary *)dictionary WithError:(NSString *)error{
    @try{
        uploadCount++;
        
        if (error != nil) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"error", @"error") message:error preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                             }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
            
        }else{
            [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
            [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
            [SVProgressHUD show];
            
            NSString *result = [dictionary objectForKey:@"RESULT"];
            if ([result isEqualToString:@"SUCCESS"]) {
                if ([dictionary objectForKey:@"FILE_URL"]==nil) {
                    
                } else{
                    [self.imageFilePathArray addObject:[dictionary objectForKey:@"FILE_URL"]];
                    fileNameCnt++;
                    
                    if(uploadCount<editImages.count){
                        //첫번째 파일 먼저 올리고, 순차적으로 업로드 하기 위해 재호출.
                        UIImage *image = [editImages objectAtIndex:uploadCount];
                        NSData * data = UIImageJPEGRepresentation(image, 0.1);
                        NSString *fileName = [imgNameArr objectAtIndex:uploadCount];
                        [self saveAttachedFile:data AndFileName:fileName];
                        
                    } else if (uploadCount==editImages.count) {
                        //dataArr에 있는 UIImage데이터를 URL형식 NSString으로 바꾸기위해.
                        [self imageToUrlString];
                        [self saveTask];
                    }
                    
                }
                
            } else {
                uploadCount = 0;
                fileNameCnt = 0;
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"업로드실패" message:@"재시도 하시겠습니까?" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                                 }];
                
                UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel") style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                                     }];
                
                [alert addAction:okButton];
                [alert addAction:cancelButton];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
    
    [SVProgressHUD dismiss];
}

- (void)returnResponse:(NSURLResponse *)response WithError:(NSString *)error{
    NSLog(@"%@", error);
}

-(void)imageToUrlString{
    int changeCnt = 0;
    
    @try {
        for(int i=0; i<uploadImgArr.count; i++){
            NSString *type = [[uploadImgArr objectAtIndex:i] objectForKey:@"TYPE"];
            
            if([type isEqualToString:@"IMG"]){
                NSString *value = [[uploadImgArr objectAtIndex:i] objectForKey:@"VALUE"];
                if([value rangeOfString:@"https://"].location==NSNotFound || [value rangeOfString:@"http://"].location == NSNotFound){
                    NSString *imagePath = [self.imageFilePathArray objectAtIndex:changeCnt];
                    if(changeCnt<=fileNameCnt){
                        [[uploadImgArr objectAtIndex:i] setObject:imagePath forKey:@"VALUE"];
                    }
                    changeCnt++;
                }
            }
        }
        
//        for(int i=0; i<uploadImgArr.count; i++){
//            NSString *img = [NSString stringWithFormat:@"%@", [uploadImgArr objectAtIndex:i]];
//            NSString *type = [[uploadImgArr objectAtIndex:i] objectForKey:@"TYPE"];
//
//            if([type isEqualToString:@"IMG"]){
//                NSString *value = [[uploadImgArr objectAtIndex:i] objectForKey:@"VALUE"];
//                if([value rangeOfString:@"https"].location==NSNotFound || [value rangeOfString:@"http"].location == NSNotFound){
//                    NSString *imagePath = [self.imageFilePathArray objectAtIndex:changeCnt];
//                    if(changeCnt<=fileNameCnt){
//                        [[uploadImgArr objectAtIndex:i] setObject:imagePath forKey:@"VALUE"];
//                    }
//                    changeCnt++;
//                }
//            }

    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

#pragma mark - MFURLSession Delegate
- (void)returnDataWithObject:(MFURLSession *)session error:(NSString *)error{
    if (error != nil) {
        
    }else{
        @try {
            NSString *wsName = [[session.url absoluteString] lastPathComponent];
            NSString *result = [session.returnDictionary objectForKey:@"RESULT"];
            
            if ([result isEqualToString:@"SUCCESS"]) {
                if ([wsName isEqualToString:@"getTaskNo"]) {
                    self.taskNo = [[[session.returnDictionary objectForKey:@"DATASET"] objectAtIndex:0] objectForKey:@"SEQ"];
                    
                    if(editImages.count>0) [self saveAttachedFile];
                    else [self saveTask];
                    
                    
                }else if ([wsName isEqualToString:@"saveTask"]) {
                    NSString *affected = [session.returnDictionary objectForKey:@"AFFECTED"];
                    if ([affected intValue]>0) {
                        [self dismissViewControllerAnimated:YES completion:^(void){
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_SaveTask" object:nil];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"noti_TaskModify" object:nil];
                        }];
                    }
                } else if([wsName isEqualToString:@"getSNSMemberList"]){
                    NSError *error;
                    
                    NSString *managerNoList = [NSString urlDecodeString:[self.taskInfoDic objectForKey:@"MANAGER_LIST"]];
                    NSData *jsonData = [managerNoList dataUsingEncoding:NSUTF8StringEncoding];
                    mUserList = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
                    
                    NSString *referencerNoList = [NSString urlDecodeString:[self.taskInfoDic objectForKey:@"REFERENCER_LIST"]];
                    NSData *jsonData2 = [referencerNoList dataUsingEncoding:NSUTF8StringEncoding];
                    rUserList = [NSJSONSerialization JSONObjectWithData:jsonData2 options:kNilOptions error:&error];
                    
                }
            }else{
                
            }
            
        } @catch (NSException *exception) {
            NSLog(@"Exception : %@", exception);
        }
    }
    [SVProgressHUD dismiss];
}

- (void)returnError:(MFURLSession *)session error:(NSError *)error{
    NSLog(@"error : %@", error);
}

#pragma mark - UIToolbar Button Action
- (IBAction)photo:(id)sender{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *takePictureAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"popup_camera1", @"popup_camera1")
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action){
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSString *mediaAuth = [NSString stringWithFormat:@"%@", [prefs objectForKey:@"MEDIA_AUTH"]]; //@"0"; //미디어 접근 권한 임시 변수
            if([[MFSingleton sharedInstance] mediaAuthCheck] && [mediaAuth isEqualToString:@"0"]){
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"user_permission_media_title", @"user_permission_media_title") message:NSLocalizedString(@"user_permission_media", @"user_permission_media") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                    [alert dismissViewControllerAnimated:YES completion:nil];
                    
                    [AccessAuthCheck cameraAccessCheckNotAuth:^(BOOL status) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(status==YES){
                                UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
                                self.picker = [[UIImagePickerController alloc] init];
                                self.picker.delegate = self;
                                self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                
                                self.picker.modalPresentationStyle = UIModalPresentationFullScreen;
                                [top presentViewController:self.picker animated:YES completion:nil];
                            }
                        });
                    }];
                    
                }];
                [alert addAction:okButton];
                [self presentViewController:alert animated:YES completion:nil];
                
            } else {
                [AccessAuthCheck cameraAccessCheckNotAuth:^(BOOL status) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(status==YES){
                            UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
                            self.picker = [[UIImagePickerController alloc] init];
                            self.picker.delegate = self;
                            self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                            
                            self.picker.modalPresentationStyle = UIModalPresentationFullScreen;
                            [top presentViewController:self.picker animated:YES completion:nil];
                        }
                    });
                }];
            }
            
//            if([AccessAuthCheck cameraAccessCheck]){
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
//                    self.picker = [[UIImagePickerController alloc] init];
//                    self.picker.delegate = self;
//                    self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//
//                    self.picker.modalPresentationStyle = UIModalPresentationFullScreen;
//                    [top presentViewController:self.picker animated:YES completion:nil];
//                });
//            }
            
        }else{
            [actionSheet dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    UIAlertAction *selectPhotoAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"popup_camera2", @"popup_camera2")
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action){
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *mediaAuth = [NSString stringWithFormat:@"%@", [prefs objectForKey:@"MEDIA_AUTH"]]; //@"0"; //미디어 접근 권한 임시 변수
        if([[MFSingleton sharedInstance] mediaAuthCheck] && [mediaAuth isEqualToString:@"0"]){
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"user_permission_media_title", @"user_permission_media_title") message:NSLocalizedString(@"user_permission_media", @"user_permission_media") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction actionWithTitle:NSLocalizedString(@"done", @"done") style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
                
                [AccessAuthCheck photoAccessCheckNotAuth:^(BOOL status) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(status==YES) [self performSegueWithIdentifier:@"TASK_MODIFY_PHLIB_MODAL" sender:@"PHOTO"];
                    });
                }];
                
            }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
            
        } else {
            [AccessAuthCheck photoAccessCheckNotAuth:^(BOOL status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(status==YES) [self performSegueWithIdentifier:@"TASK_MODIFY_PHLIB_MODAL" sender:@"PHOTO"];
                });
            }];
        }
        
//        if([AccessAuthCheck photoAccessCheck]){
//            [self performSegueWithIdentifier:@"TASK_MODIFY_PHLIB_MODAL" sender:@"PHOTO"];
//        }
        [actionSheet dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [actionSheet addAction:takePictureAction];
    [actionSheet addAction:selectPhotoAction];
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel")
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action){
            [actionSheet dismissViewControllerAnimated:YES completion:nil];
        }];
        [actionSheet addAction:cancelAction];
        
        [actionSheet.popoverPresentationController setPermittedArrowDirections:0];
        CGRect rect = self.view.frame;
        rect.origin.x = (self.view.frame.size.width/2)-(actionSheet.view.frame.size.width/2);
        rect.origin.y = (self.view.frame.size.height/2)-(actionSheet.view.frame.size.height/2);
        actionSheet.popoverPresentationController.sourceView = self.view;
        actionSheet.popoverPresentationController.sourceRect = rect;
    } else {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", @"cancel")
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action){
            [actionSheet dismissViewControllerAnimated:YES completion:nil];
        }];
        [actionSheet addAction:cancelAction];
    }
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (IBAction)video:(id)sender{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"" message:@"개발중인 기능입니다." preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alert dismissViewControllerAnimated:YES completion:nil];
    });
}

-(void)setImageFromNoti :(NSDictionary *)userInfo{
    @try{
        self.assetArray = [userInfo objectForKey:@"ASSET_LIST"];
        
        //사진앨범에서 선택
        if(self.assetArray.count > 0){
            for (int i=0; i<self.imageArray.count; i++) {
                UIImage *image = [self.imageArray objectAtIndex:i];
//                NSData * data = UIImageJPEGRepresentation(image, 0.3);
                
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setObject:@"IMG" forKey:@"TYPE"];
                
                NSMutableDictionary *dict2 = [NSMutableDictionary dictionary];
                [dict2 setObject:image forKey:@"TMP_IMG"];
                
                [dict setObject:dict2 forKey:@"VALUE"];
                
                [uploadImgArr addObject:dict];
                
                
                [self.collectionView reloadData];
            }
            
        } else {
            //사진촬영
            NSString *aditInfo = [userInfo objectForKey:@"ADIT_INFO"];
            
            NSData* imgData = [[NSFileManager defaultManager] contentsAtPath:aditInfo];
            UIImage *image = [UIImage imageWithData:imgData];
//            NSData * data = UIImageJPEGRepresentation(image, 0.3);
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:@"IMG" forKey:@"TYPE"];
            
            NSMutableDictionary *dict2 = [NSMutableDictionary dictionary];
            [dict2 setObject:image forKey:@"TMP_IMG"];
            
            [dict setObject:dict2 forKey:@"VALUE"];
            
            [uploadImgArr addObject:dict];
            
            [self.collectionView reloadData];
            
        }
        
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:uploadImgArr.count-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}
- (void)saveAttachedFile{
    //처음 이미지 먼저 업로드 후 완료되면 순차적으로 업로드 하기 위해.
    UIImage *image = [editImages objectAtIndex:0];
    
    for (int i=0; i<editImages.count; i++) {
        NSString *fileName = [self createFileName];
        [imgNameArr addObject:fileName];
    }
    
    NSData * data = UIImageJPEGRepresentation(image, 0.1);
//    NSLog(@"File size is : %.2f MB",(float)data.length/1024.0f/1024.0f);
    
    [self saveAttachedFile:data AndFileName:[imgNameArr objectAtIndex:0]];
    
}

- (void)saveAttachedFile:(NSData *)data AndFileName:(NSString *)fileName{
    @try{
        //ADIT_INFO : {"TMP_NO":Long,"LOCAL_CONTENT":String}
        NSString *dvcID = [appDelegate.appPrefs objectForKey:@"DVC_ID"];//[MFUtil getUUID];
        NSString *userNo = [appDelegate.appPrefs objectForKey:[appDelegate setPreferencesKey:@"CUSERNO"]];
        
        NSMutableDictionary *aditDic = [NSMutableDictionary dictionary];
        [aditDic setObject:@1 forKey:@"TMP_NO"];
        [aditDic setObject:dvcID forKey:@"DEVICE_ID"];
        
        NSData* aditData = [NSJSONSerialization dataWithJSONObject:aditDic options:0 error:nil];
        NSString* aditJsonData = [[NSString alloc] initWithData:aditData encoding:NSUTF8StringEncoding];
        
        NSMutableDictionary *sendFileParam = [NSMutableDictionary dictionary];
        [sendFileParam setObject:self.taskNo forKey:@"taskNo"];
        [sendFileParam setObject:[appDelegate.appPrefs objectForKey:@"USERID"] forKey:@"usrId"];
        [sendFileParam setObject:userNo forKey:@"usrNo"];
        [sendFileParam setObject:@"6" forKey:@"refTy"];
        [sendFileParam setObject:userNo forKey:@"refNo"];
        [sendFileParam setObject:aditJsonData forKey:@"aditInfo"];
        [sendFileParam setObject:@"false" forKey:@"isShared"];
        [sendFileParam setObject:@"" forKey:@"srcFileUrl"];
        
        NSString *urlString = [[MFSingleton sharedInstance] mainUrl];
        urlString = [urlString stringByAppendingPathComponent:@"saveAttachedFile"];
        
        //처음 이미지 먼저 업로드 후 완료되면 순차적으로 업로드 하기 위해.
        [self sessionFileUpload:urlString :sendFileParam :data :fileName];
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}

-(void)sessionFileUpload :(NSString *)urlString :(NSMutableDictionary *)sendFileParam :(NSData *)data :(NSString *)fileName{
    MFURLSessionUpload *sessionUpload = [[MFURLSessionUpload alloc]initWithURL:[NSURL URLWithString:urlString] option:sendFileParam WithData:data AndFileName:fileName];
    sessionUpload.delegate = self;
    if ([sessionUpload start]) {
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
        [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
        [SVProgressHUD show];
    }
}

- (void)getImageNotification:(NSNotification *)notification {
    self.imageArray = [notification.userInfo objectForKey:@"IMG_LIST"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getImageNotification" object:nil];
    [self setImageFromNoti:notification.userInfo];
}

#pragma mark - UITapGestureRecognizer
- (void)tapDeleteImage:(UITapGestureRecognizer*)tap{
    NSInteger index = tap.view.tag;
    
    [uploadImgArr removeObjectAtIndex:index];
    
    [self.collectionView reloadData];
}

- (void)noti_ChangeSubInfo2:(NSNotification *)notification{
    NSLog(@"userInfo : %@", notification.userInfo);
    
    NSString *type = [notification.userInfo objectForKey:@"TYPE"];
    @try{
        if([type isEqualToString:@"TASK_STATUS"]){
            [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
            
            statusVal = [notification.userInfo objectForKey:@"TASK_STATUS"];
            
            if([statusVal isEqualToString:@"1"]) statusVal = NSLocalizedString(@"task_status1", @"task_status1");
            else if([statusVal isEqualToString:@"2"]) statusVal = @"진행";
            else if([statusVal isEqualToString:@"3"]) statusVal = NSLocalizedString(@"task_status3", @"task_status3");
            else if([statusVal isEqualToString:@"4"]) statusVal = @"보류";
            
            NSIndexPath *indexPath=nil;
            indexPath = [NSIndexPath indexPathForItem:1 inSection:0];
            //            [self.collectionView performBatchUpdates:^{
            //                [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
            //            } completion:nil];
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

- (void)noti_ChangeTaskDate:(NSNotification *)notification{
    NSLog(@"userInfo : %@", notification.userInfo);
    
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
    
    NSString *type = [notification.userInfo objectForKey:@"TYPE"];
    NSIndexPath *indexPath=nil;
    
    @try{
        if([type isEqualToString:@"TASK_START_DATE"]){
//            NSLog(@"TASK_START_DATE : %@",[notification.userInfo objectForKey:@"TASK_START_DATE"]);
            startDateVal = [notification.userInfo objectForKey:@"TASK_START_DATE"];
            indexPath = [NSIndexPath indexPathForItem:4 inSection:0];
            //            [self.collectionView performBatchUpdates:^{
            //                [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
            //            } completion:nil];
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
            
        } else if([type isEqualToString:@"TASK_END_DATE"]){
            endDateVal = [notification.userInfo objectForKey:@"TASK_END_DATE"];
            indexPath = [NSIndexPath indexPathForItem:5 inSection:0];
            //            [self.collectionView performBatchUpdates:^{
            //                [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
            //            } completion:nil];
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
    }
}

- (void)noti_ChangeTaskUser:(NSNotification *)notification{
    //여기서 유저번호를 유저이름으로 변경?
    NSLog(@"userInfo : %@", notification.userInfo);
    
    NSString *type = [notification.userInfo objectForKey:@"TYPE"];
    NSIndexPath *indexPath=nil;
    
    mUserList = [NSArray array];
    rUserList = [NSArray array];
    
    @try{
        if([type isEqualToString:@"TASK_MANAGER"]){
            //NSLog(@"USER_LIST : %@",[notification.userInfo objectForKey:@"CHECK_USER_LIST"]);
            mUserList = [notification.userInfo objectForKey:@"CHECK_USER_LIST"];
            NSUInteger userCnt = mUserList.count;
            
            NSMutableArray *editManagerArr = [NSMutableArray array];
            
            mUserNoArr = [NSMutableArray array];
            NSMutableArray *mUserNmArr = [NSMutableArray array];
            
            for(int i=0; i<userCnt; i++){
                //[mUserNoArr addObject:[[mUserList objectAtIndex:i] objectForKey:@"CUSER_NO"]];
                //[mUserNmArr addObject:[NSString urlDecodeString:[[mUserList objectAtIndex:i] objectForKey:@"USER_NM"]]];
                [mUserNoArr addObject:[NSNumber numberWithInt:[[mUserList objectAtIndex:i] intValue]]];
                
                NSString *sqlString = [appDelegate.dbHelper getUserInfo:[mUserList objectAtIndex:i]];
                NSArray *arr = [appDelegate.dbHelper selectMutableArray:sqlString];
                [editManagerArr addObjectsFromArray:arr];
                [mUserNmArr addObject:[[arr objectAtIndex:0] objectForKey:@"USER_NM"]];
            }
           
            managerVal = [mUserNmArr componentsJoinedByString:@", "];
            
            indexPath = [NSIndexPath indexPathForItem:2 inSection:0];
            //            [self.collectionView performBatchUpdates:^{
            //                [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
            //            } completion:nil];
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
            
        } else if([type isEqualToString:@"TASK_REFERENCE"]){
            rUserList = [notification.userInfo objectForKey:@"CHECK_USER_LIST"];
            NSUInteger userCnt = rUserList.count;
            
            NSMutableArray *editReferencerArr = [NSMutableArray array];
            
            rUserNoArr = [NSMutableArray array];
            NSMutableArray *rUserNmArr = [NSMutableArray array];
            
            for(int i=0; i<userCnt; i++){
                //[rUserNoArr addObject:[[rUserList objectAtIndex:i] objectForKey:@"CUSER_NO"]];
                //[rUserNmArr addObject:[NSString urlDecodeString:[[rUserList objectAtIndex:i] objectForKey:@"USER_NM"]]];
                [rUserNoArr addObject:[NSNumber numberWithInt:[[rUserList objectAtIndex:i] intValue]]];
                
                NSString *sqlString = [appDelegate.dbHelper getUserInfo:[rUserList objectAtIndex:i]];
                NSArray *arr = [appDelegate.dbHelper selectMutableArray:sqlString];
                [editReferencerArr addObjectsFromArray:arr];
                [rUserNmArr addObject:[[arr objectAtIndex:0] objectForKey:@"USER_NM"]];
            }
            
            refUserVal = [rUserNmArr componentsJoinedByString:@", "];
            
            indexPath = [NSIndexPath indexPathForItem:3 inSection:0];
            //            [self.collectionView performBatchUpdates:^{
            //                [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
            //            } completion:nil];
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
        }
        
    } @catch(NSException *exception){
        NSLog(@"Exception : %@", exception);
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
        self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"regist", @"regist")
                                                                                style:UIBarButtonItemStylePlain
                                                                               target:self
                                                                               action:@selector(rightSideMenuButtonPressed:)];
        self.keyboardHeight.constant = kbSize.height;
        [self.view layoutIfNeeded];
        
    }else if([notification name]==UIKeyboardWillHideNotification){
        self.keyboardHeight.constant = 0;
        [self.view layoutIfNeeded];
        
    }
    [UIView commitAnimations];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getImageNotification:)
                                                 name:@"getImageNotification"
                                               object:nil];
    
    if ([[segue identifier] isEqualToString:@"TASK_MODIFY_PHLIB_MODAL"]) {
        UINavigationController *destination = segue.destinationViewController;
        PHLibListViewController *vc = [[destination childViewControllers] objectAtIndex:0];
        vc.fromSegue = segue.identifier;
        vc.listType = sender;
        destination.modalPresentationStyle = UIModalPresentationOverFullScreen;
        
    } else if([segue.identifier isEqualToString:@"TASK_MODIFY_MEMBER_PUSH"]){
        MemberManageViewController *destination = segue.destinationViewController;
        destination.snsNo = self.snsNo;
        destination.snsName = self.snsName;
        destination.snsKind = @"2";
        self.navigationController.navigationBar.topItem.title = @"";
        
        if([sender isEqualToString:@"TASK_MANAGER"]){
            destination.fromSegue = @"TASK_MANAGER";
            destination.userListArr = mUserList;
            
        } else if([sender isEqualToString:@"TASK_REFERENCE"]){
            destination.fromSegue = @"TASK_REFERENCE";
            destination.userListArr = rUserList;
        }
        
    }
}

#pragma mark - UIImagePickerController Delegate
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.movie"]) {
        NSURL *mediaUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        [picker dismissViewControllerAnimated:YES completion:nil];
        
        if([[[MFSingleton sharedInstance] legacyName] isEqualToString:@"NONE"]){
            UISaveVideoAtPathToSavedPhotosAlbum([mediaUrl path], self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
            
        } else if([[[MFSingleton sharedInstance] legacyName] isEqualToString:@"ANYMATE"]){
            UISaveVideoAtPathToSavedPhotosAlbum([mediaUrl path], self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
            
        } else if([[[MFSingleton sharedInstance] legacyName] isEqualToString:@"HHI"]){
            [self video:mediaUrl.absoluteString didFinishSavingWithError:nil contextInfo:nil];
        }
        
    }else{
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        [picker dismissViewControllerAnimated:YES completion:nil];
        
        if([[[MFSingleton sharedInstance] legacyName] isEqualToString:@"NONE"]){
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            
        } else if([[[MFSingleton sharedInstance] legacyName] isEqualToString:@"ANYMATE"]){
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            
        } else if([[[MFSingleton sharedInstance] legacyName] isEqualToString:@"HHI"]){
            [self image:image didFinishSavingWithError:nil contextInfo:nil];
        }
    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        NSLog(@"error: %@", [error localizedDescription]);
        
    } else {
//        NSLog(@"video saved");
    }
}

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        NSLog(@"error: %@", [error localizedDescription]);

    } else {
        UIImage *rotateImg = nil;
        if(image.size.width>image.size.height){
            rotateImg = [MFUtil rotateImage:image byOrientationFlag:image.imageOrientation];
        } else {
            rotateImg = [MFUtil rotateImage90:image];
        }
        
        NSString *getFileName = [self createFileName];
        NSData *imageData = UIImageJPEGRepresentation(rotateImg, 0.1);
        
        NSString *tmpPath = NSTemporaryDirectory();
        NSString *imagePath = [tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",getFileName]];
        //NSLog(@"imagePath : %@", imagePath);
        [imageData writeToFile:imagePath atomically:YES];
//        NSLog(@"사진촬영 원본이미지 : %@", imagePath);
        
        //썸네일이미지 로컬 tmp경로에 저장
        NSData *imageThumbData = UIImagePNGRepresentation([MFUtil imageByScalingAndCroppingForSize:CGSizeMake(225, 300) :rotateImg]);
        NSString *imageThumbPath =[tmpPath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@",getFileName]];
        [imageThumbData writeToFile:imageThumbPath atomically:YES];
//        NSLog(@"사진촬영 썸네일이미지 : %@", imageThumbPath);
        
        NSMutableDictionary *imageInfoDic = [NSMutableDictionary dictionary];
        [imageInfoDic setObject:imagePath forKey:@"ADIT_INFO"];
        [imageInfoDic setObject:getFileName forKey:@"FILE_NM"];
        
        [self setImageFromNoti:imageInfoDic];
    }
}

- (NSString *)createFileName{
    @try{
        NSString *fileName = nil;
        NSDate *today = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMdd-HHmmssSSS"];
        NSString *currentTime = [dateFormatter stringFromDate:today];
        //NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"USER_ID"];
        //fileName = [NSString stringWithFormat:@"%@(%@).png",userID,currentTime];
        fileName = [NSString stringWithFormat:@"%@.png",currentTime];
        return fileName;
        
    } @catch (NSException *exception) {
        NSLog(@"Exception : %@", exception);
    }
}
- (CGSize)targetSize {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize targetSize = CGSizeMake(CGRectGetWidth(self.view.bounds) * scale, CGRectGetHeight(self.view.bounds) * scale);
    return targetSize;
}

- (BOOL)isIphoneX
{
    NSString *platform = [[UIDevice currentDevice] modelName];
    NSRange range = NSMakeRange(7, 1);
    NSString *platformNumber = [platform substringWithRange:range];
    if([platformNumber isEqualToString:@"X"]){
        return YES;
    } else {
        return NO;
    }
//    if (CGRectEqualToRect([UIScreen mainScreen].bounds,CGRectMake(0, 0, 375, 812))) {
//        return YES;
//    } else {
//        return NO;
//    }
}


@end
