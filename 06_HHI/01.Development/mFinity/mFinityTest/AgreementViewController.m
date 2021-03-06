//
//  AgreementViewController.m
//  mFinity_HHI
//
//  Created by hilee on 30/03/2020.
//  Copyright © 2020 Jun hyeong Park. All rights reserved.
//

#import "AgreementViewController.h"

@interface AgreementViewController ()

@end

@implementation AgreementViewController {
    int h;
    CGFloat screenWidth;
    
    UILabel *titleLabel;
    UITextView *boxTxtView;
    
    UIView *mdmBoxView;
    UIView *privateBoxView;
    
//    UIView *buttonView;
//    UIButton *agreeBtn;
//    UIButton *disagreeBtn;
//    UIView *centerBorder;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (@available(iOS 13.0, *)) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDarkContent];
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    }
    
    CGRect screen = [[UIScreen mainScreen] bounds];
    screenWidth = screen.size.width;
    
    [_scrollView setFrame:CGRectMake(0, 0, screenWidth, screen.size.height-44)];
    [_container setFrame:CGRectMake(0, 0, screenWidth, screen.size.height-44)];
    
    MFinityAppDelegate *appDelegate = (MFinityAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    
    NSString *str1 = @"터치원 관련 MDM 기능에 대한 고지 및\n개인정보 수집/이용 동의 안내";
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 80)];
    titleLabel.text = str1;
    titleLabel.numberOfLines = 0;
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [appDelegate myRGBfromHex:@"0093D5"];
    [titleLabel setUserInteractionEnabled:NO];
    [_container addSubview:titleLabel];
    

    NSString *str2_1 = @"안녕하세요? \n원활한 터치원 서비스 제공과 관련하여 모바일단말관리 (MDM) 기능을 통해 사용자 ";
    NSMutableAttributedString *attrStr2_1 = [[NSMutableAttributedString alloc]initWithString:str2_1];
    [attrStr2_1 addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} range:NSMakeRange(0, str2_1.length)];
    
    NSString *str2_2 = @"단말기의 일부 기능이 제한ㆍ통제될 수 있음";
    NSMutableAttributedString *attrStr2_2 = [[NSMutableAttributedString alloc]initWithString:str2_2];
    [attrStr2_2 addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16], NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)} range:NSMakeRange(0, str2_2.length)];
    
    NSString *str2_3 = @"을 안내드리며, 이러한 ";
    NSMutableAttributedString *attrStr2_3 = [[NSMutableAttributedString alloc]initWithString:str2_3];
    [attrStr2_3 addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} range:NSMakeRange(0, str2_3.length)];

    NSString *str2_4 = @"사용자 단말기 제한ㆍ통제 대상 항목 및 목적에 대하여 고지";
    NSMutableAttributedString *attrStr2_4 = [[NSMutableAttributedString alloc]initWithString:str2_4];
    [attrStr2_4 addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16], NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)} range:NSMakeRange(0, str2_4.length)];
    
    NSString *str2_5 = @"하고 이에 대한 동의를 구하고자 합니다. 또한 임직원의 개인정보를 수집, 이용함에 있어 개인정보보호법, 정보통신망 이용촉진 및 정보보호등에 관한 법률, 위치정보의 보호 및 이용 등에 관한 법률, 통신비밀보호법 등에 관한 법률 등 관련 법령상의 개인정보보호규정을 준수할 것이며, 다음과 같이 ";
    NSMutableAttributedString *attrStr2_5 = [[NSMutableAttributedString alloc]initWithString:str2_5];
    [attrStr2_5 addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} range:NSMakeRange(0, str2_5.length)];
    
    NSString *str2_6 = @"임직원의 개인정보 수집항목, 수집 및 이용목적, 보유 및 이용기간";
    NSMutableAttributedString *attrStr2_6 = [[NSMutableAttributedString alloc]initWithString:str2_6];
    [attrStr2_6 addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16], NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)} range:NSMakeRange(0, str2_6.length)];
    
    NSString *str2_7 = @"을 설명하고 개인정보 수집 및 이용에 대한 동의를 구하고자 합니다. 개인정보 수집/이용을 원하지 않으실 경우 동의하지 않을 수 있으며, 미동의 시에는 터치원 서비스 이용이 불가함을 알려드립니다.";
    NSMutableAttributedString *attrStr2_7 = [[NSMutableAttributedString alloc]initWithString:str2_7];
    [attrStr2_7 addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} range:NSMakeRange(0, str2_7.length)];
                                
    NSMutableAttributedString *str2AttrContent = [[NSMutableAttributedString alloc]initWithString:@""];
    [str2AttrContent appendAttributedString:attrStr2_1];
    [str2AttrContent appendAttributedString:attrStr2_2];
    [str2AttrContent appendAttributedString:attrStr2_3];
    [str2AttrContent appendAttributedString:attrStr2_4];
    [str2AttrContent appendAttributedString:attrStr2_5];
    [str2AttrContent appendAttributedString:attrStr2_6];
    [str2AttrContent appendAttributedString:attrStr2_7];
    
    boxTxtView = [[UITextView alloc] initWithFrame:CGRectMake(15, titleLabel.frame.origin.y+titleLabel.frame.size.height+15, screenWidth-30, 25)];
    boxTxtView.attributedText = str2AttrContent;
    boxTxtView.font = [UIFont systemFontOfSize:16];
    [boxTxtView setUserInteractionEnabled:NO];
    [boxTxtView sizeToFit];
    
