show databases ;
create table if not exists gmall_Insurance;
use gmall_Insurance;


--开启spark-sql客户端，将下面的代码粘贴到spark-sql中运行。
drop database if exists insurance_ods cascade;
create database insurance_ods;
use insurance_ods;

drop  table if exists mort_10_13;
create table mort_10_13(
                           age  smallint comment '年龄',
                           cl1 decimal(10, 8) comment '非养老类业务一表，男（CL1）',
                           cl2 decimal(10, 8) comment '非养老类业务一表，女（CL2）',
                           cl3 decimal(10, 8) comment '非养老类业务二表，男（CL3）',
                           cl4 decimal(10, 8) comment '非养老类业务二表，女（CL4）',
                           cl5  decimal(10, 8) comment '养老类业务表，男（CL5）',
                           cl6  decimal(10, 8) comment '养老类业务表，女（CL6）'
) comment '中国人身保险业经验生命表（2010－2013）'
    row format delimited fields terminated by '\t';
load data local inpath '/export/data/workspace/insurance_test/5_hive_data/mort_10_13.txt' overwrite into table mort_10_13;

drop table if exists dd_table;
create table dd_table(
                         age      smallint comment '年龄',
                         male     decimal(10, 8) comment '男性的重疾发生率',
                         female   decimal(10, 8) comment '女性的重疾发生率',
                         k_male   decimal(10, 8) comment '男性的K值',
                         k_female decimal(10, 8) comment '女性的K值'
) comment '行业25种重疾发生率'
    row format delimited fields terminated by '\t';
load data local inpath '/export/data/workspace/insurance_test/5_hive_data/dd_table.txt' overwrite into table dd_table;


--ASSUMPTION 预定附加费用率 pre_add_exp_ratio
drop table if exists  pre_add_exp_ratio;
create table pre_add_exp_ratio  (
                                    PPP smallint comment '缴费期',
                                    r1 decimal(10,8) comment '如果保单年度=1',
                                    r2 decimal(10,8) comment '如果保单年度=2',
                                    r3 decimal(10,8) comment '如果保单年度=3',
                                    r4 decimal(10,8) comment '如果保单年度=4',
                                    r5 decimal(10,8) comment '如果保单年度=5',
                                    r6_ decimal(10,8) comment '如果保单年度>=6',
                                    r_avg decimal(10,8) comment 'Avg',
                                    r_max decimal(10,8) comment '上限'
) comment '预定附加费用率'
    row format delimited fields terminated by '\t';
load data local inpath '/export/data/workspace/insurance_test/5_hive_data/pre_add_exp_ratio.txt' overwrite into table pre_add_exp_ratio;


drop table if exists prem_std_real;
create table prem_std_real
(
    age_buy smallint comment '年投保龄',
    sex     string comment '性别',
    ppp     smallint comment '缴费期',
    bpp     string comment '保障期',
    prem    decimal(14, 6) comment '每期交的保费',
    nbev    decimal(10,8) comment '新业务价值率（NBEV，New Business Embed Value）'
)comment '标准保费真实参照表' row format delimited fields terminated by '\t';
load data local inpath '/export/data/workspace/insurance_test/5_hive_data/prem_std_real.txt' overwrite into table prem_std_real;

drop table if exists prem_cv_real;
create table prem_cv_real
(
    age_buy smallint comment '年投保龄',
    sex     string comment '性别',
    ppp     smallint comment '缴费期间',
    prem_cv      decimal(15, 7) comment '保单价值准备金毛保险费(Preuim)'
)comment '保单价值准备金毛保险费，真实参照表'
    row format delimited fields terminated by '\t';
load data local inpath '/export/data/workspace/insurance_test/5_hive_data/prem_cv_real.txt' overwrite into table prem_cv_real;

drop table if exists area;
create table area
(
    id        smallint comment '编号',
    province  string comment '省份',
    city      string comment '城市',
    direction String comment '大区域'
) comment '中国省市区域表' row format delimited fields terminated by '\t';
load data local inpath '/export/data/workspace/insurance_test/5_hive_data/area.txt' overwrite into table area;


drop table if exists policy_client;
CREATE TABLE policy_client(
                              user_id STRING COMMENT '用户号',
                              name STRING COMMENT '姓名',
                              id_card STRING COMMENT '身份证号',
                              phone STRING COMMENT '手机号',
                              sex STRING COMMENT '性别',
                              birthday STRING COMMENT '出生日期',
                              province STRING COMMENT '省份',
                              city STRING COMMENT '城市',
                              direction STRING COMMENT '区域',
                              income INT COMMENT '收入'
)
    comment '客户信息表' row format delimited fields terminated by '\t';
