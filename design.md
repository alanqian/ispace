# ispace

解决问题：超市的空间管理(货架商品摆放)

手风琴效果的导航

1. 按门店、品类进行管理；
   Plan = Store + Fixture + Products

2. 可视化：提供一个可以通过拖拽来进行货架商品摆放的GUI界面；

# Features

## user: 用户管理
  * 用户注销
  * 用户信息变更（升迁等）
  * 用户的个人信息变更 (密码等)
  * 用户注册(P2)
  * 用户注册核准(P2)
  ---
  * 区域、门店及其用户导入
  * Login/Logout

  Roles
  -----
  0. 系统管理员，预置，不可删除；admin
     import store
     duty:
       区域管理；门店管理；用户管理；

  1. 空间管理用户(总店): designer
     import other
     duty:
       品类设置
       商品数据的管理(品牌、生产商、供应商、商品)
       货架的设计和管理
       空间布局管理
       销售数据管理

  2. 门店用户: salesman
     add store_id
     import sales
     duty:
       下载本门店的各品类的空间布局图表(准备货品，进行摆放)；
       录入相关货品摆放完成日期(摆放完成后1-2天内)
       按规定定期上传本门店当期销售详细数据(分品类，可放在一张或几张xls表中)；

  3. 领导用户: manager (P2, 先不做，下同)
     抽查任意门店的当前布局情况；
     查看各种统计数据；


## store: 门店管理
  * 层级区域设置
  * 门店基本信息设置
  * 样板店设置
  * 门店最近活动(空间、数据)
  ---
  * 按层级区域的门店列表
  * 按样板的门店列表

## cat: 品类设置
  品类: 大类、中类、小类
  添加品类：一次性在一个品类下添加一个品类
            导入;
  编辑品类信息：列表方式浏览、编辑；

