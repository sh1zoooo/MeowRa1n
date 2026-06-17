#import "RootViewController.h"
#import "JailbreakEngine.h"

@interface RootViewController ()
@property (nonatomic, strong) UIView          *infoCard;
@property (nonatomic, strong) UILabel         *statusValueLabel;
@property (nonatomic, strong) UIButton        *jailbreakButton;
@property (nonatomic, strong) UITextView      *logView;
@property (nonatomic, strong) UIProgressView  *progressView;
@property (nonatomic, strong) JailbreakEngine *engine;
@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupGradientBackground];
    [self setupUI];
    [self detectDevice];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    // Обновляем gradient frame при изменении размера
    for (CALayer *layer in self.view.layer.sublayers) {
        if ([layer isKindOfClass:[CAGradientLayer class]]) {
            layer.frame = self.view.bounds;
        }
    }
}

- (void)setupGradientBackground {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    // Сверху тёмно-серый → снизу чёрный
    gradient.colors = @[
        (id)[UIColor colorWithWhite:0.20 alpha:1.0].CGColor,
        (id)[UIColor blackColor].CGColor
    ];
    gradient.startPoint = CGPointMake(0.5, 0.0);
    gradient.endPoint   = CGPointMake(0.5, 1.0);
    [self.view.layer insertSublayer:gradient atIndex:0];
}

- (void)setupUI {
    CGFloat W = self.view.bounds.size.width;
    CGFloat H = self.view.bounds.size.height;

    // ── Заголовок "MeowRa1n" ──────────────────────────────
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"MeowRa1n";
    titleLabel.font = [UIFont systemFontOfSize:38 weight:UIFontWeightBold];
    titleLabel.textColor = [UIColor colorWithRed:0.808 green:0.808 blue:0.808 alpha:1.0]; // #CECECE
    titleLabel.layer.shadowColor   = [UIColor whiteColor].CGColor;
    titleLabel.layer.shadowOffset  = CGSizeZero;
    titleLabel.layer.shadowRadius  = 16;
    titleLabel.layer.shadowOpacity = 0.9;
    titleLabel.layer.masksToBounds = NO;
    [titleLabel sizeToFit];

    // ── Лапка paw.png ──────────────────────────────────────
    UIImageView *pawView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"paw"]];
    pawView.tintColor = [UIColor colorWithRed:0.847 green:0.847 blue:0.847 alpha:1.0]; // #D8D8D8
    pawView.contentMode = UIViewContentModeScaleAspectFit;
    pawView.layer.shadowColor   = [UIColor whiteColor].CGColor;
    pawView.layer.shadowOffset  = CGSizeZero;
    pawView.layer.shadowRadius  = 14;
    pawView.layer.shadowOpacity = 0.9;
    pawView.layer.masksToBounds = NO;

    CGFloat pawSize   = 36;
    CGFloat gap       = 10;
    CGFloat totalW    = titleLabel.frame.size.width + gap + pawSize;
    CGFloat startX    = (W - totalW) / 2.0;
    CGFloat titleTopY = 72;

    titleLabel.frame = CGRectMake(startX,
                                  titleTopY,
                                  titleLabel.frame.size.width,
                                  titleLabel.frame.size.height);
    pawView.frame = CGRectMake(startX + titleLabel.frame.size.width + gap,
                               titleTopY + (titleLabel.frame.size.height - pawSize) / 2.0,
                               pawSize, pawSize);
    [self.view addSubview:titleLabel];
    [self.view addSubview:pawView];

    // ── Подзаголовок (без glow) ────────────────────────────
    UILabel *sub = [[UILabel alloc] init];
    sub.text = @"iOS 17.4 - 26.2 Beta 1";
    sub.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    sub.textColor = [UIColor colorWithRed:0.808 green:0.808 blue:0.808 alpha:1.0]; // #CECECE
    sub.textAlignment = NSTextAlignmentCenter;
    sub.frame = CGRectMake(0, titleTopY + titleLabel.frame.size.height + 8, W, 22);
    [self.view addSubview:sub];

    // ── Карточка по центру ────────────────────────────────
    CGFloat cardW = W - 40;
    CGFloat cardH = 240;
    CGFloat cardX = 20;
    CGFloat cardY = (H - cardH) / 2.0;

    self.infoCard = [[UIView alloc] initWithFrame:CGRectMake(cardX, cardY, cardW, cardH)];
    self.infoCard.backgroundColor = [UIColor colorWithRed:0.624 green:0.624 blue:0.624 alpha:0.15]; // #9F9F9F 15%
    self.infoCard.layer.cornerRadius = 22;
    self.infoCard.layer.masksToBounds = NO;
    self.infoCard.layer.shadowColor   = [UIColor colorWithRed:0.624 green:0.624 blue:0.624 alpha:1.0].CGColor;
    self.infoCard.layer.shadowOffset  = CGSizeZero;
    self.infoCard.layer.shadowRadius  = 20;
    self.infoCard.layer.shadowOpacity = 0.15;
    [self.view addSubview:self.infoCard];

    // ── Строки карточки — всё в одну строку слева ─────────
    // "• Device:" серый + "iPhone 14 Pro" белый → через NSAttributedString
    NSArray *keys = @[@"Device:", @"iOS:", @"Model:", @"Chip:", @"Jailbreak:"];
    NSArray *tags = @[@100, @101, @102, @103, @104];
    CGFloat rowH  = cardH / 5.0;

    UIColor *keyColor = [UIColor colorWithRed:0.851 green:0.851 blue:0.851 alpha:1.0]; // #D9D9D9
    UIFont  *rowFont  = [UIFont systemFontOfSize:16 weight:UIFontWeightLight];

    for (int i = 0; i < 5; i++) {
        CGFloat rowY = i * rowH + (rowH - 24) / 2.0;

        // Одна строка: "• Device: " серым + значение белым через attributed string
        UILabel *rowLabel = [[UILabel alloc] initWithFrame:CGRectMake(22, rowY, cardW - 44, 24)];
        rowLabel.tag = [tags[i] integerValue];
        rowLabel.font = rowFont;

        // Базовый текст — ключ серый
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc]
            initWithString:[NSString stringWithFormat:@"• %@  ", keys[i]]
                attributes:@{
                    NSForegroundColorAttributeName: keyColor,
                    NSFontAttributeName: rowFont
                }];
        // Значение — белое, placeholder
        [attr appendAttributedString:[[NSAttributedString alloc]
            initWithString:@"..."
                attributes:@{
                    NSForegroundColorAttributeName: [UIColor whiteColor],
                    NSFontAttributeName: rowFont
                }]];
        rowLabel.attributedText = attr;
        [self.infoCard addSubview:rowLabel];
    }
    self.statusValueLabel = (UILabel *)[self.infoCard viewWithTag:104];

    // ── Progress bar (скрыт) ──────────────────────────────
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView.frame = CGRectMake(20, cardY + cardH + 16, W - 40, 4);
    self.progressView.progressTintColor = [UIColor colorWithWhite:0.85 alpha:1.0];
    self.progressView.trackTintColor    = [UIColor colorWithWhite:0.2 alpha:1.0];
    self.progressView.hidden = YES;
    [self.view addSubview:self.progressView];

    // ── Лог (скрыт) ───────────────────────────────────────
    self.logView = [[UITextView alloc] initWithFrame:CGRectMake(20, cardY + cardH + 28, W - 40, 110)];
    self.logView.backgroundColor = [UIColor colorWithWhite:0.05 alpha:1.0];
    self.logView.textColor = [UIColor colorWithRed:0.2 green:0.9 blue:0.4 alpha:1.0];
    self.logView.font = [UIFont fontWithName:@"Menlo" size:11];
    self.logView.layer.cornerRadius = 10;
    self.logView.editable = NO;
    self.logView.hidden = YES;
    [self.view addSubview:self.logView];

    // ── Кнопка Jailbreak ─────────────────────────────────
    CGFloat btnW = W - 60;
    CGFloat btnH = 60;
    CGFloat btnX = 30;
    CGFloat btnY = H - btnH - 50;

    self.jailbreakButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.jailbreakButton.frame = CGRectMake(btnX, btnY, btnW, btnH);
    self.jailbreakButton.backgroundColor = [UIColor colorWithRed:0.624 green:0.624 blue:0.624 alpha:1.0]; // #9F9F9F
    self.jailbreakButton.layer.cornerRadius = 18;
    self.jailbreakButton.layer.masksToBounds = NO;
    [self.jailbreakButton setTitle:@"Jailbreak" forState:UIControlStateNormal];
    [self.jailbreakButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.jailbreakButton.titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
    self.jailbreakButton.layer.shadowColor   = [UIColor colorWithRed:0.624 green:0.624 blue:0.624 alpha:1.0].CGColor;
    self.jailbreakButton.layer.shadowOffset  = CGSizeZero;
    self.jailbreakButton.layer.shadowRadius  = 18;
    self.jailbreakButton.layer.shadowOpacity = 0.7;
    [self.jailbreakButton addTarget:self action:@selector(startJailbreak) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.jailbreakButton];
}

