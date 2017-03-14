//
//  HTAddressPickerView.m
//  MyComsTest
//
//  Created by HengtaoDai on 16/8/3.
//  Copyright © 2016年 DaiHT. All rights reserved.
//

#import "HTAddressPickerView.h"
#import "HTAddressBean.h"

#define G_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
static const CGFloat kAnimateDuration = 0.3;        //动画持续时间
static NSString *const keyForCity = @"cities";      //字典中城市数组所对应的key
static NSString *const keyForRegion = @"districts"; //字典中县/区数组所对应的key

@interface HTAddressPickerView () <UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic, strong) UIView *viewBack;         //背景视图
@property (nonatomic, strong) UIView *viewButtons;      //按钮背景

@property (nonatomic, strong) UIPickerView *pickerView;       //地址选择器

@property (nonatomic, assign) NSInteger iProvinceRow;      //当前省所在的行数
@property (nonatomic, assign) NSInteger iCityRow;          //当前市所在的行数
@property (nonatomic, assign) NSInteger iRegionRow;        //当前县/区所在的行数

@property (nonatomic, strong) NSMutableArray *marrAlldata;      //总数据
@property (nonatomic, strong) NSMutableArray *marrProvince;     //所有省
@property (nonatomic, strong) NSMutableArray *marrCity;         //当前省的所有市
@property (nonatomic, strong) NSMutableArray *marrRegion;       //当前市的所有县/区

@end

@implementation HTAddressPickerView

- (id)initWithFrame:(CGRect)frame withAddressArray:(NSArray *)arrData {
    if (self == [super initWithFrame:frame]) {
        _marrAlldata = [arrData mutableCopy];
        
        //初始化数组
        _marrProvince = [NSMutableArray array];
        _marrCity = [NSMutableArray array];
        _marrRegion = [NSMutableArray array];
    
        _numberOfComponents = 2; //默认列数
    
        //黑色背景
        _viewBack = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _viewBack.backgroundColor = RGBACOLOR(0, 0, 0, 0.6);
        [_viewBack addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnCancel)]];
        [self addSubview:_viewBack];
        
        //滚轮
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-220, self.frame.size.width, 220)];
        _pickerView.backgroundColor = [UIColor whiteColor];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
        [_viewBack addSubview:_pickerView];
        
        //按钮背景
        _viewButtons = [[UIView alloc] initWithFrame:CGRectMake(0, _pickerView.frame.origin.y-45, self.frame.size.width, 45)];
        _viewButtons.backgroundColor = [UIColor whiteColor];
        [_viewBack addSubview:_viewButtons];
        
        //取消按钮
        UIButton *btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _viewButtons.frame.size.width/2, 44)];
        [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
        [btnCancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btnCancel.backgroundColor = [UIColor whiteColor];
        [btnCancel setTitleEdgeInsets:UIEdgeInsetsMake(0, -50, 0, 0)];
        [btnCancel addTarget:self action:@selector(btnCancel) forControlEvents:UIControlEventTouchUpInside];
        [_viewButtons addSubview:btnCancel];
        
        //确定按钮
        CGFloat left = btnCancel.frame.origin.x + btnCancel.frame.size.width;
        UIButton *btnSure = [[UIButton alloc] initWithFrame:CGRectMake(left, btnCancel.frame.origin.y, btnCancel.frame.size.width, 44)];
        [btnSure setTitle:@"确定" forState:UIControlStateNormal];
        [btnSure setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btnSure.backgroundColor = [UIColor whiteColor];
        [btnSure setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -50)];
        [btnSure addTarget:self action:@selector(btnSure) forControlEvents:UIControlEventTouchUpInside];
        [_viewButtons addSubview:btnSure];
        
        //分割线
        CGFloat top = btnCancel.frame.origin.y + btnCancel.frame.size.height;
        UIView *hxLine = [[UIView alloc] initWithFrame:CGRectMake(0, top, _pickerView.frame.size.width, 1)];
        hxLine.backgroundColor = RGBCOLOR(230, 230, 230);
        [_viewButtons addSubview:hxLine];
    }
    
    return self;
}


- (id)initWithFrame:(CGRect)frame withAddressArray:(NSArray *)arrData withAddressBlock:(HTAddressBlock)block
{
    _addrBlock = block;
    
    return [self initWithFrame:frame withAddressArray:arrData];
}


/*
 使用默认的省、市、区数据
 */
- (id)initWithFrame:(CGRect)frame
{
    //读取plist文件
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"area" ofType:@"plist"];
    NSArray *arrData = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    
    return [self initWithFrame:frame withAddressArray:arrData];
}


- (id)initWithFrame:(CGRect)frame withAddressBlock:(HTAddressBlock)block
{
    _addrBlock = block;
    
    return [self initWithFrame:frame];
}



#pragma mark - 滚轮数量的setter方法
- (void)setNumberOfComponents:(NSInteger)numberOfComponents //设置滚轮列数
{
    NSAssert(numberOfComponents > 0 && numberOfComponents < 4, @"列数不合法！");  //根据实际情况可以更改
    
    _numberOfComponents = numberOfComponents;
    
    switch (_numberOfComponents)
    {
        case 3: [self getRegionArrayByProvince:0 City:0];
        case 2: [self getCityArrayByProvince:0];
        case 1: [self getProvinceArray]; break;
    }
    
    [_pickerView reloadAllComponents];
}


#pragma mark - 省/市/区 数组获取
- (void)getProvinceArray
{
    _marrProvince = [self getListByArray:_marrAlldata];
}


- (void)getCityArrayByProvince:(NSUInteger)indexProvince
{
    NSArray *arrTemp = _marrAlldata[indexProvince][keyForCity];
    _marrCity = [self getListByArray:arrTemp];
}


