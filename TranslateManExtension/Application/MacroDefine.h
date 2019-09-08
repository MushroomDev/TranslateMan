
#import "AppDelegate.h"

/*--------------------------------开发中常用到的宏定义--------------------------------------*/

//系统目录
#define ALLDocuments  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

// 是否iphoneX
#define kDevice_iPhoneX CGSizeEqualToSize(CGSizeMake(375.f, 812.f), [[UIScreen mainScreen] bounds].size)

#define kSafeAreaInsetsTop                  (kDevice_iPhoneX ? kStatusBarHeight : 0.f)     // 安全区域上部
#define kSafeAreaInsetsBottom               (kDevice_iPhoneX ? 34.f : 0.f)                 // 安全区域底部

//系统的宽高
#define iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125,2436), [[UIScreen mainScreen] currentMode].size) : NO)
#define kNavigationBarHeight                44
#define kStatusBarHeight                    [UIApplication sharedApplication].statusBarFrame.size.height
#define kTabBarHeight                       (iPhoneX?83:49)
#define kFullNavigationBarHeight            (kNavigationBarHeight+kStatusBarHeight)
#define kBottomSpace                        (iPhoneX?34:0)
#define kWindowWidth                        ([[UIScreen mainScreen] bounds].size.width)
#define kWindowHeight                       ([[UIScreen mainScreen] bounds].size.height)

//----------方法简写-------
#define ALLAppDelegate        (AppDelegate *)[[UIApplication sharedApplication] delegate]
#define ALLWindow             [[[UIApplication sharedApplication] windows] lastObject]
#define ALLKeyWindow          [[UIApplication sharedApplication] keyWindow]
#define ALLUserDefaults       [NSUserDefaults standardUserDefaults]
#define ALLNotificationCenter [NSNotificationCenter defaultCenter]
#define ALLPostNotification(name,obj) [[NSNotificationCenter defaultCenter] postNotificationName:name object:obj]

//------快速定义 weak 变量
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
#define WEAK(n)     __weak __typeof(&*n)weak##n=n;

//加载图片
#define ALLImageByName(name)        [UIImage imageNamed:name]
#define ALLImageByBundlePath(name, ext)   [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:name ofType:ext]]
#define ALLImageByPath(path)    [UIImage imageWithContentsOfFile:path]


//以tag读取View
#define ALLViewByTag(parentView, tag, Class)  (Class *)[parentView viewWithTag:tag]
//读取Xib文件的类
#define ALLViewByNib(Class, owner) [[[NSBundle mainBundle] loadNibNamed:Class owner:owner options:nil] lastObject]
//从Xib加载视图
#define ABNLoadViewFromNib(nibName) [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil].lastObject

//id对象与NSData之间转换
#define ALLObjectToData(object)   [NSKeyedArchiver archivedDataWithRootObject:object]
#define ALLDataToObject(data)     [NSKeyedUnarchiver unarchiveObjectWithData:data]

//度弧度转换
#define ALLDegreesToRadian(x)      (M_PI * (x) / 180.0)
#define ALLRadianToDegrees(radian) (radian*180.0) / (M_PI)

//颜色转换
#define ALLRGBColor(r, g, b)         [NSColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define ALLRGBAColor(r, g, b, a) [NSColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a/255.0]
//rgb颜色转换（16进制->10进制）
#define ALLRGBToColor(rgb) [UIColor colorWithRed:((float)((rgb & 0xFF0000) >> 16))/255.0 green:((float)((rgb & 0xFF00) >> 8))/255.0 blue:((float)(rgb & 0xFF))/255.0 alpha:1.0];
//获取系统默认字体
#define Font(F) [UIFont systemFontOfSize:(F)]

//G－C－D
#define ALLGCDBackground(block) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
#define ALLGCDMain(block)       dispatch_async(dispatch_get_main_queue(),block)

//简单的以AlertView显示提示信息
#define ALLAlertView(title, msg) \
UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil \
cancelButtonTitle:@"确定" \
otherButtonTitles:nil]; \
[alert show];




//----------设备系统相关---------
#define mRetina   ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
#define mIsiP5    ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136),[[UIScreen mainScreen] currentMode].size) : NO)
#define mIsPad    (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define mIsiphone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)


#define ALLDEVICE_BOUNDS [[UIScreen mainScreen] applicationFrame]
#define ALLDEVICE_SIZE [[UIScreen mainScreen] bounds].size
#define ALLDEVICE_OS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

#define ALLSystemVersion   ([[UIDevice currentDevice] systemVersion])
#define ALLCurrentLanguage ([[NSLocale preferredLanguages] objectAtIndex:0])
#define ALLAPPVersion      [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]


//---------统计代码使用时间
#define ALLCODE_USE_BEGAIN  NSTimeInterval CODE_USER_BEGAIN_OLD=[NSDate date].timeIntervalSince1970;
#define ALLCODE_USE_END(str)    NSLog(@"%@ : %f s",str,[NSDate date].timeIntervalSince1970-CODE_USER_BEGAIN_OLD);

#define ALLTICK(name)   NSDate *name = [NSDate date]
#define ALLTOCK(name)   NSLog(@"Time [ %s ]: %f",#name, -[name timeIntervalSinceNow])



//--------调试相关-------


//调试模式下输入NSLog，发布后不再输入。
//#ifndef __OPTIMIZE__
//#define NSLog(...) NSLog(__VA_ARGS__)
#ifndef __OPTIMIZE__
#define NSLog(...) printf("%f %s\n",[[NSDate date]timeIntervalSince1970],[[NSString stringWithFormat:__VA_ARGS__]UTF8String]);
#else
#define NSLog(...) {}
#endif


//AllLog
#ifndef __OPTIMIZE__
#define AllLog(...) printf("%f %s\n",[[NSDate date]timeIntervalSince1970],[[NSString stringWithFormat:__VA_ARGS__]UTF8String]);
#else
#define AllLog(...) {}
#endif



#if mTargetOSiPhone
//iPhone Device
#endif

#if mTargetOSiPhoneSimulator
//iPhone Simulator
#endif



#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)


//只有在debug 环境才生效的代码
static inline void debugBlock(void (^block)(void))
{
    #ifdef DEBUG
    block();
    #endif
}

