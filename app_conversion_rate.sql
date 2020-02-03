#http://im-h5-in.quantum1tech.com/agent.html 为测试数据
#channel_no为test 为测试数据

select 日期,
	IOS_打开,
	IOS_验证,
	IOS_点击注册,
	IOS_注册,
	IOS_下载,
	CONCAT(ROUND(IOS_验证/IOS_打开*100,0),'%')iOS打开_验证,
	CONCAT(ROUND(IOS_点击注册/IOS_验证*100,0),'%')iOS验证_点击注册,
	CONCAT(ROUND(IOS_下载/IOS_注册*100,0),'%')iOS注册_下载,

	Android_打开,
	Android_验证,
	Android_点击注册,

	Android_new_点击注册,
	Android_new_注册,
	Android_new_下载,
	Android_new_登陆,

	Android_old_点击注册,
	Android_old_注册,
	Android_old_下载,
	Android_old_登陆,

	CONCAT(ROUND(Android_验证/Android_打开*100,0),'%')Android打开_验证,
	CONCAT(ROUND(Android_点击注册/Android_验证*100,0),'%')Android验证_点击注册,

	CONCAT(ROUND(Android_new_下载/Android_new_注册*100,0),'%')Android_new_注册_下载,
	CONCAT(ROUND(Android_old_下载/Android_old_注册*100,0),'%')Android_old_注册_下载,

	CONCAT(ROUND(Android_new_登陆/Android_new_下载*100,0),'%')Android_new_下载_登陆,
	CONCAT(ROUND(Android_old_登陆/Android_old_下载*100,0),'%')Android_old_下载_登陆



