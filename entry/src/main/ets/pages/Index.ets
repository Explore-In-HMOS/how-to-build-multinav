import {MultiNavigation,MultiNavPathStack, SplitPolicy} from '@ohos.arkui.advanced.MultiNavigation';
import { NavPushPathHelper } from '@ohos.atomicservice.NavPushPathHelper';
import { AtomicServiceNavigation,BackgroundTheme,GradientAlpha,MixMode} from '@ohos.atomicservice.AtomicServiceNavigation';
import { ArcList, ArcListItem } from '@ohos.arkui.ArcList';

interface FitnessRouteParam {
  tab: number;
  tabTitle: string;
  title: string;
  subtitle: string;
  metric: string;
}

interface FitnessCard {
  title: string;
  subtitle: string;
  metric: string;
}

const WORKOUT_TAB: number = 0;
const SOCIAL_TAB: number = 1;
const SETTINGS_TAB: number = 2;

@Entry
@Component
struct Index {
  @State activeTab: number = WORKOUT_TAB;
  @State routeLog: string = 'Scroll state is per tab';
  @State atomicShellStack: NavPathStack = new NavPathStack();
  @State workoutStack: MultiNavPathStack = new MultiNavPathStack();
  @State socialStack: MultiNavPathStack = new MultiNavPathStack();
  @State settingsStack: MultiNavPathStack = new MultiNavPathStack();
  private workoutScrollOffset: number = 0;
  private socialScrollOffset: number = 0;
  private settingsScrollOffset: number = 0;

  private workoutScroller: Scroller = new Scroller();
  private socialScroller: Scroller = new Scroller();
  private settingsScroller: Scroller = new Scroller();

  private workoutCards: FitnessCard[] = [
    { title: 'Warmup Flow', subtitle: '5 min mobility', metric: '72 bpm' },
    { title: 'Interval Run', subtitle: '4 x 90 sec push', metric: '2.4 km' },
    { title: 'Cooldown', subtitle: 'Breath and stretch', metric: '6 min' },
    { title: 'Strength Set', subtitle: 'Core and balance', metric: '18 reps' },
    { title: 'Recovery Walk', subtitle: 'Zone 2 finish', metric: '900 m' },
    { title: 'Hydration', subtitle: 'Post workout check', metric: '250 ml' }
  ];

  private socialCards: FitnessCard[] = [
    { title: 'Team Ring', subtitle: '3 friends active now', metric: '12 kudos' },
    { title: 'Challenge', subtitle: 'Weekend steps sprint', metric: '64%' },
    { title: 'Coach Note', subtitle: 'Cadence improved', metric: '+8%' },
    { title: 'Group Run', subtitle: 'Tonight at 19:30', metric: '4 joined' },
    { title: 'Share Goal', subtitle: 'Weekly streak', metric: '5 days' },
    { title: 'Inbox', subtitle: 'New teammate reply', metric: '2 new' }
  ];

  private settingsCards: FitnessCard[] = [
    { title: 'Heart Zone', subtitle: 'Alert above 165 bpm', metric: 'On' },
    { title: 'Haptics', subtitle: 'Workout milestones', metric: 'Soft' },
    { title: 'Sync', subtitle: 'Cloud and phone link', metric: 'Auto' },
    { title: 'Display', subtitle: 'Always-on summary', metric: 'Off' },
    { title: 'Units', subtitle: 'Distance and weight', metric: 'Metric' },
    { title: 'Privacy', subtitle: 'Hide live location', metric: 'On' }
  ];

  aboutToAppear() {
    this.seedStack(this.workoutStack, WORKOUT_TAB, 'Workout', 'WorkoutHome');
    this.seedStack(this.socialStack, SOCIAL_TAB, 'Social', 'SocialHome');
    this.seedStack(this.settingsStack, SETTINGS_TAB, 'Settings', 'SettingsHome');
  }