- (void)getRegionArrayByProvince:(NSUInteger)indexProvince City:(NSUInteger)indexCity
{
    NSArray *arrTemp = _marrAlldata[indexProvince][keyForCity][indexCity][keyForRegion];
    _marrRegion = [self getListByArray:arrTemp];
}


- (NSMutableArray *)getListByArray:(NSArray *)array //分别获取 省/市/区 列表
{
    NSMutableArray *marr = [NSMutableArray array];
    for (NSDictionary *dic in array)
    {
        HTAddressBean *bean = [[HTAddressBean alloc] init];
        bean.strID = dic[@"id"];
        bean.strName = dic[@"name"];
        [marr addObject:bean];
    }
    return marr;
}


#pragma mark - 点击事件
- (void)btnCancel   //取消
{
    [UIView animateWithDuration:kAnimateDuration animations:^{
        
        CGRect frame = _pickerView.frame;
        frame.origin.y = G_SCREEN_HEIGHT;
        _pickerView.frame = frame;
        _viewButtons.frame = frame;
        
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


- (void)btnSure     //确定
{
    NSMutableDictionary *mdic = [NSMutableDictionary dictionary];
    
    switch (_numberOfComponents)
    {
        case 3: {
            if (_marrRegion.count > _iRegionRow)
            {
                HTAddressBean *bean = _marrRegion[_iRegionRow];
                [mdic setObject:bean.strID forKey:@"regionId"];
                [mdic setObject:bean.strName forKey:@"regionName"];
            }
            else
            {
                [mdic setObject:@"" forKey:@"regionId"];
                [mdic setObject:@"" forKey:@"regionName"];
            }
        };
            
        case 2: {
            if (_numberOfComponents == 2)
            {
                [mdic setObject:@"" forKey:@"regionId"];
                [mdic setObject:@"" forKey:@"regionName"];
            }
            
            HTAddressBean *bean = _marrCity[_iCityRow];
            [mdic setObject:bean.strID forKey:@"cityId"];
            [mdic setObject:bean.strName forKey:@"cityName"];
        };
            
        case 1: {
            if (_numberOfComponents == 1)
            {
                [mdic setObject:@"" forKey:@"regionId"];
                [mdic setObject:@"" forKey:@"regionName"];
                [mdic setObject:@"" forKey:@"cityId"];
                [mdic setObject:@"" forKey:@"cityName"];
            }
            
            HTAddressBean *bean = _marrProvince[_iProvinceRow];
            [mdic setObject:bean.strID forKey:@"provinceId"];
            [mdic setObject:bean.strName forKey:@"provinceName"];
        }; break;
    }
    
    if (_delegate)  //调用代理方法
    {
        [_delegate addressInfo:mdic];
    }
    if (_addrBlock)     //调用block
    {
        _addrBlock(mdic);
    }
    
    [self btnCancel];
}


#pragma mark - pickerView 代理方法
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return _numberOfComponents;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component)
    {
        case 0: return _marrProvince.count; break;
        case 1: return _marrCity.count; break;
        case 2: return _marrRegion.count; break;
    }
    
    return 0;
}


- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if (_numberOfComponents == 1)
    {
        return _pickerView.frame.size.width;
    }
    else if (_numberOfComponents == 2)
    {
        return _pickerView.frame.size.width/_numberOfComponents;
    }
    else if (_numberOfComponents == 3)
    {
        if (component == 2)
        {
            return _pickerView.frame.size.width*0.4;
        }
        else
        {
            return _pickerView.frame.size.width*0.3;
        }
    }
    
    return _pickerView.frame.size.width/_numberOfComponents;
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *lbl = (UILabel *)view;
    if (!lbl)
    {
        lbl = [[UILabel alloc] init];
        lbl.textColor = [UIColor blackColor];
        lbl.textAlignment = NSTextAlignmentCenter;
        if (_numberOfComponents > 2)
        {
            lbl.font = [UIFont systemFontOfSize:13];
        }
        else
        {
            lbl.font = [UIFont systemFontOfSize:15];
        }
    }
    
    NSArray *arrTemp = @[];
    if (component == 0)
    {
        arrTemp = _marrProvince;
    }
    else if (component == 1)
    {
        arrTemp = _marrCity;
    }
    else if (component == 2)
    {
        arrTemp = _marrRegion;
    }
    
    HTAddressBean *bean = arrTemp[row];
    lbl.text = bean.strName;
    
    return lbl;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0)
    {
        if (_numberOfComponents == 2)
        {
            [self getCityArrayByProvince:row];
            
            [pickerView reloadComponent:1];
            [pickerView selectRow:0 inComponent:1 animated:YES];
            
            _iCityRow = 0;
        }
        else if (_numberOfComponents == 3)
        {
            [self getCityArrayByProvince:row];
            [self getRegionArrayByProvince:row City:0];
            
            [pickerView reloadComponent:1];
            [pickerView reloadComponent:2];
            
            [pickerView selectRow:0 inComponent:1 animated:YES];
            [pickerView selectRow:0 inComponent:2 animated:YES];
            
            _iCityRow = 0;
            _iRegionRow = 0;
        }
        
        _iProvinceRow = row;
    }
    else if (component == 1)
    {
        if (_numberOfComponents == 3)
        {
            [self getRegionArrayByProvince:_iProvinceRow City:row];
            
            [pickerView reloadComponent:2];
            [pickerView selectRow:0 inComponent:2 animated:YES];
            
            _iRegionRow = 0;
        }
        
        _iCityRow = row;
    }
    else if (component == 2)
    {
        _iRegionRow = row;
    }
}


@end
