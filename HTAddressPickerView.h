//
//  HTAddressPickerView.h
//  MyComsTest
//
//  Created by HengtaoDai on 16/8/3.
//  Copyright © 2016年 DaiHT. All rights reserved.
//  需将本视图加载到 self.view.window 上

#import <Foundation/Foundation.h>

//typedef struct {
//    char *strID;
//    char *strName;
//}HTAddress;
//
//
//typedef struct{
//    HTAddress province; //省
//    HTAddress city;     //市
//    HTAddress region;   //区/县
//}HTCompleteAddress;

// dic 的 key 为：provinceId、provinceName、cityId、cityName、regionId、regionName;
typedef void(^HTAddressBlock)(NSDictionary *dic);


@protocol HTAddressPickerViewDelegate <NSObject>

// dic 的 key 为：provinceId、provinceName、cityId、cityName、regionId、regionName;
- (void)addressInfo:(NSDictionary *)dic;

@end

@interface HTAddressPickerView : UIView

@property (nonatomic,strong) id<HTAddressPickerViewDelegate> delegate;
@property (nonatomic,assign) NSInteger numberOfComponents;  //滚轮的列数

/*
 arrData: 使用用户指定的省、市、区所有的数据
 arrData的样式：[
    {
        id: 5
        name: "浙江省"
        cities: [
            {
                id: 501
                name: "杭州市"
                districts: [
                    {
                        id: 50101
                        name: "西湖区"
                    }
 
                    ...
                ]
            }
 
            ...
        ]
    }

    ...
 ]
 
 "id" 和 "name" 可以自定义，在.m文件中修改 getListByArray: 方法
 "cities" 和 "districts" 可以自定义，在.m文件中修改 keyForCity 和 keyForRegion 的预定义值
 */
- (id)initWithFrame:(CGRect)frame withAddressArray:(NSArray *)arrData;

- (id)initWithFrame:(CGRect)frame withAddressArray:(NSArray *)arrData withAddressBlock:(HTAddressBlock)block;

/*
 使用默认的省、市、区数据
 */
- (id)initWithFrame:(CGRect)frame;

- (id)initWithFrame:(CGRect)frame withAddressBlock:(HTAddressBlock)block;

@end