load data local inpath '/export/data/workspace/insurance_test/5_hive_data/policy_client.txt' overwrite into table policy_client;


drop table if exists policy_benefit;
CREATE TABLE policy_benefit(  pol_no STRING COMMENT '保单号',
                              user_id STRING COMMENT '用户号',
                              ppp STRING COMMENT '缴费期',
                              age_buy BIGINT COMMENT '投保年龄',
                              buy_datetime STRING COMMENT '购买日期',
                              insur_name STRING COMMENT '保险名称',
                              insur_code STRING COMMENT '保险代码',
                              pol_flag smallint COMMENT '保单状态，1有效，0失效',
                              elapse_date STRING COMMENT '保单失效时间')
    comment '客户投保详情表' row format delimited fields terminated by '\t';
load data local inpath '/export/data/workspace/insurance_test/5_hive_data/policy_benefit.txt' overwrite into table policy_benefit;

drop table if exists claim_info;
create table claim_info
(
    pol_no string comment '保单号',
    user_id string comment '用户号',
    buy_datetime string comment '购买日期',
    insur_code string comment '保险代码',
    claim_date string comment '理赔日期',
    claim_item string comment '理赔责任',
    claim_mnt decimal(35,6) comment '理赔金额'
)  comment '理赔信息表'
    row format delimited fields terminated by '\t';
load data local inpath '/export/data/workspace/insurance_test/5_hive_data/claim_info.txt' overwrite into table claim_info;

drop table if exists policy_surrender;
create table  policy_surrender
(
    pol_no string comment '保单号',
    user_id string comment '用户号',
    buy_datetime string comment '投保日期',
    keep_days smallint comment '退保前的保单持有天数',
    elapse_date string comment '保单失效日期'
) comment '退保记录表'
    row format delimited fields terminated by '\t';
load data local inpath '/export/data/workspace/insurance_test/5_hive_data/policy_surrender.txt' overwrite into table policy_surrender;



drop database  if exists insurance_dw cascade ;
create database insurance_dw;
use insurance_dw;

drop table if exists prem_src;
create table prem_src
(
    age_buy       smallint comment '投保年龄',
    nursing_age   smallint comment '长期护理保险金给付期满年龄',
    sex           string comment '性别',
    t_age         smallint comment '满期年龄(Terminate Age)',
    ppp           smallint comment '交费期间(Premuim Payment Period PPP)',
    bpp           smallint comment '保险期间(BPP)',
    interest_rate decimal(6, 4)  comment '预定利息率(Interest Rate PREM&RSV)',
    sa            decimal(12, 2) comment '基本保险金额(Baisc Sum Assured)',
    policy_year   smallint comment '保单年度',
    age           smallint comment '保单年度对应的年龄',
    qx            decimal(17, 12) comment '死亡率',
    kx            decimal(17, 12) comment '残疾死亡占死亡的比例',
    qx_d          decimal(17, 12) comment '扣除残疾的死亡率',
    qx_ci         decimal(17, 12) comment '残疾率',
    dx_d          decimal(17, 12) comment '',
    dx_ci         decimal(17, 12) comment '',
    lx            decimal(17, 12) comment '有效保单数',
    lx_d          decimal(17, 12) comment '健康人数',
    cx            decimal(17, 12) comment '当期发生该事件的概率，如下指的是死亡发生概率',
    cx_           decimal(17, 12) comment '对Cx做调整，不精确的话，可以不做',
    ci_cx         decimal(17, 12) comment '当期发生重疾的概率',
    ci_cx_        decimal(17, 12) comment '当期发生重疾的概率，调整',
    dx            decimal(17, 12) comment '有效保单生存因子',
    dx_d_         decimal(17, 12) comment '健康人数生存因子',
    ppp_          smallint comment '是否在缴费期间，1-是，0-否',
    bpp_          smallint comment '是否在保险期间，1-是，0-否',
    expense       decimal(17, 12) comment '附加费用率',
    db1           decimal(17, 12) comment '残疾给付',
    db2_factor    decimal(17, 12) comment '长期护理保险金给付因子',
    db2           decimal(17, 12) comment '长期护理保险金',
    db3           decimal(17, 12) comment '养老关爱金',
    db4           decimal(5, 2) comment '身故给付保险金',
    db5           decimal(17, 12) comment '豁免保费因子'
) comment '保费因子表（到每个保单年度）'
    row format delimited fields terminated by '\t';