from
(
	select
		'累计-11.22前' 日期,
		
		count(distinct case when dk.operation_system='IOS' then dk.visitor_no end) IOS_打开,
		count(distinct case when dk.operation_system='Android' then dk.visitor_no end) Android_打开,

	#	dk.date 日期,
	#	dk.channel_no 渠道编码,
	#	dk.operation_system 操作系统,

		count(distinct case when dk.operation_system='IOS' then yz.visitor_no end) IOS_验证,
		count(distinct case when dk.operation_system='Android' then yz.visitor_no end) Android_验证,


		count(distinct case when dk.operation_system='IOS' then zc.visitor_no end) IOS_点击注册,
		count(distinct case when dk.operation_system='Android' then zc.visitor_no end) Android_点击注册,
	#	count(distinct case when dk.operation_system='Android' and account_no % 2 = 0 then zc.visitor_no end) Android_new_注册,

		count(distinct case when dk.operation_system='Android' and zc.phone_no % 2 = 0 and dk.date>='2018-11-22' then zc.phone_no else null end) Android_new_点击注册,
		count(distinct case when dk.operation_system='Android' and ((zc.phone_no % 2 = 1 and dk.date>='2018-11-22') or dk.date<'2018-11-22') then zc.phone_no end) Android_old_点击注册,


		count(distinct case when dk.operation_system='IOS' then g.rphone_no end) IOS_注册,
		count(distinct case when dk.operation_system='Android' and ((g.rphone_no % 2 = 1 and dk.date>='2018-11-22') or dk.date<'2018-11-22') then g.rphone_no end) Android_old_注册,
		count(distinct case when dk.operation_system='Android' and g.rphone_no % 2 = 0 and dk.date>='2018-11-22' then g.rphone_no else null end) Android_new_注册,

		count(distinct case when dk.operation_system='IOS' then xzios.phone_no end) IOS_下载,
		count(distinct case when dk.operation_system='Android' and ((xz.phone_no % 2 = 1 and dk.date>='2018-11-22') or dk.date<'2018-11-22') then xz.phone_no end) Android_old_下载,
		count(distinct case when dk.operation_system='Android' and xz.phone_no % 2 = 0 and dk.date>='2018-11-22' then xz.phone_no else null end) Android_new_下载,

		count(distinct case when dk.operation_system='Android' and xz.phone_no % 2 = 0 and dk.date>='2018-11-22' then dlnew.phone_no else null end) Android_new_登陆,
		count(distinct case when dk.operation_system='Android' and ((xz.phone_no % 2 = 1 and dk.date>='2018-11-22') or dk.date<'2018-11-22') then dlold.phone_no end) Android_old_登陆		


	from

	(
		select distinct visitor_no,
			channel_no,
			date(inst_date) date,
			operation_system,
			phone_no
		from data_cal.b_ot_open_page
		where remark = '速来拿引流打开页面' 
			and cur_address not like 'http://im-h5-in.quantum1tech.com/agent.html%' 
			and channel_no <> 'test' 
			and cur_address not like 'http://localhost:%'
			and
			    (
				 SELECT COUNT(1) AS num 
				 FROM ba.a_test_info 
				 WHERE data_cal.b_ot_open_page.PHONE_NO = ba.a_test_info.PHONE_NO
				) = 0 
	)dk


	left join 
	(
		select distinct visitor_no,
			channel_no,
			date(inst_date) date
		from data_cal.b_ot_open_page
		where remark = '速来拿引流获取验证码' 
			and cur_address not like 'http://im-h5-in.quantum1tech.com/agent.html%' 
			and channel_no <> 'test'
			and cur_address not like 'http://localhost:%'
	)yz
	on dk.visitor_no=yz.visitor_no and dk.date=yz.date


#点击注册
	left join 
	(
		select distinct visitor_no,
			channel_no,
			phone_no,
			date(inst_date) date
		from data_cal.b_ot_open_page
		where remark = '速来拿引流注册' 
			and cur_address not like 'http://im-h5-in.quantum1tech.com/agent.html%' 
			and channel_no <> 'test'
			and cur_address not like 'http://localhost:%'
	)zc
	on yz.visitor_no=zc.visitor_no and yz.date=zc.date


#注册
			left join 
			(
				select date(inst_date) as date,
					phone_no as rphone_no

				from
				(
						select ot.date as inst_date, 
							e.account_no as phone_no
						from
						(
							select date(inst_date) as date,
								 phone_no
							from data_cal.b_ot_open_page 
							where remark = '速来拿引流注册'
								and cur_address not like 'http://im-h5-in.quantum1tech.com/agent.html%' and channel_no <> 'test'
						) as ot
								
						left join 
						(
							select distinct account_no,
								date(created_on) date
							from data_cal.user
						) as e
						on ot.phone_no = e.account_no and ot.date=e.date

				) f
			) g
			on zc.date = g.date and zc.phone_no = g.rphone_no 


	left join 
	(
		select distinct visitor_no,
			channel_no,
			date(inst_date) date,
			phone_no
		from data_cal.b_ot_open_page
		where remark in ('速来拿引流安卓下载','速来拿引流安卓扫码下载','速来拿引流微信QQ打开后安卓下载')
	)xz
	on xz.phone_no=g.rphone_no and xz.date=zc.date


	left join 
	(
		select distinct visitor_no,
			channel_no,
			date(inst_date) date,
			phone_no
		from data_cal.b_ot_open_page
		where remark = '速来拿引流IOS跳转H5' and cur_address not like 'http://im-h5-in.quantum1tech.com/agent.html%' and channel_no <> 'test'
	)xzios
	on xzios.phone_no=g.rphone_no and xzios.date=zc.date


	left join
	(
		select remark log_status,
			phone_no
		from c_cu_login_log
		where remark='登陆成功！'
	)dlnew
	on xz.phone_no=dlnew.phone_no


	left join
	(
		select account_no phone_no,
			if_frist_login
		from user
		where if_frist_login=1
	)dlold
	on xz.phone_no=dlold.phone_no


	where dk.date<'2018-11-22'



)al




union


#累计20181122以后数据

select 日期,
	IOS_打开,
	IOS_验证,
	IOS_点击注册,
	IOS_注册,
	IOS_下载,
	CONCAT(ROUND(IOS_验证/IOS_打开*100,0),'%')iOS打开_验证,
	CONCAT(ROUND(IOS_点击注册/IOS_验证*100,0),'%')iOS验证_点击注册,
	CONCAT(ROUND(IOS_下载/IOS_注册*100,0),'%')iOS注册_下载,

	Android_打开,
	Android_验证,
	Android_点击注册,

	Android_new_点击注册,
	Android_new_注册,
	Android_new_下载,
	Android_new_登陆,

	Android_old_点击注册,
	Android_old_注册,
	Android_old_下载,
	Android_old_登陆,

	CONCAT(ROUND(Android_验证/Android_打开*100,0),'%')Android打开_验证,
	CONCAT(ROUND(Android_点击注册/Android_验证*100,0),'%')Android验证_点击注册,

	CONCAT(ROUND(Android_new_下载/Android_new_注册*100,0),'%')Android_new_注册_下载,
	CONCAT(ROUND(Android_old_下载/Android_old_注册*100,0),'%')Android_old_注册_下载,

	CONCAT(ROUND(Android_new_登陆/Android_new_下载*100,0),'%')Android_new_下载_登陆,
	CONCAT(ROUND(Android_old_登陆/Android_old_下载*100,0),'%')Android_old_下载_登陆