  private seedStack(stack: MultiNavPathStack, tab: number, tabTitle: string, routeName: string): void {
    if (stack.size() > 0) {
      return;
    }

    stack.keepBottomPage(true);
    stack.setHomeWidthRange(100, 100);
    const homeParam: FitnessRouteParam = {
      tab: tab,
      tabTitle: tabTitle,
      title: `${tabTitle} Stack`,
      subtitle: 'Home destination kept at the bottom',
      metric: 'Home'
    };
    const placeholderParam: FitnessRouteParam = {
      tab: tab,
      tabTitle: tabTitle,
      title: 'Pick an item',
      subtitle: 'The detail column waits here in split mode',
      metric: 'Ready'
    };
    stack.pushPath(new NavPathInfo(routeName, homeParam, undefined, true), false, SplitPolicy.HOME_PAGE);
    stack.setPlaceholderPage(new NavPathInfo(`${tabTitle}Placeholder`, placeholderParam));
  }

  private stackForTab(tab: number): MultiNavPathStack {
    if (tab === SOCIAL_TAB) {
      return this.socialStack;
    }

    if (tab === SETTINGS_TAB) {
      return this.settingsStack;
    }

    return this.workoutStack;
  }

  private scrollerForTab(tab: number): Scroller {
    if (tab === SOCIAL_TAB) {
      return this.socialScroller;
    }

    if (tab === SETTINGS_TAB) {
      return this.settingsScroller;
    }

    return this.workoutScroller;
  }

  private tabTitle(tab: number): string {
    if (tab === SOCIAL_TAB) {
      return 'Social';
    }

    if (tab === SETTINGS_TAB) {
      return 'Settings';
    }

    return 'Workout';
  }

  private scrollOffsetForTab(tab: number): number {
    if (tab === SOCIAL_TAB) {
      return this.socialScrollOffset;
    }

    if (tab === SETTINGS_TAB) {
      return this.settingsScrollOffset;
    }

    return this.workoutScrollOffset;
  }

  private setScrollOffset(tab: number, offset: number): void {
    if (tab === SOCIAL_TAB) {
      this.socialScrollOffset = offset;
      return;
    }

    if (tab === SETTINGS_TAB) {
      this.settingsScrollOffset = offset;
      return;
    }

    this.workoutScrollOffset = offset;
  }

  private rememberScroll(tab: number): void {
    try {
      const offset: OffsetResult = this.scrollerForTab(tab).currentOffset();
      this.setScrollOffset(tab, offset.yOffset);
      this.routeLog = `${this.tabTitle(tab)} scroll ${Math.round(offset.yOffset)} vp`;
    } catch (_err) {
    }
  }

  private restoreScroll(tab: number): void {
    try {
      this.scrollerForTab(tab).scrollTo({
        xOffset: 0,
        yOffset: this.scrollOffsetForTab(tab),
        animation: false
      });
    } catch (_err) {
    }
  }

  private restoreScrollAfterRender(tab: number): void {
    this.restoreScroll(tab);
    setTimeout(() => {
      this.restoreScroll(tab);
    }, 0);
  }

  private pushNamedPath(tab: number, card: FitnessCard): void {
    const stack: MultiNavPathStack = this.stackForTab(tab);
    const helper: NavPushPathHelper = new NavPushPathHelper(stack);
    const param: FitnessRouteParam = {
      tab: tab,
      tabTitle: this.tabTitle(tab),
      title: card.title,
      subtitle: card.subtitle,
      metric: card.metric
    };

    helper.pushPathByName('entry', 'FitnessDetail', param, false)
      .then(() => {
        this.routeLog = `${param.tabTitle}: NavPushPathHelper pushed ${param.title}`;
      })
      .catch(() => {
        stack.pushPathByName('FitnessDetail', param, false, SplitPolicy.DETAIL_PAGE);
        this.routeLog = `${param.tabTitle}: MultiNavPathStack pushed ${param.title}`;
      });
  }