drop table if exists prem_std;
create table prem_std
(
    age_buy smallint comment '年投保龄',
    sex     string comment '性别',
    ppp     smallint comment '缴费期',
    bpp     string comment '保障期',
    prem    decimal(14, 6) comment '每期交的保费'
) comment '标准保费结果表' row format delimited
    fields terminated by '\t';

drop table if exists cv_src;
create table cv_src(
                       age_buy       smallint comment '年投保龄',
                       nursing_age   smallint comment '长期护理保险金给付期满年龄',
                       sex           string comment '性别',
                       t_age         smallint comment '满期年龄(Terminate Age)',
                       ppp           smallint comment '交费期间(Premuim Payment Period PPP)',
                       bpp           smallint comment '保险期间(BPP)',
                       interest_rate_cv decimal(6, 4) comment '现金价值预定利息率（Interest Rate CV）',
                       sa            decimal(12, 2) comment '基本保险金额(Baisc Sum Assured)',
                       policy_year   smallint comment '保单年度',
                       age           smallint comment '保单年度对应的年龄',
                       qx            decimal(8, 7) comment '死亡率',
                       kx            decimal(8, 7) comment '残疾死亡占死亡的比例',
                       qx_d          decimal(8, 7) comment '扣除残疾的死亡率',
                       qx_ci         decimal(8, 7) comment '残疾率',
                       dx_d          decimal(8, 7) comment '',
                       dx_ci         decimal(8, 7) comment '',
                       lx            decimal(8, 7) comment '有效保单数',
                       lx_d          decimal(8, 7) comment '健康人数',
                       cx            decimal(8, 7) comment '当期发生该事件的概率，如下指的是死亡发生概率',
                       cx_           decimal(8, 7) comment '对Cx做调整，不精确的话，可以不做',
                       ci_cx         decimal(8, 7) comment '当期发生重疾的概率',
                       ci_cx_        decimal(8, 7) comment '当期发生重疾的概率，调整',
                       dx            decimal(8, 7) comment '有效保单生存因子',
                       dx_d_         decimal(8, 7) comment '健康人数生存因子',
                       ppp_          smallint comment '是否在缴费期间，1-是，0-否',
                       bpp_          smallint comment '是否在保险期间，1-是，0-否',
                       expense       decimal(8, 7) comment '附加费用率',
                       db1           decimal(12, 2) comment '残疾给付',
                       db2_factor    decimal(8, 7) comment '长期护理保险金给付因子',
                       db2           decimal(17, 7) comment '长期护理保险金',
                       db3           decimal(12, 2) comment '养老关爱金',
                       db4           decimal(12, 2) comment '身故给付保险金',
                       db5           decimal(17, 7) comment '豁免保费因子',
                       np_         DECIMAL(12, 2) comment '净保费',
                       pvnp        DECIMAL(17, 7) comment '净保费现值',
                       pvdb1       DECIMAL(17, 7) comment '',
                       pvdb2       DECIMAL(17, 7) comment '',
                       pvdb3       DECIMAL(17, 7) comment '',
                       pvdb4       DECIMAL(17, 7) comment '',
                       pvdb5       DECIMAL(17, 7) comment '',
                       pvr         DECIMAL(17, 7) comment '保单价值准备金',
                       rt          DECIMAL(6, 3) comment '',
                       np          DECIMAL(17, 7) comment '修匀净保费',
                       sur_ben     DECIMAL(17, 7) comment '生存金',
                       cv_1a       DECIMAL(17, 7) comment '现金价值年末（生存给付前）',
                       cv_1b       DECIMAL(17, 7) comment '现金价值年末（生存给付后）',
                       cv_2        DECIMAL(17, 7) comment '现金价值年中'
)comment '现金价值表（到每个保单年度）' row format delimited
    fields terminated by ',';

drop table if exists prem_cv;
create table prem_cv
(
    age_buy smallint comment '年投保龄',
    sex     string comment '性别',
    ppp     smallint comment '缴费期间',
    prem_cv      decimal(15, 7) comment '保单价值准备金毛保险费(Preuim)'
)comment '保单价值准备金毛保险费表' row format delimited
    fields terminated by '\t';