from
(
	select
		'累计-11.22后' 日期,
		
		count(distinct case when dk.operation_system='IOS' then dk.visitor_no end) IOS_打开,
		count(distinct case when dk.operation_system='Android' then dk.visitor_no end) Android_打开,

	#	dk.date 日期,
	#	dk.channel_no 渠道编码,
	#	dk.operation_system 操作系统,

		count(distinct case when dk.operation_system='IOS' then yz.visitor_no end) IOS_验证,
		count(distinct case when dk.operation_system='Android' then yz.visitor_no end) Android_验证,


		count(distinct case when dk.operation_system='IOS' then zc.visitor_no end) IOS_点击注册,
		count(distinct case when dk.operation_system='Android' then zc.visitor_no end) Android_点击注册,
	#	count(distinct case when dk.operation_system='Android' and account_no % 2 = 0 then zc.visitor_no end) Android_new_注册,

		count(distinct case when dk.operation_system='Android' and zc.phone_no % 2 = 0 and dk.date>='2018-11-22' then zc.phone_no else null end) Android_new_点击注册,
		count(distinct case when dk.operation_system='Android' and ((zc.phone_no % 2 = 1 and dk.date>='2018-11-22') or dk.date<'2018-11-22') then zc.phone_no end) Android_old_点击注册,


		count(distinct case when dk.operation_system='IOS' then g.rphone_no end) IOS_注册,
		count(distinct case when dk.operation_system='Android' and ((g.rphone_no % 2 = 1 and dk.date>='2018-11-22') or dk.date<'2018-11-22') then g.rphone_no end) Android_old_注册,
		count(distinct case when dk.operation_system='Android' and g.rphone_no % 2 = 0 and dk.date>='2018-11-22' then g.rphone_no else null end) Android_new_注册,

		count(distinct case when dk.operation_system='IOS' then xzios.phone_no end) IOS_下载,
		count(distinct case when dk.operation_system='Android' and ((xz.phone_no % 2 = 1 and dk.date>='2018-11-22') or dk.date<'2018-11-22') then xz.phone_no end) Android_old_下载,
		count(distinct case when dk.operation_system='Android' and xz.phone_no % 2 = 0 and dk.date>='2018-11-22' then xz.phone_no else null end) Android_new_下载,

		count(distinct case when dk.operation_system='Android' and xz.phone_no % 2 = 0 and dk.date>='2018-11-22' then dlnew.phone_no else null end) Android_new_登陆,
		count(distinct case when dk.operation_system='Android' and ((xz.phone_no % 2 = 1 and dk.date>='2018-11-22') or dk.date<'2018-11-22') then dlold.phone_no end) Android_old_登陆	



	from

	(
		select distinct visitor_no,
			channel_no,
			date(inst_date) date,
			operation_system
		from data_cal.b_ot_open_page
		where remark = '速来拿引流打开页面'
				and cur_address not like 'http://im-h5-in.quantum1tech.com/agent.html%' 
				and channel_no <> 'test' 
				and cur_address not like 'http://localhost:%'
				and
			    (
				 SELECT COUNT(1) AS num 
				 FROM ba.a_test_info 
				 WHERE data_cal.b_ot_open_page.PHONE_NO = ba.a_test_info.PHONE_NO
				) = 0 
	)dk


	left join 
	(
		select distinct visitor_no,
			channel_no,
			date(inst_date) date
		from data_cal.b_ot_open_page
		where remark = '速来拿引流获取验证码' and cur_address not like 'http://im-h5-in.quantum1tech.com/agent.html%' and channel_no <> 'test'
	)yz
	on dk.visitor_no=yz.visitor_no and dk.date=yz.date


	left join 
	(
		select distinct visitor_no,
			channel_no,
			phone_no,
			date(inst_date) date
		from data_cal.b_ot_open_page
		where remark = '速来拿引流注册' and cur_address not like 'http://im-h5-in.quantum1tech.com/agent.html%' and channel_no <> 'test'
	)zc
	on yz.visitor_no=zc.visitor_no and yz.date=zc.date



			left join 
			(
				select date(inst_date) as date,
					phone_no as rphone_no

				from
				(
						select ot.date as inst_date, 
							e.account_no as phone_no
						from
						(
							select date(inst_date) as date,
								 phone_no
							from data_cal.b_ot_open_page 
							where remark = '速来拿引流注册'
								and cur_address not like 'http://im-h5-in.quantum1tech.com/agent.html%' and channel_no <> 'test'
						) as ot
								
						left join 
						(
							select distinct account_no,
								date(created_on) date
							from data_cal.user
						) as e
						on ot.phone_no = e.account_no and ot.date=e.date

				) as f
			) as g
			on zc.date = g.date and zc.phone_no = g.rphone_no 


	left join 
	(
		select distinct visitor_no,
			channel_no,
			date(inst_date) date,
			phone_no
		from data_cal.b_ot_open_page
		where remark in ('速来拿引流安卓下载','速来拿引流安卓扫码下载','速来拿引流微信QQ打开后安卓下载')
	)xz
	on xz.phone_no=zc.phone_no and xz.date=zc.date


	left join 
	(
		select distinct visitor_no,
			channel_no,
			date(inst_date) date,
			phone_no
		from data_cal.b_ot_open_page
		where remark = '速来拿引流IOS跳转H5' and cur_address not like 'http://im-h5-in.quantum1tech.com/agent.html%' and channel_no <> 'test'
	)xzios
	on xzios.phone_no=zc.phone_no and xzios.date=zc.date


	left join
	(
		select remark log_status,
			phone_no
		from c_cu_login_log
		where remark='登陆成功！'
	)dlnew
	on xz.phone_no=dlnew.phone_no


	left join
	(
		select account_no phone_no,
			if_frist_login
		from user
		where if_frist_login=1
	)dlold
	on xz.phone_no=dlold.phone_no

	where dk.date<>curdate()
		and dk.date>='2018-11-22'



)al