//    boxTxtView.layer.borderWidth = 1;
//    boxTxtView.layer.borderColor = [UIColor blackColor].CGColor;
    
    [_container addSubview:boxTxtView];
    [_container setFrame:CGRectMake(_container.frame.origin.x, 0, screenWidth, boxTxtView.frame.origin.y+boxTxtView.frame.size.height+20)];
    
    //    [self setContentTextView];
    
    NSString *str3 = @"Ⅰ. 모바일 단말 관리(MDM) 기능에 대한 고지";
    UITextView *txtView3 = [[UITextView alloc] initWithFrame:CGRectMake(_container.frame.origin.x, _container.frame.size.height, screenWidth, 20)];
    txtView3.text = str3;
    txtView3.font = [UIFont boldSystemFontOfSize:17];
    [txtView3 setUserInteractionEnabled:NO];
    txtView3.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
    int leftIdx3 = 9 * 2;
    [txtView3 setFrame:CGRectMake(leftIdx3, _container.frame.size.height, screenWidth-leftIdx3-10, 20)];
    [txtView3 sizeToFit];
    [_container addSubview:txtView3];
    [_container setFrame:CGRectMake(_container.frame.origin.x, 0, screenWidth, _container.frame.size.height+20)];
    

    mdmBoxView = [[UIView alloc] initWithFrame:CGRectMake(20, _container.frame.size.height+10, screenWidth-40, 5)];
    mdmBoxView.layer.borderWidth = 1;
    mdmBoxView.layer.borderColor = [UIColor blackColor].CGColor;
    
    
    NSString *str4 = @"1. 모바일 단말 관리 통제 항목";
    UITextView *txtView4 = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, mdmBoxView.frame.size.width, 20)];
    txtView4.text = str4;
    txtView4.font = [UIFont boldSystemFontOfSize:16];
    [txtView4 setUserInteractionEnabled:NO];
    txtView4.textContainerInset = UIEdgeInsetsMake(5, 0, 0, 0);
    int leftIdx4 = 9 * 1;
    [txtView4 setFrame:CGRectMake(leftIdx4, mdmBoxView.frame.size.height, mdmBoxView.frame.size.width-leftIdx4-10, 20)];
    [txtView4 sizeToFit];
    [mdmBoxView addSubview:txtView4];
    [mdmBoxView setFrame:CGRectMake(20, _container.frame.size.height+10, screenWidth-40, mdmBoxView.frame.size.height+txtView4.frame.size.height)];
    
    
    NSString *str5 = @"화면 캡쳐 허용 방지 \n";
    UITextView *txtView5 = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, mdmBoxView.frame.size.width, 20)];
    txtView5.text = str5;
    txtView5.font = [UIFont systemFontOfSize:15];
    [txtView5 setUserInteractionEnabled:NO];
    txtView5.textContainerInset = UIEdgeInsetsMake(5, 0, 0, 0);
    int leftIdx5 = 9 * 3;
    [txtView5 setFrame:CGRectMake(leftIdx5, mdmBoxView.frame.size.height, mdmBoxView.frame.size.width-leftIdx5-10, 20)];
    [txtView5 sizeToFit];
    [mdmBoxView addSubview:txtView5];
    [mdmBoxView setFrame:CGRectMake(20, _container.frame.size.height+10, screenWidth-40, mdmBoxView.frame.size.height+txtView5.frame.size.height)];

    
    NSString *str6 = @"2. 모바일 단말 관리 통제 목적";
    UITextView *txtView6 = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, mdmBoxView.frame.size.width, 20)];
    txtView6.text = str6;
    txtView6.font = [UIFont boldSystemFontOfSize:16];
    [txtView6 setUserInteractionEnabled:NO];
    txtView6.textContainerInset = UIEdgeInsetsMake(5, 0, 0, 0);
    int leftIdx6 = 9 * 1;
    [txtView6 setFrame:CGRectMake(leftIdx6, mdmBoxView.frame.size.height, mdmBoxView.frame.size.width-leftIdx6-10, 20)];
    [txtView6 sizeToFit];
    [mdmBoxView addSubview:txtView6];
    [mdmBoxView setFrame:CGRectMake(20, _container.frame.size.height+10, screenWidth-40, mdmBoxView.frame.size.height+txtView6.frame.size.height)];
    
    
    NSString *str7 = @"회사는 터치원을 이용한 회사 자료 유출 등 터치원 사용 중에 발생할 수 있는 보안사고를 미연에 방지하기 위하여 터치원 서비스 접속 시간 동안 모바일 단말 관리 기능을 통해 사용자 단말기의 화면 캡쳐 기능을 제한ㆍ통제 하고자 합니다. \n";
    UITextView *txtView7 = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, mdmBoxView.frame.size.width, 20)];
    txtView7.text = str7;
    txtView7.font = [UIFont systemFontOfSize:15];
    [txtView7 setUserInteractionEnabled:NO];
    txtView7.textContainerInset = UIEdgeInsetsMake(5, 0, 0, 0);
    int leftIdx7 = 9 * 3;
    [txtView7 setFrame:CGRectMake(leftIdx7, mdmBoxView.frame.size.height, mdmBoxView.frame.size.width-leftIdx7-10, 20)];
    [txtView7 sizeToFit];
    [mdmBoxView addSubview:txtView7];
    [mdmBoxView setFrame:CGRectMake(20, _container.frame.size.height+10, screenWidth-40, mdmBoxView.frame.size.height+txtView7.frame.size.height)];
    
    
    NSString *str8 = @"3. 회사는 추후 터치원에 적용되는 모바일 단말 관리 통제 기능이 추가·변경될 경우, 이를 즉시 임직원에게 고지하겠습니다. \n";
    UITextView *txtView8 = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, mdmBoxView.frame.size.width, 20)];
    txtView8.text = str8;
    txtView8.font = [UIFont boldSystemFontOfSize:16];
    [txtView8 setUserInteractionEnabled:NO];
    txtView8.textContainerInset = UIEdgeInsetsMake(5, 0, 0, 0);
    int leftIdx8 = 9 * 1;
    [txtView8 setFrame:CGRectMake(leftIdx8, mdmBoxView.frame.size.height, mdmBoxView.frame.size.width-leftIdx8-10, 20)];
    [txtView8 sizeToFit];
    [mdmBoxView addSubview:txtView8];
    [mdmBoxView setFrame:CGRectMake(20, _container.frame.size.height+10, screenWidth-40, mdmBoxView.frame.size.height+txtView8.frame.size.height)];
    
    
    NSString *str9 = @"4. 임직원은 본 동의서에 의한 모바일 단말 관리 통제 기능에 대한 동의를 거부하실 권리가 있습니다. 단, 동의를 거부하는 경우에는 터치원 사용이 불가함을 알려드립니다.";
    UITextView *txtView9 = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, mdmBoxView.frame.size.width, 20)];
    txtView9.text = str9;
    txtView9.font = [UIFont boldSystemFontOfSize:16];
    [txtView9 setUserInteractionEnabled:NO];
    txtView9.textContainerInset = UIEdgeInsetsMake(5, 0, 0, 0);
    int leftIdx9 = 9 * 1;
    [txtView9 setFrame:CGRectMake(leftIdx9, mdmBoxView.frame.size.height, mdmBoxView.frame.size.width-leftIdx9-10, 20)];
    [txtView9 sizeToFit];
    [mdmBoxView addSubview:txtView9];
    [mdmBoxView setFrame:CGRectMake(20, _container.frame.size.height+10, screenWidth-40, mdmBoxView.frame.size.height+txtView9.frame.size.height+10)];

    [_container addSubview:mdmBoxView];
    [_container setFrame:CGRectMake(_container.frame.origin.x, 0, screenWidth, _container.frame.size.height+mdmBoxView.frame.size.height+20)];
    
    
    NSString *str10 = @"Ⅱ. 개인정보 수집/이용 동의서";
    UITextView *txtView10 = [[UITextView alloc] initWithFrame:CGRectMake(_container.frame.origin.x, _container.frame.size.height, screenWidth, 20)];
    txtView10.text = str10;
    txtView10.font = [UIFont boldSystemFontOfSize:17];
    [txtView10 setUserInteractionEnabled:NO];
    txtView10.textContainerInset = UIEdgeInsetsMake(20, 0, 0, 0);
    int leftIdx10 = 9 * 2;
    [txtView10 setFrame:CGRectMake(leftIdx10, _container.frame.size.height, screenWidth-leftIdx10-10, 20)];
    [txtView10 sizeToFit];
    [_container addSubview:txtView10];
    [_container setFrame:CGRectMake(_container.frame.origin.x, 0, screenWidth, _container.frame.size.height+txtView10.frame.size.height)];
    
    
    privateBoxView = [[UIView alloc] initWithFrame:CGRectMake(20, _container.frame.size.height+10, screenWidth-40, 5)];
    privateBoxView.layer.borderWidth = 1;
    privateBoxView.layer.borderColor = [UIColor blackColor].CGColor;
    
    NSString *str11 = @"5. 개인정보의 수집 및 이용 목적";
    UITextView *txtView11 = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, privateBoxView.frame.size.width, 20)];
    txtView11.text = str11;
    txtView11.font = [UIFont boldSystemFontOfSize:16];
    [txtView11 setUserInteractionEnabled:NO];
    txtView11.textContainerInset = UIEdgeInsetsMake(5, 0, 0, 0);
    int leftIdx11 = 9 * 1;
    [txtView11 setFrame:CGRectMake(leftIdx11, privateBoxView.frame.size.height, privateBoxView.frame.size.width-leftIdx11-10, 20)];
    [txtView11 sizeToFit];
    [privateBoxView addSubview:txtView11];
    [privateBoxView setFrame:CGRectMake(20, _container.frame.size.height+10, screenWidth-40, privateBoxView.frame.size.height+txtView11.frame.size.height)];
    
    NSString *str12 = @"회사는 임직원의 터치원 서비스 제공을 위한 목적으로 임직원의 개인정보를 수집 및 이용하고자 하며, 본 동의서의 범위를 초과하는 수집 및 이용이 필요한 경우에는 별도의 동의를 받겠습니다. \n";
    UITextView *txtView12 = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, privateBoxView.frame.size.width, 20)];
    txtView12.text = str12;
    txtView12.font = [UIFont systemFontOfSize:15];
    [txtView12 setUserInteractionEnabled:NO];
    txtView12.textContainerInset = UIEdgeInsetsMake(5, 0, 0, 0);
    int leftIdx12 = 9 * 3;
    [txtView12 setFrame:CGRectMake(leftIdx12, privateBoxView.frame.size.height, privateBoxView.frame.size.width-leftIdx12-10, 20)];
    [txtView12 sizeToFit];
    [privateBoxView addSubview:txtView12];
    [privateBoxView setFrame:CGRectMake(20, _container.frame.size.height+10, screenWidth-40, privateBoxView.frame.size.height+txtView12.frame.size.height)];

    
    NSString *str13 = @"6. 개인정보의 수집 항목";
    UITextView *txtView13 = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, privateBoxView.frame.size.width, 20)];
    txtView13.text = str13;
    txtView13.font = [UIFont boldSystemFontOfSize:16];
    [txtView13 setUserInteractionEnabled:NO];
    txtView13.textContainerInset = UIEdgeInsetsMake(5, 0, 0, 0);
    int leftIdx13 = 9 * 1;
    [txtView13 setFrame:CGRectMake(leftIdx13, privateBoxView.frame.size.height, privateBoxView.frame.size.width-leftIdx13-10, 20)];
    [txtView13 sizeToFit];
    [privateBoxView addSubview:txtView13];
    [privateBoxView setFrame:CGRectMake(20, _container.frame.size.height+10, screenWidth-40, privateBoxView.frame.size.height+txtView13.frame.size.height)];
    
    NSString *str14_1 = @"가.";
    UITextView *txtView14_1 = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, privateBoxView.frame.size.width, 20)];
    txtView14_1.text = str14_1;
    txtView14_1.font = [UIFont systemFontOfSize:15];
    [txtView14_1 setUserInteractionEnabled:NO];
    txtView14_1.textContainerInset = UIEdgeInsetsMake(5, 0, 0, 0);
    int leftIdx14_1 = 9 * 3;
    [txtView14_1 setFrame:CGRectMake(leftIdx14_1, privateBoxView.frame.size.height, privateBoxView.frame.size.width-leftIdx14_1-10, 20)];
    [txtView14_1 sizeToFit];
    [privateBoxView addSubview:txtView14_1];
    [privateBoxView setFrame:CGRectMake(20, _container.frame.size.height+10, screenWidth-40, privateBoxView.frame.size.height+txtView14_1.frame.size.height)];
    
    NSString *str14_2 = @"터치원 관련 수집 항목 \n- 설치 단말기 정보, 사용자정보 \n- 로그인 정보, 업무앱 실행시간";
    UITextView *txtView14_2 = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, privateBoxView.frame.size.width, 20)];
    txtView14_2.text = str14_2;
    txtView14_2.font = [UIFont systemFontOfSize:15];
    [txtView14_2 setUserInteractionEnabled:NO];
    txtView14_2.textContainerInset = UIEdgeInsetsMake(5, 0, 0, 0);
    [txtView14_2 setFrame:CGRectMake(txtView14_1.frame.origin.x+txtView14_1.frame.size.width-5, txtView14_1.frame.origin.y, privateBoxView.frame.size.width-leftIdx14_1-txtView14_1.frame.size.width, 20)];
    [txtView14_2 sizeToFit];
    [privateBoxView addSubview:txtView14_2];
    [privateBoxView setFrame:CGRectMake(20, _container.frame.size.height+10, screenWidth-40, privateBoxView.frame.size.height+txtView14_2.frame.size.height)];
    
    NSString *str14_3 = @"나.";
    UITextView *txtView14_3 = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, privateBoxView.frame.size.width, 20)];
    txtView14_3.text = str14_3;
    txtView14_3.font = [UIFont systemFontOfSize:15];
    [txtView14_3 setUserInteractionEnabled:NO];
    txtView14_3.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
    int leftIdx14_3 = 9 * 3;
    [txtView14_3 setFrame:CGRectMake(leftIdx14_3, privateBoxView.frame.size.height, privateBoxView.frame.size.width-leftIdx14_3-10, 20)];
    [txtView14_3 sizeToFit];
    [privateBoxView addSubview:txtView14_3];
    [privateBoxView setFrame:CGRectMake(20, _container.frame.size.height+10, screenWidth-40, privateBoxView.frame.size.height+txtView14_3.frame.size.height)];
    
    NSString *str14_4 = @"MDM 관련 수집 항목 \n- 설치 단말기 정보 \n- 사용자 정보, 로그인 정보";
    UITextView *txtView14_4 = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, privateBoxView.frame.size.width, 20)];
    txtView14_4.text = str14_4;
    txtView14_4.font = [UIFont systemFontOfSize:15];
    [txtView14_4 setUserInteractionEnabled:NO];
    txtView14_4.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [txtView14_4 setFrame:CGRectMake(txtView14_3.frame.origin.x+txtView14_3.frame.size.width-5, txtView14_3.frame.origin.y, privateBoxView.frame.size.width-leftIdx14_3-txtView14_3.frame.size.width, 20)];
    [txtView14_4 sizeToFit];
    [privateBoxView addSubview:txtView14_4];
    [privateBoxView setFrame:CGRectMake(20, _container.frame.size.height+10, screenWidth-40, privateBoxView.frame.size.height+txtView14_4.frame.size.height)];
    
    
    NSString *str15 = @"7. 개인정보의 보유 및 이용기간";
    UITextView *txtView15 = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, privateBoxView.frame.size.width, 20)];
    txtView15.text = str15;
    txtView15.font = [UIFont boldSystemFontOfSize:16];
    [txtView15 setUserInteractionEnabled:NO];
    txtView15.textContainerInset = UIEdgeInsetsMake(5, 0, 0, 0);
    int leftIdx15 = 9 * 1;
    [txtView15 setFrame:CGRectMake(leftIdx15, privateBoxView.frame.size.height, privateBoxView.frame.size.width-leftIdx15-10, 20)];
    [txtView15 sizeToFit];
    [privateBoxView addSubview:txtView15];
    [privateBoxView setFrame:CGRectMake(20, _container.frame.size.height+10, screenWidth-40, privateBoxView.frame.size.height+txtView15.frame.size.height)];
    
    NSString *str16_1 = @"가.";
    UITextView *txtView16_1 = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, privateBoxView.frame.size.width, 20)];
    txtView16_1.text = str16_1;
    txtView16_1.font = [UIFont systemFontOfSize:15];
    [txtView16_1 setUserInteractionEnabled:NO];
    txtView16_1.textContainerInset = UIEdgeInsetsMake(5, 0, 0, 0);
    int leftIdx16_1 = 9 * 3;
    [txtView16_1 setFrame:CGRectMake(leftIdx16_1, privateBoxView.frame.size.height, privateBoxView.frame.size.width-leftIdx16_1-10, 20)];
    [txtView16_1 sizeToFit];
    [privateBoxView addSubview:txtView16_1];
    [privateBoxView setFrame:CGRectMake(20, _container.frame.size.height+10, screenWidth-40, privateBoxView.frame.size.height+txtView16_1.frame.size.height)];
    
    NSString *str16_2 = @"회사는 임직원으로부터 수집한 개인정보를 개인정보의 수집∙이용 목적 달성 시(퇴사 및 계약종료) 까지 보유 및 이용할 수 있습니다.";
    UITextView *txtView16_2 = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, privateBoxView.frame.size.width, 20)];
    txtView16_2.text = str16_2;
    txtView16_2.font = [UIFont systemFontOfSize:15];
    [txtView16_2 setUserInteractionEnabled:NO];
    txtView16_2.textContainerInset = UIEdgeInsetsMake(5, 0, 0, 0);
    [txtView16_2 setFrame:CGRectMake(txtView16_1.frame.origin.x+txtView16_1.frame.size.width-5, txtView16_1.frame.origin.y, privateBoxView.frame.size.width-leftIdx16_1-txtView16_1.frame.size.width, 20)];
    [txtView16_2 sizeToFit];
    [privateBoxView addSubview:txtView16_2];
    [privateBoxView setFrame:CGRectMake(20, _container.frame.size.height+10, screenWidth-40, privateBoxView.frame.size.height+txtView16_2.frame.size.height)];
    
    NSString *str16_3 = @"나.";
    UITextView *txtView16_3 = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, privateBoxView.frame.size.width, 20)];
    txtView16_3.text = str16_3;
    txtView16_3.font = [UIFont systemFontOfSize:15];
    [txtView16_3 setUserInteractionEnabled:NO];
    txtView16_3.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
    int leftIdx16_3 = 9 * 3;
    [txtView16_3 setFrame:CGRectMake(leftIdx16_3, privateBoxView.frame.size.height, privateBoxView.frame.size.width-leftIdx16_3-10, 20)];
    [txtView16_3 sizeToFit];
    [privateBoxView addSubview:txtView16_3];
    [privateBoxView setFrame:CGRectMake(20, _container.frame.size.height+10, screenWidth-40, privateBoxView.frame.size.height+txtView16_3.frame.size.height)];
    
    NSString *str16_4 = @"회사는 개인정보의 보유 및 이용기간이 경과하거나 수집 이용 목적이 달성된(퇴사 및 계약종료) 경우에는 개인정보를 지체없이 파기하겠습니다. 단, 관련 법률에 따라 보존할 필요가 있거나 임직원의 별도 동의를 받은 경우에는 수집/이용 기간이 종료한 경우에도 필요한 목적 범위의 한도 내에서 보존할 수 있으며, 이에 대하여 대상자에게 고지하겠습니다.";
    UITextView *txtView16_4 = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, privateBoxView.frame.size.width, 20)];
    txtView16_4.text = str16_4;
    txtView16_4.font = [UIFont systemFontOfSize:15];
    [txtView16_4 setUserInteractionEnabled:NO];
    txtView16_4.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [txtView16_4 setFrame:CGRectMake(txtView16_3.frame.origin.x+txtView16_3.frame.size.width-5, txtView16_3.frame.origin.y, privateBoxView.frame.size.width-leftIdx16_3-txtView16_3.frame.size.width, 20)];
    [txtView16_4 sizeToFit];
    [privateBoxView addSubview:txtView16_4];
    [privateBoxView setFrame:CGRectMake(20, _container.frame.size.height+10, screenWidth-40, privateBoxView.frame.size.height+txtView16_4.frame.size.height)];
    
    NSString *str16_5 = @"다.";
    UITextView *txtView16_5 = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, privateBoxView.frame.size.width, 20)];
    txtView16_5.text = str16_5;
    txtView16_5.font = [UIFont systemFontOfSize:15];
    [txtView16_5 setUserInteractionEnabled:NO];
    txtView16_5.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
    int leftIdx16_5 = 9 * 3;
    [txtView16_5 setFrame:CGRectMake(leftIdx16_5, privateBoxView.frame.size.height, privateBoxView.frame.size.width-leftIdx16_5-10, 20)];
    [txtView16_5 sizeToFit];
    [privateBoxView addSubview:txtView16_5];
    [privateBoxView setFrame:CGRectMake(20, _container.frame.size.height+10, screenWidth-40, privateBoxView.frame.size.height+txtView16_5.frame.size.height)];
    
    NSString *str16_6 = @"수집된 개인정보는 개인정보 제공자가 동의한 내용 외의 다른 목적으로 이용되지 않으며, 제공된 개인정보의 이용을 거부하고자 할 때에는 개인정보 관리책임자를 통해 열람, 정정, 삭제를 요구할 수 있습니다. \n* 개인정보 관리담당자 \n: 정보보안인프라팀 김광호차장 \n(kwangkim@hhi.co.kr)";
    UITextView *txtView16_6 = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, privateBoxView.frame.size.width, 20)];
    txtView16_6.text = str16_6;
    txtView16_6.font = [UIFont systemFontOfSize:15];
    [txtView16_6 setUserInteractionEnabled:NO];
    txtView16_6.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [txtView16_6 setFrame:CGRectMake(txtView16_5.frame.origin.x+txtView16_5.frame.size.width-5, txtView16_5.frame.origin.y, privateBoxView.frame.size.width-leftIdx16_5-txtView16_5.frame.size.width, 20)];
    [txtView16_6 sizeToFit];
    [privateBoxView addSubview:txtView16_6];
    [privateBoxView setFrame:CGRectMake(20, _container.frame.size.height+10, screenWidth-40, privateBoxView.frame.size.height+txtView16_6.frame.size.height)];
    
    NSString *str17 = @"8. 임직원은 본 동의서에 의한 개인정보의 수집 및 이용에 대한 동의를 거부하실 권리가 있습니다. 단, 동의를 거부하는 경우에는 터치원 사용이 불가함을 알려드립니다.";
    UITextView *txtView17 = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, privateBoxView.frame.size.width, 20)];
    txtView17.text = str17;
    txtView17.font = [UIFont boldSystemFontOfSize:16];
    [txtView17 setUserInteractionEnabled:NO];
    txtView17.textContainerInset = UIEdgeInsetsMake(5, 0, 10, 0);
    int leftIdx17 = 9 * 1;
    [txtView17 setFrame:CGRectMake(leftIdx17, privateBoxView.frame.size.height, privateBoxView.frame.size.width-leftIdx17-10, 20)];
    [txtView17 sizeToFit];
    [privateBoxView addSubview:txtView17];
    [privateBoxView setFrame:CGRectMake(20, _container.frame.size.height+10, screenWidth-40, privateBoxView.frame.size.height+txtView17.frame.size.height)];
    
    [_container addSubview:privateBoxView];
    [_container setFrame:CGRectMake(_container.frame.origin.x, 0, screenWidth, _container.frame.size.height+privateBoxView.frame.size.height+20)];
       
    NSString *str18 = @"▣ 본인은 모바일 단말 관리 기능에 대한 고지 및 개인정보 수집/이용 동의서 내용을 확인하고 회사가 본인의 개인정보를 수집/이용하는 것에 동의합니다. \n";
    UITextView *txtView18 = [[UITextView alloc] initWithFrame:CGRectMake(_container.frame.origin.x, _container.frame.size.height, screenWidth, 20)];
    txtView18.text = str18;
    txtView18.font = [UIFont boldSystemFontOfSize:17];
    [txtView18 setUserInteractionEnabled:NO];
    txtView18.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
    int leftIdx18 = 9 * 2;
    [txtView18 setFrame:CGRectMake(leftIdx18, _container.frame.size.height, screenWidth-(leftIdx18*2), 20)];
    [txtView18 sizeToFit];
    [_container addSubview:txtView18];
    [_container setFrame:CGRectMake(_container.frame.origin.x, 0, screenWidth, _container.frame.size.height+txtView18.frame.size.height+20)];
    

    UISegmentedControl *agreeSegment = [[UISegmentedControl alloc]initWithItems:@[NSLocalizedString(@"personal_disagree", @"personal_disagree"), NSLocalizedString(@"personal_agree", @"personal_agree")]];
    [agreeSegment setFrame:CGRectMake(10, _container.frame.size.height, screenWidth-20, 40)];

    agreeSegment.tintColor = [appDelegate myRGBfromHex:@"0093D5"];
    agreeSegment.backgroundColor = [UIColor whiteColor];
    if (@available(iOS 13.0, *)) {
        agreeSegment.selectedSegmentTintColor = [appDelegate myRGBfromHex:@"0093D5"];
    }
    agreeSegment.layer.borderWidth = 1;
    agreeSegment.layer.borderColor = [appDelegate myRGBfromHex:@"0093D5"].CGColor;
    
    [agreeSegment setSelectedSegmentIndex:UISegmentedControlNoSegment];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont systemFontOfSize:16], NSFontAttributeName,
                                [UIColor blackColor], NSForegroundColorAttributeName,
                                nil];