drop table if exists rsv_src;
create table rsv_src
(
    age_buy       smallint comment '投保年龄',
    nursing_age   smallint comment '长期护理保险金给付期满年龄',
    sex           string comment '性别',
    t_age         smallint comment '满期年龄(Terminate Age)',
    ppp           smallint comment '交费期间(Premuim Payment Period PPP)',
    bpp           smallint comment '保险期间(BPP)',
    interest_rate decimal(6, 4)  comment '预定利息率(Interest Rate PREM&RSV)',
    sa            decimal(12, 2) comment '基本保险金额(Baisc Sum Assured)',
    policy_year   smallint comment '保单年度',
    age           smallint comment '保单年度对应的年龄',
    qx            decimal(8,7) comment '死亡率',
    kx            decimal(8,7) comment '残疾死亡占死亡的比例',
    qx_d          decimal(8,7) comment '扣除残疾的死亡率',
    qx_ci         decimal(8,7) comment '残疾率',
    dx_d          decimal(8,7) comment '',
    dx_ci         decimal(8,7) comment '',
    lx            decimal(8,7) comment '有效保单数',
    lx_d          decimal(8,7) comment '健康人数',
    cx            decimal(8,7) comment '当期发生该事件的概率，如下指的是死亡发生概率',
    cx_           decimal(8,7) comment '对Cx做调整，不精确的话，可以不做',
    ci_cx         decimal(8,7) comment '当期发生重疾的概率',
    ci_cx_        decimal(8,7) comment '当期发生重疾的概率，调整',
    dx            decimal(8,7) comment '有效保单生存因子',
    dx_d_         decimal(8,7) comment '健康人数生存因子',
    ppp_          smallint comment '是否在缴费期间，1-是，0-否',
    bpp_          smallint comment '是否在保险期间，1-是，0-否',
    db1           decimal(12, 2) comment '残疾给付',
    db2_factor    decimal(8, 7) comment '长期护理保险金给付因子',
    db2           decimal(12, 2) comment '长期护理保险金',
    db3           decimal(12, 2) comment '养老关爱金',
    db4           decimal(12, 2) comment '身故给付保险金',
    db5           decimal(12, 2) comment '豁免保费因子',
    np_           decimal(12, 2) comment '修正纯保费',
    pvnp          decimal(17, 7) comment '修正纯保费现值',
    pvdb1         decimal(17, 7) comment '',
    pvdb2         decimal(17, 7) comment '',
    pvdb3         decimal(17, 7) comment '',
    pvdb4         decimal(17, 7) comment '',
    pvdb5         decimal(17, 7) comment '',
    prem_rsv      decimal(17, 7) comment '保险费(Preuim)',
    alpha         decimal(17, 7) comment '修正纯保费首年',
    beta          decimal(17, 7) comment '修正纯保费续年',
    rsv1          decimal(17, 7) comment '准备金年末',
    rsv2          decimal(17, 7) comment '准备金年初（未加当年初纯保费）',
    rsv1_re       decimal(17, 7) comment '修正责任准备金年末',
    rsv2_re       decimal(17, 7) comment '修正责任准备金年初(未加当年初纯保费）'
)comment '准备金表（到每个保单年度）' row format delimited
    fields terminated by ',';


--开启spark-sql客户端，将下面的代码粘贴到spark-sql中运行。
drop database if exists insurance_app cascade;
create database insurance_app;
use insurance_app;
drop table if exists insurance_app.policy_actuary;
create table insurance_app.policy_actuary
(
    age_buy     smallint comment '年投保龄',
    sex         string comment '性别',
    ppp         smallint comment '交费期间(Premuim Payment Period PPP)',
    bpp         smallint comment '保险期间(BPP)',
    policy_year smallint comment '保单年度',
    sa          decimal(12, 2) comment '基本保险金额(Baisc Sum Assured)',
    cv_1a       decimal(17, 7) comment '现金价值年末（生存给付前）',
    cv_1b       decimal(17, 7) comment '现金价值年末（生存给付后）',
    sur_ben     decimal(17, 7) comment '生存金',
    np          decimal(17, 7) comment '修匀净保费',
    rsv2_re     decimal(17, 7) comment '修正责任准备金年初(未加当年初纯保费）',
    rsv1_re     decimal(17) comment '修正责任准备金年末',
    np_         decimal(12) comment '修正纯保费'
) comment '产品精算数据表' row format delimited fields terminated by '\t';