  private pushFullScreenSummary(tab: number): void {
    const stack: MultiNavPathStack = this.stackForTab(tab);
    const param: FitnessRouteParam = {
      tab: tab,
      tabTitle: this.tabTitle(tab),
      title: `${this.tabTitle(tab)} Summary`,
      subtitle: 'Full-page destination from the active stack',
      metric: `${stack.size()} pages`
    };
    stack.pushPathByName('FitnessSummary', param, false, SplitPolicy.FULL_PAGE);
    this.routeLog = `${this.tabTitle(tab)} summary pushed`;
  }

  private popActiveStack(): void {
    const stack: MultiNavPathStack = this.stackForTab(this.activeTab);
    stack.pop(false);
    this.restoreScrollAfterRender(this.activeTab);
    this.routeLog = `${this.tabTitle(this.activeTab)} pop`;
  }

  private resetActiveStack(): void {
    const tab: number = this.activeTab;
    const stack: MultiNavPathStack = this.stackForTab(tab);
    stack.clear(false);
    this.setScrollOffset(tab, 0);
    this.seedStack(stack, tab, this.tabTitle(tab), `${this.tabTitle(tab)}Home`);
    this.restoreScroll(tab);
    this.routeLog = `${this.tabTitle(tab)} reset`;
  }

  private pageBackgroundColor(): string {
    return '#F3F6FB';
  }

  private tabSurfaceColor(tab: number): string {
    if (tab === SOCIAL_TAB) {
      return '#EDF8F1';
    }

    if (tab === SETTINGS_TAB) {
      return '#F3EEFF';
    }

    return '#EEF5FF';
  }

  private tabAccentSoftColor(tab: number): string {
    if (tab === SOCIAL_TAB) {
      return '#D8F0E1';
    }

    if (tab === SETTINGS_TAB) {
      return '#E7D9FF';
    }

    return '#D9EAFF';
  }