- (void)updateRowTag:(NSInteger)tag value:(NSString *)value {
    UILabel *label = (UILabel *)[self.infoCard viewWithTag:tag];
    if (!label) return;

    NSArray *keyNames = @[@"Device:", @"iOS:", @"Model:", @"Chip:", @"Jailbreak:"];
    NSArray *tagList  = @[@100, @101, @102, @103, @104];
    NSInteger idx = [tagList indexOfObject:@(tag)];
    NSString *keyStr = idx != NSNotFound ? keyNames[idx] : @"";

    UIFont  *rowFont  = [UIFont systemFontOfSize:16 weight:UIFontWeightLight];
    UIColor *keyColor = [UIColor colorWithRed:0.851 green:0.851 blue:0.851 alpha:1.0];

    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc]
        initWithString:[NSString stringWithFormat:@"• %@  ", keyStr]
            attributes:@{NSForegroundColorAttributeName: keyColor, NSFontAttributeName: rowFont}];
    [attr appendAttributedString:[[NSAttributedString alloc]
        initWithString:value
            attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: rowFont}]];
    label.attributedText = attr;
}

- (void)detectDevice {
    [self updateRowTag:100 value:[[UIDevice currentDevice] model]];
    [self updateRowTag:101 value:[[UIDevice currentDevice] systemVersion]];
    [self updateRowTag:102 value:@"Unknown"];
    [self updateRowTag:103 value:@"Apple Silicon"];
    [self updateRowTag:104 value:@"Ready"];
}

- (void)startJailbreak {
    self.jailbreakButton.enabled = NO;
    [self.jailbreakButton setTitle:@"Running..." forState:UIControlStateNormal];
    self.progressView.hidden = NO;
    self.logView.hidden = NO;
    self.logView.text = @"";
    [self updateRowTag:104 value:@"Working..."];

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
            [weakSelf updateRowTag:104 value:@"Active"];
        });
    }];
}

@end
