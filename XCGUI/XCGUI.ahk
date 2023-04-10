/************************************************************************
 * @description 炫彩界面库
 * @file xcgui.ahk
 * @author thqby
 * @date 2021/10/04
 * @version 0.0.1
 ***********************************************************************/

class XC {
  static STYLE := {
    default: 0,
    button_default: 0,	; <默认风格
    button_check: 1,	; <复选按钮
    button_radio: 2,	; <单选按钮
    button_expand: 3,	; <展开收缩按钮
    button_scrollbar_left: 4,	; <水平滚动条,左按钮
    button_scrollbar_right: 5,	; <水平滚动条,右按钮
    button_scrollbar_up: 6,	; <垂直滚动条,上按钮
    button_scrollbar_down: 7,	; <垂直滚动条,下按钮
    button_scrollbar_slider_h: 8,	; <水平滚动条,滑块
    button_scrollbar_slider_v: 9,	; <垂直滚动条,滑块
    button_tabBar_button: 10,	; <TabBar上的标签按钮
    button_toolBar_left: 11,	; <ToolBar左滚动按钮
    button_toolBar_right: 12,	; <ToolBar右滚动按钮
    button_pane_close: 13,	; <窗格关闭按钮
    button_pane_lock: 14,	; <窗格锁定按钮
    button_pane_menu: 15,	; <窗格下拉菜单按钮
    button_pane_dockH: 16,	; <框架窗口左边或右边码头上按钮
    button_pane_dockV: 17,	; <框架窗口上边或下边码头上按钮
    frameWnd_dock_left: 18,	; <框架窗口停靠码头
    frameWnd_dock_top: 19,	; <框架窗口停靠码头
    frameWnd_dock_right: 20,	; <框架窗口停靠码头
    frameWnd_dock_bottom: 21,	; <框架窗口停靠码头
    ToolBar_separator: 22,	; <工具条上的分割线
    listBox_comboBox: 23	; <下拉组合框弹出的listBox
  }
  static TYPE_EX := {
    error: -1,	; <错误类型
    button_default: 0,	; <默认类型
    button_radio: 1,	; <单选按钮
    button_check: 2,	; <复选按钮
    button_close: 3,	; <窗口关闭按钮
    button_min: 4,	; <窗口最小化按钮
    button_max: 5,	; <窗口最大化还原按钮
    element_layout: 6	; <布局元素启用布局功能的元素
  }
  static WINDOW := {
    TOP: 1,	; 上
    BOTTOM: 2,	; 下
    LEFT: 3,	; 左
    RIGHT: 4,	; 右
    TOPLEFT: 5,	; 左上角
    TOPRIGHT: 6,	; 右上角
    BOTTOMLEFT: 7,	; 左下角
    BOTTOMRIGHT: 8,	; 右下角
    CAPTION: 9,	; 标题栏移动窗口区域
    BODY: 10
  }
  static ID := {
    ROOT: 0,	; <根节点
    ERROR: -1,	; <ID错误
    FIRST: -2,	; <插入开始位置
    LAST: -3	; <插入末尾位置
  }
  static window_style := {
    nothing: 0x00,	; <什么也没有
    caption: 0x01,	; <top布局,如果指定该属性,默认为绑定标题栏元素
    border: 0x02,	; <边框,指定默认上下左右布局大小,如果没有指定,那么边框布局大小为0
    center: 0x04,	; <窗口居中
    drag_border: 0x08,	; <拖动窗口边框
    drag_window: 0x10,	; <拖动窗口
    allow_maxWindow: 0x20,	; 允许窗口最大化
    default: 0x2f,
    default2: 0x2b,
    modal: 0x7	; 模态窗口样式
  }
  static window_position := {
    error: -1,	; <错误
    top: 0,	; <top
    bottom: 1,	; <bottom
    left: 2,	; <left
    right: 3,	; <right
    body: 4,	; <body
    window: 5	; <window 整个窗口
  }
  static element_position := {
    no: 0x00,	; <无效
    left: 0x01,	; <左边
    top: 0x02,	; <上边
    right: 0x04,	; <右边
    bottom: 0X08	; <下边
  }
  static window_transparent := {
    false: 0,	; <默认窗口,不透明
    shaped: 1,	; <透明窗口,带透明通道,异型
    shadow: 2,	; <阴影窗口,带透明通道,边框阴影,窗口透明或半透明
    simple: 3,	; <透明窗口,不带透明通道,指定半透明度,指定透明色
    win7: 4	; <WIN7玻璃窗口,需要WIN7开启特效,当前未启用,当前未启用.
  }
  static menu_item_flags := {
    normal: 0x00,	; <正常
    select: 0x01,	; <选择
    check: 0x02,	; <勾选
    popup: 0x04,	; <弹出
    separator: 0x08,	; <分隔栏 ID号任意,ID号被忽略
    disable: 0x10	; <禁用
  }
  static menu_popup_position := {
    left_top: 0,	; <左上角
    left_bottom: 1,	; <左下角
    right_top: 2,	; <右上角
    right_bottom: 3,	; <右下角
    center_left: 4,	; <左居中
    center_top: 5,	; <上居中
    center_right: 6,	; <右居中
    center_bottom: 7	; <下居中
  }
  static image_draw_type := {
    default: 0,	; <默认
    stretch: 1,	; <拉伸
    adaptive: 2,	; <自适应,九宫格
    tile: 3,	; <平铺
    fixed_ratio: 4,	; <固定比例,当图片超出显示范围时,按照原始比例压缩显示图片
    adaptive_border: 5	; <九宫格不绘制中间区域
  }
  static common_state3 := {
    leave: 0,	; <离开
    stay: 1,	; <停留
    down: 2	; <按下
  }
  static button_state := {
    leave: 0,	; <离开状态
    stay: 1,	; <停留状态
    down: 2,	; <按下状态
    check: 3,	; <选中状态
    disable: 4	; <禁用状态
  }
  static comboBox_state := {
    leave: 0,	; <鼠标离开状态
    stay: 1,	; <鼠标停留状态
    down: 2	; <按下状态
  }
  static list_item_state := {
    leave: 0,	; <项鼠标离开状态
    stay: 1,	; <项鼠标停留状态
    select: 2,	; <项选择状态
    cache: 3	; <缓存的项
  }
  static tree_item_state := {
    leave: 0,	; <项鼠标离开状态
    stay: 1,	; <项鼠标停留状态
    select: 2	; <项选择状态
  }
  static button_icon_align := {
    left: 0,	; <图标在左边
    top: 1,	; <图标在顶部
    right: 2,	; <图标在右边
    bottom: 3	; <图标在底部
  }
  static layout_size_type := {
    fixed: 0,	; <指定大小
    fill: 1,	; <fill 填充父
    auto: 2,	; <auto 自动大小,根据内容计算大小
    weight: 3,	; <weight 比例,按照比例分配剩余空间
    disable: 4	; <disable 不使用
  }
  static list_drawItemBk_flags := {
    nothing: 0x000,	; <不绘制
    leave: 0x001,	; <绘制鼠标离开状态项背景
    stay: 0x002,	; <绘制鼠标选择状态项背景
    select: 0x004,	; <绘制鼠标停留状态项项背景
    group_leave: 0x008,	; <绘制鼠标离开状态组背景,当项为组时
    group_stay: 0x010	; <绘制鼠标停留状态组背景,当项为组时
  }
  static messageBox_flags := {
    other: 0x00,	; <其他
    ok: 0x01,	; <确定按钮
    cancel: 0x02,	; <取消按钮
    icon_appicon: 0x01000,	; <图标 应用程序  IDI_APPLICATION
    icon_info: 0x02000,	; <图标 信息     IDI_ASTERISK
    icon_qustion: 0x04000,	; <图标 问询/帮助/提问   IDI_QUESTION
    icon_error: 0x08000,	; <图标 错误/拒绝/禁止  IDI_ERROR
    icon_warning: 0x10000,	; <图标 警告       IDI_WARNING
    icon_shield: 0x20000	; <图标 盾牌/安全   IDI_SHIELD
  }
  static propertyGrid_item_type := {
    text: 0,	; <默认,字符串类型
    edit: 1,	; <编辑框
    edit_color: 2,	; <颜色选择元素
    edit_file: 3,	; <文件选择编辑框
    edit_set: 4,	; <设置
    comboBox: 5,	; <组合框
    group: 6,	; <组
    panel: 7	; <面板
  }
  static zorder := {
    top: 0,	; <最上面
    bottom: 1,	; <最下面
    before: 2,	; <指定目标下面
    after: 3	; <指定目标上面
  }
  static layout_align := {
    left: 0,	; <左侧
    top: 1,	; <顶部
    right: 2,	; <右侧
    bottom: 3,	; <底部
    center: 4,	; <居中
    equidistant: 5	; <等距
  }
  static pane_align := {
    error: -1,	; <错误
    left: 0,	; <左侧
    top: 1,	; <顶部
    right: 2,	; <右侧
    bottom: 3,	; <底部
    center: 4	; <居中
  }
  static align_flag := {
    left: 0x0,	; <左侧
    right: 0x1,	; <右侧
    center: 0x2,	; <水平居中
    top: 0x0,	; <顶部
    bottom: 0x4,	; <底部
    center_v: 0x8	; <垂直居中
  }
  static pane_state := {
    error: -1,
    any: 0,
    lock: 1,	; <锁定
    dock: 2,	; <停靠码头
    float: 3	; <浮动窗格
  }
  static layout_float_type := {
    none: 0,	; <无
    left: 1,	; <浮动左侧
    right: 2	; <浮动右侧
  }
  static textFormatFlag := {
    AlignFlag_left: 0,	; <左对齐
    AlignFlag_top: 0,	; <垂直顶对齐
    AlignFlag_left_top: 0x4000,	; <内部保留
    AlignFlag_center: 0x1,	; <水平居中
    AlignFlag_right: 0x2,	; <右对齐
    AlignFlag_vcenter: 0x4,	; <垂直居中
    AlignFlag_bottom: 0x8,	; <垂直底对齐
    DirectionRightToLeft: 0x10,	; <从右向左顺序显示文本
    NoWrap: 0x20,	; <禁止换行
    DirectionVertical: 0x40,	; <垂直显示文本
    NoFitBlackBox: 0x80,	; <允许部分字符延伸该字符串的布局矩形。默认情况下，将重新定位字符以避免任何延伸
    DisplayFormatControl: 0x100,	; <控制字符（如从左到右标记）随具有代表性的标志符号一起显示在输出中。
    NoFontFallback: 0x200,	; <对于请求的字体中不支持的字符，禁用回退到可选字体。缺失的任何字符都用缺失标志符号的字体显示，通常是一个空的方块
    MeasureTrailingSpaces: 0x400,	; <包括每一行结尾处的尾随空格。在默认情况下，MeasureString 方法返回的边框都将排除每一行结尾处的空格。设置此标记以便在测定时将空格包括进去
    LineLimit: 0x800,	; <如果内容显示高度不够一行,那么不显示
    NoClip: 0x1000,	; <允许显示标志符号的伸出部分和延伸到边框外的未换行文本。在默认情况下，延伸到边框外侧的所有文本和标志符号部分都被剪裁
    Trimming_None: 0,	; <不使用去尾
    Trimming_Character: 0x40000,	; <以字符为单位去尾
    Trimming_Word: 0x80000,	; <以单词为单位去尾
    Trimming_EllipsisCharacter: 0x8000,	; <以字符为单位去尾,省略部分使用且略号表示
    Trimming_EllipsisWord: 0x10000,	; <以单词为单位去尾,
    Trimming_EllipsisPath: 0x20000	; <略去字符串中间部分，保证字符的首尾都能够显示
  }
  static listItemTemp_type := {
    tree: 0x01,	; <tree
    listBox: 0x02,	; <listBox
    list_head: 0x04,	; <list 列表头
    list_item: 0x08,	; <list 列表项
    listView_group: 0x10,	; <listView 列表视组
    listView_item: 0x20,	; <listView 列表视项
    list: 0x0c,	; <list (列表头)与(列表项)组合
    listView: 0x30	; <listView (列表视组)与(列表视项)组合
  }
  static xc_adjustLayout := {
    no: 0x00,	; <不调整布局
    all: 0x01,	; <强制调整自身和子对象布局.
    self: 0x02,	; <只调整自身布局,不调整子对象布局.
    free: 0x03	; 调整布局,非强制性, 只调整坐标改变的对象
  }
  static edit_type := {
    none: 0,	; <普通编辑框,   每行的高度相同
    editor: 1,	; <代码编辑
    richedit: 2,	; <富文本编辑框, 每行的高度可能不同
    chat: 3,	; <聊天气泡, 每行的高度可能不同
    codeTable: 4	; <代码表格,内部使用,  每行的高度相同
  }
  static edit_style_type := {
    font_color: 1,	; <字体
    image: 2,	; <图片
    obj: 3	; <UI对象
  }
  static chat_flag := {
    left: 0x1,	; <左侧
    right: 0x2,	; <右侧
    center: 0x4,	; <中间
    next_row_bubble: 0x8	; <下一行显示气泡
  }
  static layoutStack_align := {
    center: 0x0,	; <居中
    left: 0x1,	; <左侧
    right: 0x2	; <右侧
  }
  static layoutStack_width_type := {
    fill: 0,	; <填充
    fixed: 1,	; <指定大小
    percent: 2	; <百分比
  }
  static ease_flag := {
    easeIn: 0,	; <从慢到快
    easeOut: 1,	; <从快到慢
    easeInOut: 2	; <从慢到快再到慢
  }
  static table_flag := {
    full: 0,	; <铺满组合单元格
    none: 1	; <正常最小单元格
  }
  static table_line_flag := {
    left: 0x1,
    top: 0x2,
    right: 0x4,
    bottom: 0x8,
    left2: 0x10,
    top2: 0x20,
    right2: 0x40,
    bottom2: 0x80
  }
  static window_state_flag := {
    nothing: 0x0000,	; <无
    leave: 0x0001,	; <整个窗口
    body_leave: 0x0002,	; <窗口-body
    top_leave: 0x0004,	; <窗口-top
    bottom_leave: 0x0008,	; <窗口-bottom
    left_leave: 0x0010,	; <窗口-left
    right_leave: 0x0020,	; <窗口-right
    layout_body: 0x20000000	; <布局内容区
  }
  static element_state_flag := {
    nothing: 0,	; <无
    enable: 0x0001,	; <启用
    disable: 0x0002,	; <禁用
    focus: 0x0004,	; <焦点
    focus_no: 0x0008,	; <无焦点
    focusEx: 0x40000000,	; <该元素或该元素的子元素拥有焦点
    focusEx_no: 0x80000000,	; <无焦点Ex
    layout_state_flag_layout_body: 0x20000000,	; <布局内容区
    leave: 0x0010,	; <鼠标离开
    stay: 0x0020,	; <为扩展模块保留
    down: 0x0040	; <为扩展模块保留
  }
  static button_state_flag := {
    leave: 0x0010,	; <鼠标离开
    stay: 0x0020,	; <鼠标停留
    down: 0x0040,	; <鼠标按下
    check: 0x0080,	; <选中
    check_no: 0x0100,	; <未选中
    WindowRestore: 0x0200,	; <窗口还原
    WindowMaximize: 0x0400	; <窗口最大化
  }
  static comboBox_state_flag := {
    leave: 0x0010,	; <鼠标离开
    stay: 0x0020,	; <鼠标停留
    down: 0x0040	; <鼠标按下
  }
  static listBox_state_flag := {
    item_leave: 0x0080,	; <项鼠标离开
    item_stay: 0x0100,	; <项鼠标停留
    item_select: 0x0200,	; <项选择
    item_select_no: 0x0400	; <项未选择
  }
  static list_state_flag := {
    item_leave: 0x0080,	; <项鼠标离开
    item_stay: 0x0100,	; <项鼠标停留
    item_select: 0x0200,	; <项选择
    item_select_no: 0x0400	; <项未选择
  }
  static listHeader_state_flag := {
    item_leave: 0x0080,	; <项鼠标离开
    item_stay: 0x0100,	; <项鼠标停留
    item_down: 0x0200	; <项鼠标按下
  }
  static listView_state_flag := {
    item_leave: 0x0080,	; <项鼠标离开
    item_stay: 0x0100,	; <项鼠标停留
    item_select: 0x0200,	; <项选择
    item_select_no: 0x0400,	; <项未选择
    group_leave: 0x0800,	; <组鼠标离开
    group_stay: 0x1000,	; <组鼠标停留
    group_select: 0x2000,	; <组选择
    group_select_no: 0x4000	; <组未选择
  }
  static tree_state_flag := {
    item_leave: 0x0080,	; <项鼠标离开
    item_stay: 0x0100,	; <项鼠标停留,保留值, 暂未使用
    item_select: 0x0200,	; <项选择
    item_select_no: 0x0400,	; <项未选择
    group: 0x0800,	; <项为组
    group_no: 0x1000	; <项不为组
  }
  static monthCal_state_flag := {
    leave: 0x0010,	; <离开状态
    item_leave: 0x0080,	; < 项-离开
    item_stay: 0x0100,	; < 项-停留
    item_down: 0x0200,	; < 项-按下
    item_select: 0x0400,	; < 项-选择
    item_select_no: 0x0800,	; < 项-未选择
    item_today: 0x1000,	; < 项-今天
    item_other: 0x2000,	; < 项-上月及下月
    item_last_month: 0x4000,	; < 项-上月
    item_cur_month: 0x8000,	; < 项-当月
    item_next_month: 0x10000	; < 项-下月
  }
  static propertyGrid_state_flag := {
    item_leave: 0x0080,
    item_stay: 0x0100,
    item_select: 0x0200,
    item_select_no: 0x0400,
    group_leave: 0x0800,
    group_expand: 0x1000,
    group_expand_no: 0x2000
  }
  static pane_state_flag := {
    leave: 0x0010,
    stay: 0x0020,
    caption: 0x0080,
    body: 0x0100
  }
  static layout_state_flag := {
    nothing: 0x0000,	; <无
    full: 0x0001,	; 完整背景
    body: 0x0002	; 内容区域, 不包含边大小
  }
  static monthCal_button_type := {
    today: 0,	; < 今天按钮
    last_year: 1,	; < 上一年
    next_year: 2,	; < 下一年
    last_month: 3,	; < 上一月
    next_month: 4	; < 下一月
  }
  static xc_fontStyle_i := {
    regular: 0,	; <正常
    bold: 1,	; <粗体
    italic: 2,	; <斜体
    boldItalic: 3,	; <粗斜体
    underline: 4,	; <下划线
    strikeout: 8	; <删除线
  }
  static adapter_date_type := {
    error: -1,
    int: 0,	; <整形
    float: 1,	; <浮点型
    string: 2,	; <字符串
    image: 3	; <图片
  }
  static eleEvents := {
    ELEPROCE: 1,	; 元素事件处理过程  OnEventProc(UINT nEvent, WPARAM wParam, LPARAM lParam, BOOL *pbHandled)
    PAINT: 2,	; OnDraw(HDRAW hDraw,BOOL *pbHandled)
    PAINT_END: 3,	; 元素及子元素绘制完成后触发,需要启用该功能,XEle_EnableEvent_PAINT_END()  OnPaintEnd(HDRAW hDraw,BOOL *pbHandled)
    PAINT_SCROLLVIEW: 4,	; OnDrawScrollView(HDRAW hDraw,BOOL *pbHandled)
    MOUSEMOVE: 5,	; OnMouseMove(UINT nFlags, POINT *pPt, BOOL *pbHandled)
    MOUSESTAY: 6,	; 停留  OnMouseStay(BOOL *pbHandled)
    MOUSEHOVER: 7,	; 悬停  OnMouseHover(UINT nFlags, POINT *pPt, BOOL *pbHandled)
    MOUSELEAVE: 8,	; 离开  OnMouseLeave(HELE hEleStay,BOOL *pbHandled)
    MOUSEWHEEL: 9,	; 鼠标滚轮  wParam:标识,lParam:POINT坐标  OnMouseWheel(UINT nFlags,POINT *pPt,BOOL *pbHandled)
    LBUTTONDOWN: 10,	; OnLButtonDown(UINT nFlags, POINT *pPt,BOOL *pbHandled)
    LBUTTONUP: 11,	; OnLButtonUp(UINT nFlags, POINT *pPt,BOOL *pbHandled)
    RBUTTONDOWN: 12,	; OnRButtonDown(UINT nFlags, POINT *pPt,BOOL *pbHandled)
    RBUTTONUP: 13,	; OnRButtonUp(UINT nFlags, POINT *pPt,BOOL *pbHandled)
    LBUTTONDBCLICK: 14,	; OnLButtonDBClick(UINT nFlags, POINT *pPt,BOOL *pbHandled)
    RBUTTONDBCLICK: 15,
    XC_TIMER: 16,	; wParam:定时器ID, lParam:0  OnEleXCTimer(UINT nTimerID,BOOL *pbHandled)
    ADJUSTLAYOUT: 17,	; OnAdjustLayout(int nFlags, BOOL *pbHandled)
    ADJUSTLAYOUT_END: 18,	; OnAdjustLayoutEnd(int nFlags, BOOL *pbHandled)
    SETFOCUS: 31,	; OnSetFocus(BOOL *pbHandled)
    KILLFOCUS: 32,	; OnKillFocus(BOOL *pbHandled)
    DESTROY: 33,	; 元素销毁  OnDestroy(BOOL *pbHandled)
    DESTROY_END: 42,	; 元素销毁  OnDestroyeEnd(BOOL *pbHandled)
    BNCLICK: 34,	; OnBtnClick(BOOL *pbHandled)
    BUTTON_CHECK: 35,	; 按钮选中事件  OnButtonCheck(BOOL bCheck,BOOL *pbHandled)
    SIZE: 36,	; OnSize(int nFlags, BOOL *pbHandled)
    SHOW: 37,	; wParam:TRUE或FALSE, lParam:0  OnShow(BOOL bShow,BOOL *pbHandled)
    SETFONT: 38,	; OnSetFont(BOOL *pbHandled)
    KEYDOWN: 39,	; wParam和lParam参数与标准消息相同  OnEventKeyDown(WPARAM wParam,LPARAM lParam,BOOL *pbHandled)
    KEYUP: 40,	; wParam和lParam参数与标准消息相同  OnEventKeyUp(WPARAM wParam,LPARAM lParam,BOOL *pbHandled)
    CHAR: 41,	; wParam和lParam参见MSDN  OnEventChar(WPARAM wParam,LPARAM lParam,BOOL *pbHandled)
    SETCAPTURE: 51,	; OnSetCapture(BOOL *pbHandled)
    KILLCAPTURE: 52,	; OnKillCapture(BOOL *pbHandled)
    SETCURSOR: 53,	;  SetCursor  OnSetCursor(WPARAM wParam,LPARAM lParam,BOOL *pbHandled)
    SCROLLVIEW_SCROLL_H: 54,	; 滚动视图 滚动事件 wParam:滚动点,lParam:0 (滚动视图触发,表明滚动视图已滚动完成)  OnScrollViewScrollH(int pos,BOOL *pbHandled)
    SCROLLVIEW_SCROLL_V: 55,	; 滚动视图 滚动事件 wParam:滚动点,lParam:0 (滚动视图触发,表明滚动视图已滚动完成)  OnScrollViewScrollV(int pos,BOOL *pbHandled)
    SBAR_SCROLL: 56,	; 滚动条滚动事件 wParam:滚动点,lParam:0 (滚动条触发)  OnSBarScroll(int pos,BOOL *pbHandled)
    MENU_POPUP: 57,	; OnMenuPopup(HMENUX hMenu, BOOL *pbHandled)
    MENU_POPUP_WND: 58,	; OnMenuPopupWnd(HMENUX hMenu,menu_popupWnd_i* pInfo,BOOL *pbHandled)
    MENU_SELECT: 59,	; 菜单项选择 wParam:菜单ID,lParam:0  OnMenuSelect(int nItem,BOOL *pbHandled)
    MENU_DRAW_BACKGROUND: 60,	; 绘制菜单背景  OnMenuDrawBackground(HDRAW hDraw,menu_drawBackground_i *pInfo,BOOL *pbHandled)
    MENU_DRAWITEM: 61,	; 绘制菜单项   OnMenuDrawItem(HDRAW hDraw,menu_drawItem_i* pInfo,BOOL *pbHandled)
    MENU_EXIT: 62,	; 菜单退出  OnMenuExit(BOOL *pbHandled)
    SLIDERBAR_CHANGE: 63,	; OnSliderBarChange(int pos,BOOL *pbHandled)
    PROGRESSBAR_CHANGE: 64,	; OnProgressBarChange(int pos,BOOL *pbHandled)
    COMBOBOX_SELECT: 71,	; 组合框项选择    OnComboBoxSelect(int iItem,BOOL *pbHandled)
    COMBOBOX_SELECT_END: 74,	; 组合框项选择    OnComboBoxSelectEnd(int iItem,BOOL *pbHandled)
    COMBOBOX_POPUP_LIST: 72,	; OnComboBoxPopupList(HWINDOW hWindow,HELE hListBox,BOOL *pbHandled)
    COMBOBOX_EXIT_LIST: 73,	; OnComboBoxExitList(BOOL *pbHandled)
    LISTBOX_TEMP_CREATE: 81,	; OnListBoxTemplateCreate(listBox_item_i* pItem, int nFlag, BOOL *pbHandled)
    LISTBOX_TEMP_CREATE_END: 82,	; OnListBoxTemplateCreateEnd(listBox_item_i* pItem, int nFlag, BOOL *pbHandled)
    LISTBOX_TEMP_DESTROY: 83,	; OnListBoxTemplateDestroy(listBox_item_i* pItem, int nFlag, BOOL *pbHandled)
    LISTBOX_TEMP_ADJUST_COORDINATE: 84,	; OnListBoxTemplateAdjustCoordinate(listBox_item_i* pItem, BOOL *pbHandled)
    LISTBOX_DRAWITEM: 85,	; OnListBoxDrawItem(HDRAW hDraw,listBox_item_i* pItem,BOOL *pbHandled)
    LISTBOX_SELECT: 86,	; OnListBoxSelect(int iItem,BOOL *pbHandled)
    LIST_TEMP_CREATE: 101,	; OnListTemplateCreate(list_item_i* pItem,int nFlag, BOOL *pbHandled)
    LIST_TEMP_CREATE_END: 102,	; OnListTemplateCreateEnd(list_item_i* pItem, int nFlag, BOOL *pbHandled)
    LIST_TEMP_DESTROY: 103,	; OnListTemplateDestroy(list_item_i* pItem, int nFlag, BOOL *pbHandled)
    LIST_TEMP_ADJUST_COORDINATE: 104,	; typedef OnListTemplateAdjustCoordinate(list_item_i* pItem,BOOL *pbHandled)
    LIST_DRAWITEM: 105,	; OnListDrawItem(HDRAW hDraw,list_item_i* pItem,BOOL *pbHandled)
    LIST_SELECT: 106,	; OnListSelect(int iItem,BOOL *pbHandled)
    LIST_HEADER_DRAWITEM: 107,	; OnListHeaderDrawItem(HDRAW hDraw, list_header_item_i* pItem, BOOL *pbHandled)
    LIST_HEADER_CLICK: 108,	; OnListHeaderClick(int iItem, BOOL *pbHandled)
    LIST_HEADER_WIDTH_CHANGE: 109,	; OnListHeaderItemWidthChange(int iItem, int nWidth BOOL *pbHandled)
    LIST_HEADER_TEMP_CREATE: 110,	; OnListHeaderTemplateCreate(list_header_item_i* pItem,BOOL *pbHandled)
    LIST_HEADER_TEMP_CREATE_END: 111,	; OnListHeaderTemplateCreateEnd(list_header_item_i* pItem,BOOL *pbHandled)
    LIST_HEADER_TEMP_DESTROY: 112,	; OnListHeaderTemplateDestroy(list_header_item_i* pItem,BOOL *pbHandled)
    LIST_HEADER_TEMP_ADJUST_COORDINATE: 113,	; typedef OnListHeaderTemplateAdjustCoordinate(list_header_item_i* pItem,BOOL *pbHandled)
    TREE_TEMP_CREATE: 121,	; OnTreeTemplateCreate(tree_item_i* pItem,int nFlag, BOOL *pbHandled)
    TREE_TEMP_CREATE_END: 122,	; OnTreeTemplateCreateEnd(tree_item_i* pItem, int nFlag, BOOL *pbHandled)
    TREE_TEMP_DESTROY: 123,	; OnTreeTemplateDestroy(tree_item_i* pItem, int nFlag, BOOL *pbHandled)
    TREE_TEMP_ADJUST_COORDINATE: 124,	; OnTreeTemplateAdjustCoordinate(tree_item_i* pItem,BOOL *pbHandled)
    TREE_DRAWITEM: 125,	; OnTreeDrawItem(HDRAW hDraw,tree_item_i* pItem,BOOL *pbHandled)
    TREE_SELECT: 126,	; OnTreeSelect(int nItemID,BOOL *pbHandled)
    TREE_EXPAND: 127,	; OnTreeExpand(int id,BOOL bExpand,BOOL *pbHandled)
    TREE_DRAG_ITEM_ING: 128,	;;  @brief 树元素,用户正在拖动项, 可对参数值修改.OnTreeDragItemIng(tree_drag_item_i* pInfo, BOOL *pbHandled)
    TREE_DRAG_ITEM: 129,	; ;  @brief 树元素,拖动项事件.OnTreeDragItem(tree_drag_item_i* pInfo, BOOL *pbHandled)
    LISTVIEW_TEMP_CREATE: 141,	; OnListViewTemplateCreate(listView_item_i* pItem,int nFlag, BOOL *pbHandled)
    LISTVIEW_TEMP_CREATE_END: 142,	; OnListViewTemplateCreateEnd(listView_item_i* pItem,int nFlag, BOOL *pbHandled)
    LISTVIEW_TEMP_DESTROY: 143,	; OnListViewTemplateDestroy(listView_item_i* pItem, int nFlag, BOOL *pbHandled)
    LISTVIEW_TEMP_ADJUST_COORDINATE: 144,	; OnListViewTemplateAdjustCoordinate(listView_item_i* pItem,BOOL *pbHandled)
    LISTVIEW_DRAWITEM: 145,	; OnListViewDrawItem(HDRAW hDraw,listView_item_i* pItem,BOOL *pbHandled)
    LISTVIEW_SELECT: 146,	; OnListViewSelect(int iGroup,int iItem,BOOL *pbHandled)
    LISTVIEW_EXPAND: 147,	; OnListViewExpand(int iGroup,BOOL bExpand,BOOL *pbHandled)
    PGRID_VALUE_CHANGE: 151,	; OnPGridValueChange(int nItemID,BOOL *pbHandled)
    PGRID_ITEM_SET: 152,	; OnPGridItemSet(int nItemID, BOOL *pbHandled)
    PGRID_ITEM_SELECT: 153,	; 项选择  OnPGridItemSelect(int nItemID, BOOL *pbHandled)
    PGRID_ITEM_ADJUST_COORDINATE: 154,	; OnPGridItemAdjustCoordinate(propertyGrid_item_i* pItem, BOOL *pbHandled)
    PGRID_ITEM_DESTROY: 155,	; OnPGridItemDestroy(int nItemID, BOOL *pbHandled)
    PGRID_ITEM_EXPAND: 156,	; OnPGridItemExpand(int nItemID, BOOL bExpand, BOOL *pbHandled)
    RICHEDIT_CHANGE: 161,	;  XRichEdit_SetText()、 XRichEdit_InsertString()不会触发此事件  OnRichEditChange(BOOL *pbHandled)
    EDIT_SET: 162,	; OnEditSet(BOOL *pbHandled)
    EDIT_DRAWROW: 181,	; 暂未使用  OnEditDrawRow(HDRAW hDraw, int iRow, BOOL *pbHandled)
    EDIT_CHANGED: 182,	; 内容被更改  OnEditChanged(int nFlag, BOOL *pbHandled)
    EDIT_POS_CHANGED: 183,	; 位置改变  OnEditPosChanged(int iPos, BOOL *pbHandled)
    EDIT_STYLE_CHANGED: 184,	; 样式改变  OnEditStyleChanged(int iStyle, BOOL *pbHandled)
    EDIT_ENTER_GET_TABALIGN: 185,	; 回车TAB对齐,返回需要TAB数量  OnEditEnterGetTabAlign(BOOL *pbHandled)
    EDITOR_MODIFY_ROWS: 186,	; 多行内容修改事件  OnEditChangeRows(int iRow, int nRows, BOOL *pbHandled)
    EDITOR_SETBREAKPOINT: 191,	; 设置断点  OnEditorSetBreakpoint(int iRow, BOOL bCheck, BOOL *pbHandled)
    EDITOR_REMOVEBREAKPOINT: 192,	; 移除断点  OnEditorRemoveBreakpoint(int iRow, BOOL *pbHandled)
    EDIT_ROW_CHANGED: 193,	; 可对断点位置修改  OnEditorBreakpointChanged(int iRow, int nChangeRows, BOOL *pbHandled)
    EDITOR_AUTOMATCH_SELECT: 194,	; OnEditorAutoMatchSelect(int iRow, int nRows, BOOL *pbHandled)
    TABBAR_SELECT: 221,	; OnTabBarSelect(int iItem, BOOL *pbHandled)
    TABBAR_DELETE: 222,	; OnTabBarDelete(int iItem, BOOL *pbHandled)
    MONTHCAL_CHANGE: 231,	; 月历 日期改变事件  OnCalendarChange(BOOL *pbHandled)
    DATETIME_CHANGE: 241,	; 日期时间元素  改变事件  OnDateTimeChange(BOOL *pbHandled)
    DATETIME_POPUP_MONTHCAL: 242,	; 日期时间元素  弹出月历事件  OnDateTimePopupMonthCal(HWINDOW hMonthCalWnd,HELE hMonthCal,BOOL *pbHandled)
    DATETIME_EXIT_MONTHCAL: 243,	; 日期时间元素  退出月历事件  OnDateTimeExitMonthCal(HWINDOW hMonthCalWnd,HELE hMonthCal,BOOL *pbHandled)
    DROPFILES: 250	; OnDropFiles(HDROP hDropInfo, BOOL *pbHandled)
  }
  ;#region Messages
  static WM_REDRAW_ELE := 0x7001	; 重绘元素 wParam:元素句柄, lParam:RECT*基于窗口坐标
  static WM_WINDPROC := 0x7002	; 注册窗口处理过程 OnWndProc(UINT message, WPARAM wParam, LPARAM lParam, BOOL *pbHandled)
  static WM_DRAW_T := 0x7003	; 窗口绘制,内部使用, wParam:0, lParam:0
  static WM_TIMER_T := 0x7004	; 内部使用, wParam:hXCGUI, lParam:ID
  static WM_XC_TIMER := 0x7005	; wParam:定时器ID, lParam:0 OnWndXCTimer(UINT nTimerID,BOOL *pbHandled)
  static WM_CLOUDUI_DOWNLOADFILE_COMPLETE := 0x7006	; 内部使用
  static WM_CLOUNDUI_OPENURL_WAIT := 0x7007	; 内部使用
  static WM_CALL_UI_THREAD := 0x7008	; 内部使用
  static WM_MENU_POPUP := 0x700b	; 菜单弹出OnWndMenuPopup(HMENUX hMenu, BOOL *pbHandled)
  static WM_MENU_POPUP_WND := 0x700c	; 菜单弹出窗口 OnWndMenuPopupWnd(HMENUX hMenu,menu_popupWnd_i *pInfo,BOOL *pbHandled)
  static WM_MENU_SELECT := 0x700d	; 菜单选择 wParam:菜单项ID, lParam:0 OnWndMenuSelect(int nID,BOOL *pbHandled)
  static WM_MENU_EXIT := 0x700e	; 菜单退出 wParam:0, lParam:0 OnWndMenuExit(BOOL *pbHandled)
  static WM_MENU_DRAW_BACKGROUND := 0x700f	; 绘制菜单背景, 启用该功能需要调用XMenu_EnableDrawBackground(). OnWndMenuDrawBackground(HDRAW hDraw,menu_drawBackground_i *pInfo,BOOL *pbHandled)
  static WM_MENU_DRAWITEM := 0x7010	; 绘制菜单项事件, 启用该功能需要调用XMenu_EnableDrawItem(). OnMenuDrawItem(HDRAW hDraw,menu_drawItem_i* pInfo,BOOL *pbHandled)
  static WM_COMBOBOX_POPUP_DROPLIST := 0x7011	; 弹出下拉组框列表,内部使用
  static WM_FLOAT_PANE := 0x7012	; 浮动窗格, 窗格从框架窗口中弹出,变成浮动窗格 OnWndFloatPane(HWINDOW hFloatWnd, HELE hPane, BOOL *pbHandled)
  static WM_PAINT_END := 0x7013	; 窗口绘制完成消息 OnWndDrawWindowEnd(HDRAW hDraw,BOOL *pbHandled)
  static WM_PAINT_DISPLAY := 0x7014	; 窗口绘制完成并且已经显示到屏幕 OnWndDrawWindowDisplay(BOOL *pbHandled)
  ;#endregion
  ;#region OBJECT_TYPE
  static OBJECT_TYPE := Map(
    -1, 'ERROR',	; /<错误类型
    0, 'NOTHING',
    1, 'WINDOW',	; /<窗口
    2, 'MODALWINDOW',	; /<模态窗口
    3, 'FRAMEWND',	; /<框架窗口
    4, 'FLOATWND',	; /<浮动窗口
    11, 'COMBOBOXWINDOW',	; comboBoxWindow_        组合框弹出下拉列表窗口
    12, 'POPUPMENUWINDOW',	; popupMenuWindow_       弹出菜单主窗口
    13, 'POPUPMENUCHILDWINDOW',	; popupMenuChildWindow_  弹出菜单子窗口
    19, 'OBJECT_UI',	; /<...
    20, 'WIDGET_UI',	; 元素
    21, 'ELE',	; /<基础元素
    53, 'ELE_LAYOUT',	; /<布局元素
    54, 'LAYOUT_STACK',	; /<流式布局
    22, 'BUTTON',	; /<按钮
    45, 'EDIT',	; /<编辑框
    46, 'EDITOR',	; /<代码编辑框
    47, 'RICHEDIT2',
    48, 'Chat',
    23, 'RICHEDIT',	; /<富文本编辑框
    24, 'COMBOBOX',	; /<下拉组合框
    25, 'SCROLLBAR',	; /<滚动条
    26, 'SCROLLVIEW',	; /<滚动视图
    27, 'LIST',	; /<列表
    28, 'LISTBOX',	; /<列表框
    29, 'LISTVIEW',	; /<列表视图,大图标
    30, 'TREE',	; /<列表树
    31, 'MENUBAR',	; /<菜单条
    32, 'SLIDERBAR',	; /<滑动条
    33, 'PROGRESSBAR',	; /<进度条
    34, 'TOOLBAR',	; /<工具条
    35, 'MONTHCAL',	; /<月历卡片
    36, 'DATETIME',	; /<日期时间
    37, 'PROPERTYGRID',	; /<属性网格
    38, 'EDIT_COLOR',	; /<颜色选择框
    39, 'EDIT_SET',	; /<设置编辑框
    40, 'TABBAR',	; /<tab条
    41, 'TEXTLINK',	; /<文本链接按钮
    42, 'PANE',	; /<窗格
    43, 'PANE_SPLIT',	; /<窗格拖动分割条
    44, 'MENUBAR_BUTTON',	; /<菜单条上的按钮
    45, 'TOOLBAR_BUTTON',	; /<工具条上按钮
    46, 'PROPERTYPAGE_LABEL',	; /<属性页标签按钮
    47, 'PIER',	; /<窗格停靠码头
    48, 'BUTTON_MENU',	; /<弹出菜单按钮
    49, 'VIRTUAL_ELE',	; /<虚拟元素
    50, 'EDIT_FILE',	; /<EditFile 文件选择编辑框
    51, 'EDIT_FOLDER',	; /<EditFolder  文件夹选择编辑框
    52, 'LIST_HEADER',	; /<列表头元素
    61, 'SHAPE',	; /<形状对象
    62, 'SHAPE_TEXT',	; /<形状对象-文本
    63, 'SHAPE_PICTURE',	; /<形状对象-图片
    64, 'SHAPE_RECT',	; /<形状对象-矩形
    65, 'SHAPE_ELLIPSE',	; /<形状对象-圆
    66, 'SHAPE_LINE',	; /<形状对象-直线
    67, 'SHAPE_GROUPBOX',	; /<形状对象-组框
    68, 'SHAPE_GIF',	; /<形状对象-GIF
    69, 'SHAPE_TABLE',	; /<形状对象-表格

    ; 其他类型
    81, 'MENU',	; /<弹出菜单
    82, 'IMAGE',	; /<图片
    83, 'HDRAW',	; /<绘图操作
    84, 'FONT',	; /<炫彩字体
    85, 'FLASH',	; /<flash
    86, 'PANE_CELL',	; /<...
    87, 'WEB',	; /<...
    88, 'IMAGE_FRAME',	; /<图片帧,指定图片的渲染属性

    101, 'LAYOUT_OBJECT',	; /<布局对象LayoutObject
    102, 'ADAPTER',	; /<...
    103, 'ADAPTER_TABLE',	; /<数据适配器AdapterTable
    104, 'ADAPTER_TREE',	; /<数据适配器AdapterTree
    105, 'ADAPTER_LISTVIEW',	; /<数据适配器AdapterListView
    106, 'ADAPTER_MAP',	; /<数据适配器AdapterMap
    116, 'BKINFOM',	; 背景管理器

    ; 无实体对象,只是用来判断布局
    111, 'LAYOUT_LISTVIEW',
    112, 'LAYOUT_LIST',
    113, 'LAYOUT_OBJECT_GROUP',
    114, 'LAYOUT_OBJECT_ITEM',
    115, 'LAYOUT_PANEL',	; 无实体对象,只是用来判断类型
    121, 'LIST_ITEM',	; 列表项模板 list_item
    122, 'LISTVIEW_GROUP',
    123, 'LISTVIEW_ITEM'
  )
  ;#endregion
  ;#region Structs
  class RECTF {
    __New(left := 0, top := 0, right := 0, bottom := 0) {
      this.__buf := Buffer(16), this.ptr := this.__buf.Ptr
      NumPut('float', left, 'float', top, 'float', right, 'float', bottom, this.ptr)
    }
    left {
      get => NumGet(this.ptr, 'float')
      set => NumPut('float', value, this.ptr)
    }
    top {
      get => NumGet(this.ptr, 4, 'float')
      set => NumPut('float', value, this.ptr, 4)
    }
    right {
      get => NumGet(this.ptr, 8, 'float')
      set => NumPut('float', value, this.ptr, 8)
    }
    bottom {
      get => NumGet(this.ptr, 12, 'float')
      set => NumPut('float', value, this.ptr, 12)
    }
  }
  class POINT {
    __New(x := 0, y := 0) {
      this.__buf := Buffer(8), this.ptr := this.__buf.Ptr
      NumPut('int', x, 'int', y, this.ptr)
    }
    x {
      get => NumGet(this.ptr, 'int')
      set => NumPut('int', value, this.ptr)
    }
    y {
      get => NumGet(this.ptr, 4, 'int')
      set => NumPut('int', value, this.ptr, 4)
    }
  }
  class POINTF {
    __New(x := 0, y := 0) {
      this.__buf := Buffer(8), this.ptr := this.__buf.Ptr
      NumPut('float', x, 'float', y, this.ptr)
    }
    x {
      get => NumGet(this.ptr, 'float')
      set => NumPut('float', value, this.ptr)
    }
    y {
      get => NumGet(this.ptr, 4, 'float')
      set => NumPut('float', value, this.ptr, 4)
    }
  }
  class BorderSize_i {
    __New(left := 0, top := 0, right := 0, bottom := 0) {
      this.__buf := Buffer(16), this.ptr := this.__buf.Ptr
      NumPut('int', left, 'int', top, 'int', right, 'int', bottom, this.ptr)
    }
    left {
      get => NumGet(this.ptr, 'int')
      set => NumPut('int', value, this.ptr)
    }
    top {
      get => NumGet(this.ptr, 4, 'int')
      set => NumPut('int', value, this.ptr, 4)
    }
    right {
      get => NumGet(this.ptr, 8, 'int')
      set => NumPut('int', value, this.ptr, 8)
    }
    bottom {
      get => NumGet(this.ptr, 12, 'int')
      set => NumPut('int', value, this.ptr, 12)
    }
  }
  class Position_i {
    __New(iRow := 0, iColumn := 0) {
      this.__buf := Buffer(8), this.ptr := this.__buf.Ptr
      NumPut('float', iRow, 'float', iColumn, this.ptr)
    }
    iRow {
      get => NumGet(this.ptr, 'float')
      set => NumPut('float', value, this.ptr)
    }
    iColumn {
      get => NumGet(this.ptr, 4, 'float')
      set => NumPut('float', value, this.ptr, 4)
    }
  }
  class listBox_item_i {
    __New() {
      this.__buf := Buffer(A_PtrSize = 8 ? 64 : 44), this.ptr := this.__buf.Ptr
    }
    index {
      get => NumGet(this.ptr, 'int')
      set => NumPut('int', value, this.ptr)
    }
    nUserData {
      get => NumGet(this.ptr, A_PtrSize, 'ptr')
      set => NumPut('ptr', value, this.ptr, A_PtrSize)
    }
    nHeight {
      get => NumGet(this.ptr, A_PtrSize * 2, 'int')
      set => NumPut('int', value, this.ptr, A_PtrSize * 2)
    }
    nSelHeight {
      get => NumGet(this.ptr, A_PtrSize * 2 + 4, 'int')
      set => NumPut('int', value, this.ptr, A_PtrSize * 2 + 4)
    }
    ; list_item_state
    nState {
      get => NumGet(this.ptr, A_PtrSize * 2 + 8, 'int')
      set => NumPut('int', value, this.ptr, A_PtrSize * 2 + 8)
    }
    rcItem => {Base: XC.BorderSize_i.Prototype, ptr: this.ptr + A_PtrSize * 2 + 12, buf: this.__buf}
    ; HXCGUI
    hLayout {
      get => NumGet(this.ptr, A_PtrSize * 3 + 24, 'int')
      set => NumPut('int', value, this.ptr, A_PtrSize * 3 + 24)
    }
    hTemp {
      get => NumGet(this.ptr, A_PtrSize * 4 + 24, 'int')
      set => NumPut('int', value, this.ptr, A_PtrSize * 4 + 24)
    }
  }
  class listBox_item_info_i {
    __New(nUserData := 0, nHeight := -1, nSelHeight := -1) {
      this.__buf := Buffer(A_PtrSize + 8), this.ptr := this.__buf.Ptr
      NumPut('ptr', nUserData, 'int', nHeight, 'int', nSelHeight, this.ptr)
    }
    nUserData {
      get => NumGet(this.ptr, 'ptr')
      set => NumPut('ptr', value, this.ptr)
    }
    nHeight {
      get => NumGet(this.ptr, A_PtrSize, 'ptr')
      set => NumPut('ptr', value, this.ptr, A_PtrSize)
    }
    nSelHeight {
      get => NumGet(this.ptr, A_PtrSize + 4, 'ptr')
      set => NumPut('ptr', value, this.ptr, A_PtrSize + 4)
    }
  }
  class listView_item_id_i {
    __New(iGroup := 0, iItem := 0) {
      this.__buf := Buffer(8), this.ptr := this.__buf.Ptr
      NumPut('int', iGroup, 'int', iItem, this.ptr)
    }
    iGroup {
      get => NumGet(this.ptr, 'int')
      set => NumPut('int', value, this.ptr)
    }
    iItem {
      get => NumGet(this.ptr, 4, 'ptr')
      set => NumPut('ptr', value, this.ptr, 4)
    }
  }
  class list_item_i {
    __New() {
      this.__buf := Buffer(A_PtrSize = 8 ? 64 : 48), this.ptr := this.__buf.Ptr
    }
    index {
      get => NumGet(this.ptr, 'int')
      set => NumPut('int', value, this.ptr)
    }
    iSubItem {
      get => NumGet(this.ptr, 4, 'int')
      set => NumPut('int', value, this.ptr, 4)
    }
    nUserData {
      get => NumGet(this.ptr, 8, 'ptr')
      set => NumPut('ptr', value, this.ptr, 8)
    }
    nHeight {
      get => NumGet(this.ptr, A_PtrSize + 8, 'int')
      set => NumPut('int', value, this.ptr, A_PtrSize + 8)
    }
    nSelHeight {
      get => NumGet(this.ptr, A_PtrSize + 12, 'int')
      set => NumPut('int', value, this.ptr, A_PtrSize + 12)
    }
    ; list_item_state
    nState {
      get => NumGet(this.ptr, A_PtrSize + 16, 'int')
      set => NumPut('int', value, this.ptr, A_PtrSize + 16)
    }
    rcItem => {Base: XC.BorderSize_i.Prototype, ptr: this.ptr + A_PtrSize + 20, buf: this.__buf}
    ; HXCGUI
    hLayout {
      get => NumGet(this.ptr, A_PtrSize * 2 + 32, 'int')
      set => NumPut('int', value, this.ptr, A_PtrSize * 2 + 32)
    }
    hTemp {
      get => NumGet(this.ptr, A_PtrSize * 3 + 32, 'int')
      set => NumPut('int', value, this.ptr, A_PtrSize * 3 + 32)
    }
  }
  class list_header_item_i {
    __New() {
      this.__buf := Buffer(A_PtrSize = 8 ? 64 : 48), this.ptr := this.__buf.Ptr
    }
    index {
      get => NumGet(this.ptr, 0, 'int')
      set => NumPut('int', value, this.ptr, 0)
    }
    nUserData {
      get => NumGet(this.ptr, A_PtrSize = 8 ? 8 : 4, 'ptr')
      set => NumPut('ptr', value, this.ptr, A_PtrSize = 8 ? 8 : 4)
    }
    bSort {
      get => NumGet(this.ptr, A_PtrSize = 8 ? 16 : 8, 'Int')
      set => NumPut('Int', value, this.ptr, A_PtrSize = 8 ? 16 : 8)
    }
    nSortType {
      get => NumGet(this.ptr, A_PtrSize = 8 ? 20 : 12, 'int')
      set => NumPut('int', value, this.ptr, A_PtrSize = 8 ? 20 : 12)
    }
    iColumnAdapter {
      get => NumGet(this.ptr, A_PtrSize = 8 ? 24 : 16, 'int')
      set => NumPut('int', value, this.ptr, A_PtrSize = 8 ? 24 : 16)
    }
    ; common_state3
    nState {
      get => NumGet(this.ptr, A_PtrSize = 8 ? 28 : 20, 'int')
      set => NumPut('int', value, this.ptr, A_PtrSize = 8 ? 28 : 20)
    }
    rcItem => {Base: XC.BorderSize_i.Prototype, ptr: this.ptr + (A_PtrSize = 8 ? 32 : 24), __buf: this.__buf}
    hLayout {
      get => NumGet(this.ptr, A_PtrSize = 8 ? 48 : 40, 'ptr')
      set => NumPut('ptr', value, this.ptr, A_PtrSize = 8 ? 48 : 40)
    }
    hTemp {
      get => NumGet(this.ptr, A_PtrSize = 8 ? 56 : 44, 'ptr')
      set => NumPut('ptr', value, this.ptr, A_PtrSize = 8 ? 56 : 44)
    }
  }
  class tree_item_i {
    __New() {
      this.__buf := Buffer(A_PtrSize = 8 ? 64 : 52), this.ptr := this.__buf.Ptr
    }
    nID {
      get => NumGet(this.ptr, 0, 'int')
      set => NumPut('int', value, this.ptr, 0)
    }
    nDepth {
      get => NumGet(this.ptr, 4, 'int')
      set => NumPut('int', value, this.ptr, 4)
    }
    nHeight {
      get => NumGet(this.ptr, 8, 'int')
      set => NumPut('int', value, this.ptr, 8)
    }
    nSelHeight {
      get => NumGet(this.ptr, 12, 'int')
      set => NumPut('int', value, this.ptr, 12)
    }
    nUserData {
      get => NumGet(this.ptr, 16, 'ptr')
      set => NumPut('ptr', value, this.ptr, 16)
    }
    bExpand {
      get => NumGet(this.ptr, A_PtrSize = 8 ? 24 : 20, 'Int')
      set => NumPut('Int', value, this.ptr, A_PtrSize = 8 ? 24 : 20)
    }
    ; tree_item_state
    nState {
      get => NumGet(this.ptr, A_PtrSize = 8 ? 28 : 24, 'int')
      set => NumPut('int', value, this.ptr, A_PtrSize = 8 ? 28 : 24)
    }
    rcItem => {Base: XC.BorderSize_i.Prototype, ptr: this.ptr + (A_PtrSize = 8 ? 32 : 28), __buf: this.__buf}
    hLayout {
      get => NumGet(this.ptr, A_PtrSize = 8 ? 48 : 44, 'Ptr')
      set => NumPut('Ptr', value, this.ptr, A_PtrSize = 8 ? 48 : 44)
    }
    hTemp {
      get => NumGet(this.ptr, A_PtrSize = 8 ? 56 : 48, 'Ptr')
      set => NumPut('Ptr', value, this.ptr, A_PtrSize = 8 ? 56 : 48)
    }
  }
  class listView_item_i {
    __New() {
      this.__buf := Buffer(A_PtrSize = 8 ? 56 : 40), this.ptr := this.__buf.Ptr
    }
    iGroup {
      get => NumGet(this.ptr, 0, 'int')
      set => NumPut('int', value, this.ptr, 0)
    }
    iItem {
      get => NumGet(this.ptr, 4, 'int')
      set => NumPut('int', value, this.ptr, 4)
    }
    nUserData {
      get => NumGet(this.ptr, 8, 'ptr')
      set => NumPut('ptr', value, this.ptr, 8)
    }
    ; list_item_state
    nState {
      get => NumGet(this.ptr, A_PtrSize = 8 ? 16 : 12, 'int')
      set => NumPut('int', value, this.ptr, A_PtrSize = 8 ? 16 : 12)
    }
    rcItem => {Base: XC.BorderSize_i.Prototype, ptr: this.ptr + (A_PtrSize = 8 ? 20 : 16), __buf: this.__buf}
    hLayout {
      get => NumGet(this.ptr, A_PtrSize = 8 ? 40 : 32, 'Ptr')
      set => NumPut('Ptr', value, this.ptr, A_PtrSize = 8 ? 40 : 32)
    }
    hTemp {
      get => NumGet(this.ptr, A_PtrSize = 8 ? 48 : 36, 'Ptr')
      set => NumPut('Ptr', value, this.ptr, A_PtrSize = 8 ? 48 : 36)
    }
  }
  class layout_info_i {
    __New() {
      this.__buf := Buffer(20), this.ptr := this.__buf.Ptr
    }
    ; layout_size_type
    widthType {
      get => NumGet(this.ptr, 0, 'int')
      set => NumPut('int', value, this.ptr, 0)
    }
    heightType {
      get => NumGet(this.ptr, 4, 'int')
      set => NumPut('int', value, this.ptr, 4)
    }
    width {
      get => NumGet(this.ptr, 8, 'short')
      set => NumPut('short', value, this.ptr, 8)
    }
    height {
      get => NumGet(this.ptr, 10, 'short')
      set => NumPut('short', value, this.ptr, 10)
    }
    ; layout_float_type
    float_ {
      get => NumGet(this.ptr, 12, 'int')
      set => NumPut('int', value, this.ptr, 12)
    }
    bWrap {
      get => NumGet(this.ptr, 16, 'Int')
      set => NumPut('Int', value, this.ptr, 16)
    }
  }
  class menu_popupWnd_i {
    __New() {
      this.__buf := Buffer(A_PtrSize = 8 ? 16 : 8), this.ptr := this.__buf.Ptr
    }
    hWindow {
      get => NumGet(this.ptr, 0, 'ptr')
      set => NumPut('ptr', value, this.ptr, 0)
    }
    nParentID {
      get => NumGet(this.ptr, A_PtrSize = 8 ? 8 : 4, 'int')
      set => NumPut('int', value, this.ptr, A_PtrSize = 8 ? 8 : 4)
    }
  }
  class menu_drawBackground_i {
    __New() {
      this.__buf := Buffer(A_PtrSize = 8 ? 24 : 12), this.ptr := this.__buf.Ptr
    }
    hMenu {
      get => NumGet(this.ptr, 0, 'ptr')
      set => NumPut('ptr', value, this.ptr, 0)
    }
    hWindow {
      get => NumGet(this.ptr, A_PtrSize = 8 ? 8 : 4, 'ptr')
      set => NumPut('ptr', value, this.ptr, A_PtrSize = 8 ? 8 : 4)
    }
    nParentID {
      get => NumGet(this.ptr, A_PtrSize = 8 ? 16 : 8, 'int')
      set => NumPut('int', value, this.ptr, A_PtrSize = 8 ? 16 : 8)
    }
  }
  class menu_drawItem_i {
    __New() {
      this.__buf := Buffer(A_PtrSize = 8 ? 56 : 40), this.ptr := this.__buf.Ptr
    }
    hMenu {
      get => NumGet(this.ptr, 0, 'ptr')
      set => NumPut('ptr', value, this.ptr, 0)
    }
    hWindow {
      get => NumGet(this.ptr, A_PtrSize = 8 ? 8 : 4, 'ptr')
      set => NumPut('ptr', value, this.ptr, A_PtrSize = 8 ? 8 : 4)
    }
    nID {
      get => NumGet(this.ptr, A_PtrSize = 8 ? 16 : 8, 'int')
      set => NumPut('int', value, this.ptr, A_PtrSize = 8 ? 16 : 8)
    }
    nState {
      get => NumGet(this.ptr, A_PtrSize = 8 ? 20 : 12, 'int')
      set => NumPut('int', value, this.ptr, A_PtrSize = 8 ? 20 : 12)
    }
    rcItem => {Base: XC.BorderSize_i.Prototype, ptr: this.ptr + (A_PtrSize = 8 ? 24 : 16), __buf: this.__buf}
    hIcon {
      get => NumGet(this.ptr, A_PtrSize = 8 ? 40 : 32, 'ptr')
      set => NumPut('ptr', value, this.ptr, A_PtrSize = 8 ? 40 : 32)
    }
    pText {
      get => NumGet(this.ptr, A_PtrSize = 8 ? 48 : 36, 'ptr')
      set => NumPut('ptr', value, this.ptr, A_PtrSize = 8 ? 48 : 36)
    }
  }
  class tree_drag_item_i {
    __New() {
      this.__buf := Buffer(12), this.ptr := this.__buf.Ptr
    }
    nDragItem {
      get => NumGet(this.ptr, 0, 'int')
      set => NumPut('int', value, this.ptr, 0)
    }
    nDestItem {
      get => NumGet(this.ptr, 4, 'int')
      set => NumPut('int', value, this.ptr, 4)
    }
    nType {
      get => NumGet(this.ptr, 8, 'int')
      set => NumPut('int', value, this.ptr, 8)
    }
  }
  class xc_font_info_i {
    __New() {
      this.__buf := Buffer(72), this.ptr := this.__buf.Ptr
    }
    nSize {
      get => NumGet(this.ptr, 0, 'int')
      set => NumPut('int', value, this.ptr, 0)
    }
    nStyle {
      get => NumGet(this.ptr, 4, 'int')
      set => NumPut('int', value, this.ptr, 4)
    }
    name {
      get => NumGet(this.ptr, 8, 'ushort')
      set => NumPut('ushort', value, this.ptr, 8)
    }
  }
  class propertyGrid_item_i {
    __New() {
      this.__buf := Buffer(A_PtrSize = 8 ? 72 : 60), this.ptr := this.__buf.Ptr
    }
    ; propertyGrid_item_type
    nType {
      get => NumGet(this.ptr, 0, 'int')
      set => NumPut('int', value, this.ptr, 0)
    }
    nID {
      get => NumGet(this.ptr, 4, 'int')
      set => NumPut('int', value, this.ptr, 4)
    }
    nDepth {
      get => NumGet(this.ptr, 8, 'int')
      set => NumPut('int', value, this.ptr, 8)
    }
    nUserData {
      get => NumGet(this.ptr, A_PtrSize = 8 ? 16 : 12, 'ptr')
      set => NumPut('ptr', value, this.ptr, A_PtrSize = 8 ? 16 : 12)
    }
    nNameColWidth {
      get => NumGet(this.ptr, A_PtrSize = 8 ? 24 : 16, 'int')
      set => NumPut('int', value, this.ptr, A_PtrSize = 8 ? 24 : 16)
    }
    rcItem => {Base: XC.BorderSize_i.Prototype, ptr: this.ptr + (A_PtrSize = 8 ? 28 : 20), __buf: this.__buf}
    rcExpand => {Base: XC.BorderSize_i.Prototype, ptr: this.ptr + (A_PtrSize = 8 ? 44 : 36), __buf: this.__buf}
    bExpand {
      get => NumGet(this.ptr, A_PtrSize = 8 ? 60 : 52, 'int')
      set => NumPut('int', value, this.ptr, A_PtrSize = 8 ? 60 : 52)
    }
    bShow {
      get => NumGet(this.ptr, A_PtrSize = 8 ? 64 : 56, 'int')
      set => NumPut('int', value, this.ptr, A_PtrSize = 8 ? 64 : 56)
    }
  }
  class edit_style_info {
    __New() {
      this.__buf := Buffer(A_PtrSize = 8 ? 24 : 20), this.ptr := this.__buf.Ptr
    }
    ; edit_style_type
    type {
      get => NumGet(this.ptr, 0, 'int')
      set => NumPut('int', value, this.ptr, 0)
    }
    nRef {
      get => NumGet(this.ptr, 4, 'ushort')
      set => NumPut('ushort', value, this.ptr, 4)
    }
    hFont_image_obj {
      get => NumGet(this.ptr, 8, 'ptr')
      set => NumPut('ptr', value, this.ptr, 8)
    }
    color {
      get => NumGet(this.ptr, A_PtrSize = 8 ? 16 : 12, 'uint')
      set => NumPut('uint', value, this.ptr, A_PtrSize = 8 ? 16 : 12)
    }
    bColor {
      get => NumGet(this.ptr, A_PtrSize = 8 ? 20 : 16, 'int')
      set => NumPut('int', value, this.ptr, A_PtrSize = 8 ? 20 : 16)
    }
  }
  class edit_data_copy_style {
    __New() {
      this.__buf := Buffer(A_PtrSize = 8 ? 16 : 12), this.ptr := this.__buf.Ptr
    }
    hFont_image_obj {
      get => NumGet(this.ptr, 0, 'ptr')
      set => NumPut('ptr', value, this.ptr, 0)
    }
    color {
      get => NumGet(this.ptr, A_PtrSize = 8 ? 8 : 4, 'uint')
      set => NumPut('uint', value, this.ptr, A_PtrSize = 8 ? 8 : 4)
    }
    bColor {
      get => NumGet(this.ptr, A_PtrSize = 8 ? 12 : 8, 'int')
      set => NumPut('int', value, this.ptr, A_PtrSize = 8 ? 12 : 8)
    }
  }
  class edit_data_copy {
    __New() {
      this.__buf := Buffer(A_PtrSize = 8 ? 24 : 16), this.ptr := this.__buf.Ptr
    }
    nCount {
      get => NumGet(this.ptr, 0, 'int')
      set => NumPut('int', value, this.ptr, 0)
    }
    nStyleCount {
      get => NumGet(this.ptr, 4, 'int')
      set => NumPut('int', value, this.ptr, 4)
    }
    ; edit_data_copy_style*
    pStyle {
      get => NumGet(this.ptr, 8, 'ptr')
      set => NumPut('ptr', value, this.ptr, 8)
    }
    ; uint*
    pData {
      get => NumGet(this.ptr, A_PtrSize = 8 ? 16 : 12, 'ptr')
      set => NumPut('ptr', value, this.ptr, A_PtrSize = 8 ? 16 : 12)
    }
  }
  class editor_color {
    __New() {
      this.__buf := Buffer(32), this.ptr := this.__buf.Ptr
    }
    clrMargin1 {
      get => NumGet(this.ptr, 0, 'uint')
      set => NumPut('uint', value, this.ptr, 0)
    }
    clrMargin2 {
      get => NumGet(this.ptr, 4, 'uint')
      set => NumPut('uint', value, this.ptr, 4)
    }
    clrMarginText {
      get => NumGet(this.ptr, 8, 'uint')
      set => NumPut('uint', value, this.ptr, 8)
    }
    clrBreakpoint {
      get => NumGet(this.ptr, 12, 'uint')
      set => NumPut('uint', value, this.ptr, 12)
    }
    clrBreakpointArrow {
      get => NumGet(this.ptr, 16, 'uint')
      set => NumPut('uint', value, this.ptr, 16)
    }
    clrRun {
      get => NumGet(this.ptr, 20, 'uint')
      set => NumPut('uint', value, this.ptr, 20)
    }
    clrCurRow {
      get => NumGet(this.ptr, 24, 'uint')
      set => NumPut('uint', value, this.ptr, 24)
    }
    clrMatch {
      get => NumGet(this.ptr, 28, 'uint')
      set => NumPut('uint', value, this.ptr, 28)
    }
  }
  class monthCal_item_i {
    __New() {
      this.__buf := Buffer(28), this.ptr := this.__buf.Ptr
    }
    nDay {
      get => NumGet(this.ptr, 0, 'int')
      set => NumPut('int', value, this.ptr, 0)
    }
    nType {	; 1上月,2当月,3下月
      get => NumGet(this.ptr, 4, 'int')
      set => NumPut('int', value, this.ptr, 4)
    }
    ; monthCal_state_flag
    nState {
      get => NumGet(this.ptr, 8, 'int')
      set => NumPut('int', value, this.ptr, 8)
    }
    rcItem => {Base: XC.BorderSize_i.Prototype, ptr: this.ptr + 12, __buf: this.__buf}
  }
  ;#endregion
  static InitXCGUI(pText := 0) => DllCall('xcgui\XInitXCGUI', 'ptr', pText, 'int')
  static RunXCGUI() => DllCall('xcgui\XRunXCGUI')
  static ExitXCGUI() => DllCall('xcgui\XExitXCGUI')
  static MessageBox(hWindow, Text, Caption, nFlags) => DllCall('xcgui\XC_MessageBox', 'ptr', hWindow, 'wstr', Text, 'wstr', Caption, 'int', nFlags, 'int')
  static SendMessage(hWindow, msg, wParam, lParam) => DllCall('xcgui\XC_SendMessage', 'ptr', hWindow, 'uint', msg, 'uptr', wParam, 'ptr', lParam, 'ptr')
  static PostMessage(hWindow, msg, wParam, lParam) => DllCall('xcgui\XC_PostMessage', 'ptr', hWindow, 'uint', msg, 'uptr', wParam, 'ptr', lParam, 'int')
  static CallUiThread(pCall, data) => DllCall('xcgui\XC_CallUiThread', 'funCallUiThread', pCall, 'int', data, 'int')
  static DebugToFileInfo(Info) => DllCall('xcgui\XC_DebugToFileInfo', 'astr', Info)
  static IsHELE(hEle) => DllCall('xcgui\XC_IsHELE', 'ptr', hEle, 'int')
  static IsHWINDOW(hWindow) => DllCall('xcgui\XC_IsHWINDOW', 'ptr', hWindow, 'int')
  static IsShape(hShape) => DllCall('xcgui\XC_IsShape', 'ptr', hShape, 'int')
  static IsHXCGUI(hXCGUI, nType) => DllCall('xcgui\XC_IsHXCGUI', 'ptr', hXCGUI, 'int', nType, 'int')
  static hWindowFromHWnd(hWnd) => DllCall('xcgui\XC_hWindowFromHWnd', 'ptr', hWnd, 'ptr')
  static SetActivateTopWindow() => DllCall('xcgui\XC_SetActivateTopWindow', , 'int')
  static SetProperty(hXCGUI, Name, Value) => DllCall('xcgui\XC_SetProperty', 'ptr', hXCGUI, 'wstr', Name, 'wstr', Value, 'int')
  static GetProperty(hXCGUI, Name) => DllCall('xcgui\XC_GetProperty', 'ptr', hXCGUI, 'wstr', Name, 'wstr')
  static RegisterWindowClassName(ClassName) => DllCall('xcgui\XC_RegisterWindowClassName', 'wstr', ClassName, 'int')
  static IsSViewExtend(hEle) => DllCall('xcgui\XC_IsSViewExtend', 'ptr', hEle, 'int')
  static GetObjectType(hXCGUI) => DllCall('xcgui\XC_GetObjectType', 'ptr', hXCGUI, 'int')
  static GetObjectByID(hWindow, nID) => DllCall('xcgui\XC_GetObjectByID', 'ptr', hWindow, 'int', nID, 'ptr')
  static GetObjectByIDName(hWindow, Name) => DllCall('xcgui\XC_GetObjectByIDName', 'ptr', hWindow, 'wstr', Name, 'ptr')
  static GetObjectByUID(nUID) => DllCall('xcgui\XC_GetObjectByUID', 'int', nUID, 'ptr')
  static GetObjectByUIDName(Name) => DllCall('xcgui\XC_GetObjectByUIDName', 'wstr', Name, 'ptr')
  static GetObjectByName(Name) => DllCall('xcgui\XC_GetObjectByName', 'wstr', Name, 'ptr')
  static SetPaintFrequency(nMilliseconds) => DllCall('xcgui\XC_SetPaintFrequency', 'int', nMilliseconds)
  static SetTextRenderingHint(nType) => DllCall('xcgui\XC_SetTextRenderingHint', 'int', nType)
  static EnableGdiDrawText(bEnable) => DllCall('xcgui\XC_EnableGdiDrawText', 'int', bEnable)
  static RectInRect(pRect1, pRect2) => DllCall('xcgui\XC_RectInRect', 'ptr', pRect1, 'ptr', pRect2, 'int')
  static CombineRect(pDest, pSrc1, pSrc2) => DllCall('xcgui\XC_CombineRect', 'ptr', pDest, 'ptr', pSrc1, 'ptr', pSrc2)
  static ShowLayoutFrame(bShow) => DllCall('xcgui\XC_ShowLayoutFrame', 'int', bShow)
  static EnableDebugFile(bEnable) => DllCall('xcgui\XC_EnableDebugFile', 'int', bEnable)
  static EnableResMonitor(bEnable) => DllCall('xcgui\XC_EnableResMonitor', 'int', bEnable)
  static SetLayoutFrameColor(color) => DllCall('xcgui\XC_SetLayoutFrameColor', 'uint', color)
  static EnableErrorMessageBox(bEnabel) => DllCall('xcgui\XC_EnableErrorMessageBox', 'int', bEnabel)
  static EnableAutoExitApp(bEnabel) => DllCall('xcgui\XC_EnableAutoExitApp', 'int', bEnabel)
  static GetTextSize(String, length, hFontX, &OutSize) => DllCall('xcgui\XC_GetTextSize', 'wstr', String, 'int', length, 'ptr', hFontX, 'ptr', OutSize := Buffer(8))
  static GetTextShowSize(String, length, hFontX, &OutSize) => DllCall('xcgui\XC_GetTextShowSize', 'wstr', String, 'int', length, 'ptr', hFontX, 'ptr', OutSize := Buffer(8))
  static GetTextShowSizeEx(String, length, hFontX, nTextAlign, &OutSize) => DllCall('xcgui\XC_GetTextShowSizeEx', 'wstr', String, 'int', length, 'ptr', hFontX, 'int', nTextAlign, 'ptr', OutSize := Buffer(8))
  static GetTextShowRect(String, length, hFontX, width, &OutSize) => DllCall('xcgui\XC_GetTextShowRect', 'wstr', String, 'int', length, 'ptr', hFontX, 'int', width, 'ptr', OutSize := Buffer(8))
  static GetDefaultFont() => DllCall('xcgui\XC_GetDefaultFont', 'ptr')
  static SetDefaultFont(hFontX) => DllCall('xcgui\XC_SetDefaultFont', 'ptr', hFontX)
  static AddFileSearchPath(Path) => DllCall('xcgui\XC_AddFileSearchPath', 'wstr', Path)
  static InitFont(pFont, Name, size, bBold := false, bItalic := false, bUnderline := false, bStrikeOut := false) => DllCall('xcgui\XC_InitFont', 'ptr', pFont, 'wstr', Name, 'int', size, 'int', bBold, 'int', bItalic, 'int', bUnderline, 'int', bStrikeOut)
  static Malloc(size) => DllCall('xcgui\XC_Malloc', 'int', size, 'ptr')
  static Free(p) => DllCall('xcgui\XC_Free', 'ptr', p)
  static Alert(Text, Title) => DllCall('xcgui\XC_Alert', 'wstr', Text, 'wstr', Title)
  static Sys_ShellExecute(hwnd, Operation, File, Parameters, Directory, nShowCmd) => DllCall('xcgui\XC_Sys_ShellExecute', 'ptr', hwnd, 'wstr', Operation, 'wstr', File, 'wstr', Parameters, 'wstr', Directory, 'int', nShowCmd, 'ptr')
  static LoadLibrary(FileName) => DllCall('xcgui\XC_LoadLibrary', 'wstr', FileName, 'ptr')
  static GetProcAddress(hModule, ProcName) => DllCall('xcgui\XC_GetProcAddress', 'ptr', hModule, 'astr', ProcName, 'ptr')
  static FreeLibrary(hModule) => DllCall('xcgui\XC_FreeLibrary', 'ptr', hModule, 'int')
  static LoadDll(DllFileName) => DllCall('xcgui\XC_LoadDll', 'wstr', DllFileName, 'ptr')
  static LoadLayout(FileName, hParent := 0) => DllCall('xcgui\XC_LoadLayout', 'wstr', FileName, 'ptr', hParent, 'ptr')
  static LoadLayoutZip(ZipFileName, FileName, pPassword := 0, hParent := 0) => DllCall('xcgui\XC_LoadLayoutZip', 'wstr', ZipFileName, 'wstr', FileName, 'ptr', pPassword, 'ptr', hParent, 'ptr')
  static LoadLayoutZipMem(data, length, FileName, pPassword := 0, hParent := 0) => DllCall('xcgui\XC_LoadLayoutZipMem', 'ptr', data, 'int', length, 'wstr', FileName, 'ptr', pPassword, 'ptr', hParent, 'ptr')
  static LoadLayoutFromString(StringXML, hParent := 0) => DllCall('xcgui\XC_LoadLayoutFromString', 'astr', StringXML, 'ptr', hParent, 'ptr')
  static LoadLayoutFromStringUtf8(pStringXML, hParent := 0) => DllCall('xcgui\XC_LoadLayoutFromStringUtf8', 'ptr', pStringXML, 'ptr', hParent, 'ptr')
  static LoadStyle(FileName) => DllCall('xcgui\XC_LoadStyle', 'wstr', FileName, 'int')
  static LoadStyleZip(ZipFile, FileName, pPassword := 0) => DllCall('xcgui\XC_LoadStyleZip', 'wstr', ZipFile, 'wstr', FileName, 'ptr', pPassword, 'int')
  static LoadStyleZipMem(data, length, FileName, pPassword := 0) => DllCall('xcgui\XC_LoadStyleZipMem', 'ptr', data, 'int', length, 'wstr', FileName, 'ptr', pPassword, 'int')
  static LoadResource(FileName) => DllCall('xcgui\XC_LoadResource', 'wstr', FileName, 'int')
  static LoadResourceZip(ZipFileName, FileName, pPassword := 0) => DllCall('xcgui\XC_LoadResourceZip', 'wstr', ZipFileName, 'wstr', FileName, 'ptr', pPassword, 'int')
  static LoadResourceZipMem(data, length, FileName, pPassword := 0) => DllCall('xcgui\XC_LoadResourceZipMem', 'ptr', data, 'int', length, 'wstr', FileName, 'ptr', pPassword, 'int')
  static LoadResourceFromString(StringXML, FileName) => DllCall('xcgui\XC_LoadResourceFromString', 'astr', StringXML, 'wstr', FileName, 'int')
  static LoadResourceFromStringUtf8(pStringXML, pFileName) => DllCall('xcgui\XC_LoadResourceFromStringUtf8', 'ptr', pStringXML, 'ptr', pFileName, 'int')
  static PostQuitMessage(nExitCode) => DllCall('xcgui\XC_PostQuitMessage', 'int', nExitCode)
}
class CXBase {
  ptr := 0
  GetType() => XC.OBJECT_TYPE[DllCall('xcgui\XObj_GetType', 'ptr', this, 'int')]
  GetTypeBase() => XC.OBJECT_TYPE[DllCall('xcgui\XObj_GetTypeBase', 'ptr', this, 'int')]
  GetTypeEx() => DllCall('xcgui\XObj_GetTypeEx', 'ptr', this, 'int')
}
class CXObjectUI extends CXBase {
  SetStyle(nStyle) => DllCall('xcgui\XUI_SetStyle', 'ptr', this, 'int', nStyle)
  GetStyle() => DllCall('xcgui\XUI_GetStyle', 'ptr', this, 'int')
}
class CXWidgetUI extends CXObjectUI {
  IsShow() => DllCall('xcgui\XWidget_IsShow', 'ptr', this, 'int')
  Show(bShow) => DllCall('xcgui\XWidget_Show', 'ptr', this, 'int', bShow)
  GetParentEle() => DllCall('xcgui\XWidget_GetParentEle', 'ptr', this, 'ptr')
  GetParent() => DllCall('xcgui\XWidget_GetParent', 'ptr', this, 'ptr')
  GetHWND() => DllCall('xcgui\XWidget_GetHWND', 'ptr', this, 'ptr')
  GetHWINDOW() => DllCall('xcgui\XWidget_GetHWINDOW', 'ptr', this, 'ptr')
}
class CXWindow extends CXWidgetUI {
  static Create(x, y, cx, cy, Title, hWndParent := 0, XCStyle := 0x2f) {
    if hWindow := DllCall('xcgui\XWnd_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'wstr', Title, 'ptr', hWndParent, 'int', XCStyle)
      return {Base: CXWindow.Prototype, ptr: hWindow}
  }
  static CreateEx(dwExStyle, ClassName, WindowName, dwStyle, x, y, cx, cy, hWndParent := 0, XCStyle := 0x2f) {
    if hWindow := DllCall('xcgui\XWnd_CreateEx', 'uint', dwExStyle, 'wstr', ClassName, 'wstr', WindowName, 'uint', dwStyle, 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hWndParent, 'int', XCStyle, 'ptr')
      return {Base: CXWindow.Prototype, ptr: hWindow}
  }
  __New(x, y, cx, cy, Title, hWndParent := 0, XCStyle := 0x2f) {
    if !hWindow := DllCall('xcgui\XWnd_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'wstr', Title, 'ptr', hWndParent, 'int', XCStyle, 'ptr')
      throw
    this.ptr := hWindow
  }
  RegEventC(nEvent, pFun) => DllCall('xcgui\XWnd_RegEventC', 'ptr', this, 'int', nEvent, 'ptr', pFun, 'int')
  RegEventC1(nEvent, pFun) => DllCall('xcgui\XWnd_RegEventC1', 'ptr', this, 'int', nEvent, 'ptr', pFun, 'int')
  RemoveEventC(nEvent, pFun) => DllCall('xcgui\XWnd_RemoveEventC', 'ptr', this, 'int', nEvent, 'ptr', pFun, 'int')
  AddChild(hChild) => DllCall('xcgui\XWnd_AddChild', 'ptr', this, 'ptr', hChild, 'int')
  InsertChild(hChild, index) => DllCall('xcgui\XWnd_InsertChild', 'ptr', this, 'ptr', hChild, 'int', index, 'int')
  RedrawWnd(bImmediate := false) => DllCall('xcgui\XWnd_RedrawWnd', 'ptr', this, 'int', bImmediate)
  RedrawWndRect(pRect, bImmediate := false) => DllCall('xcgui\XWnd_RedrawWndRect', 'ptr', this, 'ptr', pRect, 'int', bImmediate)
  SetFocusEle(hFocusEle) => DllCall('xcgui\XWnd_SetFocusEle', 'ptr', this, 'ptr', hFocusEle)
  GetFocusEle() => DllCall('xcgui\XWnd_GetFocusEle', 'ptr', this, 'ptr')
  GetStayHELE() => DllCall('xcgui\XWnd_GetStayHELE', 'ptr', this, 'ptr')
  DrawWindow(hDraw) => DllCall('xcgui\XWnd_DrawWindow', 'ptr', this, 'ptr', hDraw)
  Center() => DllCall('xcgui\XWnd_Center', 'ptr', this)
  CenterEx(width, height) => DllCall('xcgui\XWnd_CenterEx', 'ptr', this, 'int', width, 'int', height)
  SetCursor(hCursor) => DllCall('xcgui\XWnd_SetCursor', 'ptr', this, 'ptr', hCursor)
  GetCursor() => DllCall('xcgui\XWnd_GetCursor', 'ptr', this, 'ptr')
  GetHWND() => DllCall('xcgui\XWnd_GetHWND', 'ptr', this, 'ptr')
  EnableDragBorder(bEnable) => DllCall('xcgui\XWnd_EnableDragBorder', 'ptr', this, 'int', bEnable)
  EnableDragWindow(bEnable) => DllCall('xcgui\XWnd_EnableDragWindow', 'ptr', this, 'int', bEnable)
  EnableDragCaption(bEnable) => DllCall('xcgui\XWnd_EnableDragCaption', 'ptr', this, 'int', bEnable)
  EnableDrawBk(bEnable) => DllCall('xcgui\XWnd_EnableDrawBk', 'ptr', this, 'int', bEnable)
  EnableAutoFocus(bEnable) => DllCall('xcgui\XWnd_EnableAutoFocus', 'ptr', this, 'int', bEnable)
  EnableMaxWindow(bEnable) => DllCall('xcgui\XWnd_EnableMaxWindow', 'ptr', this, 'int', bEnable)
  EnablemLimitWindowSize(bEnable) => DllCall('xcgui\XWnd_EnablemLimitWindowSize', 'ptr', this, 'int', bEnable)
  EnableLayout(bEnable) => DllCall('xcgui\XWnd_EnableLayout', 'ptr', this, 'int', bEnable)
  ShowLayoutFrame(bEnable) => DllCall('xcgui\XWnd_ShowLayoutFrame', 'ptr', this, 'int', bEnable)
  IsEnableLayout() => DllCall('xcgui\XWnd_IsEnableLayout', 'ptr', this, 'int')
  IsMaxWindow() => DllCall('xcgui\XWnd_IsMaxWindow', 'ptr', this, 'int')
  SetCaptureEle(hEle) => DllCall('xcgui\XWnd_SetCaptureEle', 'ptr', this, 'ptr', hEle)
  GetCaptureEle() => DllCall('xcgui\XWnd_GetCaptureEle', 'ptr', this, 'ptr')
  GetDrawRect(pRcPaint) => DllCall('xcgui\XWnd_GetDrawRect', 'ptr', this, 'ptr', pRcPaint)
  ShowWindow(nCmdShow) => DllCall('xcgui\XWnd_ShowWindow', 'ptr', this, 'int', nCmdShow, 'int')
  BindLayoutEle(nPosition, hEle) => DllCall('xcgui\XWnd_BindLayoutEle', 'ptr', this, 'int', nPosition, 'ptr', hEle, 'int')
  GetLayoutEle(nPosition) => DllCall('xcgui\XWnd_GetLayoutEle', 'ptr', this, 'int', nPosition, 'ptr')
  SetCursorSys(hCursor) => DllCall('xcgui\XWnd_SetCursorSys', 'ptr', this, 'ptr', hCursor, 'ptr')
  SetFont(hFontx) => DllCall('xcgui\XWnd_SetFont', 'ptr', this, 'ptr', hFontx)
  SetTextColor(color, alpha) => DllCall('xcgui\XWnd_SetTextColor', 'ptr', this, 'uint', color, 'uchar', alpha)
  GetTextColor() => DllCall('xcgui\XWnd_GetTextColor', 'ptr', this, 'uint')
  GetTextColorEx() => DllCall('xcgui\XWnd_GetTextColorEx', 'ptr', this, 'uint')
  SetID(nID) => DllCall('xcgui\XWnd_SetID', 'ptr', this, 'int', nID)
  GetID() => DllCall('xcgui\XWnd_GetID', 'ptr', this, 'int')
  SetName(Name) => DllCall('xcgui\XWnd_SetName', 'ptr', this, 'wstr', Name)
  GetName() => DllCall('xcgui\XWnd_GetName', 'ptr', this, 'wstr')
  SetLayoutSize(left, top, right, bottom) => DllCall('xcgui\XWnd_SetLayoutSize', 'ptr', this, 'int', left, 'int', top, 'int', right, 'int', bottom)
  GetLayoutSize(pBorderSize) => DllCall('xcgui\XWnd_GetLayoutSize', 'ptr', this, 'ptr', pBorderSize)
  SetLayoutHorizon(bHorizon) => DllCall('xcgui\XWnd_SetLayoutHorizon', 'ptr', this, 'int', bHorizon)
  SetLayoutAlignH(nAlign) => DllCall('xcgui\XWnd_SetLayoutAlignH', 'ptr', this, 'int', nAlign)
  SetLayoutAlignV(nAlign) => DllCall('xcgui\XWnd_SetLayoutAlignV', 'ptr', this, 'int', nAlign)
  SetLayoutSpace(nSpace) => DllCall('xcgui\XWnd_SetLayoutSpace', 'ptr', this, 'int', nSpace)
  SetLayoutPadding(left, top, right, bottom) => DllCall('xcgui\XWnd_SetLayoutPadding', 'ptr', this, 'int', left, 'int', top, 'int', right, 'int', bottom)
  SetDragBorderSize(left, top, right, bottom) => DllCall('xcgui\XWnd_SetDragBorderSize', 'ptr', this, 'int', left, 'int', top, 'int', right, 'int', bottom)
  GetDragBorderSize(pSize) => DllCall('xcgui\XWnd_GetDragBorderSize', 'ptr', this, 'ptr', pSize)
  SetMinimumSize(width, height) => DllCall('xcgui\XWnd_SetMinimumSize', 'ptr', this, 'int', width, 'int', height)
  HitChildEle(pPt) => DllCall('xcgui\XWnd_HitChildEle', 'ptr', this, 'ptr', pPt, 'ptr')
  GetChildCount() => DllCall('xcgui\XWnd_GetChildCount', 'ptr', this, 'int')
  GetChildByIndex(index) => DllCall('xcgui\XWnd_GetChildByIndex', 'ptr', this, 'int', index, 'ptr')
  GetChildByID(nID) => DllCall('xcgui\XWnd_GetChildByID', 'ptr', this, 'int', nID, 'ptr')
  GetChild(nID) => DllCall('xcgui\XWnd_GetChild', 'ptr', this, 'int', nID, 'ptr')
  CloseWindow() => DllCall('xcgui\XWnd_CloseWindow', 'ptr', this)
  AdjustLayout() => DllCall('xcgui\XWnd_AdjustLayout', 'ptr', this)
  AdjustLayoutEx(nFlags := 2) => DllCall('xcgui\XWnd_AdjustLayoutEx', 'ptr', this, 'int', nFlags)
  CreateCaret(hEle, x, y, width, height) => DllCall('xcgui\XWnd_CreateCaret', 'ptr', this, 'ptr', hEle, 'int', x, 'int', y, 'int', width, 'int', height)
  SetCaretSize(width, height) => DllCall('xcgui\XWnd_SetCaretSize', 'ptr', this, 'int', width, 'int', height)
  SetCaretPos(x, y) => DllCall('xcgui\XWnd_SetCaretPos', 'ptr', this, 'int', x, 'int', y)
  SetCaretPosEx(x, y, width, height) => DllCall('xcgui\XWnd_SetCaretPosEx', 'ptr', this, 'int', x, 'int', y, 'int', width, 'int', height)
  SetCaretColor(color) => DllCall('xcgui\XWnd_SetCaretColor', 'ptr', this, 'uint', color)
  ShowCaret(bShow) => DllCall('xcgui\XWnd_ShowCaret', 'ptr', this, 'int', bShow)
  DestroyCaret() => DllCall('xcgui\XWnd_DestroyCaret', 'ptr', this)
  GetCaretHELE() => DllCall('xcgui\XWnd_GetCaretHELE', 'ptr', this, 'ptr')
  GetClientRect(pRect) => DllCall('xcgui\XWnd_GetClientRect', 'ptr', this, 'ptr', pRect, 'int')
  GetBodyRect(pRect) => DllCall('xcgui\XWnd_GetBodyRect', 'ptr', this, 'ptr', pRect)
  Move(x, y) => DllCall('xcgui\XWnd_Move', 'ptr', this, 'int', x, 'int', y)
  GetRect(pRect) => DllCall('xcgui\XWnd_GetRect', 'ptr', this, 'ptr', pRect)
  SetRect(pRect) => DllCall('xcgui\XWnd_SetRect', 'ptr', this, 'ptr', pRect)
  SetTop() => DllCall('xcgui\XWnd_SetTop', 'ptr', this)
  MaxWindow(bMaximize) => DllCall('xcgui\XWnd_MaxWindow', 'ptr', this, 'int', bMaximize)
  SetTimer(nIDEvent, uElapse) => DllCall('xcgui\XWnd_SetTimer', 'ptr', this, 'uint', nIDEvent, 'uint', uElapse, 'uint')
  KillTimer(nIDEvent) => DllCall('xcgui\XWnd_KillTimer', 'ptr', this, 'uint', nIDEvent, 'int')
  SetXCTimer(nIDEvent, uElapse) => DllCall('xcgui\XWnd_SetXCTimer', 'ptr', this, 'uint', nIDEvent, 'uint', uElapse, 'int')
  KillXCTimer(nIDEvent) => DllCall('xcgui\XWnd_KillXCTimer', 'ptr', this, 'uint', nIDEvent, 'int')
  GetBkManager() => DllCall('xcgui\XWnd_GetBkManager', 'ptr', this, 'ptr')
  GetBkManagerEx() => DllCall('xcgui\XWnd_GetBkManagerEx', 'ptr', this, 'ptr')
  SetBkMagager(hBkInfoM) => DllCall('xcgui\XWnd_SetBkMagager', 'ptr', this, 'ptr', hBkInfoM)
  SetTransparentType(nType) => DllCall('xcgui\XWnd_SetTransparentType', 'ptr', this, 'int', nType)
  SetTransparentAlpha(alpha) => DllCall('xcgui\XWnd_SetTransparentAlpha', 'ptr', this, 'uchar', alpha)
  SetTransparentColor(color) => DllCall('xcgui\XWnd_SetTransparentColor', 'ptr', this, 'uint', color)
  SetShadowInfo(nSize, nDepth, nAngeleSize, bRightAngle, color) => DllCall('xcgui\XWnd_SetShadowInfo', 'ptr', this, 'int', nSize, 'int', nDepth, 'int', nAngeleSize, 'int', bRightAngle, 'uint', color)
  GetShadowInfo(&nSize, &nDepth, &nAngeleSize, &bRightAngle, &Color) => DllCall('xcgui\XWnd_GetShadowInfo', 'ptr', this, 'int*', &nSize, 'int*', &nDepth, 'int*', &nAngeleSize, 'int*', &bRightAngle, 'uint*', &Color)
  GetTransparentType() => DllCall('xcgui\XWnd_GetTransparentType', 'ptr', this, 'int')
  EnableCSS(bEnable) => DllCall('xcgui\XWnd_EnableCSS', 'ptr', this, 'int', bEnable)
  SetCssName(Name) => DllCall('xcgui\XWnd_SetCssName', 'ptr', this, 'wstr', Name)
  GetCssName() => DllCall('xcgui\XWnd_GetCssName', 'ptr', this, 'wstr')
}
class CXModalWindow extends CXWindow {
  static Create(nWidth, nHeight, Title, hWndParent, XCStyle := 7) {
    if hWindow := DllCall('xcgui\XModalWnd_Create', 'int', nWidth, 'int', nHeight, 'wstr', Title, 'ptr', hWndParent, 'int', XCStyle, 'ptr')
      return {Base: CXModalWindow.Prototype, ptr: hWindow}
  }
  static CreateEx(dwExStyle, ClassName, WindowName, dwStyle, x, y, cx, cy, hWndParent, XCStyle := 7) {
    if hWindow := DllCall('xcgui\XModalWnd_CreateEx', 'uint', dwExStyle, 'wstr', ClassName, 'wstr', WindowName, 'uint', dwStyle, 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hWndParent, 'int', XCStyle, 'ptr')
      return {Base: CXModalWindow.Prototype, ptr: hWindow}
  }
  __New(nWidth, nHeight, Title, hWndParent, XCStyle := 7) {
    if !hWindow := DllCall('xcgui\XModalWnd_Create', 'int', nWidth, 'int', nHeight, 'wstr', Title, 'ptr', hWndParent, 'int', XCStyle)
      throw
    this.ptr := hWindow
  }
  EnableAutoClose(bEnable) => DllCall('xcgui\XModalWnd_EnableAutoClose', 'ptr', this, 'int', bEnable)
  EnableEscClose(bEnable) => DllCall('xcgui\XModalWnd_EnableEscClose', 'ptr', this, 'int', bEnable)
  DoModal() => DllCall('xcgui\XModalWnd_DoModal', 'ptr', this, 'int')
  EndModal(nResult) => DllCall('xcgui\XModalWnd_EndModal', 'ptr', this, 'int', nResult)
}
class CXFrameWindow extends CXWindow {
  static Create(x, y, cx, cy, Title, hWndParent, XCStyle) {
    if hWindow := DllCall('xcgui\XFrameWnd_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'wstr', Title, 'ptr', hWndParent, 'int', XCStyle, 'ptr')
      return {Base: CXFrameWindow.Prototype, ptr: hWindow}
  }
  static CreateEx(dwExStyle, ClassName, WindowName, dwStyle, x, y, cx, cy, hWndParent, XCStyle) {
    if hWindow := DllCall('xcgui\XFrameWnd_CreateEx', 'uint', dwExStyle, ClassName, WindowName, 'uint', dwStyle, 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hWndParent, 'int', XCStyle, 'ptr')
      return {Base: CXFrameWindow.Prototype, ptr: hWindow}
  }
  __New(x, y, cx, cy, Title, hWndParent, XCStyle) {
    if !hWindow := DllCall('xcgui\XFrameWnd_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'wstr', Title, 'ptr', hWndParent, 'int', XCStyle)
      throw
    this.ptr := hWindow
  }
  GetLayoutAreaRect(pRect) => DllCall('xcgui\XFrameWnd_GetLayoutAreaRect', 'ptr', this, 'ptr', pRect)
  SetView(hEle) => DllCall('xcgui\XFrameWnd_SetView', 'ptr', this, 'ptr', hEle)
  SetPaneSplitBarColor(color, alpha := 255) => DllCall('xcgui\XFrameWnd_SetPaneSplitBarColor', 'ptr', this, 'uint', color, 'uchar', alpha)
  SetTabBarHeight(nHeight) => DllCall('xcgui\XFrameWnd_SetTabBarHeight', 'ptr', this, 'int', nHeight)
  SaveLayoutToFile(FileName) => DllCall('xcgui\XFrameWnd_SaveLayoutToFile', 'ptr', this, 'wstr', FileName, 'int')
  static LoadLayoutFile(aPaneList, nEleCount, FileName) => DllCall('xcgui\XFrameWnd_LoadLayoutFile', 'ptr', this, 'ptr', aPaneList, 'int', nEleCount, 'wstr', FileName, 'int')
  AddPane(hPaneDest, hPaneNew, align) => DllCall('xcgui\XFrameWnd_AddPane', 'ptr', this, 'ptr', hPaneDest, 'ptr', hPaneNew, 'int', align, 'int')
  MergePane(hPaneDest, hPaneNew) => DllCall('xcgui\XFrameWnd_MergePane', 'ptr', this, 'ptr', hPaneDest, 'ptr', hPaneNew, 'int')
}
class CXMenu extends CXBase {
  static Create() {
    if hMenu := DllCall('xcgui\XMenu_Create', 'ptr')
      return {Base: CXMenu.Prototype, ptr: hMenu}
  }
  __New() {
    if !hMenu := DllCall('xcgui\XMenu_Create', 'ptr')
      throw
    this.ptr := hMenu
  }
  AddItem(nID, Text, parentId := 0, nFlags := 0) => DllCall('xcgui\XMenu_AddItem', 'ptr', this, 'int', nID, 'wstr', Text, 'int', parentId, 'int', nFlags)
  AddItemIcon(nID, Text, nParentID, hImage, nFlags := 0) => DllCall('xcgui\XMenu_AddItemIcon', 'ptr', this, 'int', nID, 'wstr', Text, 'int', nParentID, 'ptr', hImage, 'int', nFlags)
  InsertItem(nID, Text, nFlags, insertID) => DllCall('xcgui\XMenu_InsertItem', 'ptr', this, 'int', nID, 'wstr', Text, 'int', nFlags, 'int', insertID)
  InsertItemIcon(nID, Text, hIcon, nFlags, insertID) => DllCall('xcgui\XMenu_InsertItemIcon', 'ptr', this, 'int', nID, 'wstr', Text, 'ptr', hIcon, 'int', nFlags, 'int', insertID)
  GetFirstChildItem(nID) => DllCall('xcgui\XMenu_GetFirstChildItem', 'ptr', this, 'int', nID, 'int')
  GetEndChildItem(nID) => DllCall('xcgui\XMenu_GetEndChildItem', 'ptr', this, 'int', nID, 'int')
  GetPrevSiblingItem(nID) => DllCall('xcgui\XMenu_GetPrevSiblingItem', 'ptr', this, 'int', nID, 'int')
  GetNextSiblingItem(nID) => DllCall('xcgui\XMenu_GetNextSiblingItem', 'ptr', this, 'int', nID, 'int')
  GetParentItem(nID) => DllCall('xcgui\XMenu_GetParentItem', 'ptr', this, 'int', nID, 'int')
  SetAutoDestroy(bAuto) => DllCall('xcgui\XMenu_SetAutoDestroy', 'ptr', this, 'int', bAuto)
  EnableDrawBackground(bEnable) => DllCall('xcgui\XMenu_EnableDrawBackground', 'ptr', this, 'int', bEnable)
  EnableDrawItem(bEnable) => DllCall('xcgui\XMenu_EnableDrawItem', 'ptr', this, 'int', bEnable)
  Popup(hParentWnd, x, y, hParentEle := 0, nPosition := 0) => DllCall('xcgui\XMenu_Popup', 'ptr', this, 'ptr', hParentWnd, 'int', x, 'int', y, 'ptr', hParentEle, 'int', nPosition, 'int')
  DestroyMenu() => DllCall('xcgui\XMenu_DestroyMenu', 'ptr', this)
  CloseMenu() => DllCall('xcgui\XMenu_CloseMenu', 'ptr', this)
  SetBkImage(hImage) => DllCall('xcgui\XMenu_SetBkImage', 'ptr', this, 'ptr', hImage)
  SetItemText(nID, Text) => DllCall('xcgui\XMenu_SetItemText', 'ptr', this, 'int', nID, 'wstr', Text, 'int')
  GetItemText(nID) => DllCall('xcgui\XMenu_GetItemText', 'ptr', this, 'int', nID, 'wstr')
  GetItemTextLength(nID) => DllCall('xcgui\XMenu_GetItemTextLength', 'ptr', this, 'int', nID, 'int')
  SetItemIcon(nID, hIcon) => DllCall('xcgui\XMenu_SetItemIcon', 'ptr', this, 'int', nID, 'ptr', hIcon, 'int')
  SetItemFlags(nID, uFlags) => DllCall('xcgui\XMenu_SetItemFlags', 'ptr', this, 'int', nID, 'int', uFlags, 'int')
  SetItemHeight(height) => DllCall('xcgui\XMenu_SetItemHeight', 'ptr', this, 'int', height)
  GetItemHeight() => DllCall('xcgui\XMenu_GetItemHeight', 'ptr', this, 'int')
  SetBorderColor(crColor, alpha := 255) => DllCall('xcgui\XMenu_SetBorderColor', 'ptr', this, 'uint', crColor, 'uchar', alpha)
  SetBorderSize(nLeft, nTop, nRight, nBottom) => DllCall('xcgui\XMenu_SetBorderSize', 'ptr', this, 'int', nLeft, 'int', nTop, 'int', nRight, 'int', nBottom)
  GetLeftWidth() => DllCall('xcgui\XMenu_GetLeftWidth', 'ptr', this, 'int')
  GetLeftSpaceText() => DllCall('xcgui\XMenu_GetLeftSpaceText', 'ptr', this, 'int')
  GetItemCount() => DllCall('xcgui\XMenu_GetItemCount', 'ptr', this, 'int')
  SetItemCheck(nID, bCheck) => DllCall('xcgui\XMenu_SetItemCheck', 'ptr', this, 'int', nID, 'int', bCheck, 'int')
  IsItemCheck(nID) => DllCall('xcgui\XMenu_IsItemCheck', 'ptr', this, 'int', nID, 'int')
}
class CXEle extends CXWidgetUI {
  static Create(x, y, cx, cy, hParent := 0) {
    if hEle := DllCall('xcgui\XEle_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent, 'ptr')
      return {Base: CXEle.Prototype, ptr: hEle}
  }
  __New(x, y, cx, cy, hParent := 0) {
    if !hEle := DllCall('xcgui\XEle_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent)
      throw
    this.ptr := hEle
  }
  RegEventC(nEvent, pFun) => DllCall('xcgui\XEle_RegEventC', 'ptr', this, 'int', nEvent, 'ptr', pFun, 'int')
  RegEventC1(nEvent, pFun) => DllCall('xcgui\XEle_RegEventC1', 'ptr', this, 'int', nEvent, 'ptr', pFun, 'int')
  RegEventC2(nEvent, pFun) => DllCall('xcgui\XEle_RegEventC2', 'ptr', this, 'int', nEvent, 'ptr', pFun, 'int')
  RemoveEventC(nEvent, pFun) => DllCall('xcgui\XEle_RemoveEventC', 'ptr', this, 'int', nEvent, 'ptr', pFun, 'int')
  SendEvent(hEventEle, nEvent, wParam, lParam) => DllCall('xcgui\XEle_SendEvent', 'ptr', this, 'ptr', hEventEle, 'int', nEvent, 'uptr', wParam, 'ptr', lParam, 'int')
  PostEvent(hEventEle, nEvent, wParam, lParam) => DllCall('xcgui\XEle_PostEvent', 'ptr', this, 'ptr', hEventEle, 'int', nEvent, 'uptr', wParam, 'ptr', lParam, 'int')
  GetRect(pRect) => DllCall('xcgui\XEle_GetRect', 'ptr', this, 'ptr', pRect)
  GetRectLogic(pRect) => DllCall('xcgui\XEle_GetRectLogic', 'ptr', this, 'ptr', pRect)
  GetClientRect(pRect) => DllCall('xcgui\XEle_GetClientRect', 'ptr', this, 'ptr', pRect)
  SetWidth(nWidth) => DllCall('xcgui\XEle_SetWidth', 'ptr', this, 'int', nWidth)
  SetHeight(nHeight) => DllCall('xcgui\XEle_SetHeight', 'ptr', this, 'int', nHeight)
  GetWidth() => DllCall('xcgui\XEle_GetWidth', 'ptr', this, 'int')
  GetHeight() => DllCall('xcgui\XEle_GetHeight', 'ptr', this, 'int')
  RectWndClientToEleClient(pRect) => DllCall('xcgui\XEle_RectWndClientToEleClient', 'ptr', this, 'ptr', pRect)
  PointWndClientToEleClient(pPt) => DllCall('xcgui\XEle_PointWndClientToEleClient', 'ptr', this, 'ptr', pPt)
  RectClientToWndClient(pRect) => DllCall('xcgui\XEle_RectClientToWndClient', 'ptr', this, 'ptr', pRect)
  PointClientToWndClient(pPt) => DllCall('xcgui\XEle_PointClientToWndClient', 'ptr', this, 'ptr', pPt)
  GetWndClientRect(pRect) => DllCall('xcgui\XEle_GetWndClientRect', 'ptr', this, 'ptr', pRect)
  GetType() => DllCall('xcgui\XEle_GetType', 'ptr', this, 'int')
  GetHWND() => DllCall('xcgui\XEle_GetHWND', 'ptr', this, 'ptr')
  GetHWINDOW() => DllCall('xcgui\XEle_GetHWINDOW', 'ptr', this, 'ptr')
  GetCursor() => DllCall('xcgui\XEle_GetCursor', 'ptr', this, 'ptr')
  SetCursor(hCursor) => DllCall('xcgui\XEle_SetCursor', 'ptr', this, 'ptr', hCursor)
  AddChild(hChild) => DllCall('xcgui\XEle_AddChild', 'ptr', this, 'ptr', hChild, 'int')
  InsertChild(hChild, index) => DllCall('xcgui\XEle_InsertChild', 'ptr', this, 'ptr', hChild, 'int', index, 'int')
  ShowEle(bShow) => DllCall('xcgui\XEle_ShowEle', 'ptr', this, 'int', bShow)
  SetRect(pRect, bRedraw := false, nFlags := 1) => DllCall('xcgui\XEle_SetRect', 'ptr', this, 'ptr', pRect, 'int', bRedraw, 'int', nFlags, 'int')
  SetRectEx(x, y, cx, cy, bRedraw := false, nFlags := 1) => DllCall('xcgui\XEle_SetRectEx', 'ptr', this, 'int', x, 'int', y, 'int', cx, 'int', cy, 'int', bRedraw, 'int', nFlags, 'int')
  SetRectLogic(pRect, bRedraw := false, nFlags := 1) => DllCall('xcgui\XEle_SetRectLogic', 'ptr', this, 'ptr', pRect, 'int', bRedraw, 'int', nFlags, 'int')
  Move(x, y, bRedraw := false, nFlags := 1) => DllCall('xcgui\XEle_Move', 'ptr', this, 'int', x, 'int', y, 'int', bRedraw, 'int', nFlags, 'int')
  MoveLogic(x, y, bRedraw := false, nFlags := 1) => DllCall('xcgui\XEle_MoveLogic', 'ptr', this, 'int', x, 'int', y, 'int', bRedraw, 'int', nFlags, 'int')
  SetID(nID) => DllCall('xcgui\XEle_SetID', 'ptr', this, 'int', nID)
  GetID() => DllCall('xcgui\XEle_GetID', 'ptr', this, 'int')
  SetUID(nUID) => DllCall('xcgui\XEle_SetUID', 'ptr', this, 'int', nUID)
  GetUID() => DllCall('xcgui\XEle_GetUID', 'ptr', this, 'int')
  SetName(Name) => DllCall('xcgui\XEle_SetName', 'ptr', this, 'wstr', Name)
  GetName() => DllCall('xcgui\XEle_GetName', 'ptr', this, 'wstr')
  IsShow() => DllCall('xcgui\XEle_IsShow', 'ptr', this, 'int')
  IsDrawFocus() => DllCall('xcgui\XEle_IsDrawFocus', 'ptr', this, 'int')
  IsEnable() => DllCall('xcgui\XEle_IsEnable', 'ptr', this, 'int')
  IsEnableFocus() => DllCall('xcgui\XEle_IsEnableFocus', 'ptr', this, 'int')
  IsMouseThrough() => DllCall('xcgui\XEle_IsMouseThrough', 'ptr', this, 'int')
  HitChildEle(pPt) => DllCall('xcgui\XEle_HitChildEle', 'ptr', this, 'ptr', pPt, 'ptr')
  IsBkTransparent() => DllCall('xcgui\XEle_IsBkTransparent', 'ptr', this, 'int')
  IsEnableEvent_XE_PAINT_END() => DllCall('xcgui\XEle_IsEnableEvent_XE_PAINT_END', 'ptr', this, 'int')
  IsKeyTab() => DllCall('xcgui\XEle_IsKeyTab', 'ptr', this, 'int')
  IsSwitchFocus() => DllCall('xcgui\XEle_IsSwitchFocus', 'ptr', this, 'int')
  IsEnable_XE_MOUSEWHEEL() => DllCall('xcgui\XEle_IsEnable_XE_MOUSEWHEEL', 'ptr', this, 'int')
  IsChildEle(hChildEle) => DllCall('xcgui\XEle_IsChildEle', 'ptr', this, 'ptr', hChildEle, 'int')
  IsEnableCanvas() => DllCall('xcgui\XEle_IsEnableCanvas', 'ptr', this, 'int')
  IsFocus() => DllCall('xcgui\XEle_IsFocus', 'ptr', this, 'int')
  IsFocusEx() => DllCall('xcgui\XEle_IsFocusEx', 'ptr', this, 'int')
  Enable(bEnable) => DllCall('xcgui\XEle_Enable', 'ptr', this, 'int', bEnable)
  EnableFocus(bEnable) => DllCall('xcgui\XEle_EnableFocus', 'ptr', this, 'int', bEnable)
  EnableDrawFocus(bEnable) => DllCall('xcgui\XEle_EnableDrawFocus', 'ptr', this, 'int', bEnable)
  EnableDrawBorder(bEnable) => DllCall('xcgui\XEle_EnableDrawBorder', 'ptr', this, 'int', bEnable)
  EnableCanvas(bEnable) => DllCall('xcgui\XEle_EnableCanvas', 'ptr', this, 'int', bEnable)
  EnableEvent_XE_PAINT_END(bEnable) => DllCall('xcgui\XEle_EnableEvent_XE_PAINT_END', 'ptr', this, 'int', bEnable)
  EnableBkTransparent(bEnable) => DllCall('xcgui\XEle_EnableBkTransparent', 'ptr', this, 'int', bEnable)
  EnableMouseThrough(bEnable) => DllCall('xcgui\XEle_EnableMouseThrough', 'ptr', this, 'int', bEnable)
  EnableKeyTab(bEnable) => DllCall('xcgui\XEle_EnableKeyTab', 'ptr', this, 'int', bEnable)
  EnableSwitchFocus(bEnable) => DllCall('xcgui\XEle_EnableSwitchFocus', 'ptr', this, 'int', bEnable)
  EnableEvent_XE_MOUSEWHEEL(bEnable) => DllCall('xcgui\XEle_EnableEvent_XE_MOUSEWHEEL', 'ptr', this, 'int', bEnable)
  GetParentEle() => DllCall('xcgui\XEle_GetParentEle', 'ptr', this, 'ptr')
  GetParent() => DllCall('xcgui\XEle_GetParent', 'ptr', this, 'ptr')
  RemoveEle() => DllCall('xcgui\XEle_RemoveEle', 'ptr', this)
  SetZOrder(index) => DllCall('xcgui\XEle_SetZOrder', 'ptr', this, 'int', index, 'int')
  SetZOrderEx(hDestEle, nType) => DllCall('xcgui\XEle_SetZOrderEx', 'ptr', this, 'ptr', hDestEle, 'int', nType, 'int')
  GetZOrder() => DllCall('xcgui\XEle_GetZOrder', 'ptr', this, 'int')
  SetTopmost(bTopmost) => DllCall('xcgui\XEle_SetTopmost', 'ptr', this, 'int', bTopmost, 'int')
  EnableCSS(bEnable) => DllCall('xcgui\XEle_EnableCSS', 'ptr', this, 'int', bEnable)
  SetCssName(Name) => DllCall('xcgui\XEle_SetCssName', 'ptr', this, 'wstr', Name)
  GetCssName() => DllCall('xcgui\XEle_GetCssName', 'ptr', this, 'wstr')
  RedrawEle(bImmediate := false) => DllCall('xcgui\XEle_RedrawEle', 'ptr', this, 'int', bImmediate)
  RedrawRect(pRect, bImmediate := false) => DllCall('xcgui\XEle_RedrawRect', 'ptr', this, 'ptr', pRect, 'int', bImmediate)
  GetChildCount() => DllCall('xcgui\XEle_GetChildCount', 'ptr', this, 'int')
  GetChildByIndex(index) => DllCall('xcgui\XEle_GetChildByIndex', 'ptr', this, 'int', index, 'ptr')
  GetChildByID(nID) => DllCall('xcgui\XEle_GetChildByID', 'ptr', this, 'int', nID, 'ptr')
  SetBorderSize(left, top, right, bottom) => DllCall('xcgui\XEle_SetBorderSize', 'ptr', this, 'int', left, 'int', top, 'int', right, 'int', bottom)
  GetBorderSize(pBorder) => DllCall('xcgui\XEle_GetBorderSize', 'ptr', this, 'ptr', pBorder)
  SetPadding(left, top, right, bottom) => DllCall('xcgui\XEle_SetPadding', 'ptr', this, 'int', left, 'int', top, 'int', right, 'int', bottom)
  GetPadding(pPadding) => DllCall('xcgui\XEle_GetPadding', 'ptr', this, 'ptr', pPadding)
  SetDragBorder(nFlags) => DllCall('xcgui\XEle_SetDragBorder', 'ptr', this, 'int', nFlags)
  SetDragBorderBindEle(nFlags, hBindEle, nSpace) => DllCall('xcgui\XEle_SetDragBorderBindEle', 'ptr', this, 'int', nFlags, 'ptr', hBindEle, 'int', nSpace)
  SetMinSize(nWidth, nHeight) => DllCall('xcgui\XEle_SetMinSize', 'ptr', this, 'int', nWidth, 'int', nHeight)
  SetMaxSize(nWidth, nHeight) => DllCall('xcgui\XEle_SetMaxSize', 'ptr', this, 'int', nWidth, 'int', nHeight)
  SetLockScroll(bHorizon, bVertical) => DllCall('xcgui\XEle_SetLockScroll', 'ptr', this, 'int', bHorizon, 'int', bVertical)
  SetTextColor(color, alpha := 255) => DllCall('xcgui\XEle_SetTextColor', 'ptr', this, 'uint', color, 'uchar', alpha)
  GetTextColor() => DllCall('xcgui\XEle_GetTextColor', 'ptr', this, 'uint')
  GetTextColorEx() => DllCall('xcgui\XEle_GetTextColorEx', 'ptr', this, 'uint')
  SetFocusBorderColor(color, alpha := 255) => DllCall('xcgui\XEle_SetFocusBorderColor', 'ptr', this, 'uint', color, 'uchar', alpha)
  GetFocusBorderColor() => DllCall('xcgui\XEle_GetFocusBorderColor', 'ptr', this, 'uint')
  SetFont(hFontx) => DllCall('xcgui\XEle_SetFont', 'ptr', this, 'ptr', hFontx)
  GetFont() => DllCall('xcgui\XEle_GetFont', 'ptr', this, 'ptr')
  GetFontEx() => DllCall('xcgui\XEle_GetFontEx', 'ptr', this, 'ptr')
  SetAlpha(alpha) => DllCall('xcgui\XEle_SetAlpha', 'ptr', this, 'uchar', alpha)
  Destroy() => DllCall('xcgui\XEle_Destroy', 'ptr', this)
  AddBkBorder(color, alpha, width) => DllCall('xcgui\XEle_AddBkBorder', 'ptr', this, 'uint', color, 'uchar', alpha, 'int', width)
  AddBkFill(color, alpha) => DllCall('xcgui\XEle_AddBkFill', 'ptr', this, 'uint', color, 'uchar', alpha)
  AddBkImage(hImage) => DllCall('xcgui\XEle_AddBkImage', 'ptr', this, 'ptr', hImage)
  GetBkInfoCount() => DllCall('xcgui\XEle_GetBkInfoCount', 'ptr', this, 'int')
  ClearBkInfo() => DllCall('xcgui\XEle_ClearBkInfo', 'ptr', this)
  GetBkManager() => DllCall('xcgui\XEle_GetBkManager', 'ptr', this, 'ptr')
  GetBkManagerEx() => DllCall('xcgui\XEle_GetBkManagerEx', 'ptr', this, 'ptr')
  SetBkManager(hBkInfoM) => DllCall('xcgui\XEle_SetBkManager', 'ptr', this, 'ptr', hBkInfoM)
  GetStateFlags() => DllCall('xcgui\XEle_GetStateFlags', 'ptr', this, 'int')
  DrawFocus(hDraw, pRect) => DllCall('xcgui\XEle_DrawFocus', 'ptr', this, 'ptr', hDraw, 'ptr', pRect, 'int')
  DrawEle(hDraw) => DllCall('xcgui\XEle_DrawEle', 'ptr', this, 'ptr', hDraw)
  SetUserData(nData) => DllCall('xcgui\XEle_SetUserData', 'ptr', this, 'ptr', nData)
  GetUserData() => DllCall('xcgui\XEle_GetUserData', 'ptr', this, 'ptr')
  GetContentSize(pSize) => DllCall('xcgui\XEle_GetContentSize', 'ptr', this, 'ptr', pSize)
  SetCapture(b) => DllCall('xcgui\XEle_SetCapture', 'ptr', this, 'int', b)
  SetLayoutWidth(nType, nWidth) => DllCall('xcgui\XEle_SetLayoutWidth', 'ptr', this, 'uint', nType, 'int', nWidth)
  SetLayoutHeight(nType, nHeight) => DllCall('xcgui\XEle_SetLayoutHeight', 'ptr', this, 'uint', nType, 'int', nHeight)
  GetLayoutWidth(&Type, &Width) => DllCall('xcgui\XEle_GetLayoutWidth', 'ptr', this, 'uint*', &Type, 'int*', &Width)
  GetLayoutHeight(&Type, &Height) => DllCall('xcgui\XEle_GetLayoutHeight', 'ptr', this, 'uint*', &Type, 'int*', &Height)
  SetLayoutFloat(nFloat_) => DllCall('xcgui\XEle_SetLayoutFloat', 'ptr', this, 'uint', nFloat_)
  SetLayoutWrap(bWrap) => DllCall('xcgui\XEle_SetLayoutWrap', 'ptr', this, 'int', bWrap)
  EnableTransparentChannel(bEnable) => DllCall('xcgui\XEle_EnableTransparentChannel', 'ptr', this, 'int', bEnable)
  SetXCTimer(nIDEvent, uElapse) => DllCall('xcgui\XEle_SetXCTimer', 'ptr', this, 'uint', nIDEvent, 'uint', uElapse, 'int')
  KillXCTimer(nIDEvent) => DllCall('xcgui\XEle_KillXCTimer', 'ptr', this, 'uint', nIDEvent, 'int')
  SetToolTip(Text) => DllCall('xcgui\XEle_SetToolTip', 'ptr', this, 'wstr', Text)
  SetToolTipEx(Text, nTextAlign) => DllCall('xcgui\XEle_SetToolTipEx', 'ptr', this, 'wstr', Text, 'int', nTextAlign)
  GetToolTip() => DllCall('xcgui\XEle_GetToolTip', 'ptr', this, 'wstr')
  PopupToolTip(x, y) => DllCall('xcgui\XEle_PopupToolTip', 'ptr', this, 'int', x, 'int', y)
  AdjustLayout() => DllCall('xcgui\XEle_AdjustLayout', 'ptr', this)
  AdjustLayoutEx(nFlags := 2) => DllCall('xcgui\XEle_AdjustLayoutEx', 'ptr', this, 'int', nFlags)
}
class CXLayout extends CXEle {
  static Create(x, y, cx, cy, hParent) {
    if hEle := DllCall('xcgui\XLayout_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent, 'ptr')
      return {Base: CXLayout.Prototype, ptr: hEle}
  }
  static CreateEx(hParent) {
    if hEle := DllCall('xcgui\XLayout_CreateEx', 'ptr', hParent, 'ptr')
      return {Base: CXLayout.Prototype, ptr: hEle}
  }
  __New(x, y, cx, cy, hParent) {
    if !hEle := DllCall('xcgui\XLayout_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent)
      throw
    this.ptr := hEle
  }
  IsEnableLayout() => DllCall('xcgui\XLayout_IsEnableLayout', 'ptr', this, 'int')
  EnableLayout(bEnable) => DllCall('xcgui\XLayout_EnableLayout', 'ptr', this, 'int', bEnable)
  ShowLayoutFrame(bEnable) => DllCall('xcgui\XLayout_ShowLayoutFrame', 'ptr', this, 'int', bEnable)
  GetWidthIn() => DllCall('xcgui\XLayout_GetWidthIn', 'ptr', this, 'int')
  GetHeightIn() => DllCall('xcgui\XLayout_GetHeightIn', 'ptr', this, 'int')
  SetHorizon(bHorizon) => DllCall('xcgui\XLayout_SetHorizon', 'ptr', this, 'int', bHorizon)
  SetAlignH(nAlign) => DllCall('xcgui\XLayout_SetAlignH', 'ptr', this, 'int', nAlign)
  SetAlignV(nAlign) => DllCall('xcgui\XLayout_SetAlignV', 'ptr', this, 'int', nAlign)
  SetSpace(nSpace) => DllCall('xcgui\XLayout_SetSpace', 'ptr', this, 'int', nSpace)
  SetPadding(left, top, right, bottom) => DllCall('xcgui\XLayout_SetPadding', 'ptr', this, 'int', left, 'int', top, 'int', right, 'int', bottom)
  GetLayoutPadding(pPadding) => DllCall('xcgui\XLayout_GetLayoutPadding', 'ptr', this, 'ptr', pPadding)
}
class CXScrollView extends CXEle {
  static Create(x, y, cx, cy, hParent := 0) {
    if hEle := DllCall('xcgui\XSView_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent, 'ptr')
      return {Base: CXScrollView.Prototype, ptr: hEle}
  }
  __New(x, y, cx, cy, hParent := 0) {
    if !hEle := DllCall('xcgui\XSView_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent)
      throw
    this.ptr := hEle
  }
  SetTotalSize(cx, cy) => DllCall('xcgui\XSView_SetTotalSize', 'ptr', this, 'int', cx, 'int', cy, 'int')
  GetTotalSize(pSize) => DllCall('xcgui\XSView_GetTotalSize', 'ptr', this, 'ptr', pSize)
  SetLineSize(nWidth, nHeight) => DllCall('xcgui\XSView_SetLineSize', 'ptr', this, 'int', nWidth, 'int', nHeight, 'int')
  GetLineSize(pSize) => DllCall('xcgui\XSView_GetLineSize', 'ptr', this, 'ptr', pSize)
  SetScrollBarSize(size) => DllCall('xcgui\XSView_SetScrollBarSize', 'ptr', this, 'int', size)
  GetViewPosH() => DllCall('xcgui\XSView_GetViewPosH', 'ptr', this, 'int')
  GetViewPosV() => DllCall('xcgui\XSView_GetViewPosV', 'ptr', this, 'int')
  GetViewWidth() => DllCall('xcgui\XSView_GetViewWidth', 'ptr', this, 'int')
  GetViewHeight() => DllCall('xcgui\XSView_GetViewHeight', 'ptr', this, 'int')
  GetViewRect(pRect) => DllCall('xcgui\XSView_GetViewRect', 'ptr', this, 'ptr', pRect)
  GetScrollBarH() => DllCall('xcgui\XSView_GetScrollBarH', 'ptr', this, 'ptr')
  GetScrollBarV() => DllCall('xcgui\XSView_GetScrollBarV', 'ptr', this, 'ptr')
  SetBorderSize(left, top, right, bottom) => DllCall('xcgui\XSView_SetBorderSize', 'ptr', this, 'int', left, 'int', top, 'int', right, 'int', bottom)
  GetBorderSize(pBorder) => DllCall('xcgui\XSView_GetBorderSize', 'ptr', this, 'ptr', pBorder)
  ScrollPosH(pos) => DllCall('xcgui\XSView_ScrollPosH', 'ptr', this, 'int', pos, 'int')
  ScrollPosV(pos) => DllCall('xcgui\XSView_ScrollPosV', 'ptr', this, 'int', pos, 'int')
  ScrollPosXH(posX) => DllCall('xcgui\XSView_ScrollPosXH', 'ptr', this, 'int', posX, 'int')
  ScrollPosYV(posY) => DllCall('xcgui\XSView_ScrollPosYV', 'ptr', this, 'int', posY, 'int')
  ShowSBarH(bShow) => DllCall('xcgui\XSView_ShowSBarH', 'ptr', this, 'int', bShow)
  ShowSBarV(bShow) => DllCall('xcgui\XSView_ShowSBarV', 'ptr', this, 'int', bShow)
  EnableAutoShowScrollBar(bEnable) => DllCall('xcgui\XSView_EnableAutoShowScrollBar', 'ptr', this, 'int', bEnable)
  ScrollLeftLine() => DllCall('xcgui\XSView_ScrollLeftLine', 'ptr', this, 'int')
  ScrollRightLine() => DllCall('xcgui\XSView_ScrollRightLine', 'ptr', this, 'int')
  ScrollTopLine() => DllCall('xcgui\XSView_ScrollTopLine', 'ptr', this, 'int')
  ScrollBottomLine() => DllCall('xcgui\XSView_ScrollBottomLine', 'ptr', this, 'int')
  ScrollLeft() => DllCall('xcgui\XSView_ScrollLeft', 'ptr', this, 'int')
  ScrollRight() => DllCall('xcgui\XSView_ScrollRight', 'ptr', this, 'int')
  ScrollTop() => DllCall('xcgui\XSView_ScrollTop', 'ptr', this, 'int')
  ScrollBottom() => DllCall('xcgui\XSView_ScrollBottom', 'ptr', this, 'int')
}
class CXLayoutStack extends CXScrollView {
  static Create(x, y, cx, cy, hParent := 0) {
    if hEle := DllCall('xcgui\XLayoutStack_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent, 'ptr')
      return {Base: CXLayoutStack.Prototype, ptr: hEle}
  }
  __New(x, y, cx, cy, hParent := 0) {
    if !hEle := DllCall('xcgui\XLayoutStack_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent)
      throw
    this.ptr := hEle
  }
  ShowLayoutFrame(bEnable) => DllCall('xcgui\XLayoutStack_ShowLayoutFrame', 'ptr', this, 'int', bEnable)
  SetWidth(nType, nWidth) => DllCall('xcgui\XLayoutStack_SetWidth', 'ptr', this, 'uint', nType, 'int', nWidth)
  SetAlign(nAlign) => DllCall('xcgui\XLayoutStack_SetAlign', 'ptr', this, 'uint', nAlign)
}
class CXButton extends CXEle {
  static Create(x, y, cx, cy, Name, hParent := 0) {
    if hEle := DllCall('xcgui\XBtn_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'wstr', Name, 'ptr', hParent, 'ptr')
      return {Base: CXButton.Prototype, ptr: hEle}
  }
  __New(x, y, cx, cy, Name, hParent := 0) {
    if !hEle := DllCall('xcgui\XBtn_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'wstr', Name, 'ptr', hParent, 'ptr')
      throw
    this.ptr := hEle
  }
  IsCheck() => DllCall('xcgui\XBtn_IsCheck', 'ptr', this, 'int')
  SetCheck(bCheck) => DllCall('xcgui\XBtn_SetCheck', 'ptr', this, 'int', bCheck, 'int')
  SetStyle(nStyle) => DllCall('xcgui\XBtn_SetStyle', 'ptr', this, 'int', nStyle, 'int')
  SetState(nState) => DllCall('xcgui\XBtn_SetState', 'ptr', this, 'int', nState)
  GetState() => DllCall('xcgui\XBtn_GetState', 'ptr', this, 'int')
  GetStateEx() => DllCall('xcgui\XBtn_GetStateEx', 'ptr', this, 'int')
  GetStyle() => DllCall('xcgui\XBtn_GetStyle', 'ptr', this, 'int')
  SetType(nType) => DllCall('xcgui\XBtn_SetType', 'ptr', this, 'int', nType)
  SetTypeEx(nType) => DllCall('xcgui\XBtn_SetTypeEx', 'ptr', this, 'int', nType)
  GetType() => DllCall('xcgui\XBtn_GetType', 'ptr', this, 'int')
  SetGroupID(nID) => DllCall('xcgui\XBtn_SetGroupID', 'ptr', this, 'int', nID)
  GetGroupID() => DllCall('xcgui\XBtn_GetGroupID', 'ptr', this, 'int')
  SetBindEle(hBindEle) => DllCall('xcgui\XBtn_SetBindEle', 'ptr', this, 'ptr', hBindEle)
  GetBindEle() => DllCall('xcgui\XBtn_GetBindEle', 'ptr', this, 'ptr')
  SetTextAlign(nFlags) => DllCall('xcgui\XBtn_SetTextAlign', 'ptr', this, 'int', nFlags)
  GetTextAlign() => DllCall('xcgui\XBtn_GetTextAlign', 'ptr', this, 'int')
  SetIconAlign(align) => DllCall('xcgui\XBtn_SetIconAlign', 'ptr', this, 'int', align)
  SetOffset(x, y) => DllCall('xcgui\XBtn_SetOffset', 'ptr', this, 'int', x, 'int', y)
  SetOffsetIcon(x, y) => DllCall('xcgui\XBtn_SetOffsetIcon', 'ptr', this, 'int', x, 'int', y)
  SetIconSpace(size) => DllCall('xcgui\XBtn_SetIconSpace', 'ptr', this, 'int', size)
  SetText(Name) => DllCall('xcgui\XBtn_SetText', 'ptr', this, 'wstr', Name)
  GetText() => DllCall('xcgui\XBtn_GetText', 'ptr', this, 'wstr')
  SetIcon(hImage) => DllCall('xcgui\XBtn_SetIcon', 'ptr', this, 'ptr', hImage)
  SetIconDisable(hImage) => DllCall('xcgui\XBtn_SetIconDisable', 'ptr', this, 'ptr', hImage)
  GetIcon(nType) => DllCall('xcgui\XBtn_GetIcon', 'ptr', this, 'int', nType, 'ptr')
  AddAnimationFrame(hImage, uElapse) => DllCall('xcgui\XBtn_AddAnimationFrame', 'ptr', this, 'ptr', hImage, 'uint', uElapse)
  EnableAnimation(bEnable, bLoopPlay := false) => DllCall('xcgui\XBtn_EnableAnimation', 'ptr', this, 'int', bEnable, 'int', bLoopPlay)
  AddBkBorder(nState, color, alpha, width) => DllCall('xcgui\XBtn_AddBkBorder', 'ptr', this, 'int', nState, 'uint', color, 'uchar', alpha, 'int', width)
  AddBkFill(nState, color, alpha) => DllCall('xcgui\XBtn_AddBkFill', 'ptr', this, 'int', nState, 'uint', color, 'uchar', alpha)
  AddBkImage(nState, hImage) => DllCall('xcgui\XBtn_AddBkImage', 'ptr', this, 'int', nState, 'ptr', hImage)
  GetBkInfoCount() => DllCall('xcgui\XBtn_GetBkInfoCount', 'ptr', this, 'int')
  ClearBkInfo() => DllCall('xcgui\XBtn_ClearBkInfo', 'ptr', this)
}
class CXEdit extends CXScrollView {
  static Create(x, y, cx, cy, hParent := 0) {
    if hEle := DllCall('xcgui\XEdit_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent, 'ptr')
      return {Base: CXEdit.Prototype, ptr: hEle}
  }
  static CreateEx(x, y, cx, cy, type, hParent := 0) {
    if hEle := DllCall('xcgui\XEdit_CreateEx', 'int', x, 'int', y, 'int', cx, 'int', cy, 'int', type, 'ptr', hParent, 'ptr')
      return {Base: CXEdit.Prototype, ptr: hEle}
  }
  __New(x, y, cx, cy, hParent := 0) {
    if !hEle := DllCall('xcgui\XEdit_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent)
      throw
    this.ptr := hEle
  }
  EnableAutoWrap(bEnable) => DllCall('xcgui\XEdit_EnableAutoWrap', 'ptr', this, 'int', bEnable)
  EnableReadOnly(bEnable) => DllCall('xcgui\XEdit_EnableReadOnly', 'ptr', this, 'int', bEnable)
  EnableMultiLine(bEnable) => DllCall('xcgui\XEdit_EnableMultiLine', 'ptr', this, 'int', bEnable)
  EnablePassword(bEnable) => DllCall('xcgui\XEdit_EnablePassword', 'ptr', this, 'int', bEnable)
  EnableAutoSelAll(bEnable) => DllCall('xcgui\XEdit_EnableAutoSelAll', 'ptr', this, 'int', bEnable)
  EnableAutoCancelSel(bEnable) => DllCall('xcgui\XEdit_EnableAutoCancelSel', 'ptr', this, 'int', bEnable)
  IsReadOnly() => DllCall('xcgui\XEdit_IsReadOnly', 'ptr', this, 'int')
  IsMultiLine() => DllCall('xcgui\XEdit_IsMultiLine', 'ptr', this, 'int')
  IsPassword() => DllCall('xcgui\XEdit_IsPassword', 'ptr', this, 'int')
  IsAutoWrap() => DllCall('xcgui\XEdit_IsAutoWrap', 'ptr', this, 'int')
  IsEmpty() => DllCall('xcgui\XEdit_IsEmpty', 'ptr', this, 'int')
  IsInSelect(iRow, iCol) => DllCall('xcgui\XEdit_IsInSelect', 'ptr', this, 'int', iRow, 'int', iCol, 'int')
  GetRowCount() => DllCall('xcgui\XEdit_GetRowCount', 'ptr', this, 'int')
  GetData() => DllCall('xcgui\XEdit_GetData', 'ptr', this, 'ptr')
  AddData(pData, styleTable, nStyleCount) => DllCall('xcgui\XEdit_AddData', 'ptr', this, 'ptr', pData, 'ptr', styleTable, 'int', nStyleCount)
  FreeData(pData) => DllCall('xcgui\XEdit_FreeData', 'ptr', pData)
  SetDefaultText(String) => DllCall('xcgui\XEdit_SetDefaultText', 'ptr', this, 'wstr', String)
  SetDefaultTextColor(color, alpha) => DllCall('xcgui\XEdit_SetDefaultTextColor', 'ptr', this, 'uint', color, 'uchar', alpha)
  SetPasswordCharacter(ch) => DllCall('xcgui\XEdit_SetPasswordCharacter', 'ptr', this, 'ushort', ch)
  SetTextAlign(align) => DllCall('xcgui\XEdit_SetTextAlign', 'ptr', this, 'int', align)
  SetTabSpace(nSpace) => DllCall('xcgui\XEdit_SetTabSpace', 'ptr', this, 'int', nSpace)
  SetText(String) => DllCall('xcgui\XEdit_SetText', 'ptr', this, 'wstr', String)
  SetTextInt(nValue) => DllCall('xcgui\XEdit_SetTextInt', 'ptr', this, 'int', nValue)
  GetText(pOut, nOutlen) => DllCall('xcgui\XEdit_GetText', 'ptr', this, 'ptr', pOut, 'int', nOutlen, 'int')
  GetTextRow(iRow, pOut, nOutlen) => DllCall('xcgui\XEdit_GetTextRow', 'ptr', this, 'int', iRow, 'ptr', pOut, 'int', nOutlen, 'int')
  GetLength() => DllCall('xcgui\XEdit_GetLength', 'ptr', this, 'int')
  GetLengthRow(iRow) => DllCall('xcgui\XEdit_GetLengthRow', 'ptr', this, 'int', iRow, 'int')
  GetAt(iRow, iCol) => DllCall('xcgui\XEdit_GetAt', 'ptr', this, 'int', iRow, 'int', iCol, 'ushort')
  InsertText(iRow, iCol, String) => DllCall('xcgui\XEdit_InsertText', 'ptr', this, 'int', iRow, 'int', iCol, 'wstr', String)
  InsertTextUser(String) => DllCall('xcgui\XEdit_InsertTextUser', 'ptr', this, 'wstr', String)
  AddText(String) => DllCall('xcgui\XEdit_AddText', 'ptr', this, 'wstr', String)
  AddTextEx(String, iStyle) => DllCall('xcgui\XEdit_AddTextEx', 'ptr', this, 'wstr', String, 'int', iStyle)
  AddObject(hObj) => DllCall('xcgui\XEdit_AddObject', 'ptr', this, 'ptr', hObj, 'int')
  AddByStyle(iStyle) => DllCall('xcgui\XEdit_AddByStyle', 'ptr', this, 'int', iStyle)
  AddStyle(hFont_image_Obj, color, bColor) => DllCall('xcgui\XEdit_AddStyle', 'ptr', this, 'ptr', hFont_image_Obj, 'uint', color, 'int', bColor, 'int')
  AddStyleEx(fontName, fontSize, fontStyle, color, bColor) => DllCall('xcgui\XEdit_AddStyleEx', 'ptr', this, 'wstr', fontName, 'int', fontSize, 'int', fontStyle, 'uint', color, 'int', bColor, 'int')
  GetStyleInfo(iStyle, info) => DllCall('xcgui\XEdit_GetStyleInfo', 'ptr', this, 'int', iStyle, 'ptr', info, 'int')
  SetCurStyle(iStyle) => DllCall('xcgui\XEdit_SetCurStyle', 'ptr', this, 'int', iStyle)
  SetCaretColor(color) => DllCall('xcgui\XEdit_SetCaretColor', 'ptr', this, 'uint', color)
  SetCaretWidth(nWidth) => DllCall('xcgui\XEdit_SetCaretWidth', 'ptr', this, 'int', nWidth)
  SetSelectBkColor(color, alpha := 255) => DllCall('xcgui\XEdit_SetSelectBkColor', 'ptr', this, 'uint', color, 'uchar', alpha)
  SetRowHeight(nHeight) => DllCall('xcgui\XEdit_SetRowHeight', 'ptr', this, 'int', nHeight)
  SetRowHeightEx(iRow, nHeight) => DllCall('xcgui\XEdit_SetRowHeightEx', 'ptr', this, 'int', iRow, 'int', nHeight)
  SetCurPos(iRow, iCol) => DllCall('xcgui\XEdit_SetCurPos', 'ptr', this, 'int', iRow, 'int', iCol)
  GetCurPos() => DllCall('xcgui\XEdit_GetCurPos', 'ptr', this, 'int')
  GetCurRow() => DllCall('xcgui\XEdit_GetCurRow', 'ptr', this, 'int')
  GetCurCol() => DllCall('xcgui\XEdit_GetCurCol', 'ptr', this, 'int')
  GetPoint(iRow, iCol, pOut) => DllCall('xcgui\XEdit_GetPoint', 'ptr', this, 'int', iRow, 'int', iCol, 'ptr', pOut)
  AutoScroll() => DllCall('xcgui\XEdit_AutoScroll', 'ptr', this, 'int')
  AutoScrollEx(iRow, iCol) => DllCall('xcgui\XEdit_AutoScrollEx', 'ptr', this, 'int', iRow, 'int', iCol, 'int')
  PositionToInfo(iPos, pInfo) => DllCall('xcgui\XEdit_PositionToInfo', 'ptr', this, 'int', iPos, 'ptr', pInfo)
  SelectAll() => DllCall('xcgui\XEdit_SelectAll', 'ptr', this, 'int')
  CancelSelect() => DllCall('xcgui\XEdit_CancelSelect', 'ptr', this, 'int')
  DeleteSelect() => DllCall('xcgui\XEdit_DeleteSelect', 'ptr', this, 'int')
  SetSelect(iStartRow, iStartCol, iEndRow, iEndCol) => DllCall('xcgui\XEdit_SetSelect', 'ptr', this, 'int', iStartRow, 'int', iStartCol, 'int', iEndRow, 'int', iEndCol, 'int')
  GetSelectText(pOut, nOutLen) => DllCall('xcgui\XEdit_GetSelectText', 'ptr', this, 'ptr', pOut, 'int', nOutLen, 'int')
  GetSelectRange(pBegin, pEnd) => DllCall('xcgui\XEdit_GetSelectRange', 'ptr', this, 'ptr', pBegin, 'ptr', pEnd, 'int')
  GetVisibleRowRange(&iStart, &iEnd) => DllCall('xcgui\XEdit_GetVisibleRowRange', 'ptr', this, 'int*', &iStart, 'int*', &iEnd)
  Delete(iStartRow, iStartCol, iEndRow, iEndCol) => DllCall('xcgui\XEdit_Delete', 'ptr', this, 'int', iStartRow, 'int', iStartCol, 'int', iEndRow, 'int', iEndCol, 'int')
  DeleteRow(iRow) => DllCall('xcgui\XEdit_DeleteRow', 'ptr', this, 'int', iRow, 'int')
  ClipboardCut() => DllCall('xcgui\XEdit_ClipboardCut', 'ptr', this, 'int')
  ClipboardCopy() => DllCall('xcgui\XEdit_ClipboardCopy', 'ptr', this, 'int')
  ClipboardPaste() => DllCall('xcgui\XEdit_ClipboardPaste', 'ptr', this, 'int')
  Undo() => DllCall('xcgui\XEdit_Undo', 'ptr', this, 'int')
  Redo() => DllCall('xcgui\XEdit_Redo', 'ptr', this, 'int')
  AddChatBegin(hImageAvatar, hImageBubble, nFlag) => DllCall('xcgui\XEdit_AddChatBegin', 'ptr', this, 'ptr', hImageAvatar, 'ptr', hImageBubble, 'int', nFlag)
  AddChatEnd() => DllCall('xcgui\XEdit_AddChatEnd', 'ptr', this)
  SetChatIndentation(nIndentation) => DllCall('xcgui\XEdit_SetChatIndentation', 'ptr', this, 'int', nIndentation)
}
class CXEditor extends CXEle {
  static Create(x, y, cx, cy, hParent := 0) {
    if hEle := DllCall('xcgui\XEditor_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent := 0, 'ptr')
      return {Base: CXEditor.Prototype, ptr: hEle}
  }
  __New(x, y, cx, cy, hParent := 0) {
    if !hEle := DllCall('xcgui\XEditor_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent := 0, 'ptr')
      throw
    this.ptr := hEle
  }
  IsBreakpoint(iRow) => DllCall('xcgui\XEditor_IsBreakpoint', 'ptr', this, 'int', iRow, 'int')
  SetBreakpoint(iRow, bActivate := true) => DllCall('xcgui\XEditor_SetBreakpoint', 'ptr', this, 'int', iRow, 'int', bActivate = TRUE, 'int')
  RemoveBreakpoint(iRow) => DllCall('xcgui\XEditor_RemoveBreakpoint', 'ptr', this, 'int', iRow, 'int')
  ClearBreakpoint() => DllCall('xcgui\XEditor_ClearBreakpoint', 'ptr', this)
  SetRunRow(iRow) => DllCall('xcgui\XEditor_SetRunRow', 'ptr', this, 'int', iRow, 'int')
  GetColor(&Info) => DllCall('xcgui\XEditor_GetColor', 'ptr', this, 'int*', &Info := 0)
  SetColor(Info) => DllCall('xcgui\XEditor_SetColor', 'ptr', this, 'int*', &Info)
  SetStyleKeyword(iStyle) => DllCall('xcgui\XEditor_SetStyleKeyword', 'ptr', this, 'int', iStyle)
  SetStyleFunction(iStyle) => DllCall('xcgui\XEditor_SetStyleFunction', 'ptr', this, 'int', iStyle)
  SetStyleVar(iStyle) => DllCall('xcgui\XEditor_SetStyleVar', 'ptr', this, 'int', iStyle)
  SetStyleDataType(iStyle) => DllCall('xcgui\XEditor_SetStyleDataType', 'ptr', this, 'int', iStyle)
  SetStyleClass(iStyle) => DllCall('xcgui\XEditor_SetStyleClass', 'ptr', this, 'int', iStyle)
  SetStyleMacro(iStyle) => DllCall('xcgui\XEditor_SetStyleMacro', 'ptr', this, 'int', iStyle)
  SetStyleString(iStyle) => DllCall('xcgui\XEditor_SetStyleString', 'ptr', this, 'int', iStyle)
  SetStyleComment(iStyle) => DllCall('xcgui\XEditor_SetStyleComment', 'ptr', this, 'int', iStyle)
  SetStyleNumber(iStyle) => DllCall('xcgui\XEditor_SetStyleNumber', 'ptr', this, 'int', iStyle)
  GetBreakpointCount() => DllCall('xcgui\XEditor_GetBreakpointCount', 'ptr', this, 'int')
  GetBreakpoints() {
    buf := Buffer(4 * (s := 20)), aPoints := []
    while (s := DllCall('xcgui\XEditor_GetBreakpoints', 'ptr', this, 'ptr', buf, 'int', 20, 'int')) {
      loop s
        aPoints.Push(NumGet(buf, (A_Index - 1) * 4, 'int'))
    }
    return aPoints
  }
  SetCurRow(iRow) => DllCall('xcgui\XEditor_SetCurRow', 'ptr', this, 'int', iRow)
  GetDepth(iRow) => DllCall('xcgui\XEditor_GetDepth', 'ptr', this, 'int', iRow, 'int')
  ToExpandRow(iRow) => DllCall('xcgui\XEditor_ToExpandRow', 'ptr', this, 'int', iRow, 'int')
  ExpandAll(bExpand) => DllCall('xcgui\XEditor_ExpandAll', 'ptr', this, 'int', bExpand)
  Expand(iRow, bExpand) => DllCall('xcgui\XEditor_Expand', 'ptr', this, 'int', iRow, 'int', bExpand)
  AddKeyword(Key, iStyle) => DllCall('xcgui\XEditor_AddKeyword', 'ptr', this, 'wstr', Key, 'int', iStyle)
  AddConst(Key) => DllCall('xcgui\XEditor_AddConst', 'ptr', this, 'wstr', Key)
  AddFunction(Key) => DllCall('xcgui\XEditor_AddFunction', 'ptr', this, 'wstr', Key)
}
class CXComboBox extends CXEdit {
  static Create(x, y, cx, cy, hParent := 0) {
    if hEle := DllCall('xcgui\XComboBox_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent, 'ptr')
      return {Base: CXComboBox.Prototype, ptr: hEle}
  }
  __New(x, y, cx, cy, hParent := 0) {
    if !hEle := DllCall('xcgui\XComboBox_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent)
      throw
    this.ptr := hEle
  }
  SetSelItem(iIndex) => DllCall('xcgui\XComboBox_SetSelItem', 'ptr', this, 'int', iIndex, 'int')
  CreateAdapter() => DllCall('xcgui\XComboBox_CreateAdapter', 'ptr', this, 'ptr')
  BindAdapter(hAdapter) => DllCall('xcgui\XComboBox_BindAdapter', 'ptr', this, 'ptr', hAdapter)
  GetAdapter() => DllCall('xcgui\XComboBox_GetAdapter', 'ptr', this, 'ptr')
  GetBkInfoCount() => DllCall('xcgui\XComboboX_GetBkInfoCount', 'ptr', this, 'int')
  SetBindName(Name) => DllCall('xcgui\XComboBox_SetBindName', 'ptr', this, 'wstr', Name)
  GetButtonRect(pRect) => DllCall('xcgui\XComboBox_GetButtonRect', 'ptr', this, 'ptr', pRect)
  SetButtonSize(size) => DllCall('xcgui\XComboBox_SetButtonSize', 'ptr', this, 'int', size)
  SetDropHeight(height) => DllCall('xcgui\XComboBox_SetDropHeight', 'ptr', this, 'int', height)
  GetDropHeight() => DllCall('xcgui\XComboBox_GetDropHeight', 'ptr', this, 'int')
  SetItemTemplateXML(XmlFile) => DllCall('xcgui\XComboBox_SetItemTemplateXML', 'ptr', this, 'wstr', XmlFile)
  SetItemTemplateXMLFromString(StringXML) => DllCall('xcgui\XComboBox_SetItemTemplateXMLFromString', 'ptr', this, 'astr', StringXML)
  EnableDrawButton(bEnable) => DllCall('xcgui\XComboBox_EnableDrawButton', 'ptr', this, 'int', bEnable)
  EnableEdit(bEdit) => DllCall('xcgui\XComboBox_EnableEdit', 'ptr', this, 'int', bEdit)
  EnableDropHeightFixed(bEnable) => DllCall('xcgui\XComboBox_EnableDropHeightFixed', 'ptr', this, 'int', bEnable)
  AddBkBorder(nState, color, alpha, width) => DllCall('xcgui\XComboBox_AddBkBorder', 'ptr', this, 'int', nState, 'uint', color, 'uchar', alpha, 'int', width)
  AddBkFill(nState, color, alpha) => DllCall('xcgui\XComboBox_AddBkFill', 'ptr', this, 'int', nState, 'uint', color, 'uchar', alpha)
  AddBkImage(nState, hImage) => DllCall('xcgui\XComboBox_AddBkImage', 'ptr', this, 'int', nState, 'ptr', hImage)
  ClearBkInfo() => DllCall('xcgui\XComboBox_ClearBkInfo', 'ptr', this)
  GetSelItem() => DllCall('xcgui\XComboBox_GetSelItem', 'ptr', this, 'int')
  GetState() => DllCall('xcgui\XComboBox_GetState', 'ptr', this, 'int')
  AddItemText(Text) => DllCall('xcgui\XComboBox_AddItemText', 'ptr', this, 'wstr', Text, 'int')
  AddItemTextEx(Name, Text) => DllCall('xcgui\XComboBox_AddItemTextEx', 'ptr', this, 'wstr', Name, 'wstr', Text, 'int')
  AddItemImage(hImage) => DllCall('xcgui\XComboBox_AddItemImage', 'ptr', this, 'ptr', hImage, 'int')
  AddItemImageEx(Name, hImage) => DllCall('xcgui\XComboBox_AddItemImageEx', 'ptr', this, 'wstr', Name, 'ptr', hImage, 'int')
  InsertItemText(iItem, Value) => DllCall('xcgui\XComboBox_InsertItemText', 'ptr', this, 'int', iItem, 'wstr', Value, 'int')
  InsertItemTextEx(iItem, Name, Value) => DllCall('xcgui\XComboBox_InsertItemTextEx', 'ptr', this, 'int', iItem, 'wstr', Name, 'wstr', Value, 'int')
  InsertItemImage(iItem, hImage) => DllCall('xcgui\XComboBox_InsertItemImage', 'ptr', this, 'int', iItem, 'ptr', hImage, 'int')
  InsertItemImageEx(iItem, Name, hImage) => DllCall('xcgui\XComboBox_InsertItemImageEx', 'ptr', this, 'int', iItem, 'wstr', Name, 'ptr', hImage, 'int')
  SetItemText(iItem, iColumn, Text) => DllCall('xcgui\XComboBox_SetItemText', 'ptr', this, 'int', iItem, 'int', iColumn, 'wstr', Text, 'int')
  SetItemTextEx(iItem, Name, Text) => DllCall('xcgui\XComboBox_SetItemTextEx', 'ptr', this, 'int', iItem, 'wstr', Name, 'wstr', Text, 'int')
  SetItemImage(iItem, iColumn, hImage) => DllCall('xcgui\XComboBox_SetItemImage', 'ptr', this, 'int', iItem, 'int', iColumn, 'ptr', hImage, 'int')
  SetItemImageEx(iItem, Name, hImage) => DllCall('xcgui\XComboBox_SetItemImageEx', 'ptr', this, 'int', iItem, 'wstr', Name, 'ptr', hImage, 'int')
  SetItemInt(iItem, iColumn, nValue) => DllCall('xcgui\XComboBox_SetItemInt', 'ptr', this, 'int', iItem, 'int', iColumn, 'int', nValue, 'int')
  SetItemIntEx(iItem, Name, nValue) => DllCall('xcgui\XComboBox_SetItemIntEx', 'ptr', this, 'int', iItem, 'wstr', Name, 'int', nValue, 'int')
  SetItemFloat(iItem, iColumn, fFloat) => DllCall('xcgui\XComboBox_SetItemFloat', 'ptr', this, 'int', iItem, 'int', iColumn, 'float', fFloat, 'int')
  SetItemFloatEx(iItem, Name, fFloat) => DllCall('xcgui\XComboBox_SetItemFloatEx', 'ptr', this, 'int', iItem, 'wstr', Name, 'float', fFloat, 'int')
  GetItemText(iItem, iColumn) => DllCall('xcgui\XComboBox_GetItemText', 'ptr', this, 'int', iItem, 'int', iColumn, 'wstr')
  GetItemTextEx(iItem, Name) => DllCall('xcgui\XComboBox_GetItemTextEx', 'ptr', this, 'int', iItem, 'wstr', Name, 'wstr')
  GetItemImage(iItem, iColumn) => DllCall('xcgui\XComboBox_GetItemImage', 'ptr', this, 'int', iItem, 'int', iColumn, 'ptr')
  GetItemImageEx(iItem, Name) => DllCall('xcgui\XComboBox_GetItemImageEx', 'ptr', this, 'int', iItem, 'wstr', Name, 'ptr')
  GetItemInt(iItem, iColumn, &OutValue) => DllCall('xcgui\XComboBox_GetItemInt', 'ptr', this, 'int', iItem, 'int', iColumn, 'int*', &OutValue, 'int')
  GetItemIntEx(iItem, Name, &OutValue) => DllCall('xcgui\XComboBox_GetItemIntEx', 'ptr', this, 'int', iItem, 'wstr', Name, 'int*', &OutValue, 'int')
  GetItemFloat(iItem, iColumn, &OutValue) => DllCall('xcgui\XComboBox_GetItemFloat', 'ptr', this, 'int', iItem, 'int', iColumn, 'float*', &OutValue, 'int')
  GetItemFloatEx(iItem, Name, &OutValue) => DllCall('xcgui\XComboBox_GetItemFloatEx', 'ptr', this, 'int', iItem, 'wstr', Name, 'float*', &OutValue, 'int')
  DeleteItem(iItem) => DllCall('xcgui\XComboBox_DeleteItem', 'ptr', this, 'int', iItem, 'int')
  DeleteItemEx(iItem, nCount) => DllCall('xcgui\XComboBox_DeleteItemEx', 'ptr', this, 'int', iItem, 'int', nCount, 'int')
  DeleteItemAll() => DllCall('xcgui\XComboBox_DeleteItemAll', 'ptr', this)
  DeleteColumnAll() => DllCall('xcgui\XComboBox_DeleteColumnAll', 'ptr', this)
  GetCount() => DllCall('xcgui\XComboBox_GetCount', 'ptr', this, 'int')
  GetCountColumn() => DllCall('xcgui\XComboBox_GetCountColumn', 'ptr', this, 'int')
}
class CXListBox extends CXScrollView {
  static Create(x, y, cx, cy, hParent := 0) {
    if hEle := DllCall('xcgui\XListBox_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent, 'ptr')
      return {Base: CXListBox.Prototype, ptr: hEle}
  }
  __New(x, y, cx, cy, hParent := 0) {
    if !hEle := DllCall('xcgui\XListBox_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent)
      throw
    this.ptr := hEle
  }
  EnableFixedRowHeight(bEnable) => DllCall('xcgui\XListBox_EnableFixedRowHeight', 'ptr', this, 'int', bEnable)
  EnableVirtualTable(bEnable) => DllCall('xcgui\XListBox_EnableVirtualTable', 'ptr', this, 'int', bEnable)
  SetVirtualRowCount(nRowCount) => DllCall('xcgui\XListBox_SetVirtualRowCount', 'ptr', this, 'int', nRowCount)
  SetDrawItemBkFlags(nFlags) => DllCall('xcgui\XListBox_SetDrawItemBkFlags', 'ptr', this, 'int', nFlags)
  SetItemData(iItem, nUserData) => DllCall('xcgui\XListBox_SetItemData', 'ptr', this, 'int', iItem, 'ptr', nUserData, 'int')
  GetItemData(iItem) => DllCall('xcgui\XListBox_GetItemData', 'ptr', this, 'int', iItem, 'ptr')
  AddItemBkBorder(nState, color, alpha, width) => DllCall('xcgui\XListBox_AddItemBkBorder', 'ptr', this, 'int', nState, 'uint', color, 'uchar', alpha, 'int', width)
  AddItemBkFill(nState, color, alpha) => DllCall('xcgui\XListBox_AddItemBkFill', 'ptr', this, 'int', nState, 'uint', color, 'uchar', alpha)
  AddItemBkImage(nState, hImage) => DllCall('xcgui\XListBox_AddItemBkImage', 'ptr', this, 'int', nState, 'ptr', hImage)
  GetItemBkInfoCount() => DllCall('xcgui\XListBox_GetItemBkInfoCount', 'ptr', this, 'int')
  ClearItemBkInfo() => DllCall('xcgui\XListBox_ClearItemBkInfo', 'ptr', this)
  SetItemInfo(iItem, pItem) => DllCall('xcgui\XListBox_SetItemInfo', 'ptr', this, 'int', iItem, 'ptr', pItem, 'int')
  GetItemInfo(iItem, pItem) => DllCall('xcgui\XListBox_GetItemInfo', 'ptr', this, 'int', iItem, 'ptr', pItem, 'int')
  SetSelectItem(iItem) => DllCall('xcgui\XListBox_SetSelectItem', 'ptr', this, 'int', iItem, 'int')
  GetSelectItem() => DllCall('xcgui\XListBox_GetSelectItem', 'ptr', this, 'int')
  AddSelectItem(iItem) => DllCall('xcgui\XListBox_AddSelectItem', 'ptr', this, 'int', iItem, 'int')
  CancelSelectItem(iItem) => DllCall('xcgui\XListBox_CancelSelectItem', 'ptr', this, 'int', iItem, 'int')
  CancelSelectAll() => DllCall('xcgui\XListBox_CancelSelectAll', 'ptr', this, 'int')
  GetSelectAll(pArray, nArraySize) {
    buf := Buffer(4 * (s := 20)), sels := []
    while (s := DllCall('xcgui\XListBox_GetSelectAll', 'ptr', this, 'ptr', buf.Ptr, 'int', 20, 'int')) {
      loop s
        sels.Push(NumGet(buf, 4 * (A_Index - 1), 'int'))
    }
    return sels
  }
  GetSelectCount() => DllCall('xcgui\XListBox_GetSelectCount', 'ptr', this, 'int')
  GetItemMouseStay() => DllCall('xcgui\XListBox_GetItemMouseStay', 'ptr', this, 'int')
  SelectAll() => DllCall('xcgui\XListBox_SelectAll', 'ptr', this, 'int')
  VisibleItem(iItem) => DllCall('xcgui\XListBox_VisibleItem', 'ptr', this, 'int', iItem)
  GetVisibleRowRange(&iStart, &iEnd) => DllCall('xcgui\XListBox_GetVisibleRowRange', 'ptr', this, 'int*', &iStart, 'int*', &iEnd)
  SetItemHeightDefault(nHeight, nSelHeight) => DllCall('xcgui\XListBox_SetItemHeightDefault', 'ptr', this, 'int', nHeight, 'int', nSelHeight)
  GetItemHeightDefault(&Height, &SelHeight) => DllCall('xcgui\XListBox_GetItemHeightDefault', 'ptr', this, 'int*', &Height, 'int*', &SelHeight)
  GetItemIndexFromHXCGUI(hXCGUI) => DllCall('xcgui\XListBox_GetItemIndexFromHXCGUI', 'ptr', this, 'ptr', hXCGUI, 'int')
  SetRowSpace(nSpace) => DllCall('xcgui\XListBox_SetRowSpace', 'ptr', this, 'int', nSpace)
  GetRowSpace() => DllCall('xcgui\XListBox_GetRowSpace', 'ptr', this, 'int')
  HitTest(pPt) => DllCall('xcgui\XListBox_HitTest', 'ptr', this, 'ptr', pPt, 'int')
  HitTestOffset(pPt) => DllCall('xcgui\XListBox_HitTestOffset', 'ptr', this, 'ptr', pPt, 'int')
  SetItemTemplateXML(XmlFile) => DllCall('xcgui\XListBox_SetItemTemplateXML', 'ptr', this, 'wstr', XmlFile, 'int')
  SetItemTemplate(hTemp) => DllCall('xcgui\XListBox_SetItemTemplate', 'ptr', this, 'ptr', hTemp, 'int')
  SetItemTemplateXMLFromString(StringXML) => DllCall('xcgui\XListBox_SetItemTemplateXMLFromString', 'ptr', this, 'astr', StringXML, 'int')
  GetTemplateObject(iItem, nTempItemID) => DllCall('xcgui\XListBox_GetTemplateObject', 'ptr', this, 'int', iItem, 'int', nTempItemID, 'ptr')
  EnableMultiSel(bEnable) => DllCall('xcgui\XListBox_EnableMultiSel', 'ptr', this, 'int', bEnable)
  CreateAdapter() => DllCall('xcgui\XListBox_CreateAdapter', 'ptr', this, 'ptr')
  BindAdapter(hAdapter) => DllCall('xcgui\XListBox_BindAdapter', 'ptr', this, 'ptr', hAdapter)
  GetAdapter() => DllCall('xcgui\XListBox_GetAdapter', 'ptr', this, 'ptr')
  Sort(iColumnAdapter, bAscending) => DllCall('xcgui\XListBox_Sort', 'ptr', this, 'int', iColumnAdapter, 'int', bAscending)
  RefreshData() => DllCall('xcgui\XListBox_RefreshData', 'ptr', this)
  RefreshItem(iItem) => DllCall('xcgui\XListBox_RefreshItem', 'ptr', this, 'int', iItem)
  AddItemText(Text) => DllCall('xcgui\XListBox_AddItemText', 'ptr', this, 'wstr', Text, 'int')
  AddItemTextEx(Name, Text) => DllCall('xcgui\XListBox_AddItemTextEx', 'ptr', this, 'wstr', Name, 'wstr', Text, 'int')
  AddItemImage(hImage) => DllCall('xcgui\XListBox_AddItemImage', 'ptr', this, 'ptr', hImage, 'int')
  AddItemImageEx(Name, hImage) => DllCall('xcgui\XListBox_AddItemImageEx', 'ptr', this, 'wstr', Name, 'ptr', hImage, 'int')
  InsertItemText(iItem, Value) => DllCall('xcgui\XListBox_InsertItemText', 'ptr', this, 'int', iItem, 'wstr', Value, 'int')
  InsertItemTextEx(iItem, Name, Value) => DllCall('xcgui\XListBox_InsertItemTextEx', 'ptr', this, 'int', iItem, 'wstr', Name, 'wstr', Value, 'int')
  InsertItemImage(iItem, hImage) => DllCall('xcgui\XListBox_InsertItemImage', 'ptr', this, 'int', iItem, 'ptr', hImage, 'int')
  InsertItemImageEx(iItem, Name, hImage) => DllCall('xcgui\XListBox_InsertItemImageEx', 'ptr', this, 'int', iItem, 'wstr', Name, 'ptr', hImage, 'int')
  SetItemText(iItem, iColumn, Text) => DllCall('xcgui\XListBox_SetItemText', 'ptr', this, 'int', iItem, 'int', iColumn, 'wstr', Text, 'int')
  SetItemTextEx(iItem, Name, Text) => DllCall('xcgui\XListBox_SetItemTextEx', 'ptr', this, 'int', iItem, 'wstr', Name, 'wstr', Text, 'int')
  SetItemImage(iItem, iColumn, hImage) => DllCall('xcgui\XListBox_SetItemImage', 'ptr', this, 'int', iItem, 'int', iColumn, 'ptr', hImage, 'int')
  SetItemImageEx(iItem, Name, hImage) => DllCall('xcgui\XListBox_SetItemImageEx', 'ptr', this, 'int', iItem, 'wstr', Name, 'ptr', hImage, 'int')
  SetItemInt(iItem, iColumn, nValue) => DllCall('xcgui\XListBox_SetItemInt', 'ptr', this, 'int', iItem, 'int', iColumn, 'int', nValue, 'int')
  SetItemIntEx(iItem, Name, nValue) => DllCall('xcgui\XListBox_SetItemIntEx', 'ptr', this, 'int', iItem, 'wstr', Name, 'int', nValue, 'int')
  SetItemFloat(iItem, iColumn, fFloat) => DllCall('xcgui\XListBox_SetItemFloat', 'ptr', this, 'int', iItem, 'int', iColumn, 'float', fFloat, 'int')
  SetItemFloatEx(iItem, Name, fFloat) => DllCall('xcgui\XListBox_SetItemFloatEx', 'ptr', this, 'int', iItem, 'wstr', Name, 'float', fFloat, 'int')
  GetItemText(iItem, iColumn) => DllCall('xcgui\XListBox_GetItemText', 'ptr', this, 'int', iItem, 'int', iColumn, 'wstr')
  GetItemTextEx(iItem, Name) => DllCall('xcgui\XListBox_GetItemTextEx', 'ptr', this, 'int', iItem, 'wstr', Name, 'wstr')
  GetItemImage(iItem, iColumn) => DllCall('xcgui\XListBox_GetItemImage', 'ptr', this, 'int', iItem, 'int', iColumn, 'ptr')
  GetItemImageEx(iItem, Name) => DllCall('xcgui\XListBox_GetItemImageEx', 'ptr', this, 'int', iItem, 'wstr', Name, 'ptr')
  GetItemInt(iItem, iColumn, &OutValue) => DllCall('xcgui\XListBox_GetItemInt', 'ptr', this, 'int', iItem, 'int', iColumn, 'int*', &OutValue, 'int')
  GetItemIntEx(iItem, Name, &OutValue) => DllCall('xcgui\XListBox_GetItemIntEx', 'ptr', this, 'int', iItem, 'wstr', Name, 'int*', &OutValue, 'int')
  GetItemFloat(iItem, iColumn, &OutValue) => DllCall('xcgui\XListBox_GetItemFloat', 'ptr', this, 'int', iItem, 'int', iColumn, 'float*', &OutValue, 'int')
  GetItemFloatEx(iItem, Name, &OutValue) => DllCall('xcgui\XListBox_GetItemFloatEx', 'ptr', this, 'int', iItem, 'wstr', Name, 'float*', &OutValue, 'int')
  DeleteItem(iItem) => DllCall('xcgui\XListBox_DeleteItem', 'ptr', this, 'int', iItem, 'int')
  DeleteItemEx(iItem, nCount) => DllCall('xcgui\XListBox_DeleteItemEx', 'ptr', this, 'int', iItem, 'int', nCount, 'int')
  DeleteItemAll() => DllCall('xcgui\XListBox_DeleteItemAll', 'ptr', this)
  DeleteColumnAll() => DllCall('xcgui\XListBox_DeleteColumnAll', 'ptr', this)
  GetCount_AD() => DllCall('xcgui\XListBox_GetCount_AD', 'ptr', this, 'int')
  GetCountColumn_AD() => DllCall('xcgui\XListBox_GetCountColumn_AD', 'ptr', this, 'int')
}
class CXList extends CXScrollView {
  static Create(x, y, cx, cy, hParent := 0) {
    if hEle := DllCall('xcgui\XList_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent, 'ptr')
      return {Base: CXList.Prototype, ptr: hEle}
  }
  __New(x, y, cx, cy, hParent := 0) {
    if !hEle := DllCall('xcgui\XList_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent)
      throw
    this.ptr := hEle
  }
  AddColumn(width) => DllCall('xcgui\XList_AddColumn', 'ptr', this, 'int', width, 'int')
  InsertColumn(width, iItem) => DllCall('xcgui\XList_InsertColumn', 'ptr', this, 'int', width, 'int', iItem, 'int')
  EnableMultiSel(bEnable) => DllCall('xcgui\XList_EnableMultiSel', 'ptr', this, 'int', bEnable)
  EnableDragChangeColumnWidth(bEnable) => DllCall('xcgui\XList_EnableDragChangeColumnWidth', 'ptr', this, 'int', bEnable)
  EnableVScrollBarTop(bTop) => DllCall('xcgui\XList_EnableVScrollBarTop', 'ptr', this, 'int', bTop)
  EnableItemBkFullRow(bFull) => DllCall('xcgui\XList_EnableItemBkFullRow', 'ptr', this, 'int', bFull)
  EnableFixedRowHeight(bEnable) => DllCall('xcgui\XList_EnableFixedRowHeight', 'ptr', this, 'int', bEnable)
  EnableVirtualTable(bEnable) => DllCall('xcgui\XList_EnableVirtualTable', 'ptr', this, 'int', bEnable)
  SetVirtualRowCount(nRowCount) => DllCall('xcgui\XList_SetVirtualRowCount', 'ptr', this, 'int', nRowCount)
  SetSort(iColumn, iColumnAdapter, bEnable) => DllCall('xcgui\XList_SetSort', 'ptr', this, 'int', iColumn, 'int', iColumnAdapter, 'int', bEnable)
  SetDrawItemBkFlags(style) => DllCall('xcgui\XList_SetDrawItemBkFlags', 'ptr', this, 'int', style)
  SetColumnWidth(iItem, width) => DllCall('xcgui\XList_SetColumnWidth', 'ptr', this, 'int', iItem, 'int', width)
  SetColumnMinWidth(iItem, width) => DllCall('xcgui\XList_SetColumnMinWidth', 'ptr', this, 'int', iItem, 'int', width)
  SetColumnWidthFixed(iColumn, bFixed) => DllCall('xcgui\XList_SetColumnWidthFixed', 'ptr', this, 'int', iColumn, 'int', bFixed)
  GetColumnWidth(iColumn) => DllCall('xcgui\XList_GetColumnWidth', 'ptr', this, 'int', iColumn, 'int')
  GetColumnCount() => DllCall('xcgui\XList_GetColumnCount', 'ptr', this, 'int')
  SetItemData(iItem, iSubItem, data) => DllCall('xcgui\XList_SetItemData', 'ptr', this, 'int', iItem, 'int', iSubItem, 'int', data, 'int')
  GetItemData(iItem, iSubItem) => DllCall('xcgui\XList_GetItemData', 'ptr', this, 'int', iItem, 'int', iSubItem, 'int')
  SetSelectItem(iItem) => DllCall('xcgui\XList_SetSelectItem', 'ptr', this, 'int', iItem, 'int')
  GetSelectItem() => DllCall('xcgui\XList_GetSelectItem', 'ptr', this, 'int')
  GetSelectItemCount() => DllCall('xcgui\XList_GetSelectItemCount', 'ptr', this, 'int')
  AddSelectItem(iItem) => DllCall('xcgui\XList_AddSelectItem', 'ptr', this, 'int', iItem, 'int')
  SetSelectAll() => DllCall('xcgui\XList_SetSelectAll', 'ptr', this)
  GetSelectAll() {
    buf := Buffer(4 * (s := 20)), sels := []
    while (s := DllCall('xcgui\XList_GetSelectAll', 'ptr', this, 'ptr', buf.Ptr, 'int', 20, 'int')) {
      loop s
        sels.Push(NumGet(buf, 4 * (A_Index - 1), 'int'))
    }
    return sels
  }
  VisibleItem(iItem) => DllCall('xcgui\XList_VisibleItem', 'ptr', this, 'int', iItem)
  CancelSelectItem(iItem) => DllCall('xcgui\XList_CancelSelectItem', 'ptr', this, 'int', iItem, 'int')
  CancelSelectAll() => DllCall('xcgui\XList_CancelSelectAll', 'ptr', this)
  GetHeaderHELE() => DllCall('xcgui\XList_GetHeaderHELE', 'ptr', this, 'ptr')
  DeleteColumn(iItem) => DllCall('xcgui\XList_DeleteColumn', 'ptr', this, 'int', iItem, 'int')
  DeleteColumnAll() => DllCall('xcgui\XList_DeleteColumnAll', 'ptr', this)
  BindAdapter(hAdapter) => DllCall('xcgui\XList_BindAdapter', 'ptr', this, 'ptr', hAdapter)
  BindAdapterHeader(hAdapter) => DllCall('xcgui\XList_BindAdapterHeader', 'ptr', this, 'ptr', hAdapter)
  CreateAdapter() => DllCall('xcgui\XList_CreateAdapter', 'ptr', this, 'ptr')
  CreateAdapterHeader() => DllCall('xcgui\XList_CreateAdapterHeader', 'ptr', this, 'ptr')
  GetAdapter() => DllCall('xcgui\XList_GetAdapter', 'ptr', this, 'ptr')
  GetAdapterHeader() => DllCall('xcgui\XList_GetAdapterHeader', 'ptr', this, 'ptr')
  SetItemTemplateXML(XmlFile) => DllCall('xcgui\XList_SetItemTemplateXML', 'ptr', this, 'wstr', XmlFile, 'int')
  SetItemTemplateXMLFromString(StringXML) => DllCall('xcgui\XList_SetItemTemplateXMLFromString', 'ptr', this, 'astr', StringXML, 'int')
  SetItemTemplate(hTemp) => DllCall('xcgui\XList_SetItemTemplate', 'ptr', this, 'ptr', hTemp, 'int')
  GetTemplateObject(iItem, iSubItem, nTempItemID) => DllCall('xcgui\XList_GetTemplateObject', 'ptr', this, 'int', iItem, 'int', iSubItem, 'int', nTempItemID, 'ptr')
  GetItemIndexFromHXCGUI(hXCGUI) => DllCall('xcgui\XList_GetItemIndexFromHXCGUI', 'ptr', this, 'ptr', hXCGUI, 'int')
  GetHeaderTemplateObject(iItem, nTempItemID) => DllCall('xcgui\XList_GetHeaderTemplateObject', 'ptr', this, 'int', iItem, 'int', nTempItemID, 'ptr')
  GetHeaderItemIndexFromHXCGUI(hXCGUI) => DllCall('xcgui\XList_GetHeaderItemIndexFromHXCGUI', 'ptr', this, 'ptr', hXCGUI, 'int')
  SetHeaderHeight(height) => DllCall('xcgui\XList_SetHeaderHeight', 'ptr', this, 'int', height)
  GetHeaderHeight() => DllCall('xcgui\XList_GetHeaderHeight', 'ptr', this, 'int')
  GetVisibleRowRange(&iStart, &iEnd) => DllCall('xcgui\XList_GetVisibleRowRange', 'ptr', this, 'int*', &iStart, 'int*', &iEnd)
  AddItemBkBorder(nState, color, alpha, width) => DllCall('xcgui\XList_AddItemBkBorder', 'ptr', this, 'int', nState, 'uint', color, 'uchar', alpha, 'int', width)
  AddItemBkFill(nState, color, alpha) => DllCall('xcgui\XList_AddItemBkFill', 'ptr', this, 'int', nState, 'uint', color, 'uchar', alpha)
  AddItemBkImage(nState, hImage) => DllCall('xcgui\XList_AddItemBkImage', 'ptr', this, 'int', nState, 'ptr', hImage)
  GetItemBkInfoCount() => DllCall('xcgui\XList_GetItemBkInfoCount', 'ptr', this, 'int')
  ClearItemBkInfo() => DllCall('xcgui\XList_ClearItemBkInfo', 'ptr', this)
  SetItemHeightDefault(nHeight, nSelHeight) => DllCall('xcgui\XList_SetItemHeightDefault', 'ptr', this, 'int', nHeight, 'int', nSelHeight)
  GetItemHeightDefault(&Height, &SelHeight) => DllCall('xcgui\XList_GetItemHeightDefault', 'ptr', this, 'int*', &Height, 'int*', &SelHeight)
  SetRowSpace(nSpace) => DllCall('xcgui\XList_SetRowSpace', 'ptr', this, 'int', nSpace)
  GetRowSpace() => DllCall('xcgui\XList_GetRowSpace', 'ptr', this, 'int')
  SetLockColumnLeft(iColumn) => DllCall('xcgui\XList_SetLockColumnLeft', 'ptr', this, 'int', iColumn)
  SetLockColumnRight(iColumn) => DllCall('xcgui\XList_SetLockColumnRight', 'ptr', this, 'int', iColumn)
  SetLockRowBottom(bLock) => DllCall('xcgui\XList_SetLockRowBottom', 'ptr', this, 'int', bLock)
  SetLockRowBottomOverlap(bOverlap) => DllCall('xcgui\XList_SetLockRowBottomOverlap', 'ptr', this, 'int', bOverlap)
  HitTest(pPt, &iItem, &iSubItem) => DllCall('xcgui\XList_HitTest', 'ptr', this, 'ptr', pPt, 'int*', &iItem, 'int*', &iSubItem, 'int')
  HitTestOffset(pPt, &iItem, &iSubItem) => DllCall('xcgui\XList_HitTestOffset', 'ptr', this, 'ptr', pPt, 'int*', &iItem, 'int*', &iSubItem, 'int')
  RefreshData() => DllCall('xcgui\XList_RefreshData', 'ptr', this)
  RefreshItem(iItem) => DllCall('xcgui\XList_RefreshItem', 'ptr', this, 'int', iItem)
  AddColumnText(nWidth, Name, Text) => DllCall('xcgui\XList_AddColumnText', 'ptr', this, 'int', nWidth, 'wstr', Name, 'wstr', Text, 'int')
  AddColumnImage(nWidth, Name, hImage) => DllCall('xcgui\XList_AddColumnImage', 'ptr', this, 'int', nWidth, 'wstr', Name, 'ptr', hImage, 'int')
  AddItemText(Text) => DllCall('xcgui\XList_AddItemText', 'ptr', this, 'wstr', Text, 'int')
  AddItemTextEx(Name, Text) => DllCall('xcgui\XList_AddItemTextEx', 'ptr', this, 'wstr', Name, 'wstr', Text, 'int')
  AddItemImage(hImage) => DllCall('xcgui\XList_AddItemImage', 'ptr', this, 'ptr', hImage, 'int')
  AddItemImageEx(Name, hImage) => DllCall('xcgui\XList_AddItemImageEx', 'ptr', this, 'wstr', Name, 'ptr', hImage, 'int')
  InsertItemText(iItem, Value) => DllCall('xcgui\XList_InsertItemText', 'ptr', this, 'int', iItem, 'wstr', Value, 'int')
  InsertItemTextEx(iItem, Name, Value) => DllCall('xcgui\XList_InsertItemTextEx', 'ptr', this, 'int', iItem, 'wstr', Name, 'wstr', Value, 'int')
  InsertItemImage(iItem, hImage) => DllCall('xcgui\XList_InsertItemImage', 'ptr', this, 'int', iItem, 'ptr', hImage, 'int')
  InsertItemImageEx(iItem, Name, hImage) => DllCall('xcgui\XList_InsertItemImageEx', 'ptr', this, 'int', iItem, 'wstr', Name, 'ptr', hImage, 'int')
  SetItemText(iItem, iColumn, Text) => DllCall('xcgui\XList_SetItemText', 'ptr', this, 'int', iItem, 'int', iColumn, 'wstr', Text, 'int')
  SetItemTextEx(iItem, Name, Text) => DllCall('xcgui\XList_SetItemTextEx', 'ptr', this, 'int', iItem, 'wstr', Name, 'wstr', Text, 'int')
  SetItemImage(iItem, iColumn, hImage) => DllCall('xcgui\XList_SetItemImage', 'ptr', this, 'int', iItem, 'int', iColumn, 'ptr', hImage, 'int')
  SetItemImageEx(iItem, Name, hImage) => DllCall('xcgui\XList_SetItemImageEx', 'ptr', this, 'int', iItem, 'wstr', Name, 'ptr', hImage, 'int')
  SetItemInt(iItem, iColumn, nValue) => DllCall('xcgui\XList_SetItemInt', 'ptr', this, 'int', iItem, 'int', iColumn, 'int', nValue, 'int')
  SetItemIntEx(iItem, Name, nValue) => DllCall('xcgui\XList_SetItemIntEx', 'ptr', this, 'int', iItem, 'wstr', Name, 'int', nValue, 'int')
  SetItemFloat(iItem, iColumn, fFloat) => DllCall('xcgui\XList_SetItemFloat', 'ptr', this, 'int', iItem, 'int', iColumn, 'float', fFloat, 'int')
  SetItemFloatEx(iItem, Name, fFloat) => DllCall('xcgui\XList_SetItemFloatEx', 'ptr', this, 'int', iItem, 'wstr', Name, 'float', fFloat, 'int')
  GetItemText(iItem, iColumn) => DllCall('xcgui\XList_GetItemText', 'ptr', this, 'int', iItem, 'int', iColumn, 'wstr')
  GetItemTextEx(iItem, Name) => DllCall('xcgui\XList_GetItemTextEx', 'ptr', this, 'int', iItem, 'wstr', Name, 'wstr')
  GetItemImage(iItem, iColumn) => DllCall('xcgui\XList_GetItemImage', 'ptr', this, 'int', iItem, 'int', iColumn, 'ptr')
  GetItemImageEx(iItem, Name) => DllCall('xcgui\XList_GetItemImageEx', 'ptr', this, 'int', iItem, 'wstr', Name, 'ptr')
  GetItemInt(iItem, iColumn, &OutValue) => DllCall('xcgui\XList_GetItemInt', 'ptr', this, 'int', iItem, 'int', iColumn, 'int*', &OutValue, 'int')
  GetItemIntEx(iItem, Name, &OutValue) => DllCall('xcgui\XList_GetItemIntEx', 'ptr', this, 'int', iItem, 'wstr', Name, 'int*', &OutValue, 'int')
  GetItemFloat(iItem, iColumn, &OutValue) => DllCall('xcgui\XList_GetItemFloat', 'ptr', this, 'int', iItem, 'int', iColumn, 'float*', &OutValue, 'int')
  GetItemFloatEx(iItem, Name, &OutValue) => DllCall('xcgui\XList_GetItemFloatEx', 'ptr', this, 'int', iItem, 'wstr', Name, 'float*', &OutValue, 'int')
  DeleteItem(iItem) => DllCall('xcgui\XList_DeleteItem', 'ptr', this, 'int', iItem, 'int')
  DeleteItemEx(iItem, nCount) => DllCall('xcgui\XList_DeleteItemEx', 'ptr', this, 'int', iItem, 'int', nCount, 'int')
  DeleteItemAll() => DllCall('xcgui\XList_DeleteItemAll', 'ptr', this)
  DeleteColumnAll_AD() => DllCall('xcgui\XList_DeleteColumnAll_AD', 'ptr', this)
  GetCount_AD() => DllCall('xcgui\XList_GetCount_AD', 'ptr', this, 'int')
  GetCountColumn_AD() => DllCall('xcgui\XList_GetCountColumn_AD', 'ptr', this, 'int')
}
class CXListView extends CXScrollView {
  static Create(x, y, cx, cy, hParent := 0) {
    if hEle := DllCall('xcgui\XListView_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent, 'ptr')
      return {Base: CXListView.Prototype, ptr: hEle}
  }
  __New(x, y, cx, cy, hParent := 0) {
    if !hEle := DllCall('xcgui\XListView_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent)
      throw
    this.ptr := hEle
  }
  CreateAdapter() => DllCall('xcgui\XListView_CreateAdapter', 'ptr', this, 'ptr')
  BindAdapter(hAdapter) => DllCall('xcgui\XListView_BindAdapter', 'ptr', this, 'ptr', hAdapter)
  GetAdapter() => DllCall('xcgui\XListView_GetAdapter', 'ptr', this, 'ptr')
  SetItemTemplateXML(XmlFile) => DllCall('xcgui\XListView_SetItemTemplateXML', 'ptr', this, 'wstr', XmlFile, 'int')
  SetItemTemplateXMLFromString(StringXML) => DllCall('xcgui\XListView_SetItemTemplateXMLFromString', 'ptr', this, 'astr', StringXML, 'int')
  SetItemTemplate(hTemp) => DllCall('xcgui\XListView_SetItemTemplate', 'ptr', this, 'ptr', hTemp, 'int')
  GetTemplateObject(iGroup, iItem, nTempItemID) => DllCall('xcgui\XListView_GetTemplateObject', 'ptr', this, 'int', iGroup, 'int', iItem, 'int', nTempItemID, 'ptr')
  GetTemplateObjectGroup(iGroup, nTempItemID) => DllCall('xcgui\XListView_GetTemplateObjectGroup', 'ptr', this, 'int', iGroup, 'int', nTempItemID, 'ptr')
  GetItemIDFromHXCGUI(hXCGUI, &iGroup, &iItem) => DllCall('xcgui\XListView_GetItemIDFromHXCGUI', 'ptr', this, 'ptr', hXCGUI, 'int*', &iGroup, 'int*', &iItem, 'int')
  HitTest(pPt, &OutGroup, &OutItem) => DllCall('xcgui\XListView_HitTest', 'ptr', this, 'ptr', pPt, 'int*', &OutGroup, 'int', &OutItem, 'int')
  HitTestOffset(pPt, &OutGroup, &OutItem) => DllCall('xcgui\XListView_HitTestOffset', 'ptr', this, 'ptr', pPt, 'int*', &OutGroup, 'int*', &OutItem, 'int')
  EnableMultiSel(bEnable) => DllCall('xcgui\XListView_EnableMultiSel', 'ptr', this, 'int', bEnable)
  EnableVirtualTable(bEnable) => DllCall('xcgui\XListView_EnableVirtualTable', 'ptr', this, 'int', bEnable)
  SetVirtualItemCount(iGroup, nCount) => DllCall('xcgui\XListView_SetVirtualItemCount', 'ptr', this, 'int', iGroup, 'int', nCount, 'int')
  SetDrawItemBkFlags(nFlags) => DllCall('xcgui\XListView_SetDrawItemBkFlags', 'ptr', this, 'int', nFlags)
  SetSelectItem(iGroup, iItem) => DllCall('xcgui\XListView_SetSelectItem', 'ptr', this, 'int', iGroup, 'int', iItem, 'int')
  GetSelectItem(&iGroup, &iItem) => DllCall('xcgui\XListView_GetSelectItem', 'ptr', this, 'int*', &iGroup, 'int*', &iItem, 'int')
  AddSelectItem(iGroup, iItem) => DllCall('xcgui\XListView_AddSelectItem', 'ptr', this, 'int', iGroup, 'int', iItem, 'int')
  VisibleItem(iGroup, iItem) => DllCall('xcgui\XListView_VisibleItem', 'ptr', this, 'int', iGroup, 'int', iItem)
  GetVisibleItemRange(&iGroup1, &iGroup2, &iStartGroup, &iStartItem, &iEndGroup, &iEndItem) => DllCall('xcgui\XListView_GetVisibleItemRange', 'ptr', this, 'int*', &iGroup1, 'int*', &iGroup2, 'int*', &iStartGroup, 'int*', &iStartItem, 'int*', &iEndGroup, 'int*', &iEndItem)
  GetSelectItemCount() => DllCall('xcgui\XListView_GetSelectItemCount', 'ptr', this, 'int')
  GetSelectAll(pArray, nArraySize) {
    buf := Buffer(4 * (s := 20)), sels := []
    while (s := DllCall('xcgui\XListView_GetSelectAll', 'ptr', this, 'ptr', pArray, 'int', nArraySize, 'int')) {
      loop s
        sels.Push(NumGet(buf, 4 * (A_Index - 1), 'int'))
    }
    return sels
  }
  SetSelectAll() => DllCall('xcgui\XListView_SetSelectAll', 'ptr', this)
  CancelSelectAll() => DllCall('xcgui\XListView_CancelSelectAll', 'ptr', this)
  SetColumnSpace(space) => DllCall('xcgui\XListView_SetColumnSpace', 'ptr', this, 'int', space)
  SetRowSpace(space) => DllCall('xcgui\XListView_SetRowSpace', 'ptr', this, 'int', space)
  SetItemSize(width, height) => DllCall('xcgui\XListView_SetItemSize', 'ptr', this, 'int', width, 'int', height)
  GetItemSize(pSize) => DllCall('xcgui\XListView_GetItemSize', 'ptr', this, 'ptr', pSize)
  SetGroupHeight(height) => DllCall('xcgui\XListView_SetGroupHeight', 'ptr', this, 'int', height)
  GetGroupHeight() => DllCall('xcgui\XListView_GetGroupHeight', 'ptr', this, 'int')
  SetGroupUserData(iGroup, nData) => DllCall('xcgui\XListView_SetGroupUserData', 'ptr', this, 'int', iGroup, 'ptr', nData)
  SetItemUserData(iGroup, iItem, nData) => DllCall('xcgui\XListView_SetItemUserData', 'ptr', this, 'int', iGroup, 'int', iItem, 'ptr', nData)
  GetGroupUserData(iGroup) => DllCall('xcgui\XListView_GetGroupUserData', 'ptr', this, 'int', iGroup, 'ptr')
  GetItemUserData(iGroup, iItem) => DllCall('xcgui\XListView_GetItemUserData', 'ptr', this, 'int', iGroup, 'int', iItem, 'ptr')
  AddItemBkBorder(nState, color, alpha, width) => DllCall('xcgui\XListView_AddItemBkBorder', 'ptr', this, 'int', nState, 'uint', color, 'uchar', alpha, 'int', width)
  AddItemBkFill(nState, color, alpha) => DllCall('xcgui\XListView_AddItemBkFill', 'ptr', this, 'int', nState, 'uint', color, 'uchar', alpha)
  AddItemBkImage(nState, hImage) => DllCall('xcgui\XListView_AddItemBkImage', 'ptr', this, 'int', nState, 'ptr', hImage)
  GetItemBkInfoCount() => DllCall('xcgui\XListView_GetItemBkInfoCount', 'ptr', this, 'int')
  ClearItemBkInfo() => DllCall('xcgui\XListView_ClearItemBkInfo', 'ptr', this)
  RefreshData() => DllCall('xcgui\XListView_RefreshData', 'ptr', this)
  RefreshItem(iGroup, iItem) => DllCall('xcgui\XListView_RefreshItem', 'ptr', this, 'int', iGroup, 'int', iItem)
  ExpandGroup(iGroup, bExpand) => DllCall('xcgui\XListView_ExpandGroup', 'ptr', this, 'int', iGroup, 'int', bExpand, 'int')
  Group_AddColumn(Name) => DllCall('xcgui\XListView_Group_AddColumn', 'ptr', this, 'wstr', Name, 'int')
  Group_AddItemText(Value, iPos) => DllCall('xcgui\XListView_Group_AddItemText', 'ptr', this, 'wstr', Value, 'int', iPos, 'int')
  Group_AddItemTextEx(Name, Value, iPos) => DllCall('xcgui\XListView_Group_AddItemTextEx', 'ptr', this, 'wstr', Name, 'wstr', Value, 'int', iPos, 'int')
  Group_AddItemImage(hImage, iPos) => DllCall('xcgui\XListView_Group_AddItemImage', 'ptr', this, 'ptr', hImage, 'int', iPos, 'int')
  Group_AddItemImageEx(Name, hImage, iPos) => DllCall('xcgui\XListView_Group_AddItemImageEx', 'ptr', this, 'wstr', Name, 'ptr', hImage, 'int', iPos, 'int')
  Group_SetText(iGroup, iColumn, Value) => DllCall('xcgui\XListView_Group_SetText', 'ptr', this, 'int', iGroup, 'int', iColumn, 'wstr', Value, 'int')
  Group_SetTextEx(iGroup, Name, Value) => DllCall('xcgui\XListView_Group_SetTextEx', 'ptr', this, 'int', iGroup, 'wstr', Name, 'wstr', Value, 'int')
  Group_SetImage(iGroup, iColumn, hImage) => DllCall('xcgui\XListView_Group_SetImage', 'ptr', this, 'int', iGroup, 'int', iColumn, 'ptr', hImage, 'int')
  Group_SetImageEx(iGroup, Name, hImage) => DllCall('xcgui\XListView_Group_SetImageEx', 'ptr', this, 'int', iGroup, 'wstr', Name, 'ptr', hImage, 'int')
  Group_GetCount() => DllCall('xcgui\XListView_Group_GetCount', 'ptr', this, 'int')
  Item_GetCount(iGroup) => DllCall('xcgui\XListView_Item_GetCount', 'ptr', this, 'int', iGroup, 'int')
  Item_AddColumn(Name) => DllCall('xcgui\XListView_Item_AddColumn', 'ptr', this, 'wstr', Name, 'int')
  Item_AddItemText(iGroup, Value, iPos) => DllCall('xcgui\XListView_Item_AddItemText', 'ptr', this, 'int', iGroup, 'wstr', Value, 'int', iPos, 'int')
  Item_AddItemTextEx(iGroup, Name, Value, iPos) => DllCall('xcgui\XListView_Item_AddItemTextEx', 'ptr', this, 'int', iGroup, 'wstr', Name, 'wstr', Value, 'int', iPos, 'int')
  Item_AddItemImage(iGroup, hImage, iPos) => DllCall('xcgui\XListView_Item_AddItemImage', 'ptr', this, 'int', iGroup, 'ptr', hImage, 'int', iPos, 'int')
  Item_AddItemImageEx(iGroup, Name, hImage, iPos) => DllCall('xcgui\XListView_Item_AddItemImageEx', 'ptr', this, 'int', iGroup, 'wstr', Name, 'ptr', hImage, 'int', iPos, 'int')
  Item_SetText(iGroup, iItem, iColumn, Value) => DllCall('xcgui\XListView_Item_SetText', 'ptr', this, 'int', iGroup, 'int', iItem, 'int', iColumn, 'wstr', Value, 'int')
  Item_SetTextEx(iGroup, iItem, Name, Value) => DllCall('xcgui\XListView_Item_SetTextEx', 'ptr', this, 'int', iGroup, 'int', iItem, 'wstr', Name, 'wstr', Value, 'int')
  Item_SetImage(iGroup, iItem, iColumn, hImage) => DllCall('xcgui\XListView_Item_SetImage', 'ptr', this, 'int', iGroup, 'int', iItem, 'int', iColumn, 'ptr', hImage, 'int')
  Item_SetImageEx(iGroup, iItem, Name, hImage) => DllCall('xcgui\XListView_Item_SetImageEx', 'ptr', this, 'int', iGroup, 'int', iItem, 'wstr', Name, 'ptr', hImage, 'int')
  Group_DeleteItem(iGroup) => DllCall('xcgui\XListView_Group_DeleteItem', 'ptr', this, 'int', iGroup, 'int')
  Group_DeleteAllChildItem(iGroup) => DllCall('xcgui\XListView_Group_DeleteAllChildItem', 'ptr', this, 'int', iGroup)
  Item_DeleteItem(iGroup, iItem) => DllCall('xcgui\XListView_Item_DeleteItem', 'ptr', this, 'int', iGroup, 'int', iItem, 'int')
  DeleteAll() => DllCall('xcgui\XListView_DeleteAll', 'ptr', this)
  DeleteAllGroup() => DllCall('xcgui\XListView_DeleteAllGroup', 'ptr', this)
  DeleteAllItem() => DllCall('xcgui\XListView_DeleteAllItem', 'ptr', this)
  DeleteColumnGroup(iColumn) => DllCall('xcgui\XListView_DeleteColumnGroup', 'ptr', this, 'int', iColumn)
  DeleteColumnItem(iColumn) => DllCall('xcgui\XListView_DeleteColumnItem', 'ptr', this, 'int', iColumn)
  Item_GetTextEx(iGroup, iItem, Name) => DllCall('xcgui\XListView_Item_GetTextEx', 'ptr', this, 'int', iGroup, 'int', iItem, 'wstr', Name, 'wstr')
  Item_GetImageEx(iGroup, iItem, Name) => DllCall('xcgui\XListView_Item_GetImageEx', 'ptr', this, 'int', iGroup, 'int', iItem, 'wstr', Name, 'ptr')
}
class CXMenuBar extends CXEle {
  static Create(x, y, cx, cy, hParent := 0) {
    if hEle := DllCall('xcgui\XMenuBar_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent, 'ptr')
      return {Base: CXMenuBar.Prototype, ptr: hEle}
  }
  __New(x, y, cx, cy, hParent := 0) {
    if !hEle := DllCall('xcgui\XMenuBar_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent)
      throw
    this.ptr := hEle
  }
  AddButton(Text) => DllCall('xcgui\XMenuBar_AddButton', 'ptr', this, 'wstr', Text, 'int')
  SetButtonHeight(height) => DllCall('xcgui\XMenuBar_SetButtonHeight', 'ptr', this, 'int', height)
  GetMenu(nIndex) => DllCall('xcgui\XMenuBar_GetMenu', 'ptr', this, 'int', nIndex, 'ptr')
  DeleteButton(nIndex) => DllCall('xcgui\XMenuBar_DeleteButton', 'ptr', this, 'int', nIndex, 'int')
}
class CXPane extends CXEle {
  static Create(Name, nWidth, nHeight, hFrameWnd := 0) {
    if hEle := DllCall('xcgui\XPane_Create', 'wstr', Name, 'int', nWidth, 'int', nHeight, 'ptr', hFrameWnd, 'ptr')
      return {Base: CXPane.Prototype, ptr: hEle}
  }
  __New(Name, nWidth, nHeight, hFrameWnd := 0) {
    if !hEle := DllCall('xcgui\XPane_Create', 'wstr', Name, 'int', nWidth, 'int', nHeight, 'ptr', hFrameWnd)
      throw
    this.ptr := hEle
  }
  SetView(hView) => DllCall('xcgui\XPane_SetView', 'ptr', this, 'ptr', hView)
  SetTitle(Title) => DllCall('xcgui\XPane_SetTitle', 'ptr', this, 'wstr', Title)
  GetTitle() => DllCall('xcgui\XPane_GetTitle', 'ptr', this, 'wstr')
  SetCaptionHeight(nHeight) => DllCall('xcgui\XPane_SetCaptionHeight', 'ptr', this, 'int', nHeight)
  GetCaptionHeight() => DllCall('xcgui\XPane_GetCaptionHeight', 'ptr', this, 'int')
  IsShowPane() => DllCall('xcgui\XPane_IsShowPane', 'ptr', this, 'int')
  SetSize(nWidth, nHeight) => DllCall('xcgui\XPane_SetSize', 'ptr', this, 'int', nWidth, 'int', nHeight)
  GetState() => DllCall('xcgui\XPane_GetState', 'ptr', this, 'int')
  GetViewRect(pRect) => DllCall('xcgui\XPane_GetViewRect', 'ptr', this, 'ptr', pRect)
  HidePane() => DllCall('xcgui\XPane_HidePane', 'ptr', this)
  ShowPane() => DllCall('xcgui\XPane_ShowPane', 'ptr', this)
  DockPane() => DllCall('xcgui\XPane_DockPane', 'ptr', this)
  LockPane() => DllCall('xcgui\XPane_LockPane', 'ptr', this)
  FloatPane() => DllCall('xcgui\XPane_FloatPane', 'ptr', this)
  DrawPane(hDraw) => DllCall('xcgui\XPane_DrawPane', 'ptr', this, 'ptr', hDraw)
  SetSelect() => DllCall('xcgui\XPane_SetSelect', 'ptr', this, 'int')
}
class CXProgressBar extends CXEle {
  static Create(x, y, cx, cy, hParent := 0) {
    if hEle := DllCall('xcgui\XProgBar_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent, 'ptr')
      return {Base: CXProgressBar.Prototype, ptr: hEle}
  }
  __New(x, y, cx, cy, hParent := 0) {
    if !hEle := DllCall('xcgui\XProgBar_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent)
      throw
    this.ptr := hEle
  }
  SetRange(range) => DllCall('xcgui\XProgBar_SetRange', 'ptr', this, 'int', range)
  GetRange() => DllCall('xcgui\XProgBar_GetRange', 'ptr', this, 'int')
  SetImageLoad(hImage) => DllCall('xcgui\XProgBar_SetImageLoad', 'ptr', this, 'ptr', hImage)
  SetSpaceTwo(leftSize, rightSize) => DllCall('xcgui\XProgBar_SetSpaceTwo', 'ptr', this, 'int', leftSize, 'int', rightSize)
  SetPos(pos) => DllCall('xcgui\XProgBar_SetPos', 'ptr', this, 'int', pos)
  GetPos() => DllCall('xcgui\XProgBar_GetPos', 'ptr', this, 'int')
  SetHorizon(bHorizon) => DllCall('xcgui\XProgBar_SetHorizon', 'ptr', this, 'int', bHorizon)
}
class CXRichEdit extends CXScrollView {
  static Create(x, y, cx, cy, hParent := 0) {
    if hEle := DllCall('xcgui\XRichEdit_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent, 'ptr')
      return {Base: CXRichEdit.Prototype, ptr: hEle}
  }
  __New(x, y, cx, cy, hParent := 0) {
    if !hEle := DllCall('xcgui\XRichEdit_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent)
      throw
    this.ptr := hEle
  }
  InsertString(String, hFont := 0) => DllCall('xcgui\XRichEdit_InsertString', 'ptr', this, 'wstr', String, 'ptr', hFont)
  InsertImage(hImage, ImagePath) => DllCall('xcgui\XRichEdit_InsertImage', 'ptr', this, 'ptr', hImage, 'wstr', ImagePath, 'int')
  InsertGif(hImage, ImagePath) => DllCall('xcgui\XRichEdit_InsertGif', 'ptr', this, 'ptr', hImage, 'wstr', ImagePath, 'int')
  InsertStringEx(iRow, iColumn, String, hFont := 0) => DllCall('xcgui\XRichEdit_InsertStringEx', 'ptr', this, 'int', iRow, 'int', iColumn, 'wstr', String, 'ptr', hFont)
  InsertImageEx(iRow, iColumn, hImage, ImagePath) => DllCall('xcgui\XRichEdit_InsertImageEx', 'ptr', this, 'int', iRow, 'int', iColumn, 'ptr', hImage, 'wstr', ImagePath, 'int')
  InsertGifEx(iRow, iColumn, hImage, ImagePath) => DllCall('xcgui\XRichEdit_InsertGifEx', 'ptr', this, 'int', iRow, 'int', iColumn, 'ptr', hImage, 'wstr', ImagePath, 'int')
  SetText(String) => DllCall('xcgui\XRichEdit_SetText', 'ptr', this, 'wstr', String)
  SetTextInt(nVaule) => DllCall('xcgui\XRichEdit_SetTextInt', 'ptr', this, 'int', nVaule)
  GetText(pOut, len) => DllCall('xcgui\XRichEdit_GetText', 'ptr', this, 'ptr', pOut, 'int', len, 'int')
  GetHTMLFormat(pOut, len) => DllCall('xcgui\XRichEdit_GetHTMLFormat', 'ptr', this, 'ptr', pOut, 'int', len)
  GetData(&DataSize) => DllCall('xcgui\XRichEdit_GetData', 'ptr', this, 'int*', &DataSize := 0, 'ptr')
  InsertData(pData, iRow, iColumn) => DllCall('xcgui\XRichEdit_InsertData', 'ptr', this, 'ptr', pData, 'int', iRow, 'int', iColumn, 'int')
  EnableReadOnly(bEnable) => DllCall('xcgui\XRichEdit_EnableReadOnly', 'ptr', this, 'int', bEnable)
  EnableMultiLine(bEnable) => DllCall('xcgui\XRichEdit_EnableMultiLine', 'ptr', this, 'int', bEnable)
  EnablePassword(bEnable) => DllCall('xcgui\XRichEdit_EnablePassword', 'ptr', this, 'int', bEnable)
  EnableEvent_XE_RICHEDIT_CHANGE(bEnable) => DllCall('xcgui\XRichEdit_EnableEvent_XE_RICHEDIT_CHANGE', 'ptr', this, 'int', bEnable)
  EnableAutoWrap(bEnable) => DllCall('xcgui\XRichEdit_EnableAutoWrap', 'ptr', this, 'int', bEnable)
  EnableAutoSelAll(bEnable) => DllCall('xcgui\XRichEdit_EnableAutoSelAll', 'ptr', this, 'int', bEnable)
  EnableVerticalCenter(bEnable) => DllCall('xcgui\XRichEdit_EnableVerticalCenter', 'ptr', this, 'int', bEnable)
  SetLimitNum(nNumber) => DllCall('xcgui\XRichEdit_SetLimitNum', 'ptr', this, 'int', nNumber)
  SetCaretColor(color) => DllCall('xcgui\XRichEdit_SetCaretColor', 'ptr', this, 'uint', color)
  IsEmpty() => DllCall('xcgui\XRichEdit_IsEmpty', 'ptr', this, 'int')
  IsReadOnly() => DllCall('xcgui\XRichEdit_IsReadOnly', 'ptr', this, 'int')
  IsMultiLine() => DllCall('xcgui\XRichEdit_IsMultiLine', 'ptr', this, 'int')
  IsPassword() => DllCall('xcgui\XRichEdit_IsPassword', 'ptr', this, 'int')
  IsAutoWrap() => DllCall('xcgui\XRichEdit_IsAutoWrap', 'ptr', this, 'int')
  GetTextLength() => DllCall('xcgui\XRichEdit_GetTextLength', 'ptr', this, 'int')
  SetRowHeight(nHeight) => DllCall('xcgui\XRichEdit_SetRowHeight', 'ptr', this, 'uint', nHeight)
  SetDefaultText(String) => DllCall('xcgui\XRichEdit_SetDefaultText', 'ptr', this, 'wstr', String)
  SetDefaultTextColor(color, alpha) => DllCall('xcgui\XRichEdit_SetDefaultTextColor', 'ptr', this, 'uint', color, 'uchar', alpha)
  SetCurrentInputTextColor(color, alpha) => DllCall('xcgui\XRichEdit_SetCurrentInputTextColor', 'ptr', this, 'uint', color, 'uchar', alpha)
  GetCurrentRow() => DllCall('xcgui\XRichEdit_GetCurrentRow', 'ptr', this, 'int')
  GetCurrentColumn() => DllCall('xcgui\XRichEdit_GetCurrentColumn', 'ptr', this, 'int')
  SetCurrentPos(iRow, iColumn) => DllCall('xcgui\XRichEdit_SetCurrentPos', 'ptr', this, 'int', iRow, 'int', iColumn)
  GetRowCount() => DllCall('xcgui\XRichEdit_GetRowCount', 'ptr', this, 'int')
  GetRowLength(iRow) => DllCall('xcgui\XRichEdit_GetRowLength', 'ptr', this, 'int', iRow, 'int')
  GetRowHeight(iRow) => DllCall('xcgui\XRichEdit_GetRowHeight', 'ptr', this, 'int', iRow, 'int')
  GetSelectText(pOut, len) => DllCall('xcgui\XRichEdit_GetSelectText', 'ptr', this, 'ptr', pOut, 'int', len, 'int')
  GetSelectPosition(pBegin, pEnd) => DllCall('xcgui\XRichEdit_GetSelectPosition', 'ptr', this, 'ptr', pBegin, 'ptr', pEnd, 'int')
  SetSelect(iStartRow, iStartCol, iEndRow, iEndCol) => DllCall('xcgui\XRichEdit_SetSelect', 'ptr', this, 'int', iStartRow, 'int', iStartCol, 'int', iEndRow, 'int', iEndCol, 'int')
  SetItemFontEx(beginRow, beginColumn, endRow, endColumn, hFont) => DllCall('xcgui\XRichEdit_SetItemFontEx', 'ptr', this, 'int', beginRow, 'int', beginColumn, 'int', endRow, 'int', endColumn, 'ptr', hFont, 'int')
  SetItemColorEx(beginRow, beginColumn, endRow, endColumn, color, alpha := 255) => DllCall('xcgui\XRichEdit_SetItemColorEx', 'ptr', this, 'int', beginRow, 'int', beginColumn, 'int', endRow, 'int', endColumn, 'uint', color, 'uchar', alpha, 'int')
  CancelSelect() => DllCall('xcgui\XRichEdit_CancelSelect', 'ptr', this)
  SetSelectBkColor(color, alpha := 255) => DllCall('xcgui\XRichEdit_SetSelectBkColor', 'ptr', this, 'uint', color, 'uchar', alpha)
  SetPasswordCharacter(ch) => DllCall('xcgui\XRichEdit_SetPasswordCharacter', 'ptr', this, 'ushort', ch)
  SelectAll() => DllCall('xcgui\XRichEdit_SelectAll', 'ptr', this, 'int')
  DeleteSelect() => DllCall('xcgui\XRichEdit_DeleteSelect', 'ptr', this, 'int')
  DeleteAll() => DllCall('xcgui\XRichEdit_DeleteAll', 'ptr', this)
  ClipboardCut() => DllCall('xcgui\XRichEdit_ClipboardCut', 'ptr', this, 'int')
  ClipboardCopy() => DllCall('xcgui\XRichEdit_ClipboardCopy', 'ptr', this, 'int')
  ClipboardPaste() => DllCall('xcgui\XRichEdit_ClipboardPaste', 'ptr', this, 'int')
}
class CXScrollBar extends CXEle {
  static Create(x, y, cx, cy, hParent := 0) {
    if hEle := DllCall('xcgui\XSBar_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent, 'ptr')
      return {Base: CXScrollBar.Prototype, ptr: hEle}
  }
  __New(x, y, cx, cy, hParent := 0) {
    if !hEle := DllCall('xcgui\XSBar_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent)
      throw
    this.ptr := hEle
  }
  SetRange(range) => DllCall('xcgui\XSBar_SetRange', 'ptr', this, 'int', range)
  GetRange() => DllCall('xcgui\XSBar_GetRange', 'ptr', this, 'int')
  ShowButton(bShow) => DllCall('xcgui\XSBar_ShowButton', 'ptr', this, 'int', bShow)
  SetSliderLength(length) => DllCall('xcgui\XSBar_SetSliderLength', 'ptr', this, 'int', length)
  SetSliderMinLength(minLength) => DllCall('xcgui\XSBar_SetSliderMinLength', 'ptr', this, 'int', minLength)
  SetSliderPadding(nPadding) => DllCall('xcgui\XSBar_SetSliderPadding', 'ptr', this, 'int', nPadding)
  SetHorizon(bHorizon) => DllCall('xcgui\XSBar_SetHorizon', 'ptr', this, 'int', bHorizon, 'int')
  GetSliderMaxLength() => DllCall('xcgui\XSBar_GetSliderMaxLength', 'ptr', this, 'int')
  ScrollUp() => DllCall('xcgui\XSBar_ScrollUp', 'ptr', this, 'int')
  ScrollDown() => DllCall('xcgui\XSBar_ScrollDown', 'ptr', this, 'int')
  ScrollTop() => DllCall('xcgui\XSBar_ScrollTop', 'ptr', this, 'int')
  ScrollBottom() => DllCall('xcgui\XSBar_ScrollBottom', 'ptr', this, 'int')
  ScrollPos(pos) => DllCall('xcgui\XSBar_ScrollPos', 'ptr', this, 'int', pos, 'int')
  GetButtonUp() => DllCall('xcgui\XSBar_GetButtonUp', 'ptr', this, 'ptr')
  GetButtonDown() => DllCall('xcgui\XSBar_GetButtonDown', 'ptr', this, 'ptr')
  GetButtonSlider() => DllCall('xcgui\XSBar_GetButtonSlider', 'ptr', this, 'ptr')
}
class CXSliderBar extends CXEle {
  static Create(x, y, cx, cy, hParent := 0) {
    if hEle := DllCall('xcgui\XSliderBar_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent, 'ptr')
      return {Base: CXSliderBar.Prototype, ptr: hEle}
  }
  __New(x, y, cx, cy, hParent := 0) {
    if !hEle := DllCall('xcgui\XSliderBar_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent)
      throw
    this.ptr := hEle
  }
  SetRange(range) => DllCall('xcgui\XSliderBar_SetRange', 'ptr', this, 'int', range)
  GetRange() => DllCall('xcgui\XSliderBar_GetRange', 'ptr', this, 'int')
  SetImageLoad(hImage) => DllCall('xcgui\XSliderBar_SetImageLoad', 'ptr', this, 'ptr', hImage)
  SetButtonWidth(width) => DllCall('xcgui\XSliderBar_SetButtonWidth', 'ptr', this, 'int', width)
  SetButtonHeight(height) => DllCall('xcgui\XSliderBar_SetButtonHeight', 'ptr', this, 'int', height)
  SetSpaceTwo(leftSize, rightSize) => DllCall('xcgui\XSliderBar_SetSpaceTwo', 'ptr', this, 'int', leftSize, 'int', rightSize)
  SetPos(pos) => DllCall('xcgui\XSliderBar_SetPos', 'ptr', this, 'int', pos)
  GetPos() => DllCall('xcgui\XSliderBar_GetPos', 'ptr', this, 'int')
  GetButton() => DllCall('xcgui\XSliderBar_GetButton', 'ptr', this, 'ptr')
  SetHorizon(bHorizon) => DllCall('xcgui\XSliderBar_SetHorizon', 'ptr', this, 'int', bHorizon)
}
class CXTabBar extends CXEle {
  static Create(x, y, cx, cy, hParent := 0) {
    if hEle := DllCall('xcgui\XTabBar_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent, 'ptr')
      return {Base: CXTabBar.Prototype, ptr: hEle}
  }
  __New(x, y, cx, cy, hParent := 0) {
    if !hEle := DllCall('xcgui\XTabBar_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent)
      throw
    this.ptr := hEle
  }
  AddLabel(Name) => DllCall('xcgui\XTabBar_AddLabel', 'ptr', this, 'wstr', Name, 'int')
  InsertLabel(index, Name) => DllCall('xcgui\XTabBar_InsertLabel', 'ptr', this, 'int', index, 'wstr', Name, 'int')
  MoveLabel(iSrc, iDest) => DllCall('xcgui\XTabBar_MoveLabel', 'ptr', this, 'int', iSrc, 'int', iDest, 'int')
  DeleteLabel(index) => DllCall('xcgui\XTabBar_DeleteLabel', 'ptr', this, 'int', index, 'int')
  DeleteLabelAll() => DllCall('xcgui\XTabBar_DeleteLabelAll', 'ptr', this)
  GetLabel(index) => DllCall('xcgui\XTabBar_GetLabel', 'ptr', this, 'int', index, 'ptr')
  GetLabelClose(index) => DllCall('xcgui\XTabBar_GetLabelClose', 'ptr', this, 'int', index, 'ptr')
  GetButtonLeft() => DllCall('xcgui\XTabBar_GetButtonLeft', 'ptr', this, 'ptr')
  GetButtonRight() => DllCall('xcgui\XTabBar_GetButtonRight', 'ptr', this, 'ptr')
  GetButtonDropMenu() => DllCall('xcgui\XTabBar_GetButtonDropMenu', 'ptr', this, 'ptr')
  GetSelect() => DllCall('xcgui\XTabBar_GetSelect', 'ptr', this, 'int')
  GetLabelSpacing() => DllCall('xcgui\XTabBar_GetLabelSpacing', 'ptr', this, 'int')
  GetLabelCount() => DllCall('xcgui\XTabBar_GetLabelCount', 'ptr', this, 'int')
  GetindexByEle(hLabel) => DllCall('xcgui\XTabBar_GetindexByEle', 'ptr', this, 'ptr', hLabel, 'int')
  SetLabelSpacing(spacing) => DllCall('xcgui\XTabBar_SetLabelSpacing', 'ptr', this, 'int', spacing)
  SetPadding(left, top, right, bottom) => DllCall('xcgui\XTabBar_SetPadding', 'ptr', this, 'int', left, 'int', top, 'int', right, 'int', bottom)
  SetSelect(index) => DllCall('xcgui\XTabBar_SetSelect', 'ptr', this, 'int', index)
  SetUp() => DllCall('xcgui\XTabBar_SetUp', 'ptr', this)
  SetDown() => DllCall('xcgui\XTabBar_SetDown', 'ptr', this)
  EnableTile(bTile) => DllCall('xcgui\XTabBar_EnableTile', 'ptr', this, 'int', bTile)
  EnableDropMenu(bEnable) => DllCall('xcgui\XTabBar_EnableDropMenu', 'ptr', this, 'int', bEnable)
  EnableClose(bEnable) => DllCall('xcgui\XTabBar_EnableClose', 'ptr', this, 'int', bEnable)
  SetCloseSize(pSize) => DllCall('xcgui\XTabBar_SetCloseSize', 'ptr', this, 'ptr', pSize)
  SetTurnButtonSize(pSize) => DllCall('xcgui\XTabBar_SetTurnButtonSize', 'ptr', this, 'ptr', pSize)
  SetLabelWidth(index, nWidth) => DllCall('xcgui\XTabBar_SetLabelWidth', 'ptr', this, 'int', index, 'int', nWidth)
  ShowLabel(index, bShow) => DllCall('xcgui\XTabBar_ShowLabel', 'ptr', this, 'int', index, 'int', bShow, 'int')
}
class CXTextLink extends CXButton {
  static Create(x, y, cx, cy, Name, hParent := 0) {
    if hEle := DllCall('xcgui\XTextLink_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'wstr', Name, 'ptr', hParent, 'ptr')
      return {Base: CXTextLink.Prototype, ptr: hEle}
  }
  __New(x, y, cx, cy, Name, hParent := 0) {
    if !hEle := DllCall('xcgui\XTextLink_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'wstr', Name, 'ptr', hParent)
      throw
    this.ptr := hEle
  }
  EnableUnderlineLeave(bEnable) => DllCall('xcgui\XTextLink_EnableUnderlineLeave', 'ptr', this, 'int', bEnable)
  EnableUnderlineStay(bEnable) => DllCall('xcgui\XTextLink_EnableUnderlineStay', 'ptr', this, 'int', bEnable)
  SetTextColorStay(color, alpha) => DllCall('xcgui\XTextLink_SetTextColorStay', 'ptr', this, 'uint', color, 'uchar', alpha)
  SetUnderlineColorLeave(color, alpha) => DllCall('xcgui\XTextLink_SetUnderlineColorLeave', 'ptr', this, 'uint', color, 'uchar', alpha)
  SetUnderlineColorStay(color, alpha) => DllCall('xcgui\XTextLink_SetUnderlineColorStay', 'ptr', this, 'uint', color, 'uchar', alpha)
}
class CXToolBar extends CXEle {
  static Create(x, y, cx, cy, hParent := 0) {
    if hEle := DllCall('xcgui\XToolBar_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent, 'ptr')
      return {Base: CXToolBar.Prototype, ptr: hEle}
  }
  __New(x, y, cx, cy, hParent := 0) {
    if !hEle := DllCall('xcgui\XToolBar_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent)
      throw
    this.ptr := hEle
  }
  InsertEle(hNewEle, index := -1) => DllCall('xcgui\XToolBar_InsertEle', 'ptr', this, 'ptr', hNewEle, 'int', index, 'int')
  InsertSeparator(index := -1, color := 0x808080) => DllCall('xcgui\XToolBar_InsertSeparator', 'ptr', this, 'int', index, 'uint', color, 'int')
  EnableButtonMenu(bEnable) => DllCall('xcgui\XToolBar_EnableButtonMenu', 'ptr', this, 'int', bEnable)
  GetEle(index) => DllCall('xcgui\XToolBar_GetEle', 'ptr', this, 'int', index, 'ptr')
  GetButtonLeft() => DllCall('xcgui\XToolBar_GetButtonLeft', 'ptr', this, 'ptr')
  GetButtonRight() => DllCall('xcgui\XToolBar_GetButtonRight', 'ptr', this, 'ptr')
  GetButtonMenu() => DllCall('xcgui\XToolBar_GetButtonMenu', 'ptr', this, 'ptr')
  SetSpace(nSize) => DllCall('xcgui\XToolBar_SetSpace', 'ptr', this, 'int', nSize)
  DeleteEle(index) => DllCall('xcgui\XToolBar_DeleteEle', 'ptr', this, 'int', index)
  DeleteAllEle() => DllCall('xcgui\XToolBar_DeleteAllEle', 'ptr', this)
}
class CXTree extends CXScrollView {
  static Create(x, y, cx, cy, hParent := 0) {
    if hEle := DllCall('xcgui\XTree_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent, 'ptr')
      return {Base: CXTree.Prototype, ptr: hEle}
  }
  __New(x, y, cx, cy, hParent := 0) {
    if !hEle := DllCall('xcgui\XTree_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent)
      throw
    this.ptr := hEle
  }
  EnableDragItem(bEnable) => DllCall('xcgui\XTree_EnableDragItem', 'ptr', this, 'int', bEnable)
  EnableConnectLine(bEnable, bSolid) => DllCall('xcgui\XTree_EnableConnectLine', 'ptr', this, 'int', bEnable, 'int', bSolid)
  EnableExpand(bEnable) => DllCall('xcgui\XTree_EnableExpand', 'ptr', this, 'int', bEnable)
  SetConnectLineColor(color, alpha) => DllCall('xcgui\XTree_SetConnectLineColor', 'ptr', this, 'uint', color, 'uchar', alpha)
  SetExpandButtonSize(nWidth, nHeight) => DllCall('xcgui\XTree_SetExpandButtonSize', 'ptr', this, 'int', nWidth, 'int', nHeight)
  SetConnectLineLength(nLength) => DllCall('xcgui\XTree_SetConnectLineLength', 'ptr', this, 'int', nLength)
  SetDragInsertPositionColor(color, alpha) => DllCall('xcgui\XTree_SetDragInsertPositionColor', 'ptr', this, 'uint', color, 'uchar', alpha)
  SetItemTemplateXML(XmlFile) => DllCall('xcgui\XTree_SetItemTemplateXML', 'ptr', this, 'wstr', XmlFile, 'int')
  SetItemTemplateXMLSel(XmlFile) => DllCall('xcgui\XTree_SetItemTemplateXMLSel', 'ptr', this, 'wstr', XmlFile, 'int')
  SetItemTemplate(hTemp) => DllCall('xcgui\XTree_SetItemTemplate', 'ptr', this, 'ptr', hTemp, 'int')
  SetItemTemplateSel(hTemp) => DllCall('xcgui\XTree_SetItemTemplateSel', 'ptr', this, 'ptr', hTemp, 'int')
  SetItemTemplateXMLFromString(StringXML) => DllCall('xcgui\XTree_SetItemTemplateXMLFromString', 'ptr', this, 'astr', StringXML, 'int')
  SetItemTemplateXMLSelFromString(StringXML) => DllCall('xcgui\XTree_SetItemTemplateXMLSelFromString', 'ptr', this, 'astr', StringXML, 'int')
  SetDrawItemBkFlags(nFlags) => DllCall('xcgui\XTree_SetDrawItemBkFlags', 'ptr', this, 'int', nFlags)
  SetItemData(nID, nUserData) => DllCall('xcgui\XTree_SetItemData', 'ptr', this, 'int', nID, 'ptr', nUserData, 'int')
  GetItemData(nID) => DllCall('xcgui\XTree_GetItemData', 'ptr', this, 'int', nID, 'ptr')
  SetSelectItem(nID) => DllCall('xcgui\XTree_SetSelectItem', 'ptr', this, 'int', nID, 'int')
  GetSelectItem() => DllCall('xcgui\XTree_GetSelectItem', 'ptr', this, 'int')
  VisibleItem(nID) => DllCall('xcgui\XTree_VisibleItem', 'ptr', this, 'int', nID)
  IsExpand(nID) => DllCall('xcgui\XTree_IsExpand', 'ptr', this, 'int', nID, 'int')
  ExpandItem(nID, bExpand) => DllCall('xcgui\XTree_ExpandItem', 'ptr', this, 'int', nID, 'int', bExpand, 'int')
  ExpandAllChildItem(nID, bExpand) => DllCall('xcgui\XTree_ExpandAllChildItem', 'ptr', this, 'int', nID, 'int', bExpand, 'int')
  HitTest(pPt) => DllCall('xcgui\XTree_HitTest', 'ptr', this, 'ptr', pPt, 'int')
  HitTestOffset(pPt) => DllCall('xcgui\XTree_HitTestOffset', 'ptr', this, 'ptr', pPt, 'int')
  GetFirstChildItem(nID) => DllCall('xcgui\XTree_GetFirstChildItem', 'ptr', this, 'int', nID, 'int')
  GetEndChildItem(nID) => DllCall('xcgui\XTree_GetEndChildItem', 'ptr', this, 'int', nID, 'int')
  GetPrevSiblingItem(nID) => DllCall('xcgui\XTree_GetPrevSiblingItem', 'ptr', this, 'int', nID, 'int')
  GetNextSiblingItem(nID) => DllCall('xcgui\XTree_GetNextSiblingItem', 'ptr', this, 'int', nID, 'int')
  GetParentItem(nID) => DllCall('xcgui\XTree_GetParentItem', 'ptr', this, 'int', nID, 'int')
  CreateAdapter() => DllCall('xcgui\XTree_CreateAdapter', 'ptr', this, 'ptr')
  BindAdapter(hAdapter) => DllCall('xcgui\XTree_BindAdapter', 'ptr', this, 'ptr', hAdapter)
  GetAdapter() => DllCall('xcgui\XTree_GetAdapter', 'ptr', this, 'ptr')
  RefreshData() => DllCall('xcgui\XTree_RefreshData', 'ptr', this)
  RefreshItem(nID) => DllCall('xcgui\XTree_RefreshItem', 'ptr', this, 'int', nID)
  SetIndentation(nWidth) => DllCall('xcgui\XTree_SetIndentation', 'ptr', this, 'int', nWidth)
  GetIndentation() => DllCall('xcgui\XTree_GetIndentation', 'ptr', this, 'int')
  SetItemHeightDefault(nHeight, nSelHeight) => DllCall('xcgui\XTree_SetItemHeightDefault', 'ptr', this, 'int', nHeight, 'int', nSelHeight)
  GetItemHeightDefault(&Height, &SelHeight) => DllCall('xcgui\XTree_GetItemHeightDefault', 'ptr', this, 'int*', &Height, 'int*', &SelHeight)
  SetItemHeight(nID, nHeight, nSelHeight) => DllCall('xcgui\XTree_SetItemHeight', 'ptr', this, 'int', nID, 'int', nHeight, 'int', nSelHeight)
  GetItemHeight(nID, &Height, &SelHeight) => DllCall('xcgui\XTree_GetItemHeight', 'ptr', this, 'int', nID, 'int*', &Height, 'int*', &SelHeight)
  SetRowSpace(nSpace) => DllCall('xcgui\XTree_SetRowSpace', 'ptr', this, 'int', nSpace)
  GetRowSpace() => DllCall('xcgui\XTree_GetRowSpace', 'ptr', this, 'int')
  MoveItem(nMoveItem, nDestItem, nFlag) => DllCall('xcgui\XTree_MoveItem', 'ptr', this, 'int', nMoveItem, 'int', nDestItem, 'int', nFlag, 'int')
  AddItemBkBorder(nState, color, alpha, width) => DllCall('xcgui\XTree_AddItemBkBorder', 'ptr', this, 'int', nState, 'uint', color, 'uchar', alpha, 'int', width)
  AddItemBkFill(nState, color, alpha) => DllCall('xcgui\XTree_AddItemBkFill', 'ptr', this, 'int', nState, 'uint', color, 'uchar', alpha)
  AddItemBkImage(nState, hImage) => DllCall('xcgui\XTree_AddItemBkImage', 'ptr', this, 'int', nState, 'ptr', hImage)
  GetItemBkInfoCount() => DllCall('xcgui\XTree_GetItemBkInfoCount', 'ptr', this, 'int')
  ClearItemBkInfo() => DllCall('xcgui\XTree_ClearItemBkInfo', 'ptr', this)
  GetTemplateObject(nID, nTempItemID) => DllCall('xcgui\XTree_GetTemplateObject', 'ptr', this, 'int', nID, 'int', nTempItemID, 'ptr')
  GetItemIDFromHXCGUI(hXCGUI) => DllCall('xcgui\XTree_GetItemIDFromHXCGUI', 'ptr', this, 'ptr', hXCGUI, 'int')
  InsertItemText(Value, nParentID := 0, insertID := -3) => DllCall('xcgui\XTree_InsertItemText', 'ptr', this, 'wstr', Value, 'int', nParentID, 'int', insertID, 'int')
  InsertItemTextEx(Name, Value, nParentID := 0, insertID := -3) => DllCall('xcgui\XTree_InsertItemTextEx', 'ptr', this, 'wstr', Name, 'wstr', Value, 'int', nParentID, 'int', insertID, 'int')
  InsertItemImage(hImage, nParentID := 0, insertID := -3) => DllCall('xcgui\XTree_InsertItemImage', 'ptr', this, 'ptr', hImage, 'int', nParentID, 'int', insertID, 'int')
  InsertItemImageEx(Name, hImage, nParentID := 0, insertID := -3) => DllCall('xcgui\XTree_InsertItemImageEx', 'ptr', this, 'wstr', Name, 'ptr', hImage, 'int', nParentID, 'int', insertID, 'int')
  GetCount() => DllCall('xcgui\XTree_GetCount', 'ptr', this, 'int')
  GetCountColumn() => DllCall('xcgui\XTree_GetCountColumn', 'ptr', this, 'int')
  SetItemText(nID, iColumn, Value) => DllCall('xcgui\XTree_SetItemText', 'ptr', this, 'int', nID, 'int', iColumn, 'wstr', Value, 'int')
  SetItemTextEx(nID, Name, Value) => DllCall('xcgui\XTree_SetItemTextEx', 'ptr', this, 'int', nID, 'wstr', Name, 'wstr', Value, 'int')
  SetItemImage(nID, iColumn, hImage) => DllCall('xcgui\XTree_SetItemImage', 'ptr', this, 'int', nID, 'int', iColumn, 'ptr', hImage, 'int')
  SetItemImageEx(nID, Name, hImage) => DllCall('xcgui\XTree_SetItemImageEx', 'ptr', this, 'int', nID, 'wstr', Name, 'ptr', hImage, 'int')
  GetItemText(nID, iColumn) => DllCall('xcgui\XTree_GetItemText', 'ptr', this, 'int', nID, 'int', iColumn, 'wstr')
  GetItemTextEx(nID, Name) => DllCall('xcgui\XTree_GetItemTextEx', 'ptr', this, 'int', nID, 'wstr', Name, 'wstr')
  GetItemImage(nID, iColumn) => DllCall('xcgui\XTree_GetItemImage', 'ptr', this, 'int', nID, 'int', iColumn, 'ptr')
  GetItemImageEx(nID, Name) => DllCall('xcgui\XTree_GetItemImageEx', 'ptr', this, 'int', nID, 'wstr', Name, 'ptr')
  DeleteItem(nID) => DllCall('xcgui\XTree_DeleteItem', 'ptr', this, 'int', nID, 'int')
  DeleteItemAll() => DllCall('xcgui\XTree_DeleteItemAll', 'ptr', this)
  DeleteColumnAll() => DllCall('xcgui\XTree_DeleteColumnAll', 'ptr', this)
}
class CXDateTime extends CXEle {
  static Create(x, y, cx, cy, hParent := 0) {
    if hEle := DllCall('xcgui\XDateTime_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent, 'ptr')
      return {Base: CXDateTime.Prototype, ptr: hEle}
  }
  __New(x, y, cx, cy, hParent := 0) {
    if !hEle := DllCall('xcgui\XDateTime_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent)
      throw
    this.ptr := hEle
  }
  SetStyle(nStyle) => DllCall('xcgui\XDateTime_SetStyle', 'ptr', this, 'int', nStyle)
  GetStyle() => DllCall('xcgui\XDateTime_GetStyle', 'ptr', this, 'int')
  EnableSplitSlash(bSlash) => DllCall('xcgui\XDateTime_EnableSplitSlash', 'ptr', this, 'int', bSlash)
  GetButton(nType) => DllCall('xcgui\XDateTime_GetButton', 'ptr', this, 'int', nType, 'ptr')
  GetSelBkColor() => DllCall('xcgui\XDateTime_GetSelBkColor', 'ptr', this, 'uint')
  SetSelBkColor(crSelectBk, alpha := 255) => DllCall('xcgui\XDateTime_SetSelBkColor', 'ptr', this, 'uint', crSelectBk, 'uchar', alpha)
  GetDate(&nYear, &nMonth, &nDay) => DllCall('xcgui\XDateTime_GetDate', 'ptr', this, 'int*', &nYear, 'int*', &nMonth, 'int*', &nDay)
  SetDate(nYear, nMonth, nDay) => DllCall('xcgui\XDateTime_SetDate', 'ptr', this, 'int', nYear, 'int', nMonth, 'int', nDay)
  GetTime(&nHour, &nMinute, &nSecond) => DllCall('xcgui\XDateTime_GetTime', 'ptr', this, 'int*', &nHour, 'int*', &nMinute, 'int*', &nSecond)
  SetTime(nHour, nMinute, nSecond) => DllCall('xcgui\XDateTime_SetTime', 'ptr', this, 'int', nHour, 'int', nMinute, 'int', nSecond)
}
class CXMonthCal extends CXEle {
  static Create(x, y, cx, cy, hParent := 0) {
    if hEle := DllCall('xcgui\XMonthCal_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent, 'ptr')
      return {Base: CXMonthCal.Prototype, ptr: hEle}
  }
  __New(x, y, cx, cy, hParent := 0) {
    if !hEle := DllCall('xcgui\XMonthCal_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent)
      throw
    this.ptr := hEle
  }
  GetButton(nType) => DllCall('xcgui\XMonthCal_GetButton', 'ptr', this, 'int', nType, 'ptr')
  SetToday(nYear, nMonth, nDay) => DllCall('xcgui\XMonthCal_SetToday', 'ptr', this, 'int', nYear, 'int', nMonth, 'int', nDay)
  GetToday(&nYear, &nMonth, &nDay) => DllCall('xcgui\XMonthCal_GetToday', 'ptr', this, 'int*', &nYear, 'int*', &nMonth, 'int*', &nDay)
  GetSelDate(&nYear, &nMonth, &nDay) => DllCall('xcgui\XMonthCal_GetSelDate', 'ptr', this, 'int*', &nYear, 'int*', &nMonth, 'int*', &nDay)
}
class CXShape extends CXWidgetUI {
  GetParentEle() => DllCall('xcgui\XShape_GetParentEle', 'ptr', this, 'ptr')
  GetHWINDOW() => DllCall('xcgui\XShape_GetHWINDOW', 'ptr', this, 'ptr')
  GetParent() => DllCall('xcgui\XShape_GetParent', 'ptr', this, 'ptr')
  RemoveShape() => DllCall('xcgui\XShape_RemoveShape', 'ptr', this)
  SetID(nID) => DllCall('xcgui\XShape_SetID', 'ptr', this, 'int', nID)
  GetID() => DllCall('xcgui\XShape_GetID', 'ptr', this, 'int')
  SetUID(nUID) => DllCall('xcgui\XShape_SetUID', 'ptr', this, 'int', nUID)
  GetUID() => DllCall('xcgui\XShape_GetUID', 'ptr', this, 'int')
  SetName(Name) => DllCall('xcgui\XShape_SetName', 'ptr', this, 'wstr', Name)
  GetName() => DllCall('xcgui\XShape_GetName', 'ptr', this, 'wstr')
  GetZOrder() => DllCall('xcgui\XShape_GetZOrder', 'ptr', this, 'int')
  Redraw() => DllCall('xcgui\XShape_Redraw', 'ptr', this)
  GetWidth() => DllCall('xcgui\XShape_GetWidth', 'ptr', this, 'int')
  GetHeight() => DllCall('xcgui\XShape_GetHeight', 'ptr', this, 'int')
  Move(x, y) => DllCall('xcgui\XShape_Move', 'ptr', this, 'int', x, 'int', y)
  GetRect(pRect) => DllCall('xcgui\XShape_GetRect', 'ptr', this, 'ptr', pRect)
  SetRect(pRect) => DllCall('xcgui\XShape_SetRect', 'ptr', this, 'ptr', pRect)
  GetWndClientRect(pRect) => DllCall('xcgui\XShape_GetWndClientRect', 'ptr', this, 'ptr', pRect)
  GetContentSize(pSize) => DllCall('xcgui\XShape_GetContentSize', 'ptr', this, 'ptr', pSize)
  ShowLayout(bShow) => DllCall('xcgui\XShape_ShowLayout', 'ptr', this, 'int', bShow)
  AdjustLayout() => DllCall('xcgui\XShape_AdjustLayout', 'ptr', this)
  Destroy() => DllCall('xcgui\XShape_Destroy', 'ptr', this)
}
class CXShapeLine extends CXShape {
  static Create(x1, y1, x2, y2, hParent := 0) {
    if hShape := DllCall('xcgui\XShapeLine_Create', 'int', x1, 'int', y1, 'int', x2, 'int', y2, 'ptr', hParent, 'ptr')
      return {Base: CXShapeLine.Prototype, ptr: hShape}
  }
  __New(x1, y1, x2, y2, hParent := 0) {
    if !hShape := DllCall('xcgui\XShapeLine_Create', 'int', x1, 'int', y1, 'int', x2, 'int', y2, 'ptr', hParent, 'ptr')
      throw
    this.ptr := hShape
  }
  SetPosition(x1, y1, x2, y2) => DllCall('xcgui\XShapeLine_SetPosition', 'ptr', this, 'int', x1, 'int', y1, 'int', x2, 'int', y2)
  SetColor(color, alpha) => DllCall('xcgui\XShapeLine_SetColor', 'ptr', this, 'uint', color, 'char', alpha)
}
class CXShapeText extends CXShape {
  static Create(x, y, cx, cy, Name, hParent := 0) {
    if hShape := DllCall('xcgui\XShapeText_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'wstr', Name, 'ptr', hParent, 'ptr')
      return {Base: CXShapeText.Prototype, ptr: hShape}
  }
  __New(x, y, cx, cy, Name, hParent := 0) {
    if !hShape := DllCall('xcgui\XShapeText_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'wstr', Name, 'ptr', hParent)
      throw
    this.ptr := hShape
  }
  SetText(Name) => DllCall('xcgui\XShapeText_SetText', 'ptr', this, 'wstr', Name)
  GetText() => DllCall('xcgui\XShapeText_GetText', 'ptr', this, 'wstr')
  GetTextLength() => DllCall('xcgui\XShapeText_GetTextLength', 'ptr', this, 'int')
  SetFont(hFontx) => DllCall('xcgui\XShapeText_SetFont', 'ptr', this, 'ptr', hFontx)
  GetFont() => DllCall('xcgui\XShapeText_GetFont', 'ptr', this, 'ptr')
  SetTextColor(color, alpha) => DllCall('xcgui\XShapeText_SetTextColor', 'ptr', this, 'uint', color, 'uchar', alpha)
  GetTextColor() => DllCall('xcgui\XShapeText_GetTextColor', 'ptr', this, 'uint')
  SetTextAlign(align) => DllCall('xcgui\XShapeText_SetTextAlign', 'ptr', this, 'int', align)
  SetOffset(x, y) => DllCall('xcgui\XShapeText_SetOffset', 'ptr', this, 'int', x, 'int', y)
  SetLayoutWidth(nType, width) => DllCall('xcgui\XShapeText_SetLayoutWidth', 'ptr', this, 'int', nType, 'int', width)
  SetLayoutHeight(nType, height) => DllCall('xcgui\XShapeText_SetLayoutHeight', 'ptr', this, 'int', nType, 'int', height)
  GetLayoutWidth(&Type, &Width) => DllCall('xcgui\XShapeText_GetLayoutWidth', 'ptr', this, 'int*', &Type, 'int*', &Width)
  GetLayoutHeight(&Type, &Height) => DllCall('xcgui\XShapeText_GetLayoutHeight', 'ptr', this, 'int*', &Type, 'int*', &Height)
  SetLayoutFloat(nFloat_) => DllCall('xcgui\XShapeText_SetLayoutFloat', 'ptr', this, 'uint', nFloat_)
  SetLayoutWrap(bWrap) => DllCall('xcgui\XShapeText_SetLayoutWrap', 'ptr', this, 'int', bWrap)
  EnableCSS(bEnable) => DllCall('xcgui\XShapeText_EnableCSS', 'ptr', this, 'int', bEnable)
  SetCssName(Name) => DllCall('xcgui\XShapeText_SetCssName', 'ptr', this, 'wstr', Name)
  GetCssName() => DllCall('xcgui\XShapeText_GetCssName', 'ptr', this, 'wstr')
}
class CXShapePicture extends CXShape {
  static Create(x, y, cx, cy, hParent := 0) {
    if hShape := DllCall('xcgui\XShapePic_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent, 'ptr')
      return {Base: CXShapePicture.Prototype, ptr: hShape}
  }
  __New(x, y, cx, cy, hParent := 0) {
    if !hShape := DllCall('xcgui\XShapePic_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent)
      throw
    this.ptr := hShape
  }
  SetImage(hImage) => DllCall('xcgui\XShapePic_SetImage', 'ptr', this, 'ptr', hImage)
  GetImage() => DllCall('xcgui\XShapePic_GetImage', 'ptr', this, 'ptr')
  SetLayoutWidth(nType, width) => DllCall('xcgui\XShapePic_SetLayoutWidth', 'ptr', this, 'uint', nType, 'int', width)
  SetLayoutHeight(nType, height) => DllCall('xcgui\XShapePic_SetLayoutHeight', 'ptr', this, 'uint', nType, 'int', height)
  GetLayoutWidth(&Type, &Width) => DllCall('xcgui\XShapePic_GetLayoutWidth', 'ptr', this, 'int*', &Type, 'int*', &Width)
  GetLayoutHeight(&Type, &Height) => DllCall('xcgui\XShapePic_GetLayoutHeight', 'ptr', this, 'int*', &Type, 'int*', &Height)
}
class CXShapeGif extends CXShape {
  static Create(x, y, cx, cy, hParent := 0) {
    if hShape := DllCall('xcgui\XShapeGif_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent, 'ptr')
      return {Base: CXShapeGif.Prototype, ptr: hShape}
  }
  __New(x, y, cx, cy, hParent := 0) {
    if !hShape := DllCall('xcgui\XShapeGif_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent)
      throw
    this.ptr := hShape
  }
  SetImage(hImage) => DllCall('xcgui\XShapeGif_SetImage', 'ptr', this, 'ptr', hImage)
  GetImage() => DllCall('xcgui\XShapeGif_GetImage', 'ptr', this, 'ptr')
  SetLayoutWidth(nType, width) => DllCall('xcgui\XShapeGif_SetLayoutWidth', 'ptr', this, 'int', nType, 'int', width)
  SetLayoutHeight(nType, height) => DllCall('xcgui\XShapeGif_SetLayoutHeight', 'ptr', this, 'int', nType, 'int', height)
  GetLayoutWidth(&Type, &Width) => DllCall('xcgui\XShapeGif_GetLayoutWidth', 'ptr', this, 'int*', &Type, 'int*', &Width)
  GetLayoutHeight(&Type, &Height) => DllCall('xcgui\XShapeGif_GetLayoutHeight', 'ptr', this, 'int*', &Type, 'int*', &Height)
}
class CXShapeRect extends CXShape {
  static Create(x, y, cx, cy, hParent := 0) {
    if hShape := DllCall('xcgui\XShapeRect_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent, 'ptr')
      return {Base: CXShapeRect.Prototype, ptr: hShape}
  }
  __New(x, y, cx, cy, hParent := 0) {
    if !hShape := DllCall('xcgui\XShapeRect_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent)
      throw
    this.ptr := hShape
  }
  SetBorderColor(color, alpha := 255) => DllCall('xcgui\XShapeRect_SetBorderColor', 'ptr', this, 'uint', color, 'uchar', alpha)
  SetFillColor(color, alpha := 255) => DllCall('xcgui\XShapeRect_SetFillColor', 'ptr', this, 'uint', color, 'uchar', alpha)
  SetRoundAngle(nWidth, nHeight) => DllCall('xcgui\XShapeRect_SetRoundAngle', 'ptr', this, 'int', nWidth, 'int', nHeight)
  GetRoundAngle(&Width, &Height) => DllCall('xcgui\XShapeRect_GetRoundAngle', 'ptr', this, 'int*', &Width, 'int*', &Height)
  EnableBorder(bEnable) => DllCall('xcgui\XShapeRect_EnableBorder', 'ptr', this, 'int', bEnable)
  EnableFill(bEnable) => DllCall('xcgui\XShapeRect_EnableFill', 'ptr', this, 'int', bEnable)
  EnableRoundAngle(bEnable) => DllCall('xcgui\XShapeRect_EnableRoundAngle', 'ptr', this, 'int', bEnable)
}
class CXShapeEllipse extends CXShape {
  static Create(x, y, cx, cy, hParent := 0) {
    if hShape := DllCall('xcgui\XShapeEllipse_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent, 'ptr')
      return {Base: CXShapeEllipse.Prototype, ptr: hShape}
  }
  __New(x, y, cx, cy, hParent := 0) {
    if !hShape := DllCall('xcgui\XShapeEllipse_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent)
      throw
    this.ptr := hShape
  }
  SetBorderColor(color, alpha := 255) => DllCall('xcgui\XShapeEllipse_SetBorderColor', 'ptr', this, 'uint', color, 'uchar', alpha)
  SetFillColor(color, alpha := 255) => DllCall('xcgui\XShapeEllipse_SetFillColor', 'ptr', this, 'uint', color, 'uchar', alpha)
  EnableBorder(bEnable) => DllCall('xcgui\XShapeEllipse_EnableBorder', 'ptr', this, 'int', bEnable)
  EnableFill(bEnable) => DllCall('xcgui\XShapeEllipse_EnableFill', 'ptr', this, 'int', bEnable)
}
class CXShapeGroupBox extends CXShape {
  static Create(x, y, cx, cy, Name, hParent := 0) {
    if hShape := DllCall('xcgui\XShapeGroupBox_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'wstr', Name, 'ptr', hParent, 'ptr')
      return {Base: CXShapeGroupBox.Prototype, ptr: hShape}
  }
  __New(x, y, cx, cy, Name, hParent := 0) {
    if !hShape := DllCall('xcgui\XShapeGroupBox_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'wstr', Name, 'ptr', hParent)
      throw
    this.ptr := hShape
  }
  SetBorderColor(color, alpha := 255) => DllCall('xcgui\XShapeGroupBox_SetBorderColor', 'ptr', this, 'uint', color, 'uchar', alpha)
  SetTextColor(color, alpha := 255) => DllCall('xcgui\XShapeGroupBox_SetTextColor', 'ptr', this, 'uint', color, 'uchar', alpha)
  SetFontX(hFontX) => DllCall('xcgui\XShapeGroupBox_SetFontX', 'ptr', this, 'ptr', hFontX)
  SetTextOffset(offsetX, offsetY) => DllCall('xcgui\XShapeGroupBox_SetTextOffset', 'ptr', this, 'int', offsetX, 'int', offsetY)
  SetRoundAngle(nWidth, nHeight) => DllCall('xcgui\XShapeGroupBox_SetRoundAngle', 'ptr', this, 'int', nWidth, 'int', nHeight)
  SetText(Text) => DllCall('xcgui\XShapeGroupBox_SetText', 'ptr', this, 'wstr', Text)
  GetTextOffset(&OffsetX, &OffsetY) => DllCall('xcgui\XShapeGroupBox_GetTextOffset', 'ptr', this, 'int*', &OffsetX, 'int*', &OffsetY)
  GetRoundAngle(&Width, &Height) => DllCall('xcgui\XShapeGroupBox_GetRoundAngle', 'ptr', this, 'int*', &Width, 'int*', &Height)
  EnableRoundAngle(bEnable) => DllCall('xcgui\XShapeGroupBox_EnableRoundAngle', 'ptr', this, 'int', bEnable)
}
class CXTable extends CXShape {
  static Create(x, y, cx, cy, hParent := 0) {
    if hShape := DllCall('xcgui\XTable_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent, 'ptr')
      return {Base: CXTable.Prototype, ptr: hShape}
  }
  __New(x, y, cx, cy, hParent := 0) {
    if !hShape := DllCall('xcgui\XTable_Create', 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr', hParent)
      throw
    this.ptr := hShape
  }
  Reset(nRow, nCol) => DllCall('xcgui\XTable_Reset', 'ptr', this, 'int', nRow, 'int', nCol)
  ComboRow(iRow, iCol, count) => DllCall('xcgui\XTable_ComboRow', 'ptr', this, 'int', iRow, 'int', iCol, 'int', count)
  ComboCol(iRow, iCol, count) => DllCall('xcgui\XTable_ComboCol', 'ptr', this, 'int', iRow, 'int', iCol, 'int', count)
  SetColWidth(iCol, width) => DllCall('xcgui\XTable_SetColWidth', 'ptr', this, 'int', iCol, 'int', width)
  SetRowHeight(iRow, height) => DllCall('xcgui\XTable_SetRowHeight', 'ptr', this, 'int', iRow, 'int', height)
  SetBorderColor(color) => DllCall('xcgui\XTable_SetBorderColor', 'ptr', this, 'uint', color)
  SetTextColor(color) => DllCall('xcgui\XTable_SetTextColor', 'ptr', this, 'uint', color)
  SetFont(hFont) => DllCall('xcgui\XTable_SetFont', 'ptr', this, 'ptr', hFont)
  SetItemPadding(leftSize, topSize, rightSize, bottomSize) => DllCall('xcgui\XTable_SetItemPadding', 'ptr', this, 'int', leftSize, 'int', topSize, 'int', rightSize, 'int', bottomSize)
  SetItemText(iRow, iCol, Text) => DllCall('xcgui\XTable_SetItemText', 'ptr', this, 'int', iRow, 'int', iCol, 'wstr', Text)
  SetItemFont(iRow, iCol, hFont) => DllCall('xcgui\XTable_SetItemFont', 'ptr', this, 'int', iRow, 'int', iCol, 'ptr', hFont)
  SetItemTextAlign(iRow, iCol, nAlign) => DllCall('xcgui\XTable_SetItemTextAlign', 'ptr', this, 'int', iRow, 'int', iCol, 'int', nAlign)
  SetItemTextColor(iRow, iCol, color, bColor) => DllCall('xcgui\XTable_SetItemTextColor', 'ptr', this, 'int', iRow, 'int', iCol, 'uint', color, 'int', bColor)
  SetItemBkColor(iRow, iCol, color, bColor) => DllCall('xcgui\XTable_SetItemBkColor', 'ptr', this, 'int', iRow, 'int', iCol, 'uint', color, 'int', bColor)
  SetItemLine(iRow1, iCol1, iRow2, iCol2, nFlag, color) => DllCall('xcgui\XTable_SetItemLine', 'ptr', this, 'int', iRow1, 'int', iCol1, 'int', iRow2, 'int', iCol2, 'int', nFlag, 'uint', color)
  SetItemFlag(iRow, iCol, flag) => DllCall('xcgui\XTable_SetItemFlag', 'ptr', this, 'int', iRow, 'int', iCol, 'int', flag)
  GetItemRect(iRow, iCol, pRect) => DllCall('xcgui\XTable_GetItemRect', 'ptr', this, 'int', iRow, 'int', iCol, 'ptr', pRect, 'int')
}
class CXAdapter extends CXBase {
  AddRef() => DllCall('xcgui\XAd_AddRef', 'ptr', this, 'int')
  Release() => DllCall('xcgui\XAd_Release', 'ptr', this, 'int')
  GetRefCount() => DllCall('xcgui\XAd_GetRefCount', 'ptr', this, 'int')
  Destroy() => DllCall('xcgui\XAd_Destroy', 'ptr', this)
  EnableAutoDestroy(bEnable) => DllCall('xcgui\XAd_EnableAutoDestroy', 'ptr', this, 'int', bEnable)
}
class CXAdapterListView extends CXAdapter {
  static Create() {
    if hAdapter := DllCall('xcgui\XAdListView_Create', 'ptr')
      return {Base: CXAdapterListView.Prototype, ptr: hAdapter}
  }
  __New() {
    if !hAdapter := DllCall('xcgui\XAdListView_Create', 'ptr')
      throw
    this.ptr := hAdapter
  }
  Group_AddColumn(Name) => DllCall('xcgui\XAdListView_Group_AddColumn', 'ptr', this, 'wstr', Name, 'int')
  Group_AddItemText(Value, iPos := -1) => DllCall('xcgui\XAdListView_Group_AddItemText', 'ptr', this, 'wstr', Value, 'int', iPos, 'int')
  Group_AddItemTextEx(Name, Value, iPos := -1) => DllCall('xcgui\XAdListView_Group_AddItemTextEx', 'ptr', this, 'wstr', Name, 'wstr', Value, 'int', iPos, 'int')
  Group_AddItemImage(hImage, iPos := -1) => DllCall('xcgui\XAdListView_Group_AddItemImage', 'ptr', this, 'ptr', hImage, 'int', iPos, 'int')
  Group_AddItemImageEx(Name, hImage, iPos := -1) => DllCall('xcgui\XAdListView_Group_AddItemImageEx', 'ptr', this, 'wstr', Name, 'ptr', hImage, 'int', iPos, 'int')
  Group_SetText(iGroup, iColumn, Value) => DllCall('xcgui\XAdListView_Group_SetText', 'ptr', this, 'int', iGroup, 'int', iColumn, 'wstr', Value, 'int')
  Group_SetTextEx(iGroup, Name, Value) => DllCall('xcgui\XAdListView_Group_SetTextEx', 'ptr', this, 'int', iGroup, 'wstr', Name, 'wstr', Value, 'int')
  Group_SetImage(iGroup, iColumn, hImage) => DllCall('xcgui\XAdListView_Group_SetImage', 'ptr', this, 'int', iGroup, 'int', iColumn, 'ptr', hImage, 'int')
  Group_SetImageEx(iGroup, Name, hImage) => DllCall('xcgui\XAdListView_Group_SetImageEx', 'ptr', this, 'int', iGroup, 'wstr', Name, 'ptr', hImage, 'int')
  Item_AddColumn(Name) => DllCall('xcgui\XAdListView_Item_AddColumn', 'ptr', this, 'wstr', Name, 'int')
  Group_GetCount() => DllCall('xcgui\XAdListView_Group_GetCount', 'ptr', this, 'int')
  Item_GetCount(iGroup) => DllCall('xcgui\XAdListView_Item_GetCount', 'ptr', this, 'int', iGroup, 'int')
  Item_AddItemText(iGroup, Value, iPos := -1) => DllCall('xcgui\XAdListView_Item_AddItemText', 'ptr', this, 'int', iGroup, 'wstr', Value, 'int', iPos, 'int')
  Item_AddItemTextEx(iGroup, Name, Value, iPos := -1) => DllCall('xcgui\XAdListView_Item_AddItemTextEx', 'ptr', this, 'int', iGroup, 'wstr', Name, 'wstr', Value, 'int', iPos, 'int')
  Item_AddItemImage(iGroup, hImage, iPos := -1) => DllCall('xcgui\XAdListView_Item_AddItemImage', 'ptr', this, 'int', iGroup, 'ptr', hImage, 'int', iPos, 'int')
  Item_AddItemImageEx(iGroup, Name, hImage, iPos := -1) => DllCall('xcgui\XAdListView_Item_AddItemImageEx', 'ptr', this, 'int', iGroup, 'wstr', Name, 'ptr', hImage, 'int', iPos, 'int')
  Group_DeleteItem(iGroup) => DllCall('xcgui\XAdListView_Group_DeleteItem', 'ptr', this, 'int', iGroup, 'int')
  Group_DeleteAllChildItem(iGroup) => DllCall('xcgui\XAdListView_Group_DeleteAllChildItem', 'ptr', this, 'int', iGroup)
  Item_DeleteItem(iGroup, iItem) => DllCall('xcgui\XAdListView_Item_DeleteItem', 'ptr', this, 'int', iGroup, 'int', iItem, 'int')
  DeleteAll() => DllCall('xcgui\XAdListView_DeleteAll', 'ptr', this)
  DeleteAllGroup() => DllCall('xcgui\XAdListView_DeleteAllGroup', 'ptr', this)
  DeleteAllItem() => DllCall('xcgui\XAdListView_DeleteAllItem', 'ptr', this)
  DeleteColumnGroup(iColumn) => DllCall('xcgui\XAdListView_DeleteColumnGroup', 'ptr', this, 'int', iColumn)
  DeleteColumnItem(iColumn) => DllCall('xcgui\XAdListView_DeleteColumnItem', 'ptr', this, 'int', iColumn)
  Item_GetTextEx(iGroup, iItem, Name) => DllCall('xcgui\XAdListView_Item_GetTextEx', 'ptr', this, 'int', iGroup, 'int', iItem, 'wstr', Name, 'wstr')
  Item_GetImageEx(iGroup, iItem, Name) => DllCall('xcgui\XAdListView_Item_GetImageEx', 'ptr', this, 'int', iGroup, 'int', iItem, 'wstr', Name, 'ptr')
  Item_SetText(iGroup, iItem, iColumn, Value) => DllCall('xcgui\XAdListView_Item_SetText', 'ptr', this, 'int', iGroup, 'int', iItem, 'int', iColumn, 'wstr', Value, 'int')
  Item_SetTextEx(iGroup, iItem, Name, Value) => DllCall('xcgui\XAdListView_Item_SetTextEx', 'ptr', this, 'int', iGroup, 'int', iItem, 'wstr', Name, 'wstr', Value, 'int')
  Item_SetImage(iGroup, iItem, iColumn, hImage) => DllCall('xcgui\XAdListView_Item_SetImage', 'ptr', this, 'int', iGroup, 'int', iItem, 'int', iColumn, 'ptr', hImage, 'int')
  Item_SetImageEx(iGroup, iItem, Name, hImage) => DllCall('xcgui\XAdListView_Item_SetImageEx', 'ptr', this, 'int', iGroup, 'int', iItem, 'wstr', Name, 'ptr', hImage, 'int')
}
class CXAdapterTable extends CXAdapter {
  static Create() {
    if hAdapter := DllCall('xcgui\XAdTable_Create', 'ptr')
      return {Base: CXAdapterTable.Prototype, ptr: hAdapter}
  }
  __New() {
    if !hAdapter := DllCall('xcgui\XAdTable_Create', 'ptr')
      throw
    this.ptr := hAdapter
  }
  Sort(iColumn, bAscending) => DllCall('xcgui\XAdTable_Sort', 'ptr', this, 'int', iColumn, 'int', bAscending)
  GetItemDataType(iItem, iColumn) => DllCall('xcgui\XAdTable_GetItemDataType', 'ptr', this, 'int', iItem, 'int', iColumn, 'int')
  GetItemDataTypeEx(iItem, Name) => DllCall('xcgui\XAdTable_GetItemDataTypeEx', 'ptr', this, 'int', iItem, 'wstr', Name, 'int')
  AddColumn(Name) => DllCall('xcgui\XAdTable_AddColumn', 'ptr', this, 'wstr', Name, 'int')
  SetColumn(ColName) => DllCall('xcgui\XAdTable_SetColumn', 'ptr', this, 'wstr', ColName, 'int')
  AddItemText(Value) => DllCall('xcgui\XAdTable_AddItemText', 'ptr', this, 'wstr', Value, 'int')
  AddItemTextEx(Name, Value) => DllCall('xcgui\XAdTable_AddItemTextEx', 'ptr', this, 'wstr', Name, 'wstr', Value, 'int')
  AddItemImage(hImage) => DllCall('xcgui\XAdTable_AddItemImage', 'ptr', this, 'ptr', hImage, 'int')
  AddItemImageEx(Name, hImage) => DllCall('xcgui\XAdTable_AddItemImageEx', 'ptr', this, 'wstr', Name, 'ptr', hImage, 'int')
  InsertItemText(iItem, Value) => DllCall('xcgui\XAdTable_InsertItemText', 'ptr', this, 'int', iItem, 'wstr', Value, 'int')
  InsertItemTextEx(iItem, Name, Value) => DllCall('xcgui\XAdTable_InsertItemTextEx', 'ptr', this, 'int', iItem, 'wstr', Name, 'wstr', Value, 'int')
  InsertItemImage(iItem, hImage) => DllCall('xcgui\XAdTable_InsertItemImage', 'ptr', this, 'int', iItem, 'ptr', hImage, 'int')
  InsertItemImageEx(iItem, Name, hImage) => DllCall('xcgui\XAdTable_InsertItemImageEx', 'ptr', this, 'int', iItem, 'wstr', Name, 'ptr', hImage, 'int')
  SetItemText(iItem, iColumn, Value) => DllCall('xcgui\XAdTable_SetItemText', 'ptr', this, 'int', iItem, 'int', iColumn, 'wstr', Value, 'int')
  SetItemTextEx(iItem, Name, Value) => DllCall('xcgui\XAdTable_SetItemTextEx', 'ptr', this, 'int', iItem, 'wstr', Name, 'wstr', Value, 'int')
  SetItemInt(iItem, iColumn, nValue) => DllCall('xcgui\XAdTable_SetItemInt', 'ptr', this, 'int', iItem, 'int', iColumn, 'int', nValue, 'int')
  SetItemIntEx(iItem, Name, nValue) => DllCall('xcgui\XAdTable_SetItemIntEx', 'ptr', this, 'int', iItem, 'wstr', Name, 'int', nValue, 'int')
  SetItemFloat(iItem, iColumn, nValue) => DllCall('xcgui\XAdTable_SetItemFloat', 'ptr', this, 'int', iItem, 'int', iColumn, 'float', nValue, 'int')
  SetItemFloatEx(iItem, Name, nValue) => DllCall('xcgui\XAdTable_SetItemFloatEx', 'ptr', this, 'int', iItem, 'wstr', Name, 'float', nValue, 'int')
  SetItemImage(iItem, iColumn, hImage) => DllCall('xcgui\XAdTable_SetItemImage', 'ptr', this, 'int', iItem, 'int', iColumn, 'ptr', hImage, 'int')
  SetItemImageEx(iItem, Name, hImage) => DllCall('xcgui\XAdTable_SetItemImageEx', 'ptr', this, 'int', iItem, 'wstr', Name, 'ptr', hImage, 'int')
  DeleteItem(iItem) => DllCall('xcgui\XAdTable_DeleteItem', 'ptr', this, 'int', iItem, 'int')
  DeleteItemEx(iItem, nCount) => DllCall('xcgui\XAdTable_DeleteItemEx', 'ptr', this, 'int', iItem, 'int', nCount, 'int')
  DeleteItemAll() => DllCall('xcgui\XAdTable_DeleteItemAll', 'ptr', this)
  DeleteColumnAll() => DllCall('xcgui\XAdTable_DeleteColumnAll', 'ptr', this)
  GetCount() => DllCall('xcgui\XAdTable_GetCount', 'ptr', this, 'int')
  GetCountColumn() => DllCall('xcgui\XAdTable_GetCountColumn', 'ptr', this, 'int')
  GetItemText(iItem, iColumn) => DllCall('xcgui\XAdTable_GetItemText', 'ptr', this, 'int', iItem, 'int', iColumn, 'wstr')
  GetItemTextEx(iItem, Name) => DllCall('xcgui\XAdTable_GetItemTextEx', 'ptr', this, 'int', iItem, 'wstr', Name, 'wstr')
  GetItemImage(iItem, iColumn) => DllCall('xcgui\XAdTable_GetItemImage', 'ptr', this, 'int', iItem, 'int', iColumn, 'ptr')
  GetItemImageEx(iItem, Name) => DllCall('xcgui\XAdTable_GetItemImageEx', 'ptr', this, 'int', iItem, 'wstr', Name, 'ptr')
  GetItemInt(iItem, iColumn, &OutValue) => DllCall('xcgui\XAdTable_GetItemInt', 'ptr', this, 'int', iItem, 'int', iColumn, 'int*', &OutValue, 'int')
  GetItemIntEx(iItem, Name, &OutValue) => DllCall('xcgui\XAdTable_GetItemIntEx', 'ptr', this, 'int', iItem, 'wstr', Name, 'int*', &OutValue, 'int')
  GetItemFloat(iItem, iColumn, &OutValue) => DllCall('xcgui\XAdTable_GetItemFloat', 'ptr', this, 'int', iItem, 'int', iColumn, 'float*', &OutValue, 'int')
  GetItemFloatEx(iItem, Name, &OutValue) => DllCall('xcgui\XAdTable_GetItemFloatEx', 'ptr', this, 'int', iItem, 'wstr', Name, 'float*', &OutValue, 'int')
}
class CXAdapterMap extends CXAdapter {
  static Create() {
    if hAdapter := DllCall('xcgui\XAdMap_Create', 'ptr')
      return {Base: CXAdapterMap.Prototype, ptr: hAdapter}
  }
  __New() {
    if !hAdapter := DllCall('xcgui\XAdMap_Create', 'ptr')
      throw
    this.ptr := hAdapter
  }
  AddItemText(Name, Value) => DllCall('xcgui\XAdMap_AddItemText', 'ptr', this, 'wstr', Name, 'wstr', Value, 'int')
  AddItemImage(Name, hImage) => DllCall('xcgui\XAdMap_AddItemImage', 'ptr', this, 'wstr', Name, 'ptr', hImage, 'int')
  DeleteItem(Name) => DllCall('xcgui\XAdMap_DeleteItem', 'ptr', this, 'wstr', Name, 'int')
  GetCount() => DllCall('xcgui\XAdMap_GetCount', 'ptr', this, 'int')
  GetItemText(Name) => DllCall('xcgui\XAdMap_GetItemText', 'ptr', this, 'wstr', Name, 'wstr')
  GetItemImage(Name) => DllCall('xcgui\XAdMap_GetItemImage', 'ptr', this, 'wstr', Name, 'ptr')
  SetItemText(Name, Value) => DllCall('xcgui\XAdMap_SetItemText', 'ptr', this, 'wstr', Name, 'wstr', Value, 'int')
  SetItemImage(Name, hImage) => DllCall('xcgui\XAdMap_SetItemImage', 'ptr', this, 'wstr', Name, 'ptr', hImage, 'int')
}
class CXAdapterTree extends CXAdapter {
  static Create() {
    if hAdapter := DllCall('xcgui\XAdTree_Create', 'ptr')
      return {Base: CXAdapterTree.Prototype, ptr: hAdapter}
  }
  __New() {
    if !hAdapter := DllCall('xcgui\XAdTree_Create', 'ptr')
      throw
    this.ptr := hAdapter
  }
  AddColumn(Name) => DllCall('xcgui\XAdTree_AddColumn', 'ptr', this, 'wstr', Name, 'int')
  SetColumn(ColName) => DllCall('xcgui\XAdTree_SetColumn', 'ptr', this, 'wstr', ColName, 'int')
  InsertItemText(Value, nParentID := 0, insertID := -3) => DllCall('xcgui\XAdTree_InsertItemText', 'ptr', this, 'wstr', Value, 'int', nParentID, 'int', insertID, 'int')
  InsertItemTextEx(Name, Value, nParentID := 0, insertID := -3) => DllCall('xcgui\XAdTree_InsertItemTextEx', 'ptr', this, 'wstr', Name, 'wstr', Value, 'int', nParentID, 'int', insertID, 'int')
  InsertItemImage(hImage, nParentID := 0, insertID := -3) => DllCall('xcgui\XAdTree_InsertItemImage', 'ptr', this, 'ptr', hImage, 'int', nParentID, 'int', insertID, 'int')
  InsertItemImageEx(Name, hImage, nParentID := 0, insertID := -3) => DllCall('xcgui\XAdTree_InsertItemImageEx', 'ptr', this, 'wstr', Name, 'ptr', hImage, 'int', nParentID, 'int', insertID, 'int')
  GetCount() => DllCall('xcgui\XAdTree_GetCount', 'ptr', this, 'int')
  GetCountColumn() => DllCall('xcgui\XAdTree_GetCountColumn', 'ptr', this, 'int')
  SetItemText(nID, iColumn, Value) => DllCall('xcgui\XAdTree_SetItemText', 'ptr', this, 'int', nID, 'int', iColumn, 'wstr', Value, 'int')
  SetItemTextEx(nID, Name, Value) => DllCall('xcgui\XAdTree_SetItemTextEx', 'ptr', this, 'int', nID, 'wstr', Name, 'wstr', Value, 'int')
  SetItemImage(nID, iColumn, hImage) => DllCall('xcgui\XAdTree_SetItemImage', 'ptr', this, 'int', nID, 'int', iColumn, 'ptr', hImage, 'int')
  SetItemImageEx(nID, Name, hImage) => DllCall('xcgui\XAdTree_SetItemImageEx', 'ptr', this, 'int', nID, 'wstr', Name, 'ptr', hImage, 'int')
  GetItemText(nID, iColumn) => DllCall('xcgui\XAdTree_GetItemText', 'ptr', this, 'int', nID, 'int', iColumn, 'wstr')
  GetItemTextEx(nID, Name) => DllCall('xcgui\XAdTree_GetItemTextEx', 'ptr', this, 'int', nID, 'wstr', Name, 'wstr')
  GetItemImage(nID, iColumn) => DllCall('xcgui\XAdTree_GetItemImage', 'ptr', this, 'int', nID, 'int', iColumn, 'ptr')
  GetItemImageEx(nID, Name) => DllCall('xcgui\XAdTree_GetItemImageEx', 'ptr', this, 'int', nID, 'wstr', Name, 'ptr')
  DeleteItem(nID) => DllCall('xcgui\XAdTree_DeleteItem', 'ptr', this, 'int', nID, 'int')
  DeleteItemAll() => DllCall('xcgui\XAdTree_DeleteItemAll', 'ptr', this)
  DeleteColumnAll() => DllCall('xcgui\XAdTree_DeleteColumnAll', 'ptr', this)
}
class CXBkManager extends CXBase {
  static Create() {
    if hBkM := DllCall('xcgui\XBkM_Create', 'ptr')
      return {Base: CXBkManager.Prototype, ptr: hBkM}
  }
  __New() {
    if !hBkM := DllCall('xcgui\XBkM_Create', 'ptr')
      throw
    this.ptr := hBkM
  }
  Destroy() => DllCall('xcgui\XBkM_Destroy', 'ptr', this)
  SetBkInfo(Text) => DllCall('xcgui\XBkM_SetBkInfo', 'ptr', this, 'wstr', Text, 'int')
  AddInfo(Text) => DllCall('xcgui\XBkM_AddInfo', 'ptr', this, 'wstr', Text, 'int')
  AddBorder(nState, color, alpha, width) => DllCall('xcgui\XBkM_AddBorder', 'ptr', this, 'int', nState, 'uint', color, 'uchar', alpha, 'int', width)
  AddFill(nState, color, alpha) => DllCall('xcgui\XBkM_AddFill', 'ptr', this, 'int', nState, 'uint', color, 'uchar', alpha)
  AddImage(nState, hImage) => DllCall('xcgui\XBkM_AddImage', 'ptr', this, 'int', nState, 'ptr', hImage)
  GetCount() => DllCall('xcgui\XBkM_GetCount', 'ptr', this, 'int')
  Clear() => DllCall('xcgui\XBkM_Clear', 'ptr', this)
  Draw(nState, hDraw, pRect) => DllCall('xcgui\XBkM_Draw', 'ptr', this, 'int', nState, 'ptr', hDraw, 'ptr', pRect, 'int')
  DrawEx(nState, hDraw, pRect, nStateEx) => DllCall('xcgui\XBkM_DrawEx', 'ptr', this, 'int', nState, 'ptr', hDraw, 'ptr', pRect, 'int', nStateEx, 'int')
  EnableAutoDestroy(bEnable) => DllCall('xcgui\XBkM_EnableAutoDestroy', 'ptr', this, 'int', bEnable)
  AddRef() => DllCall('xcgui\XBkM_AddRef', 'ptr', this)
  Release() => DllCall('xcgui\XBkM_Release', 'ptr', this)
  GetRefCount() => DllCall('xcgui\XBkM_GetRefCount', 'ptr', this, 'int')
}
class CXDraw extends CXBase {
  static Create(hdc) {
    if hDraw := DllCall('xcgui\XDraw_Create', 'ptr', hdc, 'ptr')
      return {Base: CXDraw.Prototype, ptr: hDraw}
  }
  __New(hdc) {
    if !hDraw := DllCall('xcgui\XDraw_Create', 'ptr', hdc, 'ptr')
      throw
    this.ptr := hDraw
  }
  Destroy() => DllCall('xcgui\XDraw_Destroy', 'ptr', this)
  SetOffset(x, y) => DllCall('xcgui\XDraw_SetOffset', 'ptr', this, 'int', x, 'int', y)
  GetOffset(&X, &Y) => DllCall('xcgui\XDraw_GetOffset', 'ptr', this, 'int*', &X, 'int*', &Y)
  RestoreGDIOBJ() => DllCall('xcgui\XDraw_RestoreGDIOBJ', 'ptr', this)
  GetHDC() => DllCall('xcgui\XDraw_GetHDC', 'ptr', this, 'ptr')
  SetBrushColor(color, alpha := 255) => DllCall('xcgui\XDraw_SetBrushColor', 'ptr', this, 'uint', color, 'uchar', alpha)
  SetTextVertical(bVertical) => DllCall('xcgui\XDraw_SetTextVertical', 'ptr', this, 'int', bVertical)
  SetTextAlign(nFlag) => DllCall('xcgui\XDraw_SetTextAlign', 'ptr', this, 'int', nFlag)
  SetFontX(hFontx) => DllCall('xcgui\XDraw_SetFontX', 'ptr', this, 'ptr', hFontx)
  SetLineWidth(nWidth) => DllCall('xcgui\XDraw_SetLineWidth', 'ptr', this, 'int', nWidth)
  SetBkMode(bTransparent) => DllCall('xcgui\XDraw_SetBkMode', 'ptr', this, 'int', bTransparent, 'int')
  SetClipRect(pRect) => DllCall('xcgui\XDraw_SetClipRect', 'ptr', this, 'ptr', pRect)
  ClearClip() => DllCall('xcgui\XDraw_ClearClip', 'ptr', this)
  EnableSmoothingMode(bEnable) => DllCall('xcgui\XDraw_EnableSmoothingMode', 'ptr', this, 'int', bEnable)
  EnableWndTransparent(bTransparent) => DllCall('xcgui\XDraw_EnableWndTransparent', 'ptr', this, 'int', bTransparent)
  CreateSolidBrush(crColor) => DllCall('xcgui\XDraw_CreateSolidBrush', 'ptr', this, 'uint', crColor, 'ptr')
  CreatePen(fnPenStyle, nWidth, crColor) => DllCall('xcgui\XDraw_CreatePen', 'ptr', this, 'int', fnPenStyle, 'int', nWidth, 'uint', crColor, 'ptr')
  CreateRectRgn(nLeftRect, nTopRect, nRightRect, nBottomRect) => DllCall('xcgui\XDraw_CreateRectRgn', 'ptr', this, 'int', nLeftRect, 'int', nTopRect, 'int', nRightRect, 'int', nBottomRect, 'ptr')
  CreateRoundRectRgn(nLeftRect, nTopRect, nRightRect, nBottomRect, nWidthEllipse, nHeightEllipse) => DllCall('xcgui\XDraw_CreateRoundRectRgn', 'ptr', this, 'int', nLeftRect, 'int', nTopRect, 'int', nRightRect, 'int', nBottomRect, 'int', nWidthEllipse, 'int', nHeightEllipse, 'ptr')
  CreatePolygonRgn(pPt, cPoints, fnPolyFillMode) => DllCall('xcgui\XDraw_CreatePolygonRgn', 'ptr', this, 'ptr', pPt, 'int', cPoints, 'int', fnPolyFillMode, 'ptr')
  SelectClipRgn(hRgn) => DllCall('xcgui\XDraw_SelectClipRgn', 'ptr', this, 'ptr', hRgn, 'int')
  FillRect(pRect) => DllCall('xcgui\XDraw_FillRect', 'ptr', this, 'ptr', pRect)
  FillRectColor(pRect, color, alpha := 255) => DllCall('xcgui\XDraw_FillRectColor', 'ptr', this, 'ptr', pRect, 'uint', color, 'uchar', alpha)
  FillRgn(hrgn, hbr) => DllCall('xcgui\XDraw_FillRgn', 'ptr', this, 'ptr', hrgn, 'ptr', hbr, 'int')
  FillEllipse(pRect) => DllCall('xcgui\XDraw_FillEllipse', 'ptr', this, 'ptr', pRect)
  DrawEllipse(pRect) => DllCall('xcgui\XDraw_DrawEllipse', 'ptr', this, 'ptr', pRect)
  FillRoundRect(pRect, nWidth, nHeight) => DllCall('xcgui\XDraw_FillRoundRect', 'ptr', this, 'ptr', pRect, 'int', nWidth, 'int', nHeight)
  DrawRoundRect(pRect, nWidth, nHeight) => DllCall('xcgui\XDraw_DrawRoundRect', 'ptr', this, 'ptr', pRect, 'int', nWidth, 'int', nHeight)
  FillRoundRectEx(pRect, nLeftTop, nRightTop, nRightBottom, nLeftBottom) => DllCall('xcgui\XDraw_FillRoundRectEx', 'ptr', this, 'ptr', pRect, 'int', nLeftTop, 'int', nRightTop, 'int', nRightBottom, 'int', nLeftBottom)
  DrawRoundRectEx(pRect, nLeftTop, nRightTop, nRightBottom, nLeftBottom) => DllCall('xcgui\XDraw_DrawRoundRectEx', 'ptr', this, 'ptr', pRect, 'int', nLeftTop, 'int', nRightTop, 'int', nRightBottom, 'int', nLeftBottom)
  Rectangle(nLeftRect, nTopRect, nRightRect, nBottomRect) => DllCall('xcgui\XDraw_Rectangle', 'ptr', this, 'int', nLeftRect, 'int', nTopRect, 'int', nRightRect, 'int', nBottomRect, 'int')
  DrawGroupBox_Rect(pRect, Name, textColor, textAlpha, pOffset) => DllCall('xcgui\XDraw_DrawGroupBox_Rect', 'ptr', this, 'ptr', pRect, 'wstr', Name, 'uint', textColor, 'uchar', textAlpha, 'ptr', pOffset)
  DrawGroupBox_RoundRect(pRect, Name, textColor, textAlpha, pOffset, nWidth, nHeight) => DllCall('xcgui\XDraw_DrawGroupBox_RoundRect', 'ptr', this, 'ptr', pRect, 'wstr', Name, 'uint', textColor, 'uchar', textAlpha, 'ptr', pOffset, 'int', nWidth, 'int', nHeight)
  GradientFill2(color1, alpha1, color2, alpha2, pRect, mode) => DllCall('xcgui\XDraw_GradientFill2', 'ptr', this, 'uint', color1, 'uchar', alpha1, 'uint', color2, 'uchar', alpha2, 'ptr', pRect, 'int', mode)
  GradientFill4(color1, color2, color3, color4, pRect, mode) => DllCall('xcgui\XDraw_GradientFill4', 'ptr', this, 'uint', color1, 'uint', color2, 'uint', color3, 'uint', color4, 'ptr', pRect, 'int', mode, 'int')
  FrameRgn(hrgn, hbr, nWidth, nHeight) => DllCall('xcgui\XDraw_FrameRgn', 'ptr', this, 'ptr', hrgn, 'ptr', hbr, 'int', nWidth, 'int', nHeight, 'int')
  FrameRect(pRect) => DllCall('xcgui\XDraw_FrameRect', 'ptr', this, 'ptr', pRect)
  DrawLine(x1, y1, x2, y2) => DllCall('xcgui\XDraw_DrawLine', 'ptr', this, 'int', x1, 'int', y1, 'int', x2, 'int', y2)
  DrawCurve(points, count, tension) => DllCall('xcgui\XDraw_DrawCurve', 'ptr', this, 'ptr', points, 'int', count, 'float', tension)
  FocusRect(pRect) => DllCall('xcgui\XDraw_FocusRect', 'ptr', this, 'ptr', pRect)
  MoveToEx(X, Y, pPoint := 0) => DllCall('xcgui\XDraw_MoveToEx', 'ptr', this, 'int', X, 'int', Y, 'ptr', pPoint, 'int')
  LineTo(nXEnd, nYEnd) => DllCall('xcgui\XDraw_LineTo', 'ptr', this, 'int', nXEnd, 'int', nYEnd, 'int')
  Polyline(pArrayPt, arrayPtSize) => DllCall('xcgui\XDraw_Polyline', 'ptr', this, 'ptr', pArrayPt, 'int', arrayPtSize, 'int')
  Dottedline(x1, y1, x2, y2) => DllCall('xcgui\XDraw_Dottedline', 'ptr', this, 'int', x1, 'int', y1, 'int', x2, 'int', y2)
  SetPixel(X, Y, crColor) => DllCall('xcgui\XDraw_SetPixel', 'ptr', this, 'int', X, 'int', Y, 'uint', crColor, 'uint')
  Check(x, y, color, bCheck) => DllCall('xcgui\XDraw_Check', 'ptr', this, 'int', x, 'int', y, 'uint', color, 'int', bCheck)
  DrawIconEx(xLeft, yTop, hIcon, cxWidth, cyWidth, istepIfAniCur, hbrFlickerFreeDraw, diFlags) => DllCall('xcgui\XDraw_DrawIconEx', 'ptr', this, 'int', xLeft, 'int', yTop, 'ptr', hIcon, 'int', cxWidth, 'int', cyWidth, 'uint', istepIfAniCur, 'ptr', hbrFlickerFreeDraw, 'uint', diFlags, 'int')
  BitBlt(nXDest, nYDest, nWidth, nHeight, hdcSrc, nXSrc, nYSrc, dwRop) => DllCall('xcgui\XDraw_BitBlt', 'ptr', this, 'int', nXDest, 'int', nYDest, 'int', nWidth, 'int', nHeight, 'ptr', hdcSrc, 'int', nXSrc, 'int', nYSrc, 'uint', dwRop, 'int')
  BitBlt2(nXDest, nYDest, nWidth, nHeight, hDrawSrc, nXSrc, nYSrc, dwRop) => DllCall('xcgui\XDraw_BitBlt2', 'ptr', this, 'int', nXDest, 'int', nYDest, 'int', nWidth, 'int', nHeight, 'ptr', hDrawSrc, 'int', nXSrc, 'int', nYSrc, 'uint', dwRop, 'int')
  AlphaBlend(nXOriginDest, nYOriginDest, nWidthDest, nHeightDest, hdcSrc, nXOriginSrc, nYOriginSrc, nWidthSrc, nHeightSrc, alpha) => DllCall('xcgui\XDraw_AlphaBlend', 'ptr', this, 'int', nXOriginDest, 'int', nYOriginDest, 'int', nWidthDest, 'int', nHeightDest, 'ptr', hdcSrc, 'int', nXOriginSrc, 'int', nYOriginSrc, 'int', nWidthSrc, 'int', nHeightSrc, 'int', alpha, 'int')
  TriangularArrow(align, x, y, width, height) => DllCall('xcgui\XDraw_TriangularArrow', 'ptr', this, 'int', align, 'int', x, 'int', y, 'int', width, 'int', height)
  DrawPolygon(points, nCount) => DllCall('xcgui\XDraw_DrawPolygon', 'ptr', this, 'ptr', points, 'int', nCount)
  DrawPolygonF(points, nCount) => DllCall('xcgui\XDraw_DrawPolygonF', 'ptr', this, 'ptr', points, 'int', nCount)
  FillPolygon(points, nCount) => DllCall('xcgui\XDraw_FillPolygon', 'ptr', this, 'ptr', points, 'int', nCount)
  FillPolygonF(points, nCount) => DllCall('xcgui\XDraw_FillPolygonF', 'ptr', this, 'ptr', points, 'int', nCount)
  Image(hImageFrame, x, y) => DllCall('xcgui\XDraw_Image', 'ptr', this, 'ptr', hImageFrame, 'int', x, 'int', y)
  Image2(hImageFrame, x, y, width, height) => DllCall('xcgui\XDraw_Image2', 'ptr', this, 'ptr', hImageFrame, 'int', x, 'int', y, 'int', width, 'int', height)
  ImageStretch(hImageFrame, x, y, width, height) => DllCall('xcgui\XDraw_ImageStretch', 'ptr', this, 'ptr', hImageFrame, 'int', x, 'int', y, 'int', width, 'int', height)
  ImageAdaptive(hImageFrame, pRect, bOnlyBorder := false) => DllCall('xcgui\XDraw_ImageAdaptive', 'ptr', this, 'ptr', hImageFrame, 'ptr', pRect, 'int', bOnlyBorder)
  ImageExTile(hImageFrame, pRect, flag := 0) => DllCall('xcgui\XDraw_ImageExTile', 'ptr', this, 'ptr', hImageFrame, 'ptr', pRect, 'int', flag)
  ImageSuper(hImageFrame, pRect, bClip := false) => DllCall('xcgui\XDraw_ImageSuper', 'ptr', this, 'ptr', hImageFrame, 'ptr', pRect, 'int', bClip)
  ImageSuper2(hImageFrame, pRcDest, pSrcRect) => DllCall('xcgui\XDraw_ImageSuper2', 'ptr', this, 'ptr', hImageFrame, 'ptr', pRcDest, 'ptr', pSrcRect)
  ImageSuperMask(hImageFrame, hImageFrameMask, pRect, pRectMask, bClip := false) => DllCall('xcgui\XDraw_ImageSuperMask', 'ptr', this, 'ptr', hImageFrame, 'ptr', hImageFrameMask, 'ptr', pRect, 'ptr', pRectMask, 'int', bClip)
  ImageMask(hImageFrame, hImageFrameMask, x, y, x2, y2) => DllCall('xcgui\XDraw_ImageMask', 'ptr', this, 'ptr', hImageFrame, 'ptr', hImageFrameMask, 'int', x, 'int', y, 'int', x2, 'int', y2)
  DrawText(String, nCount, lpRect) => DllCall('xcgui\XDraw_DrawText', 'ptr', this, 'wstr', String, 'int', nCount, 'ptr', lpRect)
  DrawTextUnderline(String, nCount, lpRect, colorLine, alphaLine := 255) => DllCall('xcgui\XDraw_DrawTextUnderline', 'ptr', this, 'wstr', String, 'int', nCount, 'ptr', lpRect, 'uint', colorLine, 'uchar', alphaLine)
  TextOut(nXStart, nYStart, String, cbString) => DllCall('xcgui\XDraw_TextOut', 'ptr', this, 'int', nXStart, 'int', nYStart, 'wstr', String, 'int', cbString)
  TextOutEx(nXStart, nYStart, String) => DllCall('xcgui\XDraw_TextOutEx', 'ptr', this, 'int', nXStart, 'int', nYStart, 'wstr', String)
  TextOutA(nXStart, nYStart, String) => DllCall('xcgui\XDraw_TextOutA', 'ptr', this, 'int', nXStart, 'int', nYStart, 'astr', String)
}
class CXFont extends CXBase {
  static Create(size) {
    if hFont := DllCall('xcgui\XFont_Create', 'int', size, 'ptr')
      return {Base: CXFont.Prototype, ptr: hFont}
  }
  __New(size) {
    if !hFont := DllCall('xcgui\XFont_Create', 'int', size)
      throw
    this.ptr := hFont
  }
  Create2(Name := "宋体", size := 12, style := 0) {
    hFont := DllCall('xcgui\XFont_Create2', 'wstr', Name, 'int', size, 'int', style, 'ptr')
    return hFont
  }
  Create3(pInfo) {
    hFont := DllCall('xcgui\XFont_Create3', 'ptr', pInfo, 'ptr')
    return hFont
  }
  CreateEx(pFontInfo) {
    hFont := DllCall('xcgui\XFont_CreateEx', 'ptr', pFontInfo, 'ptr')
    return hFont
  }
  CreateFromHFONT(hFont) {
    hFont := DllCall('xcgui\XFont_CreateFromHFONT', 'ptr', hFont, 'ptr')
    return hFont
  }
  CreateFromFont(pFont) {
    hFont := DllCall('xcgui\XFont_CreateFromFont', 'ptr', pFont, 'ptr')
    return hFont
  }
  CreateFromFile(FontFile, size := 12, style := 0) {
    hFont := DllCall('xcgui\XFont_CreateFromFile', 'wstr', FontFile, 'int', size, 'int', style, 'ptr')
    return hFont
  }
  EnableAutoDestroy(bEnable) => DllCall('xcgui\XFont_EnableAutoDestroy', 'ptr', this, 'int', bEnable)
  GetFont() => DllCall('xcgui\XFont_GetFont', 'ptr', this, 'ptr')
  GetFontInfo(pInfo) => DllCall('xcgui\XFont_GetFontInfo', 'ptr', this, 'ptr', pInfo)
  GetLOGFONTW(hdc, pOut) => DllCall('xcgui\XFont_GetLOGFONTW', 'ptr', this, 'ptr', hdc, 'ptr', pOut, 'int')
  Destroy() => DllCall('xcgui\XFont_Destroy', 'ptr', this)
  AddRef() => DllCall('xcgui\XFont_AddRef', 'ptr', this)
  GetRefCount() => DllCall('xcgui\XFont_GetRefCount', 'ptr', this, 'int')
  Release() => DllCall('xcgui\XFont_Release', 'ptr', this)
}
class CXImageSrc extends CXBase {
  static LoadFile(FileName) {
    if hImageSrc := DllCall('xcgui\XImgSrc_LoadFile', 'wstr', FileName, 'ptr')
      return {Base: CXImageSrc.Prototype, ptr: hImageSrc}
  }
  static LoadFileRect(FileName, x, y, cx, cy) {
    if hImageSrc := DllCall('xcgui\XImgSrc_LoadFileRect', 'wstr', FileName, 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr')
      return {Base: CXImageSrc.Prototype, ptr: hImageSrc}
  }
  static LoadRes(id, Type) {
    if hImageSrc := DllCall('xcgui\XImgSrc_LoadRes', 'int', id, 'wstr', Type, 'ptr')
      return {Base: CXImageSrc.Prototype, ptr: hImageSrc}
  }
  static LoadZip(ZipFileName, FileName, pPassword := 0) {
    if hImageSrc := DllCall('xcgui\XImgSrc_LoadZip', 'wstr', ZipFileName, 'wstr', FileName, 'ptr', pPassword, 'ptr')
      return {Base: CXImageSrc.Prototype, ptr: hImageSrc}
  }
  static LoadZipRect(ZipFileName, FileName, pPassword, x, y, cx, cy) {
    if hImageSrc := DllCall('xcgui\XImgSrc_LoadZipRect', 'wstr', ZipFileName, 'wstr', FileName, 'ptr', pPassword, 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr')
      return {Base: CXImageSrc.Prototype, ptr: hImageSrc}
  }
  static LoadZipMem(data, length, FileName, pPassword := 0) {
    if hImageSrc := DllCall('xcgui\XImgSrc_LoadZipMem', 'ptr', data, 'int', length, 'wstr', FileName, 'ptr', pPassword, 'ptr')
      return {Base: CXImageSrc.Prototype, ptr: hImageSrc}
  }
  static LoadMemory(pBuffer, nSize) {
    if hImageSrc := DllCall('xcgui\XImgSrc_LoadMemory', 'ptr', pBuffer, 'int', nSize, 'ptr')
      return {Base: CXImageSrc.Prototype, ptr: hImageSrc}
  }
  static LoadMemoryRect(pBuffer, nSize, x, y, cx, cy) {
    if hImageSrc := DllCall('xcgui\XImgSrc_LoadMemoryRect', 'ptr', pBuffer, 'int', nSize, 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr')
      return {Base: CXImageSrc.Prototype, ptr: hImageSrc}
  }
  static LoadFromImage(pImage) {
    if hImageSrc := DllCall('xcgui\XImgSrc_LoadFromImage', 'ptr', pImage, 'ptr')
      return {Base: CXImageSrc.Prototype, ptr: hImageSrc}
  }
  static LoadFromExtractIcon(FileName) {
    if hImageSrc := DllCall('xcgui\XImgSrc_LoadFromExtractIcon', 'wstr', FileName, 'ptr')
      return {Base: CXImageSrc.Prototype, ptr: hImageSrc}
  }
  static LoadFromHICON(hIcon) {
    if hImageSrc := DllCall('xcgui\XImgSrc_LoadFromHICON', 'ptr', hIcon, 'ptr')
      return {Base: CXImageSrc.Prototype, ptr: hImageSrc}
  }
  static LoadFromHBITMAP(hBitmap) {
    if hImageSrc := DllCall('xcgui\XImgSrc_LoadFromHBITMAP', 'ptr', hBitmap, 'ptr')
      return {Base: CXImageSrc.Prototype, ptr: hImageSrc}
  }
  EnableAutoDestroy(bEnable) => DllCall('xcgui\XImgSrc_EnableAutoDestroy', 'ptr', this, 'int', bEnable)
  GetWidth() => DllCall('xcgui\XImgSrc_GetWidth', 'ptr', this, 'int')
  GetHeight() => DllCall('xcgui\XImgSrc_GetHeight', 'ptr', this, 'int')
  GetFile() => DllCall('xcgui\XImgSrc_GetFile', 'ptr', this, 'wstr')
  AddRef() => DllCall('xcgui\XImgSrc_AddRef', 'ptr', this)
  Release() => DllCall('xcgui\XImgSrc_Release', 'ptr', this)
  GetRefCount() => DllCall('xcgui\XImgSrc_GetRefCount', 'ptr', this, 'int')
  Destroy() => DllCall('xcgui\XImgSrc_Destroy', 'ptr', this)
}
class CXImage extends CXBase {
  static LoadSrc(hImageSrc) {
    if hImage := DllCall('xcgui\XImage_LoadSrc', 'ptr', hImageSrc, 'ptr')
      return {Base: CXImage.Prototype, ptr: hImage}
  }
  static LoadFile(FileName, bStretch := false) {
    if hImage := DllCall('xcgui\XImage_LoadFile', 'wstr', FileName, 'int', bStretch, 'ptr')
      return {Base: CXImage.Prototype, ptr: hImage}
  }
  static LoadFileAdaptive(FileName, leftSize, topSize, rightSize, bottomSize) {
    if hImage := DllCall('xcgui\XImage_LoadFileAdaptive', 'wstr', FileName, 'int', leftSize, 'int', topSize, 'int', rightSize, 'int', bottomSize, 'ptr')
      return {Base: CXImage.Prototype, ptr: hImage}
  }
  static LoadFileRect(FileName, x, y, cx, cy) {
    if hImage := DllCall('xcgui\XImage_LoadFileRect', 'wstr', FileName, 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr')
      return {Base: CXImage.Prototype, ptr: hImage}
  }
  static LoadResAdaptive(id, Type, leftSize, topSize, rightSize, bottomSize) {
    if hImage := DllCall('xcgui\XImage_LoadResAdaptive', 'int', id, 'wstr', Type, 'int', leftSize, 'int', topSize, 'int', rightSize, 'int', bottomSize, 'ptr')
      return {Base: CXImage.Prototype, ptr: hImage}
  }
  static LoadRes(id, Type, bStretch := false) {
    if hImage := DllCall('xcgui\XImage_LoadRes', 'int', id, 'wstr', Type, 'int', bStretch, 'ptr')
      return {Base: CXImage.Prototype, ptr: hImage}
  }
  static LoadZip(ZipFileName, FileName, pPassword := 0, bStretch := false) {
    if hImage := DllCall('xcgui\XImage_LoadZip', 'wstr', ZipFileName, 'wstr', FileName, 'ptr', pPassword, 'int', bStretch, 'ptr')
      return {Base: CXImage.Prototype, ptr: hImage}
  }
  static LoadZipAdaptive(ZipFileName, FileName, pPassword, x1, x2, y1, y2) {
    if hImage := DllCall('xcgui\XImage_LoadZipAdaptive', 'wstr', ZipFileName, 'wstr', FileName, 'ptr', pPassword, 'int', x1, 'int', x2, 'int', y1, 'int', y2, 'ptr')
      return {Base: CXImage.Prototype, ptr: hImage}
  }
  static LoadZipRect(ZipFileName, FileName, pPassword, x, y, cx, cy) {
    if hImage := DllCall('xcgui\XImage_LoadZipRect', 'wstr', ZipFileName, 'wstr', FileName, 'ptr', pPassword, 'int', x, 'int', y, 'int', cx, 'int', cy, 'ptr')
      return {Base: CXImage.Prototype, ptr: hImage}
  }
  static LoadZipMem(data, length, FileName, pPassword := 0, bStretch := false) {
    if hImage := DllCall('xcgui\XImage_LoadZipMem', 'ptr', data, 'int', length, 'wstr', FileName, 'ptr', pPassword, 'int', bStretch, 'ptr')
      return {Base: CXImage.Prototype, ptr: hImage}
  }
  static LoadMemory(pBuffer, nSize, bStretch) {
    if hImage := DllCall('xcgui\XImage_LoadMemory', 'ptr', pBuffer, 'int', nSize, 'int', bStretch, 'ptr')
      return {Base: CXImage.Prototype, ptr: hImage}
  }
  static LoadMemoryRect(pBuffer, nSize, x, y, cx, cy, bStretch) {
    if hImage := DllCall('xcgui\XImage_LoadMemoryRect', 'ptr', pBuffer, 'int', nSize, 'int', x, 'int', y, 'int', cx, 'int', cy, 'int', bStretch, 'ptr')
      return {Base: CXImage.Prototype, ptr: hImage}
  }
  static LoadMemoryAdaptive(pBuffer, nSize, leftSize, topSize, rightSize, bottomSize) {
    if hImage := DllCall('xcgui\XImage_LoadMemoryAdaptive', 'ptr', pBuffer, 'int', nSize, 'int', leftSize, 'int', topSize, 'int', rightSize, 'int', bottomSize, 'ptr')
      return {Base: CXImage.Prototype, ptr: hImage}
  }
  static LoadFromImage(pImage) {
    if hImage := DllCall('xcgui\XImage_LoadFromImage', 'ptr', pImage, 'ptr')
      return {Base: CXImage.Prototype, ptr: hImage}
  }
  static LoadFromExtractIcon(FileName) {
    if hImage := DllCall('xcgui\XImage_LoadFromExtractIcon', 'wstr', FileName, 'ptr')
      return {Base: CXImage.Prototype, ptr: hImage}
  }
  static LoadFromHICON(hIcon) {
    if hImage := DllCall('xcgui\XImage_LoadFromHICON', 'ptr', hIcon, 'ptr')
      return {Base: CXImage.Prototype, ptr: hImage}
  }
  static LoadFromHBITMAP(hBitmap) {
    if hImage := DllCall('xcgui\XImage_LoadFromHBITMAP', 'ptr', hBitmap, 'ptr')
      return {Base: CXImage.Prototype, ptr: hImage}
  }
  IsStretch() => DllCall('xcgui\XImage_IsStretch', 'ptr', this, 'int')
  IsAdaptive() => DllCall('xcgui\XImage_IsAdaptive', 'ptr', this, 'int')
  IsTile() => DllCall('xcgui\XImage_IsTile', 'ptr', this, 'int')
  SetDrawType(nType) => DllCall('xcgui\XImage_SetDrawType', 'ptr', this, 'int', nType, 'int')
  SetDrawTypeAdaptive(leftSize, topSize, rightSize, bottomSize) => DllCall('xcgui\XImage_SetDrawTypeAdaptive', 'ptr', this, 'int', leftSize, 'int', topSize, 'int', rightSize, 'int', bottomSize, 'int')
  SetTranColor(color) => DllCall('xcgui\XImage_SetTranColor', 'ptr', this, 'uint', color)
  SetTranColorEx(color, tranColor) => DllCall('xcgui\XImage_SetTranColorEx', 'ptr', this, 'uint', color, 'uchar', tranColor)
  SetRotateAngle(fAngle) => DllCall('xcgui\XImage_SetRotateAngle', 'ptr', this, 'float', fAngle, 'float')
  SetSplitEqual(nCount, iIndex) => DllCall('xcgui\XImage_SetSplitEqual', 'ptr', this, 'int', nCount, 'int', iIndex)
  EnableTranColor(bEnable) => DllCall('xcgui\XImage_EnableTranColor', 'ptr', this, 'int', bEnable)
  EnableAutoDestroy(bEnable) => DllCall('xcgui\XImage_EnableAutoDestroy', 'ptr', this, 'int', bEnable)
  EnableCenter(bCenter) => DllCall('xcgui\XImage_EnableCenter', 'ptr', this, 'int', bCenter)
  IsCenter() => DllCall('xcgui\XImage_IsCenter', 'ptr', this, 'int')
  GetDrawType() => DllCall('xcgui\XImage_GetDrawType', 'ptr', this, 'int')
  GetWidth() => DllCall('xcgui\XImage_GetWidth', 'ptr', this, 'int')
  GetHeight() => DllCall('xcgui\XImage_GetHeight', 'ptr', this, 'int')
  GetImageSrc() => DllCall('xcgui\XImage_GetImageSrc', 'ptr', this, 'ptr')
  AddRef() => DllCall('xcgui\XImage_AddRef', 'ptr', this)
  Release() => DllCall('xcgui\XImage_Release', 'ptr', this)
  GetRefCount() => DllCall('xcgui\XImage_GetRefCount', 'ptr', this, 'int')
  Destroy() => DllCall('xcgui\XImage_Destroy', 'ptr', this)
}
class XEase {
  static Linear(p) => DllCall('xcgui\XEase_Linear', 'float', p, 'float')
  static Quad(p, flag) => DllCall('xcgui\XEase_Quad', 'float', p, 'int', flag, 'float')
  static Cubic(p, flag) => DllCall('xcgui\XEase_Cubic', 'float', p, 'int', flag, 'float')
  static Quart(p, flag) => DllCall('xcgui\XEase_Quart', 'float', p, 'int', flag, 'float')
  static Quint(p, flag) => DllCall('xcgui\XEase_Quint', 'float', p, 'int', flag, 'float')
  static Sine(p, flag) => DllCall('xcgui\XEase_Sine', 'float', p, 'int', flag, 'float')
  static Expo(p, flag) => DllCall('xcgui\XEase_Expo', 'float', p, 'int', flag, 'float')
  static Circ(p, flag) => DllCall('xcgui\XEase_Circ', 'float', p, 'int', flag, 'float')
  static Elastic(p, flag) => DllCall('xcgui\XEase_Elastic', 'float', p, 'int', flag, 'float')
  static Back(p, flag) => DllCall('xcgui\XEase_Back', 'float', p, 'int', flag, 'float')
  static Bounce(p, flag) => DllCall('xcgui\XEase_Bounce', 'float', p, 'int', flag, 'float')
}
class XRes {
  static EnableDelayLoad(bEnable) => DllCall('xcgui\XRes_EnableDelayLoad', 'int', bEnable)
  static SetLoadFileCallback(pFun) => DllCall('xcgui\XRes_SetLoadFileCallback', 'funLoadFile', pFun)
  static GetIDValue(Name) => DllCall('xcgui\XRes_GetIDValue', 'wstr', Name, 'int')
  static GetImage(Name) => DllCall('xcgui\XRes_GetImage', 'wstr', Name, 'ptr')
  static GetImageEx(FileName, Name) => DllCall('xcgui\XRes_GetImageEx', 'wstr', FileName, 'wstr', Name, 'ptr')
  static GetColor(Name) => DllCall('xcgui\XRes_GetColor', 'ptr', Name, 'uint')
  static GetFont(Name) => DllCall('xcgui\XRes_GetFont', 'wstr', Name, 'ptr')
  static GetBkM(Name) => DllCall('xcgui\XRes_GetBkM', 'wstr', Name, 'ptr')
}
class XTemp {
  static Load(nType, FileName) => DllCall('xcgui\XTemp_Load', 'int', nType, 'wstr', FileName, 'ptr')
  static LoadZip(nType, ZipFile, FileName, pPassword := 0) => DllCall('xcgui\XTemp_LoadZip', 'int', nType, 'wstr', ZipFile, 'wstr', FileName, 'ptr', pPassword, 'ptr')
  static LoadZipMem(nType, data, length, FileName, pPassword := 0) => DllCall('xcgui\XTemp_LoadZipMem', 'int', nType, 'ptr', data, 'int', length, 'wstr', FileName, 'ptr', pPassword, 'ptr')
  static LoadEx(nType, FileName, &pOutTemp1, &pOutTemp2) => DllCall('xcgui\XTemp_LoadEx', 'int', nType, 'wstr', FileName, 'ptr*', &pOutTemp1 := 0, 'ptr*', &pOutTemp2 := 0, 'int')
  static LoadZipEx(nType, ZipFile, FileName, pPassword, &pOutTemp1, &pOutTemp2) => DllCall('xcgui\XTemp_LoadZipEx', 'int', nType, 'wstr', ZipFile, 'wstr', FileName, 'ptr', pPassword, 'ptr*', &pOutTemp1 := 0, 'ptr', &pOutTemp2 := 0, 'int')
  static LoadZipMemEx(nType, data, length, FileName, pPassword, &pOutTemp1, &pOutTemp2) => DllCall('xcgui\XTemp_LoadZipMemEx', 'int', nType, 'ptr', data, 'int', length, 'wstr', FileName, 'ptr', pPassword, 'ptr*', &pOutTemp1 := 0, 'ptr*', &pOutTemp2 := 0, 'int')
  static LoadFromString(nType, StringXML) => DllCall('xcgui\XTemp_LoadFromString', 'int', nType, 'astr', StringXML, 'ptr')
  static LoadFromStringEx(nType, StringXML, &pOutTemp1, &pOutTemp2) => DllCall('xcgui\XTemp_LoadFromStringEx', 'int', nType, 'astr', StringXML, 'ptr*', &pOutTemp1 := 0, 'ptr*', &pOutTemp2 := 0, 'int')
  static GetType() => DllCall('xcgui\XTemp_GetType', 'ptr', this, 'int')
  static Destroy() => DllCall('xcgui\XTemp_Destroy', 'ptr', this, 'int')
  static Create(nType) => DllCall('xcgui\XTemp_Create', 'int', nType, 'ptr')
  static AddNodeRoot(hTemp, pNode) => DllCall('xcgui\XTemp_AddNodeRoot', 'ptr', hTemp, 'ptr', pNode, 'int')
  static AddNode(pParentNode, pNode) => DllCall('xcgui\XTemp_AddNode', 'ptr', pParentNode, 'ptr', pNode, 'int')
  static CreateNode(nType) => DllCall('xcgui\XTemp_CreateNode', 'int', nType, 'ptr')
  static SetNodeAttribute(pNode, Name, Attr) => DllCall('xcgui\XTemp_SetNodeAttribute', 'ptr', pNode, 'wstr', Name, 'wstr', Attr, 'int')
  static SetNodeAttributeEx(pNode, itemID, Name, Attr) => DllCall('xcgui\XTemp_SetNodeAttributeEx', 'ptr', pNode, 'int', itemID, 'wstr', Name, 'wstr', Attr, 'int')
  static List_GetNode(hTemp, index) => DllCall('xcgui\XTemp_List_GetNode', 'ptr', hTemp, 'int', index, 'ptr')
  static GetNode(pNode, itemID) => DllCall('xcgui\XTemp_GetNode', 'ptr', pNode, 'int', itemID, 'ptr')
  static CloneNode(pNode) => DllCall('xcgui\XTemp_CloneNode', 'ptr', pNode, 'ptr')
}