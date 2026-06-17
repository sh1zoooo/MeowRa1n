#import "RootViewController.h"
#import "JailbreakEngine.h"

static void applyGlow(UIView *view, UIColor *color, CGFloat radius) {
    view.layer.shadowColor  = color.CGColor;
    view.layer.shadowOffset = CGSizeZero;
    view.layer.shadowRadius = radius;
    view.layer.shadowOpacity = 1.0;
    view.layer.masksToBounds = NO;
}

@interface RootViewController ()
@property (nonatomic, strong) UILabel      *titleLabel;
@property (nonatomic, strong) UIView       *infoCard;
@property (nonatomic, strong) UILabel      *statusLabel;
@property (nonatomic, strong) UIButton     *jailbreakButton;
@property (nonatomic, strong) UITextView   *logView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) JailbreakEngine *engine;
@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Тёмно-серый фон как в оригинале
    self.view.backgroundColor = [UIColor colorWithRed:0.16 green:0.16 blue:0.16 alpha:1.0];
    [self setupUI];
    [self detectDevice];
}

- (void)setupUI {
    CGFloat W = self.view.bounds.size.width;
    CGFloat H = self.view.bounds.size.height;

    // --- Лапка (реальное изображение) ---
    UIImageView *pawView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"paw.png"]];
    pawView.contentMode = UIViewContentModeScaleAspectFit;
    pawView.tintColor = [UIColor colorWithWhite:0.85 alpha:1.0];
    CGFloat pawSize = 52;
    pawView.frame = CGRectMake(W - 80, 68, pawSize, pawSize);
    applyGlow(pawView, [UIColor whiteColor], 14);
    [self.view addSubview:pawView];

    // --- Заголовок с glow ---
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = @"MeowRa1n";
    self.titleLabel.font = [UIFont systemFontOfSize:38 weight:UIFontWeightBold];
    self.titleLabel.textColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    // Glow через shadow
    self.titleLabel.layer.shadowColor  = [UIColor whiteColor].CGColor;
    self.titleLabel.layer.shadowOffset = CGSizeZero;
    self.titleLabel.layer.shadowRadius = 12;
    self.titleLabel.layer.shadowOpacity = 0.85;
    self.titleLabel.layer.masksToBounds = NO;
    self.titleLabel.frame = CGRectMake(0, 60, W - 60, 50);
    [self.view addSubview:self.titleLabel];

    // --- Подзаголовок ---
    UILabel *sub = [[UILabel alloc] init];
    sub.text = @"iOS 17.4 - 26.2 Beta 1";
    sub.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    sub.textColor = [UIColor colorWithWhite:0.65 alpha:1.0];
    sub.textAlignment = NSTextAlignmentCenter;
    sub.layer.shadowColor  = [UIColor whiteColor].CGColor;
    sub.layer.shadowOffset = CGSizeZero;
    sub.layer.shadowRadius = 6;
    sub.layer.shadowOpacity = 0.4;
    sub.layer.masksToBounds = NO;
    sub.frame = CGRectMake(0, 116, W, 20);
    [self.view addSubview:sub];

    // --- Карточка ---
    CGFloat cardY = H * 0.35;
    self.infoCard = [[UIView alloc] initWithFrame:CGRectMake(20, cardY, W - 40, 220)];
    self.infoCard.backgroundColor = [UIColor colorWithRed:0.22 green:0.22 blue:0.22 alpha:0.85];
    self.infoCard.layer.cornerRadius = 22;
    [self.view addSubview:self.infoCard];

    NSArray *labels = @[@"Device:", @"iOS:", @"Model:", @"Chip:", @"Jailbreak:"];
    NSArray *tags   = @[@100, @101, @102, @103, @104];
    for (int i = 0; i < 5; i++) {
        // Буллет
        UILabel *dot = [[UILabel alloc] initWithFrame:CGRectMake(18, 20 + i * 38, 20, 28)];
        dot.text = @"•";
        dot.font = [UIFont systemFontOfSize:16];
        dot.textColor = [UIColor colorWithWhite:0.65 alpha:1.0];
        [self.infoCard addSubview:dot];

        // Лейбл
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(36, 20 + i * 38, 100, 28)];
        lbl.text = labels[i];
        lbl.font = [UIFont systemFontOfSize:16];
        lbl.textColor = [UIColor colorWithWhite:0.65 alpha:1.0];
        [self.infoCard addSubview:lbl];

        // Значение
        UILabel *val = [[UILabel alloc] initWithFrame:CGRectMake(130, 20 + i * 38, self.infoCard.bounds.size.width - 148, 28)];
        val.tag = [tags[i] intValue];
        val.text = @"...";
        val.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        val.textColor = [UIColor colorWithRed:0.45 green:0.75 blue:0.95 alpha:1.0];
        val.textAlignment = NSTextAlignmentRight;
        [self.infoCard addSubview:val];
    }
    self.statusLabel = (UILabel *)[self.infoCard viewWithTag:104];

    // --- Progress (скрыт) ---
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView.frame = CGRectMake(20, cardY + 235, W - 40, 4);
    self.progressView.progressTintColor = [UIColor colorWithRed:0.04 green:0.52 blue:0.97 alpha:1.0];
    self.progressView.trackTintColor = [UIColor colorWithWhite:0.25 alpha:1.0];
    self.progressView.hidden = YES;
    [self.view addSubview:self.progressView];

    // --- Лог (скрыт) ---
    self.logView = [[UITextView alloc] initWithFrame:CGRectMake(20, cardY + 248, W - 40, 140)];
    self.logView.backgroundColor = [UIColor colorWithRed:0.08 green:0.08 blue:0.09 alpha:1.0];
    self.logView.textColor = [UIColor colorWithRed:0.3 green:0.9 blue:0.5 alpha:1.0];
    self.logView.font = [UIFont fontWithName:@"Menlo" size:11];
    self.logView.layer.cornerRadius = 12;
    self.logView.editable = NO;
    self.logView.hidden = YES;
    [self.view addSubview:self.logView];

    // --- Кнопка Jailbreak ---
    self.jailbreakButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.jailbreakButton.frame = CGRectMake(20, H - 90, W - 40, 58);
    self.jailbreakButton.backgroundColor = [UIColor colorWithRed:0.38 green:0.38 blue:0.40 alpha:1.0];
    self.jailbreakButton.layer.cornerRadius = 18;
    [self.jailbreakButton setTitle:@"Jailbreak" forState:UIControlStateNormal];
    [self.jailbreakButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.jailbreakButton.titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
    [self.jailbreakButton addTarget:self action:@selector(startJailbreak) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.jailbreakButton];
}

- (void)detectDevice {
    UILabel *dev   = (UILabel *)[self.infoCard viewWithTag:100];
    UILabel *ios   = (UILabel *)[self.infoCard viewWithTag:101];
    UILabel *model = (UILabel *)[self.infoCard viewWithTag:102];
    UILabel *chip  = (UILabel *)[self.infoCard viewWithTag:103];

    dev.text   = [[UIDevice currentDevice] model];
    ios.text   = [[UIDevice currentDevice] systemVersion];
    model.text = @"Unknown";
    chip.text  = @"Apple Silicon";
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
            [weakSelf.jailbreakButton setTitle:@"Done! 🐾" forState:UIControlStateNormal];
            weakSelf.jailbreakButton.backgroundColor = [UIColor colorWithRed:0.07 green:0.28 blue:0.12 alpha:1.0];
            weakSelf.statusLabel.text = @"Active";
            weakSelf.statusLabel.textColor = [UIColor colorWithRed:0.19 green:0.82 blue:0.35 alpha:1.0];
        });
    }];
}

@end