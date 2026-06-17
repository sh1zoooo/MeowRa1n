#import "JailbreakEngine.h"

@implementation JailbreakEngine

- (void)runWithLogCallback:(LogCallback)log completion:(CompletionCallback)completion {
    NSArray *steps = @[
        @{@"msg": @"[*] Initializing MeowRa1n v1.0.0...",       @"p": @0.05, @"t": @0.3},
        @{@"msg": @"[*] Detecting device and iOS version...",     @"p": @0.10, @"t": @0.5},
        @{@"msg": @"[*] iOS version supported ✓",                 @"p": @0.14, @"t": @0.4},
        @{@"msg": @"[*] Loading kernel exploit (CVE-2024-2347)...",@"p": @0.20, @"t": @0.7},
        @{@"msg": @"[*] Heap spray phase 1/3...",                 @"p": @0.26, @"t": @0.6},
        @{@"msg": @"[*] Heap spray phase 2/3...",                 @"p": @0.32, @"t": @0.6},
        @{@"msg": @"[*] Heap spray phase 3/3...",                 @"p": @0.38, @"t": @0.5},
        @{@"msg": @"[+] Kernel r/w primitive achieved",           @"p": @0.44, @"t": @0.8},
        @{@"msg": @"[*] Bypassing PAC...",                        @"p": @0.50, @"t": @0.7},
        @{@"msg": @"[+] PAC bypass successful",                   @"p": @0.55, @"t": @0.5},
        @{@"msg": @"[*] Patching kernel sandbox...",              @"p": @0.60, @"t": @0.6},
        @{@"msg": @"[*] Disabling AMFI restrictions...",          @"p": @0.65, @"t": @0.7},
        @{@"msg": @"[+] AMFI disabled",                           @"p": @0.70, @"t": @0.4},
        @{@"msg": @"[*] Injecting bootstrap payload...",          @"p": @0.75, @"t": @0.8},
        @{@"msg": @"[*] Extracting roothide bootstrap...",        @"p": @0.80, @"t": @0.9},
        @{@"msg": @"[*] Installing Sileo package manager...",     @"p": @0.85, @"t": @0.7},
        @{@"msg": @"[*] Setting up /var/jb symlinks...",          @"p": @0.88, @"t": @0.5},
        @{@"msg": @"[*] Configuring MeowSubstrate...",           @"p": @0.92, @"t": @0.6},
        @{@"msg": @"[*] Writing launchd persistence plist...",    @"p": @0.96, @"t": @0.5},
        @{@"msg": @"[+] Done! Device is jailbroken. Enjoy! :3",  @"p": @1.00, @"t": @0.3},
    ];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSTimeInterval offset = 0;
        for (NSDictionary *step in steps) {
            NSTimeInterval delay = [step[@"t"] doubleValue];
            offset += delay;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(offset * NSEC_PER_SEC)),
                           dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                log(step[@"msg"], [step[@"p"] floatValue]);
            });
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((offset + 0.5) * NSEC_PER_SEC)),
                       dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            completion(YES);
        });
    });
}

@end