//    NSDictionary *attributes2 = [NSDictionary dictionaryWithObjectsAndKeys:
//                                [UIFont systemFontOfSize:16], NSFontAttributeName,
//                                [appDelegate myRGBfromHex:@"0093D5"], NSForegroundColorAttributeName,
//                                nil];
    [agreeSegment setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    
//    NSMutableAttributedString *disagree = [[NSMutableAttributedString alloc]initWithString:NSLocalizedString(@"personal_disagree", @"personal_disagree")];
//    [disagree addAttributes:attributes range:NSMakeRange(0, disagree.length)];
//    [agreeSegment setTitle:disagree.mutableString forSegmentAtIndex:0];
//
//    NSMutableAttributedString *agree = [[NSMutableAttributedString alloc]initWithString:NSLocalizedString(@"personal_agree", @"personal_agree")];
//    [agree addAttributes:attributes2 range:NSMakeRange(0, agree.length)];
//    [agreeSegment setTitle:agree.mutableString forSegmentAtIndex:1];
    
    NSDictionary *highlightedAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    [agreeSegment setTitleTextAttributes:highlightedAttributes forState:UIControlStateSelected];
    
    [agreeSegment addTarget:self action:@selector(agreeChangeValue:) forControlEvents:UIControlEventValueChanged];
    
    [_container addSubview:agreeSegment];
    [_container setFrame:CGRectMake(0, 0, _container.frame.size.width, _container.frame.size.height+agreeSegment.frame.size.height+30)];
    
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.contentSize = _container.frame.size;
}

