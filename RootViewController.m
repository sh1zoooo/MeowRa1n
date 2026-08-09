#import "RootViewController.h"

@interface RootViewController ()
@property (nonatomic, strong) UIView   *infoCard;
@property (nonatomic, strong) UIButton *jailbreakButton;
@end

// Акцент темы — монохромное серебристое свечение
static inline UIColor *MRNeonAccent(CGFloat alpha) {
    return [UIColor colorWithWhite:1.0 alpha:alpha];
}

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupGradientBackground];
    [self setupUI];
    [self detectDevice];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    for (CALayer *layer in self.view.layer.sublayers) {
        if ([layer isKindOfClass:[CAGradientLayer class]]) {
            layer.frame = self.view.bounds;
        }
    }
}

- (void)setupGradientBackground {
    CAGradientLayer *g = [CAGradientLayer layer];
    g.frame = self.view.bounds;
    g.colors = @[
        (id)[UIColor colorWithRed:0.243 green:0.243 blue:0.243 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.150 green:0.150 blue:0.150 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.012 green:0.012 blue:0.012 alpha:1.0].CGColor
    ];
    g.locations = @[@0.0, @0.5, @1.0];
    g.startPoint = CGPointMake(0.5, 0.0);
    g.endPoint   = CGPointMake(0.5, 1.0);
    [self.view.layer insertSublayer:g atIndex:0];
}