  @Builder
  AtomicContent() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        this.ActiveTabContent()
      }
      .height('100%')
      .width('100%')

      this.WatchTabBar()
    }
    .padding({ left: 0, right: 0, top: 0, bottom: 18 })
    .height('100%')
    .width('100%')
    .backgroundColor(this.pageBackgroundColor())
  }

  @Builder
  ActiveTabContent() {
    Stack() {
      Column() {
        this.WorkoutTab()
      }
      .height('100%')
      .width('100%')
      .visibility(this.activeTab === WORKOUT_TAB ? Visibility.Visible : Visibility.Hidden)

      Column() {
        this.SocialTab()
      }
      .height('100%')
      .width('100%')
      .visibility(this.activeTab === SOCIAL_TAB ? Visibility.Visible : Visibility.Hidden)

      Column() {
        this.SettingsTab()
      }
      .height('100%')
      .width('100%')
      .visibility(this.activeTab === SETTINGS_TAB ? Visibility.Visible : Visibility.Hidden)
    }
    .height('100%')
    .width('100%')
  }

  @Builder
  WatchTabBar() {
    Row({ space: 6 }) {
      this.WatchTabItem(WORKOUT_TAB, 'Fit')
      this.WatchTabItem(SOCIAL_TAB, 'Social')
      this.WatchTabItem(SETTINGS_TAB, 'Prefs')
    }
    .padding(3)
    .alignItems(VerticalAlign.Center)
    .height(27)
    .width(143)
    .backgroundColor('#FFFFFF')
    .borderRadius(14)
    .shadow({
      radius: 8,
      color: '#1A2A3440',
      offsetX: 0,
      offsetY: 3
    })
  }

  @Builder
  WatchTabItem(tab: number, label: string) {
    Text(label)
      .width(43)
      .height(21)
      .fontSize(10)
      .fontWeight(this.activeTab === tab ? FontWeight.Bold : FontWeight.Medium)
      .fontColor(this.activeTab === tab ? '#FFFFFF' : '#626B76')
      .textAlign(TextAlign.Center)
      .backgroundColor(this.activeTab === tab ? this.metricColor(tab) : '#00000000')
      .borderRadius(11)
      .onClick(() => {
        if (this.activeTab === tab) {
          return;
        }

        this.rememberScroll(this.activeTab);
        this.activeTab = tab;
        this.restoreScrollAfterRender(tab);
        this.routeLog = `${this.tabTitle(tab)} tab selected`;
      })
  }

  @Builder
  WorkoutTab() {
    this.StackColumn('Workout', this.workoutStack)
  }

  @Builder
  SocialTab() {
    this.StackColumn('Social', this.socialStack)
  }

  @Builder
  SettingsTab() {
    this.StackColumn('Settings', this.settingsStack)
  }

  @Builder
  StackColumn(title: string, stack: MultiNavPathStack) {
    MultiNavigation({
      multiStack: stack,
      navDestination: (name: string, param?: object) => {
        this.FitnessDestination(name, param as Object)
      },
      onNavigationModeChange: (mode: NavigationMode) => {
        this.routeLog = `${title}: MultiNavigation mode ${mode}`;
      },
      onHomeShowOnTop: (name: string) => {
        this.routeLog = `${title}: ${name} is on top`;
      }
    })
      .height('100%')
      .width('100%')
      .backgroundColor(this.pageBackgroundColor())
  }

  @Builder
  FitnessDestination(name: string, param?: Object) {
    NavDestination() {
      if ((param as FitnessRouteParam).metric === 'Home') {
        this.StackHome(
          (param as FitnessRouteParam).tab,
          (param as FitnessRouteParam).tabTitle,
          this.stackForTab((param as FitnessRouteParam).tab),
          this.cardsForTab((param as FitnessRouteParam).tab)
        )
      } else {
        this.DestinationBody(name, param as FitnessRouteParam)
      }
    }
    .title(name)
    .hideTitleBar(true)
  }

  @Builder
  DestinationBody(name: string, param: FitnessRouteParam) {
    Scroll() {
      Column({ space: 12 }) {
        Column({ space: 8 }) {
          Text(param.tabTitle)
            .fontSize(10)
            .fontColor(this.metricColor(param.tab))
            .fontWeight(FontWeight.Medium)

          Text(param.title)
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor('#121417')
            .textAlign(TextAlign.Center)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(param.subtitle)
            .fontSize(10)
            .fontColor('#5C6570')
            .textAlign(TextAlign.Center)
            .maxLines(3)

          Text(param.metric)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.metricColor(param.tab))

          Text(`Route ${name}`)
            .fontSize(9)
            .fontColor('#7A808A')
        }
        .padding({ left: 18, right: 18, top: 18, bottom: 18 })
        .width('100%')
        .backgroundColor(this.tabSurfaceColor(param.tab))
        .borderRadius(30)
        .alignItems(HorizontalAlign.Center)

        Button('Related')
          .width('100%')
          .height(38)
          .fontSize(11)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(this.metricColor(param.tab))
          .fontColor('#FFFFFF')
          .borderRadius(20)
          .onClick(() => {
            this.pushNamedPath(param.tab, {
              title: `${param.title} Detail`,
              subtitle: 'Named path pushed with params again',
              metric: param.metric
            });
          })

        Button('Back')
          .width('100%')
          .height(36)
          .fontSize(11)
          .backgroundColor('#FFFFFF')
          .fontColor('#121417')
          .borderRadius(20)
          .onClick(() => {
            this.stackForTab(param.tab).pop(false);
            this.restoreScrollAfterRender(param.tab);
          })
      }
      .padding({ left: 20, right: 20, top: 34, bottom: 68 })
      .width('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Auto)
    .edgeEffect(EdgeEffect.Spring)
    .height('100%')
    .width('100%')
    .backgroundColor(this.pageBackgroundColor())
  }

  @Builder
  StackHome(tab: number, title: string, stack: MultiNavPathStack, cards: FitnessCard[]) {
    Column() {
      ArcList({ scroller: this.scrollerForTab(tab) }) {
        ArcListItem() {
          Column({ space: 4 }) {
            Text(title)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#121417')
              .textAlign(TextAlign.Center)
              .width('100%')

            Text(`Stack ${stack.size()}  Scroll ${Math.round(this.scrollOffsetForTab(tab))}`)
              .fontSize(9)
              .fontColor('#69707A')
              .textAlign(TextAlign.Center)
              .maxLines(1)
              .width('100%')
          }
          .padding({ left: 12, right: 12, top: 13, bottom: 13 })
          .width(174)
          .height(64)
          .backgroundColor(this.tabSurfaceColor(tab))
          .borderRadius(32)
          .margin({ top: 10, bottom: 4 })
        }
        .autoScale(true)

        ForEach(cards, (card: FitnessCard) => {
          ArcListItem() {
            this.FitnessCardItem(tab, card)
          }
          .autoScale(true)
        }, (card: FitnessCard) => card.title)

        ArcListItem() {
          Row({ space: 8 }) {
            Button('Pop')
              .layoutWeight(1)
              .height(38)
              .fontSize(11)
              .backgroundColor('#FFFFFF')
              .fontColor('#121417')
              .borderRadius(20)
              .onClick(() => {
                this.popActiveStack();
              })

            Button('Reset')
              .layoutWeight(1)
              .height(38)
              .fontSize(11)
              .backgroundColor('#FFFFFF')
              .fontColor('#121417')
              .borderRadius(20)
              .onClick(() => {
                this.resetActiveStack();
              })
          }
          .width(174)
        }
        .autoScale(true)

        ArcListItem() {
          Column() {
            Blank()
              .height(42)
              .width(1)
          }
        }
      }
      .scrollBar(BarState.Off)
      .fadingEdge(true)
      .chainAnimation(true)
      .cachedCount(3)
      .onAppear(() => {
        this.restoreScrollAfterRender(tab);
      })
      .onScrollStop(() => {
        this.rememberScroll(tab);
      })
      .width('100%')
      .height('100%')
    }
    .height('100%')
    .width('100%')
    .backgroundColor(this.pageBackgroundColor())
  }

  @Builder
  FitnessCardItem(tab: number, card: FitnessCard) {
    Row({ space: 8 }) {
      Column() {
        Text(card.metric)
          .fontSize(10)
          .fontColor(this.metricColor(tab))
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .maxLines(1)
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .width(44)
      .height(44)
      .backgroundColor(this.tabAccentSoftColor(tab))
      .borderRadius(22)

      Column({ space: 4 }) {
        Text(card.title)
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor('#171A1F')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Text(card.subtitle)
          .fontSize(9)
          .fontColor('#69707A')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .alignItems(VerticalAlign.Center)
    .padding({ left: 10, right: 10, top: 8, bottom: 8 })
    .height(64)
    .width(174)
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .margin({ top: 4, bottom: 4 })
    .onClick(() => {
      this.rememberScroll(tab);
      this.pushNamedPath(tab, card);
    })
  }

  private metricColor(tab: number): string {
    if (tab === SOCIAL_TAB) {
      return '#18794E';
    }

    if (tab === SETTINGS_TAB) {
      return '#6E33B5';
    }

    return '#0A62C4';
  }

  private cardsForTab(tab: number): FitnessCard[] {
    if (tab === SOCIAL_TAB) {
      return this.socialCards;
    }

    if (tab === SETTINGS_TAB) {
      return this.settingsCards;
    }

    return this.workoutCards;
  }

  build() {
    Column() {
      AtomicServiceNavigation({
        navPathStack: this.atomicShellStack,
        title: 'WearFit Lab',
        hideTitleBar: true,
        mode: NavigationMode.Stack,
        navigationContent: () => {
          this.AtomicContent()
        },
        navDestinationBuilder: (name: string, param?: Object) => {
          this.FitnessDestination(name, param)
        },
        titleOptions: {
          backgroundColor: '#FFFFFF',
          isBlurEnabled: true
        },
        gradientBackground: {
          primaryColor: '#EAF2FF',
          secondaryColor: '#F7F9FC',
          backgroundTheme: BackgroundTheme.DEFAULT,
          mixMode: MixMode.TOWARDS,
          alpha: GradientAlpha.OPACITY_60
        }
      })
        .height('100%')
        .width('100%')
    }
    .height('100%')
    .width('100%')
    .backgroundColor(this.pageBackgroundColor())
  }
}