drop table if exists policy_result;
create table policy_result
(
    pol_no         STRING COMMENT '保单号',
    user_id        string comment '客户id',
    name           string comment '姓名',
    sex            string comment '性别',
    birthday       string comment '出生日期',
    ppp            string comment '缴费期',
    age_buy        bigint comment '投保年龄',
    buy_datetime   string comment '投保日期',
    insur_name     STRING COMMENT '保险名称',
    insur_code     STRING COMMENT '保险代码',
    province       string comment '所在省份',
    city           string comment '所在城市',
    direction      String comment '所在区域',
    bpp            smallint comment '保险期间，保障期',
    policy_year    smallint comment '保单年度',
    sa             decimal(12, 2) comment '保单年度基本保额',
    cv_1a          decimal(17, 7) comment '现金价值给付前',
    cv_1b          decimal(17, 7) comment '现金价值给付后',
    sur_ben        decimal(17, 7) comment '生存给付金',
    np             decimal(17, 7) comment '纯保费（CV.NP）',
    rsv2_re        decimal(17, 7) comment '年初责任准备金',
    rsv1_re        decimal(17, 7) comment '年末责任准备金',
    np_            decimal(12, 2) comment '纯保费(RSV.np_) ',
    prem_std       decimal(14, 6) comment '每期交保费',
    prem_thismonth decimal(14, 6) comment '本月应交保费'
)  comment '客户保单精算结果表' partitioned by (month string)
    row format delimited fields terminated by '\t';

--保费收入增长率
drop table if exists app_agg_month_incre_rate;
CREATE TABLE app_agg_month_incre_rate
(
    prem            DECIMAL(24, 6) comment '本月保费收入',
    last_prem       DECIMAL(24, 6) comment '上月保费收入',
    prem_incre_rate DECIMAL(6, 4)comment '保费收入增长率'
)comment '保费收入增长率表' partitioned by (month string comment '月份')
    row format delimited fields terminated by '\t';

drop TABLE if exists app_agg_month_first_of_total_prem;
CREATE TABLE app_agg_month_first_of_total_prem
(
    first_prem          DECIMAL(24, 6),
    total_prem          DECIMAL(24, 6),
    first_of_total_prem DECIMAL(8, 6)
) comment '首年保费与保费收入比表' partitioned by (month string comment '月份')
    row format delimited fields terminated by '\t';

drop TABLE if exists app_agg_month_premperpol;
CREATE TABLE app_agg_month_premperpol
(
    insur_code   string comment '保险代码',
    insur_name   string comment '保险名称',
    prem_per_pol DECIMAL(38, 2) comment '个人营销渠道的件均保费'
) comment '个人营销渠道的件均保费' partitioned by (month string comment '月份')
    row format delimited fields terminated by '\t';


DROP TABLE if exists app_agg_month_mort_dis_rate;
CREATE TABLE app_agg_month_mort_dis_rate
(
    insur_code string comment '保险代码',
    insur_name string comment '保险名称',
    age        int,
    sg_rate    decimal(8,6),
    sc_rate    decimal(8,6)
) comment '死亡发生率和残疾发生率表' partitioned by (month string comment '月份')
    row format delimited fields terminated by '\t';

--新业务价值率
drop table if exists app_agg_month_nbev;
create table app_agg_month_nbev
(
    insur_code string comment '保险代码',
    insur_name string comment '保险名称',
    nbev decimal(38,11) comment '新业务价值率'
)  comment '新业务价值率表' partitioned by (month string comment '月份')
    row format delimited fields terminated by '\t';

drop table if exists app_agg_month_high_net_rate;
create table app_agg_month_high_net_rate
(
    high_net_rate decimal(8, 6) comment '高净值客户比例'
) comment '高净值客户比例表' partitioned by (month string comment '月份')
    row format delimited fields terminated by '\t';


drop table if exists app_agg_month_dir;
create table app_agg_month_dir
(
    direction string comment '所在区域',
    sum_users bigint comment '总投保人数',
    sum_prem decimal(24) comment '当月保费汇总',
    sum_cv_1b decimal(27,2) comment '总现金价值',
    sum_sur_ben decimal(27) comment '总生存金',
    sum_rsv2_re decimal(27,2) comment '总准备金'
) comment '各地区的汇总保费表' partitioned by (month string comment '月份')
    row format delimited fields terminated by '\t';

