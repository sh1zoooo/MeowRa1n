#import "RootViewController.h"
#import "JailbreakEngine.h"

@interface RootViewController ()
@property (nonatomic, strong) UIView         *infoCard;
@property (nonatomic, strong) UILabel        *statusValueLabel;
@property (nonatomic, strong) UIButton       *jailbreakButton;
@property (nonatomic, strong) UITextView     *logView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) JailbreakEngine *engine;
@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupGradientBackground];
    [self setupUI];
    [self detectDevice];
}

- (void)setupGradientBackground {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = @[
        (id)[UIColor blackColor].CGColor,
        (id)[UIColor colorWithWhite:0.22 alpha:1.0].CGColor
    ];
    gradient.startPoint = CGPointMake(0.5, 0.0);
    gradient.endPoint   = CGPointMake(0.5, 1.0);
    [self.view.layer insertSublayer:gradient atIndex:0];
}

- (void)setupUI {
    CGFloat W = self.view.bounds.size.width;
    CGFloat H = self.view.bounds.size.height;

    // --- Заголовок "MeowRa1n" + paw.png в одну строку ---
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"MeowRa1n";
    titleLabel.font = [UIFont systemFontOfSize:38 weight:UIFontWeightBold];
    titleLabel.textColor = [UIColor colorWithRed:0.808 green:0.808 blue:0.808 alpha:1.0]; // #CECECE
    [titleLabel sizeToFit];

    UIImageView *pawView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"paw"]];
    pawView.tintColor = [UIColor colorWithRed:0.847 green:0.847 blue:0.847 alpha:1.0]; // #D8D8D8
    pawView.contentMode = UIViewContentModeScaleAspectFit;
    CGFloat pawSize = 38;
    pawView.frame = CGRectMake(0, 0, pawSize, pawSize);
    // Glow на лапке
    pawView.layer.shadowColor   = [UIColor whiteColor].CGColor;
    pawView.layer.shadowOffset  = CGSizeZero;
    pawView.layer.shadowRadius  = 14;
    pawView.layer.shadowOpacity = 0.9;
    pawView.layer.masksToBounds = NO;

    // Stack заголовок + лапка
    UIStackView *titleStack = [[UIStackView alloc] initWithArrangedSubviews:@[titleLabel, pawView]];
    titleStack.axis = UILayoutConstraintAxisHorizontal;
    titleStack.alignment = UIStackViewAlignmentCenter;
    titleStack.spacing = 10;
    [titleStack sizeToFit];
    titleStack.center = CGPointMake(W / 2, 100);
    // Glow на тексте заголовка
    titleLabel.layer.shadowColor   = [UIColor whiteColor].CGColor;
    titleLabel.layer.shadowOffset  = CGSizeZero;
    titleLabel.layer.shadowRadius  = 16;
    titleLabel.layer.shadowOpacity = 0.9;
    titleLabel.layer.masksToBounds = NO;
    [self.view addSubview:titleStack];

    // --- Подзаголовок (без glow, светло-серый) ---
    UILabel *sub = [[UILabel alloc] init];
    sub.text = @"iOS 17.4 - 26.2 Beta 1";
    sub.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    sub.textColor = [UIColor colorWithRed:0.808 green:0.808 blue:0.808 alpha:1.0]; // #CECECE
    sub.textAlignment = NSTextAlignmentCenter;
    sub.frame = CGRectMake(0, 135, W, 22);
    [self.view addSubview:sub];

    // --- Карточка по центру экрана ---
    CGFloat cardW = W - 40;
    CGFloat cardH = 240;
    CGFloat cardX = 20;
    CGFloat cardY = (H - cardH) / 2;

    self.infoCard = [[UIView alloc] initWithFrame:CGRectMake(cardX, cardY, cardW, cardH)];
    // Цвет #9F9F9F с прозрачностью 15%
    self.infoCard.backgroundColor = [UIColor colorWithRed:0.624 green:0.624 blue:0.624 alpha:0.15];
    self.infoCard.layer.cornerRadius = 22;
    self.infoCard.layer.masksToBounds = NO;
    // Glow карточки с opacity 15%
    self.infoCard.layer.shadowColor   = [UIColor colorWithRed:0.624 green:0.624 blue:0.624 alpha:1.0].CGColor;
    self.infoCard.layer.shadowOffset  = CGSizeZero;
    self.infoCard.layer.shadowRadius  = 20;
    self.infoCard.layer.shadowOpacity = 0.15;
    [self.view addSubview:self.infoCard];

    // --- Строки карточки ---
    NSArray *labelKeys = @[@"• Device:", @"• iOS:", @"• Model:", @"• Chip:", @"• Jailbreak:"];
    NSArray *valueTags = @[@100, @101, @102, @103, @104];
    CGFloat rowH = cardH / 5.0;

    for (int i = 0; i < 5; i++) {
        CGFloat rowY = i * rowH + (rowH - 22) / 2;

        // Ключ (серый #D9D9D9, тонкий)
        UILabel *keyLabel = [[UILabel alloc] initWithFrame:CGRectMake(22, rowY, 130, 22)];
        keyLabel.text = labelKeys[i];
        keyLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightLight];
        keyLabel.textColor = [UIColor colorWithRed:0.851 green:0.851 blue:0.851 alpha:1.0]; // #D9D9D9
        [self.infoCard addSubview:keyLabel];

        // Значение (белый #FFFFFF, тонкий)
        UILabel *valLabel = [[UILabel alloc] initWithFrame:CGRectMake(155, rowY, cardW - 175, 22)];
        valLabel.tag = [valueTags[i] integerValue];
        valLabel.text = @"...";
        valLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightLight];
        valLabel.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]; // #FFFFFF
        [self.infoCard addSubview:valLabel];
    }
    self.statusValueLabel = (UILabel *)[self.infoCard viewWithTag:104];

    // --- Progress bar (скрыт изначально) ---
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView.frame = CGRectMake(20, cardY + cardH + 16, W - 40, 4);
    self.progressView.progressTintColor = [UIColor colorWithWhite:0.85 alpha:1.0];
    self.progressView.trackTintColor    = [UIColor colorWithWhite:0.2 alpha:1.0];
    self.progressView.hidden = YES;
    [self.view addSubview:self.progressView];

    // --- Лог (скрыт изначально) ---
    self.logView = [[UITextView alloc] initWithFrame:CGRectMake(20, cardY + cardH + 28, W - 40, 110)];
    self.logView.backgroundColor = [UIColor colorWithWhite:0.05 alpha:1.0];
    self.logView.textColor = [UIColor colorWithRed:0.2 green:0.9 blue:0.4 alpha:1.0];
    self.logView.font = [UIFont fontWithName:@"Menlo" size:11];
    self.logView.layer.cornerRadius = 10;
    self.logView.editable = NO;
    self.logView.hidden = YES;
    [self.view addSubview:self.logView];

    // --- Кнопка Jailbreak ---
    CGFloat btnW = W - 60;
    CGFloat btnH = 60;
    CGFloat btnX = 30;
    CGFloat btnY = H - btnH - 50;

    self.jailbreakButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.jailbreakButton.frame = CGRectMake(btnX, btnY, btnW, btnH);
    // Цвет #9F9F9F
    self.jailbreakButton.backgroundColor = [UIColor colorWithRed:0.624 green:0.624 blue:0.624 alpha:1.0];
    self.jailbreakButton.layer.cornerRadius = 18;
    self.jailbreakButton.layer.masksToBounds = NO;
    [self.jailbreakButton setTitle:@"Jailbreak" forState:UIControlStateNormal];
    [self.jailbreakButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal]; // #FFFFFF
    self.jailbreakButton.titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
    // Glow кнопки
    self.jailbreakButton.layer.shadowColor   = [UIColor colorWithRed:0.624 green:0.624 blue:0.624 alpha:1.0].CGColor;
    self.jailbreakButton.layer.shadowOffset  = CGSizeZero;
    self.jailbreakButton.layer.shadowRadius  = 18;
    self.jailbreakButton.layer.shadowOpacity = 0.7;
    [self.jailbreakButton addTarget:self action:@selector(startJailbreak) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.jailbreakButton];
}

- (void)detectDevice {
    UILabel *devVal   = (UILabel *)[self.infoCard viewWithTag:100];
    UILabel *iosVal   = (UILabel *)[self.infoCard viewWithTag:101];
    UILabel *modelVal = (UILabel *)[self.infoCard viewWithTag:102];
    UILabel *chipVal  = (UILabel *)[self.infoCard viewWithTag:103];

    devVal.text   = [[UIDevice currentDevice] model];
    iosVal.text   = [[UIDevice currentDevice] systemVersion];
    modelVal.text = @"Unknown";
    chipVal.text  = @"Apple Silicon";

    self.statusValueLabel.text      = @"Ready";
    self.statusValueLabel.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
}

- (void)startJailbreak {
    self.jailbreakButton.enabled = NO;
    [self.jailbreakButton setTitle:@"Running..." forState:UIControlStateNormal];
    self.progressView.hidden = NO;
    self.logView.hidden = NO;
    self.logView.text = @"";
    self.statusValueLabel.text = @"Working...";

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
            weakSelf.statusValueLabel.text = @"Active";
        });
    }];
}

@end