/*
-(void)setContentTextView{
    h = 0;
    self.txtArr = [[NSMutableArray alloc] init];
    
    NSString *str4 = @"1. 모바일 단말 관리 통제 항목";
    NSString *str5 = @"화면 캡쳐 허용 방지\n";
    NSString *str6 = @"2. 모바일 단말 관리 통제 목적";
    NSString *str7 = @"회사는 터치원을 이용한 회사 자료 유출 등 터치원 사용 중에 발생할 수 있는 보안사고를 미연에 방지하기 위하여 터치원 서비스 접속 시간 동안 모바일 단말 관리 기능을 통해 사용자 단말기(IOS)의 화면 캡쳐 기능을 제한ㆍ통제 하고자 합니다.\n";
    NSString *str8 = @"3. 회사는 추후 터치원에 적용되는 모바일 단말 관리 통제 기능이 추가·변경될 경우, 이를 즉시 임직원에게 고지하겠습니다.\n";
    NSString *str9 = @"4. 임직원은 본 동의서에 의한 모바일 단말 관리 통제 기능에 대한 동의를 거부하실 권리가 있습니다. 단, 동의를 거부하는 경우에는 터치원 사용이 불가함을 알려드립니다.\n";
    NSString *str10 = @"\nⅡ. 개인정보 수집/이용 동의서\n";
    NSString *str11 = @"1. 개인정보의 수집 및 이용 목적";
    NSString *str12 = @"회사는 임직원의 터치원 서비스 제공을 위한 목적으로 임직원의 개인정보를 수집 및 이용하고자 하며, 본 동의서의 범위를 초과하는 수집 및 이용이 필요한 경우에는 별도의 동의를 받겠습니다.\n";
    NSString *str13 = @"2. 개인정보의 수집 항목";
    NSString *str14 = @"가. 터치원 관련 수집 항목 \n단말기 및 운영체제 정보, 통신사 정보, 사번, 앱 실행 정보(앱 종류, 실행 시간) 등 \n\n나. 모바일 단말 관리 관련 수집 항목 \n모바일 단말 관리 설치 일자, 단말기 정보, 설치 앱 정보, 위치정보 등\n";
    NSString *str15 = @"3. 개인정보의 보유 및 이용기간";
    NSString *str16 = @"가. 회사는 임직원으로부터 수집한 개인정보를 개인정보의 수집∙이용 목적 달성 시까지 보유 및 이용할 수 있습니다. \n\n나. 회사는 개인정보의 보유 및 이용기간이 경과하거나 수집 이용 목적이 달성된 경우에는 개인정보를 지체없이 파기하겠습니다. 단, 관련 법률에 따라 보존할 필요가 있거나 임직원의 별도 동의를 받은 경우에는 수집/이용 기간이 종료한 경우에도 필요한 목적 범위의 한도 내에서 보존할 수 있으며, 이에 대하여 대상자에게 고지하겠습니다. \n\n다. 수집된 개인정보는 개인정보 제공자가 동의한 내용 외의 다른 목적으로 이용되지 않으며, 제공된 개인정보의 이용을 거부하고자 할 때에는 개인정보 관리책임자를 통해 열람, 정정, 삭제를 요구할 수 있습니다.\n";
    NSString *str17 = @"4. 임직원은 본 동의서에 의한 개인정보의 수집 및 이용에 대한 동의를 거부하실 권리가 있습니다. 단, 동의를 거부하는 경우에는 터치원 사용이 불가함을 알려드립니다.\n";
    NSString *str18 = @"\n▣ 본인은 모바일 단말 관리 기능에 대한 고지 및 개인정보 수집/이용 동의서 내용을 확인하고, 터치원 사용시 본인의 단말기 일부 기능이 제한ㆍ통제되는 것과 회사가 본인의 개인정보를 수집/이용하는 것에 동의합니다. 동의를 거부하는 경우에는 터치원 사용이 불가함을 알려드립니다.\n";
    
    for(int i=(int)([_container subviews].count-1); i>=0; i--){
        if([[[_container subviews] objectAtIndex:i] isKindOfClass:NSClassFromString(@"UITextView")]) {
            if(i>1) [[[_container subviews] objectAtIndex:i] removeFromSuperview];
        }
    }
    
    [self setTextView:str4 textAlign:@"LEFT" fontStyle:@"BOLD" fontSize:16 tab:2];
    [self setTextView:str5 textAlign:@"LEFT" fontStyle:@"DEFAULT" fontSize:15 tab:4];
    [self setTextView:str6 textAlign:@"LEFT" fontStyle:@"BOLD" fontSize:16 tab:2];
    [self setTextView:str7 textAlign:@"LEFT" fontStyle:@"DEFAULT" fontSize:15 tab:4];
    [self setTextView:str8 textAlign:@"LEFT" fontStyle:@"BOLD" fontSize:16 tab:2];
    [self setTextView:str9 textAlign:@"LEFT" fontStyle:@"BOLD" fontSize:16 tab:2];
    [self setTextView:str10 textAlign:@"LEFT" fontStyle:@"BOLD" fontSize:17 tab:1];
    [self setTextView:str11 textAlign:@"LEFT" fontStyle:@"BOLD" fontSize:16 tab:2];
    [self setTextView:str12 textAlign:@"LEFT" fontStyle:@"DEFAULT" fontSize:15 tab:4];
    [self setTextView:str13 textAlign:@"LEFT" fontStyle:@"BOLD" fontSize:16 tab:2];
    [self setTextView:str14 textAlign:@"LEFT" fontStyle:@"DEFAULT" fontSize:15 tab:4];
    [self setTextView:str15 textAlign:@"LEFT" fontStyle:@"BOLD" fontSize:16 tab:2];
    [self setTextView:str16 textAlign:@"LEFT" fontStyle:@"DEFAULT" fontSize:15 tab:4];
    [self setTextView:str17 textAlign:@"LEFT" fontStyle:@"BOLD" fontSize:16 tab:2];
    [self setTextView:str18 textAlign:@"LEFT" fontStyle:@"DEFAULT" fontSize:15 tab:1];
    
    [_container setFrame:CGRectMake(0, 0, screenWidth, h+_container.frame.size.height)];
}

-(UITextView *)setTextView:(NSString *)content textAlign:(NSString *)align fontStyle:(NSString *)fontStyle fontSize:(int)fontSize tab:(int)tab{
    UITextView *txtView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 20)];
    txtView.text = content;
    
    if([fontStyle isEqualToString:@"BOLD"]){
        txtView.font = [UIFont boldSystemFontOfSize:fontSize];
    } else if([fontStyle isEqualToString:@"DEFAULT"]){
        txtView.font = [UIFont systemFontOfSize:fontSize];
    }
    
    if([align isEqualToString:@"CENTER"]){
        txtView.textAlignment = NSTextAlignmentCenter;
    } else if([align isEqualToString:@"LEFT"]){
        txtView.textAlignment = NSTextAlignmentLeft;
    }
    
    [txtView setUserInteractionEnabled:NO];
    txtView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
    int leftIdx = 9 * tab;
    
    [self.txtArr addObject:txtView];
    
    if(self.txtArr.count==1){
        [txtView setFrame:CGRectMake(leftIdx, _container.frame.size.height, screenWidth-leftIdx-10, 20)];
    } else {
        UITextView *tmpPrevTxt = [self.txtArr objectAtIndex:self.txtArr.count-2];
        [txtView setFrame:CGRectMake(leftIdx, tmpPrevTxt.frame.origin.y+tmpPrevTxt.frame.size.height, screenWidth-leftIdx-10, 20)];
    }
    
    [txtView sizeToFit];
    [_container addSubview:txtView];
    h += txtView.frame.size.height+1;
    
//    if([align isEqualToString:@"CENTER"]){
//        [txtView setFrame:CGRectMake((_textContainer.frame.size.width/2)-(txtView.frame.size.width/2), 0, txtView.frame.size.width, 50)];
//    }
//    [_container setFrame:CGRectMake(0, 0, _container.frame.size.width, h)];

    return txtView;
}
*/

