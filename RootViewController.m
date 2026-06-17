#import "RootViewController.h"
#import "JailbreakEngine.h"

@interface RootViewController ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *versionLabel;
@property (nonatomic, strong) UIView *infoCard;
@property (nonatomic, strong) UILabel *deviceLabel;
@property (nonatomic, strong) UILabel *iosLabel;
@property (nonatomic, strong) UILabel *modelLabel;
@property (nonatomic, strong) UILabel *chipLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIButton *jailbreakButton;
@property (nonatomic, strong) UITextView *logView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) JailbreakEngine *engine;
@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.11 green:0.11 blue:0.12 alpha:1.0];
    [self setupUI];
    [self detectDevice];
}

- (void)setupUI {
    CGFloat w = self.view.bounds.size.width;

    // Paw icon
    UILabel *pawLabel = [[UILabel alloc] init];
    pawLabel.text = @"🐾";
    pawLabel.font = [UIFont systemFontOfSize:48];
    pawLabel.textAlignment = NSTextAlignmentCenter;
    pawLabel.frame = CGRectMake(0, 80, w, 60);
    [self.view addSubview:pawLabel];

    // Title
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = @"MeowRa1n";
    self.titleLabel.font = [UIFont boldSystemFontOfSize:34];
    self.titleLabel.textColor = [UIColor colorWithWhite:0.92 alpha:1.0];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.frame = CGRectMake(0, 148, w, 42);
    [self.view addSubview:self.titleLabel];

    // Version
    self.versionLabel = [[UILabel alloc] init];
    self.versionLabel.text = @"iOS 17.4 - 26.2 Beta 1";
    self.versionLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    self.versionLabel.textColor = [UIColor colorWithWhite:0.55 alpha:1.0];
    self.versionLabel.textAlignment = NSTextAlignmentCenter;
    self.versionLabel.frame = CGRectMake(0, 196, w, 20);
    [self.view addSubview:self.versionLabel];

    // Info card
    self.infoCard = [[UIView alloc] initWithFrame:CGRectMake(24, 240, w - 48, 190)];
    self.infoCard.backgroundColor = [UIColor colorWithRed:0.17 green:0.17 blue:0.18 alpha:1.0];
    self.infoCard.layer.cornerRadius = 18;
    [self.view addSubview:self.infoCard];

    NSArray *labels = @[@"Device:", @"iOS:", @"Model:", @"Chip:", @"Jailbreak:"];
    NSArray *tags = @[@100, @101, @102, @103, @104];
    for (int i = 0; i < 5; i++) {
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(16, 12 + i * 34, 100, 28)];
        lbl.text = labels[i];
        lbl.font = [UIFont systemFontOfSize:15];
        lbl.textColor = [UIColor colorWithWhite:0.55 alpha:1.0];
        [self.infoCard addSubview:lbl];

        UILabel *val = [[UILabel alloc] initWithFrame:CGRectMake(110, 12 + i * 34, self.infoCard.bounds.size.width - 126, 28)];
        val.tag = [tags[i] intValue];
        val.text = @"...";
        val.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
        val.textColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        val.textAlignment = NSTextAlignmentRight;
        [self.infoCard addSubview:val];

        if (i < 4) {
            UIView *sep = [[UIView alloc] initWithFrame:CGRectMake(16, 40 + i * 34, self.infoCard.bounds.size.width - 32, 0.5)];
            sep.backgroundColor = [UIColor colorWithWhite:0.25 alpha:1.0];
            [self.infoCard addSubview:sep];
        }
    }

    self.deviceLabel = (UILabel *)[self.infoCard viewWithTag:100];
    self.iosLabel    = (UILabel *)[self.infoCard viewWithTag:101];
    self.modelLabel  = (UILabel *)[self.infoCard viewWithTag:102];
    self.chipLabel   = (UILabel *)[self.infoCard viewWithTag:103];
    self.statusLabel = (UILabel *)[self.infoCard viewWithTag:104];

    // Progress bar
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView.frame = CGRectMake(24, 444, w - 48, 4);
    self.progressView.progressTintColor = [UIColor colorWithRed:0.04 green:0.52 blue:0.97 alpha:1.0];
    self.progressView.trackTintColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    self.progressView.hidden = YES;
    [self.view addSubview:self.progressView];

    // Log view
    self.logView = [[UITextView alloc] initWithFrame:CGRectMake(24, 460, w - 48, 160)];
    self.logView.backgroundColor = [UIColor colorWithRed:0.07 green:0.07 blue:0.08 alpha:1.0];
    self.logView.textColor = [UIColor colorWithRed:0.4 green:0.9 blue:0.5 alpha:1.0];
    self.logView.font = [UIFont fontWithName:@"Menlo" size:11];
    self.logView.layer.cornerRadius = 12;
    self.logView.editable = NO;
    self.logView.hidden = YES;
    [self.view addSubview:self.logView];

    // Jailbreak button
    self.jailbreakButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.jailbreakButton.frame = CGRectMake(24, self.view.bounds.size.height - 100, w - 48, 56);
    self.jailbreakButton.backgroundColor = [UIColor colorWithRed:0.22 green:0.22 blue:0.24 alpha:1.0];
    self.jailbreakButton.layer.cornerRadius = 16;
    [self.jailbreakButton setTitle:@"Jailbreak" forState:UIControlStateNormal];
    [self.jailbreakButton setTitleColor:[UIColor colorWithWhite:0.92 alpha:1.0] forState:UIControlStateNormal];
    self.jailbreakButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.jailbreakButton addTarget:self action:@selector(startJailbreak) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.jailbreakButton];
}

- (void)detectDevice {
    self.deviceLabel.text = [[UIDevice currentDevice] model];
    self.iosLabel.text = [[UIDevice currentDevice] systemVersion];
    self.modelLabel.text = @"Unknown";
    self.chipLabel.text = @"Apple Silicon";
    self.statusLabel.text = @"Ready";
    self.statusLabel.textColor = [UIColor colorWithRed:0.19 green:0.82 blue:0.35 alpha:1.0];
}

- (void)startJailbreak {
    self.jailbreakButton.enabled = NO;
    [self.jailbreakButton setTitle:@"Running..." forState:UIControlStateNormal];
    self.progressView.hidden = NO;
    self.logView.hidden = NO;
    self.logView.text = @"";
    self.statusLabel.text = @"Working...";
    self.statusLabel.textColor = [UIColor colorWithRed:1.0 green:0.84 blue:0.04 alpha:1.0];

    self.engine = [[JailbreakEngine alloc] init];
    __weak typeof(self) weakSelf = self;
    [self.engine runWithLogCallback:^(NSString *line, float progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.logView.text = [weakSelf.logView.text stringByAppendingFormat:@"%@\n", line];
            [weakSelf.logView scrollRangeToVisible:NSMakeRange(weakSelf.logView.text.length, 0)];
            [weakSelf.progressView setProgress:progress animated:YES];
        });
    } completion:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [weakSelf.jailbreakButton setTitle:@"Done! 🐾" forState:UIControlStateNormal];
                weakSelf.jailbreakButton.backgroundColor = [UIColor colorWithRed:0.04 green:0.22 blue:0.1 alpha:1.0];
                weakSelf.statusLabel.text = @"Active";
                weakSelf.statusLabel.textColor = [UIColor colorWithRed:0.19 green:0.82 blue:0.35 alpha:1.0];
            }
        });
    }];
}

@end