union




select 日期,
	IOS_打开,
	IOS_验证,
	IOS_点击注册,
	IOS_注册,
	IOS_下载,
	CONCAT(ROUND(IOS_验证/IOS_打开*100,0),'%')iOS打开_验证,
	CONCAT(ROUND(IOS_点击注册/IOS_验证*100,0),'%')iOS验证_点击注册,
	CONCAT(ROUND(IOS_下载/IOS_注册*100,0),'%')iOS注册_下载,

	Android_打开,
	Android_验证,
	Android_点击注册,

	Android_new_点击注册,
	Android_new_注册,
	Android_new_下载,
	Android_new_登陆,

	Android_old_点击注册,
	Android_old_注册,
	Android_old_下载,
	Android_old_登陆,

	CONCAT(ROUND(Android_验证/Android_打开*100,0),'%')Android打开_验证,
	CONCAT(ROUND(Android_点击注册/Android_验证*100,0),'%')Android验证_点击注册,

	CONCAT(ROUND(Android_new_下载/Android_new_注册*100,0),'%')Android_new_注册_下载,
	CONCAT(ROUND(Android_old_下载/Android_old_注册*100,0),'%')Android_old_注册_下载,

	CONCAT(ROUND(Android_new_登陆/Android_new_下载*100,0),'%')Android_new_下载_登陆,
	CONCAT(ROUND(Android_old_登陆/Android_old_下载*100,0),'%')Android_old_下载_登陆