/*
-(void)agreeHighlight:(UIButton *)sender{
    [sender setBackgroundColor:[appDelegate myRGBfromHex:@"0093D5"]];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont boldSystemFontOfSize:16], NSFontAttributeName,
                                [UIColor whiteColor], NSForegroundColorAttributeName,
                                nil];
    NSAttributedString *attr1 = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"personal_agree", @"personal_agree") attributes:attributes];
    [sender setAttributedTitle:attr1 forState:UIControlStateNormal];
}

-(void)agreeNormal:(UIButton *)sender{
    [sender setBackgroundColor:[UIColor lightGrayColor]];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont boldSystemFontOfSize:16], NSFontAttributeName,
                                [UIColor blackColor], NSForegroundColorAttributeName,
                                nil];
    NSAttributedString *attr1 = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"personal_agree", @"personal_agree") attributes:attributes];
    [sender setAttributedTitle:attr1 forState:UIControlStateNormal];

    NSString *encodingID = [FBEncryptorAES encryptBase64String:[appDelegate.user_id uppercaseString]
                                                     keyString:appDelegate.AES256Key
                                                 separateLines:NO];
    encodingID = [encodingID urlEncodeUsingEncoding:NSUTF8StringEncoding];
    NSString *dvcid = [MFinityAppDelegate getUUID];
    NSString *dvcKind = [[UIDevice currentDevice] modelName];
    NSString *dvcOs = @"iOS";

    NSString *paramString;
    NSString *urlStr = [NSString stringWithFormat:@"%@/setAgreement",appDelegate.main_url];
    if (appDelegate.isAES256) {
        paramString = [[NSString alloc]initWithFormat:@"id=%@&dvcId=%@&dvcKind=%@&dvcOs=%@&encType=AES256", encodingID, dvcid, dvcKind, dvcOs];
    }else{
        paramString = [[NSString alloc]initWithFormat:@"id=%@&dvcId=%@&dvcKind=%@&dvcOs=%@", encodingID, dvcid, dvcKind, dvcOs];
    }
    [self URL:[NSURL URLWithString:urlStr] parameter:paramString];
}

-(void)disagreeHighlight:(UIButton *)sender{
    [sender setBackgroundColor:[appDelegate myRGBfromHex:@"0093D5"]];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont boldSystemFontOfSize:16], NSFontAttributeName,
                                [UIColor whiteColor], NSForegroundColorAttributeName,
                                nil];
    NSAttributedString *attr1 = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"personal_disagree", @"personal_disagree") attributes:attributes];
    [sender setAttributedTitle:attr1 forState:UIControlStateNormal];
}

-(void)disagreeNormal:(UIButton *)sender{
    [sender setBackgroundColor:[UIColor lightGrayColor]];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont boldSystemFontOfSize:16], NSFontAttributeName,
                                [UIColor blackColor], NSForegroundColorAttributeName,
                                nil];
    NSAttributedString *attr1 = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"personal_disagree", @"personal_disagree") attributes:attributes];
    [sender setAttributedTitle:attr1 forState:UIControlStateNormal];

    NSDictionary *resultDict = [[NSDictionary alloc] initWithObjectsAndKeys:_loginResult,@"LOGIN_RESULT", @"0",@"AGREE_VALUE", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AgreementNotification" object:resultDict];
    [self dismissViewControllerAnimated:YES completion:nil];
}
*/