- (void)setupUI {
    CGFloat W = self.view.bounds.size.width;
    CGFloat H = self.view.bounds.size.height;

    // ── Заголовок ─────────────────────────────────────────
    UILabel *title = [[UILabel alloc] init];
    title.text = @"MeowRa1n";
    UIFont *sfDisplay = [UIFont fontWithName:@"SFUIDisplay-Medium" size:40];
    title.font = sfDisplay ?: [UIFont systemFontOfSize:40 weight:UIFontWeightHeavy];
    title.textColor = [UIColor colorWithWhite:0.808 alpha:1.0];
    title.layer.shadowColor   = [UIColor whiteColor].CGColor;
    title.layer.shadowOffset  = CGSizeZero;
    title.layer.shadowRadius  = 16;
    title.layer.shadowOpacity = 0.9;
    title.layer.masksToBounds = NO;
    [title sizeToFit];

    // ── Лапка ─────────────────────────────────────────────
    UIImageView *paw = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"paw"]];
    paw.contentMode = UIViewContentModeScaleAspectFit;
    paw.layer.shadowColor   = [UIColor whiteColor].CGColor;
    paw.layer.shadowOffset  = CGSizeZero;
    paw.layer.shadowRadius  = 14;
    paw.layer.shadowOpacity = 0.85;
    paw.layer.masksToBounds = NO;

    CGFloat pawSize = 38;
    CGFloat gap     = 10;
    CGFloat totalW  = title.frame.size.width + gap + pawSize;
    CGFloat startX  = (W - totalW) / 2.0;
    CGFloat topY    = 72;

    title.frame = CGRectMake(startX, topY, title.frame.size.width, title.frame.size.height);
    paw.frame   = CGRectMake(startX + title.frame.size.width + gap,
                             topY + (title.frame.size.height - pawSize) / 2.0,
                             pawSize, pawSize);
    [self.view addSubview:title];
    [self.view addSubview:paw];

    // ── Подзаголовок ──────────────────────────────────────
    UILabel *sub = [[UILabel alloc] init];
    sub.text = @"iOS 17.4 - 26.2 Beta 1";
    sub.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    sub.textColor = [UIColor colorWithWhite:0.808 alpha:1.0];
    sub.textAlignment = NSTextAlignmentCenter;
    sub.frame = CGRectMake(0, topY + title.frame.size.height + 8, W, 22);
    [self.view addSubview:sub];

    // ── Кнопка (считаем геометрию заранее — карточка равняется по ней) ──
    CGFloat sideMargin = 30;
    CGFloat btnW = W - sideMargin * 2;
    CGFloat btnH = 60;
    CGFloat btnY = H - btnH - 40;

    // ── Карточка ──────────────────────────────────────────
    CGFloat fontSize  = 19.0;
    CGFloat rowH      = 42.0;
    CGFloat padV      = 18.0;
    CGFloat cardW     = btnW;                 // та же ширина, что и у кнопки
    CGFloat cardH     = rowH * 5 + padV * 2;

    CGFloat contentTop    = sub.frame.origin.y + sub.frame.size.height; // низ подзаголовка
    CGFloat contentBottom = btnY;                                       // верх кнопки
    CGFloat cardX = roundf((W - cardW) / 2.0);                          // строго по центру экрана по горизонтали
    CGFloat cardY = roundf(contentTop + (contentBottom - contentTop - cardH) / 2.0);

    self.infoCard = [[UIView alloc] initWithFrame:CGRectMake(cardX, cardY, cardW, cardH)];
    self.infoCard.backgroundColor = [UIColor clearColor];
    self.infoCard.layer.cornerRadius = 22;
    self.infoCard.layer.masksToBounds = NO;
    // Неоновое свечение самой карточки
    self.infoCard.layer.shadowColor   = MRNeonAccent(1.0).CGColor;
    self.infoCard.layer.shadowOffset  = CGSizeZero;
    self.infoCard.layer.shadowRadius  = 24;
    self.infoCard.layer.shadowOpacity = 0.35;
    [self.view addSubview:self.infoCard];

    // Настоящий blur вместо плоской заливки
    UIVisualEffectView *blur = [[UIVisualEffectView alloc] initWithEffect:
        [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialDark]];
    blur.frame = self.infoCard.bounds;
    blur.layer.cornerRadius = 22;
    blur.clipsToBounds = YES;
    blur.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.infoCard addSubview:blur];

    // Тонкий серебристый бордер поверх blur
    self.infoCard.layer.borderWidth = 1.0;
    self.infoCard.layer.borderColor = MRNeonAccent(0.35).CGColor;

    // Стеклянный "хайлайт" — градиент сверху вниз, имитирующий отражение света
    CAGradientLayer *glassHighlight = [CAGradientLayer layer];
    glassHighlight.frame = self.infoCard.bounds;
    glassHighlight.cornerRadius = 22;
    glassHighlight.colors = @[
        (id)[UIColor colorWithWhite:1.0 alpha:0.08].CGColor,
        (id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor
    ];
    glassHighlight.locations = @[@0.0, @0.45];
    [blur.contentView.layer addSublayer:glassHighlight];

    // ── Строки карточки ───────────────────────────────────
    NSArray *keys = @[@"Device:", @"iOS:", @"Model:", @"Chip:", @"Jailbreak:"];
    NSArray *tags = @[@100, @101, @102, @103, @104];
    UIColor *keyColor = [UIColor colorWithWhite:0.851 alpha:1.0]; // #D9D9D9
    UIFont  *keyFont  = [UIFont systemFontOfSize:fontSize weight:UIFontWeightMedium];
    UIFont  *valFont  = [UIFont systemFontOfSize:fontSize weight:UIFontWeightMedium];

    // Ширину значения выравниваем по самому длинному ключу — единая колонка
    CGFloat maxKeyW = 0;
    for (NSString *k in keys) {
        NSString *bulleted = [NSString stringWithFormat:@"• %@", k];
        CGSize sz = [bulleted sizeWithAttributes:@{NSFontAttributeName: keyFont}];
        maxKeyW = MAX(maxKeyW, sz.width);
    }
    CGFloat valX = 24 + maxKeyW + 8;

    for (int i = 0; i < 5; i++) {
        CGFloat rowY = padV + i * rowH;
        BOOL isStatusRow = (i == 4); // строка "Jailbreak:"

        // Ключ "• Device:"
        UILabel *keyLabel = [[UILabel alloc] init];
        keyLabel.text = [NSString stringWithFormat:@"• %@", keys[i]];
        keyLabel.font = keyFont;
        keyLabel.textColor = keyColor;
        [keyLabel sizeToFit];
        keyLabel.frame = CGRectMake(24, rowY + (rowH - keyLabel.frame.size.height) / 2.0,
                                    keyLabel.frame.size.width, keyLabel.frame.size.height);
        [blur.contentView addSubview:keyLabel];

        // Значение — единая колонка для всех строк, все значения в неоновом белом стиле
        UILabel *valLabel = [[UILabel alloc] init];
        valLabel.tag = [tags[i] integerValue];
        valLabel.text = @"...";
        valLabel.font = isStatusRow ? [UIFont systemFontOfSize:fontSize weight:UIFontWeightSemibold] : valFont;
        valLabel.textColor = MRNeonAccent(1.0);
        valLabel.layer.shadowColor   = MRNeonAccent(1.0).CGColor;
        valLabel.layer.shadowOffset  = CGSizeZero;
        valLabel.layer.shadowRadius  = 8;
        valLabel.layer.shadowOpacity = 0.9;
        valLabel.layer.masksToBounds = NO;
        valLabel.frame = CGRectMake(valX, rowY + (rowH - keyLabel.frame.size.height) / 2.0,
                                    cardW - valX - 16, keyLabel.frame.size.height);
        [blur.contentView addSubview:valLabel];
    }

    // ── Кнопка ────────────────────────────────────────────
    self.jailbreakButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.jailbreakButton.frame = CGRectMake(sideMargin, btnY, btnW, btnH);
    self.jailbreakButton.backgroundColor = [UIColor colorWithWhite:0.624 alpha:1.0];
    self.jailbreakButton.layer.cornerRadius = 18;
    self.jailbreakButton.layer.masksToBounds = NO;
    [self.jailbreakButton setTitle:@"Jailbreak" forState:UIControlStateNormal];
    [self.jailbreakButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.jailbreakButton.titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
    self.jailbreakButton.layer.shadowColor   = [UIColor colorWithWhite:0.624 alpha:1.0].CGColor;
    self.jailbreakButton.layer.shadowOffset  = CGSizeZero;
    self.jailbreakButton.layer.shadowRadius  = 18;
    self.jailbreakButton.layer.shadowOpacity = 0.7;
    [self.jailbreakButton addTarget:self action:@selector(btnDown:) forControlEvents:UIControlEventTouchDown];
    [self.jailbreakButton addTarget:self action:@selector(btnUp:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
    [self.view addSubview:self.jailbreakButton];
}

- (void)btnDown:(UIButton *)btn { [UIView animateWithDuration:0.1 animations:^{ btn.alpha = 0.6; }]; }
- (void)btnUp:(UIButton *)btn   { [UIView animateWithDuration:0.18 animations:^{ btn.alpha = 1.0; }]; }

- (void)setRowTag:(NSInteger)tag value:(NSString *)val {
    UILabel *lbl = (UILabel *)[self.infoCard viewWithTag:tag];
    if (!lbl) return;
    [UIView transitionWithView:lbl duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        lbl.text = val;
    } completion:nil];
}

- (void)detectDevice {
    [self setRowTag:100 value:[[UIDevice currentDevice] model]];
    [self setRowTag:101 value:[[UIDevice currentDevice] systemVersion]];
    [self setRowTag:102 value:@"Unknown"];
    [self setRowTag:103 value:@"Apple Silicon"];
    [self setRowTag:104 value:@"Ready"];
}

@end