from
(
select
	dk.date 日期,
	
	count(distinct case when dk.operation_system='IOS' then dk.visitor_no end) IOS_打开,
	count(distinct case when dk.operation_system='Android' then dk.visitor_no end) Android_打开,

#	dk.date 日期,
#	dk.channel_no 渠道编码,
#	dk.operation_system 操作系统,

	count(distinct case when dk.operation_system='IOS' then yz.visitor_no end) IOS_验证,
	count(distinct case when dk.operation_system='Android' then yz.visitor_no end) Android_验证,


	count(distinct case when dk.operation_system='IOS' then zc.visitor_no end) IOS_点击注册,
	count(distinct case when dk.operation_system='Android' then zc.visitor_no end) Android_点击注册,
#	count(distinct case when dk.operation_system='Android' and account_no % 2 = 0 then zc.visitor_no end) Android_new_注册,

		count(distinct case when dk.operation_system='Android' and zc.phone_no % 2 = 0 and dk.date>='2018-11-22' then zc.phone_no else null end) Android_new_点击注册,
		count(distinct case when dk.operation_system='Android' and ((zc.phone_no % 2 = 1 and dk.date>='2018-11-22') or dk.date<'2018-11-22') then zc.phone_no end) Android_old_点击注册,


		count(distinct case when dk.operation_system='IOS' then g.rphone_no end) IOS_注册,
		count(distinct case when dk.operation_system='Android' and ((g.rphone_no % 2 = 1 and dk.date>='2018-11-22') or dk.date<'2018-11-22') then g.rphone_no end) Android_old_注册,
		count(distinct case when dk.operation_system='Android' and g.rphone_no % 2 = 0 and dk.date>='2018-11-22' then g.rphone_no else null end) Android_new_注册,

		count(distinct case when dk.operation_system='IOS' then xzios.phone_no end) IOS_下载,
		count(distinct case when dk.operation_system='Android' and ((xz.phone_no % 2 = 1 and dk.date>='2018-11-22') or dk.date<'2018-11-22') then xz.phone_no end) Android_old_下载,
		count(distinct case when dk.operation_system='Android' and xz.phone_no % 2 = 0 and dk.date>='2018-11-22' then xz.phone_no else null end) Android_new_下载,

		count(distinct case when dk.operation_system='Android' and xz.phone_no % 2 = 0 and dk.date>='2018-11-22' then dlnew.phone_no else null end) Android_new_登陆,
		count(distinct case when dk.operation_system='Android' and ((xz.phone_no % 2 = 1 and dk.date>='2018-11-22') or dk.date<'2018-11-22') then dlold.phone_no end) Android_old_登陆	


from

(
	select distinct visitor_no,
		channel_no,
		date(inst_date) date,
		operation_system
	from data_cal.b_ot_open_page
	where remark = '速来拿引流打开页面' 
				and cur_address not like 'http://im-h5-in.quantum1tech.com/agent.html%' 
				and channel_no <> 'test'
				and cur_address not like 'http://localhost:%'
				and
			    (
				 SELECT COUNT(1) AS num 
				 FROM ba.a_test_info 
				 WHERE data_cal.b_ot_open_page.PHONE_NO = ba.a_test_info.PHONE_NO
				) = 0 
)dk


left join 
(
	select distinct visitor_no,
		channel_no,
		date(inst_date) date
	from data_cal.b_ot_open_page
	where remark = '速来拿引流获取验证码' #and cur_address like 'http://im-h5.quantum1tech.com/agent.html?utm_source=%'
)yz
on dk.visitor_no=yz.visitor_no and dk.date=yz.date


left join 
(
	select distinct visitor_no,
		channel_no,
		phone_no,
		date(inst_date) date
	from data_cal.b_ot_open_page
	where remark = '速来拿引流注册' #and cur_address like 'http://im-h5.quantum1tech.com/agent.html?utm_source=%'
)zc
on yz.visitor_no=zc.visitor_no and yz.date=zc.date



		left join 
		(
			select date(inst_date) as date,
				phone_no as rphone_no

			from
			(
					select ot.date as inst_date, 
						e.account_no as phone_no
					from
					(
						select date(inst_date) as date,
							 phone_no
						from data_cal.b_ot_open_page 
						where remark = '速来拿引流注册'
							#and (cur_address like 'http://im-h5.quantum1tech.com/agent.html?utm_source=%')
					) as ot
							
					left join 
					(
						select distinct account_no,
							date(created_on) date
						from data_cal.user
					) as e
					on ot.phone_no = e.account_no and ot.date=e.date

			) as f
		) as g
		on zc.date = g.date and zc.phone_no = g.rphone_no 


	left join 
	(
		select distinct visitor_no,
			channel_no,
			date(inst_date) date,
			phone_no
		from data_cal.b_ot_open_page
		where remark in ('速来拿引流安卓下载','速来拿引流安卓扫码下载','速来拿引流微信QQ打开后安卓下载')
	)xz
	on xz.phone_no=zc.phone_no and xz.date=zc.date


	left join 
	(
		select distinct visitor_no,
			channel_no,
			date(inst_date) date,
			phone_no
		from data_cal.b_ot_open_page
		where remark = '速来拿引流IOS跳转H5' #and cur_address like 'http://im-h5.quantum1tech.com/agent.html?utm_source=%'
	)xzios
	on xzios.phone_no=zc.phone_no and xzios.date=zc.date


	left join
	(
		select remark log_status,
			phone_no
		from c_cu_login_log
		where remark='登陆成功！'
	)dlnew
	on xz.phone_no=dlnew.phone_no


	left join
	(
		select account_no phone_no,
			if_frist_login
		from user
		where if_frist_login=1
	)dlold
	on xz.phone_no=dlold.phone_no

where dk.date<>curdate()
group by dk.date



)al


order by 日期 desc