-(void)agreeChangeValue: (UISegmentedControl *)sender{
    if(sender.selectedSegmentIndex == 0) {
//        NSLog(@"_loginResult0 : %@", _loginResult);
         NSDictionary *resultDict = [[NSDictionary alloc] initWithObjectsAndKeys:_loginResult,@"LOGIN_RESULT", [NSString stringWithFormat:@"%ld", (long)sender.selectedSegmentIndex],@"AGREE_VALUE", nil];
         [[NSNotificationCenter defaultCenter] postNotificationName:@"AgreementNotification" object:resultDict];
        [self dismissViewControllerAnimated:YES completion:nil];

    } else {
//        NSLog(@"_loginResult1 : %@", _loginResult);
        NSString *encodingID = [FBEncryptorAES encryptBase64String:[appDelegate.user_id uppercaseString]
                                                         keyString:appDelegate.AES256Key
                                                     separateLines:NO];
        encodingID = [encodingID urlEncodeUsingEncoding:NSUTF8StringEncoding];
        NSString *dvcid = [MFinityAppDelegate getUUID];
        NSString *dvcKind = [[UIDevice currentDevice] modelName];
        NSString *dvcOs = @"iOS";

        NSString *paramString;
        NSString *urlStr = [NSString stringWithFormat:@"%@/setAgreement",appDelegate.main_url];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        if (appDelegate.isAES256) {
            paramString = [[NSString alloc]initWithFormat:@"id=%@&dvcId=%@&dvcKind=%@&dvcOs=%@&encType=AES256", encodingID, [prefs objectForKey:@"UUID"], dvcKind, dvcOs];
        }else{
            paramString = [[NSString alloc]initWithFormat:@"id=%@&dvcId=%@&dvcKind=%@&dvcOs=%@", encodingID, [prefs objectForKey:@"UUID"], dvcKind, dvcOs];
        }
        [self URL:[NSURL URLWithString:urlStr] parameter:paramString];
    }
}