## mdse: 商品数据的管理(品牌、生产商、供应商、单品)
  品牌管理
  生产商
  供应商
  单品
   `--> 浏览、基本信息编辑、商品的上下架操作
  在售商品
  门店在售商品

## fixture: 货架管理
  货备设计
  货架设计
  货架配置, to stores...
  货架及配置门店表
  门店货架表

  TOOLS:
    BayNew, BayRemove,          | BaySpaceForm, ReferenceFixturePane
    FixtureNew, FixtureRemove,  | FixtureSpaceForm, ReferStoresPane

## plan: 空间布局管理
  新建一个Plan
  编辑Plan的基本信息
  编辑Plan的商品布局
  发布一个Plan, to stores...
  撤销发布
  PlanSet: (一个品类的所有门店)
  按PlanSet发布；
  Plan列表，查找


## sales: 销售数据管理
  上传数据
  分析统计设置

# 页面列表

* Layout

按标准的网页布局来设计：

       banner
      上导航条
左导航栏 + 右工作区
      下版权区

* banner区
  Logoff

* 上导航条内容

For admins:
NAV1: 首页 门店 用户 设置

For designers:
NAV2: 首页 门店 空间 货架 商品 数据 设置

For salesmen:
NAV3: 首页 空间 货架 商品 数据 设置

## 页面

P0-login. 登录页


Admins
------

P1a-home: 首页
  ???

P2a-stores: 门店页
  L1 门店管理
     添加门店
  L2 区域设置
  L3 导入 (区域、门店及其用户导入)

  >Workspace:

  L1: stores#index -> ajax stores#update
    stores#index:
      dataTable for all stores, with ajax inplace edit for each store;
      can search store in dataTable

      >TOOLS: stores#new, stores#remove
      >schema: add_column:
        market_type(消费市场类型字段): H1-3, M1-3, L1-3(高，中，低)，需要在界面上显示和编辑
        import_id

  L2: regions#index -> regions#edit
      树型层次结构的区域，可增删改
      可以考虑用dataTable简化界面，严格按区域名排序的方式；

      >TOOLS: regions#new, regions#remove
      >schema: add_column:
        market_type: string, # 消费市场类型字段: H1-3, M1-3, L1-3(高，中，低)，需要在界面上显示和编辑
      >schema: add_column
        code: string, unique    # 门店代码
        area: integer           # 面积：M²
        location_type: string   # 地段：市中心/城区/郊区/城镇/...
        ref_store_id:           # 参考门店，对样板店而言，ref_store_id = self.id
        import_id

  L3: import_stores#new
     界面：
       a. 上传xls文件，检查第一个非空sheet的表头。
       b. 提供xls模版文件下载;
       成功后显示上传的结果（导入的区域，门店，用户），否则出错误提示；

     >add scaffold: import_store
     >表头：
      区域 区域市场类型 区域备注 门店代码 门店名称 门店地段 门店面积 门店备注 用户名 用户邮箱 用户电话 用户备注
      除三个备注外，其余均为必填字段；
      区域是以.为间隔的字符串，如：cn.bj.chaoyang 为第三级区域

P3a-users: 用户页
  L1 用户列表: IMPL: 用户注销, 用户信息变更（升迁等）
  L2 添加用户

  > Workspace:
  L1: users#index

  L2: users#new

P4a-setup: 设置页
  L1 管理员信息设置
  L2 设置用户信息

  >Workspace:
  L1 管理员信息设置
     a. profiles#edit

  L2 设置用户信息
     a. find user: by store/by userid/by username
     b. profiles#edit

Designers
---------

P1d-home: 首页
  ???

P2d-stores: 门店
  L1 门店列表
  L2 样板店
  L3 门店最近动态(空间、数据)
  ---
  * 按层级区域的门店列表
  * 按样板的门店列表

  >Workspace:

  L1: stores#index
    view:
      a. dataTable，显示所有门店，含样板店状态
         filter: 按消费市场类型，面积范围，地段，样板店
      b. stores#view
      c. activities#view

  L2. stores#index?ref=id
    view:
      a. Select: 样板店
         样板店的详细信息：区域，消费市场类型，面积，地段等
      b. dataTable, 显示该样板店的门店
         区域，消费市场类型，面积，地段
      c. dataTable, 显示未设样板店的门店
         区域，消费市场类型，面积，地段
         选中的非样板店的详细信息：区域，消费市场类型，面积，地段等
    >TOOLS:
     add>>/<<remove store to template's store

  L3 门店最近动态(空间、数据)
    view:
      展示门店的下载活动
      展示门店的数据上传活动
      显示最近的未完成的活动、门店

P3d-plans: 空间
  * PlanSet: 规划组(一个品类的所有门店)
  L1 空间规划列表
     新建PlanSet
     新建Plan

  L2 空间规划设计
     新建规划
     编辑基本信息
     商品布局

  L3 部署管理
     部署PlanSet
     撤销部署
     实施情况

  >Workspace:

  L1 空间规划列表
     a. select undeployed planset#list, buttons: planset#new, planset#rename, planset#remove
     b. planset#edit: name/notes/plans
     c. plans#index, in planset
     d. plan#new, in this planset, may modify
        plan#edit, summary, form;
  L2 plan#edit basic form
     plan#edit, gui
     product#index, on shelf;
     product#edit, summary
     position#edit, form, with preview

     +tools: set facings for select products.
             check sale_type: 必卖品
             plan#publish,

  L3 部署管理
     a. planset#index, undeployed
     b. show complete status
        if not, show uncomplete plan name;
     c. show recent deployed planset;
     d. show opened planset list with:
        total stores(downloaded stores, deployed stores)

  ----
  >TOOLS:
  Facing#inc
  Facing#dec
  Position#remove
  SetLeadingGap
  Show/Hide product info
  define display color
  show/hide color legend
  >>finish

P4d-fixtures: 货架
  L1 货备管理
  L2 货架设计
     货架配置, to stores...
  L3 货架列表
     门店货架表
     品类货架表

  >Workspace:

  L1 货备管理
     a. bays#index box
     b. bays#edit, form + bays#preview
     c. preview: no interactive, but show active metrics in graph;

  L2 货架设计
     a. fixtures#index
     b. fixtures#edit form,
        fixture#space
     c. fixture#preview
     d. bay#preview, bay#form.disabled;
     e. fixture#refer, show template stores

  L3 货架列表
     filter by: 品类, 样板店
     dataTable: show fixture'summary: name, type, run, liear, area, cube

  >schema:
    bays:
      change name column to unique index, null: false
    fixtures:
      add code?
      remove store_id;
    add model:
      store_fixtures

P5d-mdse: 商品
  L1 品牌
  L2 生产商
  L3 供应商
  L4 单品
  L5 在售商品

  >Workspace:
  L1-L4:
    a. dataTable, ..#index,
      filter: 品类
      >TOOLS: set sale_type
    b. ..#edit, detailed

  L5:
    a. merchandises#index, show saling stores count, facings
       depend on recent deploy
       filter: 品类,
       show PERFORMANCE: volume, value, margin
    b. stores#list, price, facings, etc,

P6d-data: 数据
  L1 上传管理

  L2 分析统计设置
     统计汇总

  >Workspace:
  L1 上传管理
    a. 上传列表
      import_sheet#index
    b. 上传商品数据

  L2 分析统计设置, TBD

P7d-setup: 设置
  L1 用户信息设置
  L2 品类设置
     添加品类：一次性在一个品类下添加一批品类
     编辑品类信息：列表方式浏览、编辑；
     上传品类：批量导入品类
  L3 面积范围设置

  >Workspace:
  L1 用户信息设置
     users#edit, profile

  L2 品类设置
     a. categories#index:
        按大类、中类、小类层次列表
        在大类下可加一批中类
        在中类下可加一批小类;
        代码和名称之间用空格分开;
     b. categories#new: 一次性在一个品类下添加一个品类
     c. categories#edit: inplace edit in dataTable
     d. upload xls file: popup modal form
     ----
     code: DZZXX, name;
     2: 大类，饮料烟酒
     201: 中类，饮料
     20102: 小类，饮用水

  L3 面积范围设置
     A= range1
     B= range2
     C= range3

Salesmen
--------

P1s-home: 首页
  ???

P2s-plans: 空间
  L1 最新Plan
  L2 完成上报

  >Workspace:
  L1 最新Plan
    a. plans#index, with download link, download date
       dataTable,

  L2 完成上报
    a. plan#index, downloaded
       filled with finish date on recent downloaded plan;

P3s-fixtures: 货架
  L1 门店货架列表

  >Workspace:
  dataTable: 按品类列出配备货架表
  a. fixtures#index,
  b. fixtures#space
  c. fixtures#form, disabled
  d. fixtures#preview
  e. bays#preview, disabled bays#form

  >TOOLS: report problem?

P4s-mdse: 商品
  L1 门店在售商品
  L2 未上架商品，含下架商品

  >Workspace:
  L1 门店在售商品
    a. merchandises#index, on_shelf by this store
       dataTable, filter: category

  L2 未上架商品，含下架商品
    a. merchandises#index, off_shelf by this store
       dataTable, filter: category

P5s-data: 数据
  L1 上传历史
    a. import_products#index
    b. import_products#view, import detail

  L2 上传销售数据
    a. import_products#new,
       strict check table header, and sheet name, with date range of sales
       give a sample download file...

P6s-setup: 设置
  L1 用户信息设置
  L2 门店基本信息设置

  >Workspace:
  L1 用户信息设置
     a. profiles#edit

  L2 门店基本信息设置
     a. stores#edit