-(void)returnSessionData:(NSDictionary *)dict{
    if([[dict objectForKey:@"V1"] isEqualToString:@"SUCCEED"]){
        if([_loginResult isEqualToString:@"NOTCERT"]){
            NSDictionary *resultDict = [[NSDictionary alloc] initWithObjectsAndKeys:_loginResult,@"LOGIN_RESULT", @"1",@"AGREE_VALUE", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AgreementNotification" object:resultDict];
            [self dismissViewControllerAnimated:YES completion:nil];
            
        } else {
            if(appDelegate.isMDM) [self enterWorkApp];
            else [appDelegate.window setRootViewController:appDelegate.tabBarController];
        }
    } else {
        
    }
}

#pragma mark - URLSession
- (void)URL:(NSURL *)url parameter:(NSString *)paramString {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0f];
    [request setHTTPMethod:@"POST"];

    @try {
        if (paramString != nil) {
            NSData *paramData = [paramString dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:paramData];
        }
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
        self.returnData = [[NSMutableData alloc] init];
        [task resume];
        
    }
    @catch (NSException *exception) {
        NSLog(@"error : %@",exception);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    NSInteger code = [(NSHTTPURLResponse *) response statusCode];
    if(code >= 200 && code < 300) {
        completionHandler (NSURLSessionResponseAllow);
    } else {
        NSLog(@"error code : %ld", (long)code);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self.returnData appendData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if(!error){
        NSString *encReturnDataString = [[NSString alloc]initWithData:self.returnData encoding:NSUTF8StringEncoding];
        NSLog(@"encReturnDataString : %@", encReturnDataString);

        NSError *dicError;
        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:[encReturnDataString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&dicError];
        [self returnSessionData:dataDic];
        
    } else {
        NSLog(@"error : %@",error);
    }
}

@end
