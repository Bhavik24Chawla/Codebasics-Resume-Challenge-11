update elections
set pc_name = TRIM(pc_name)

-------------------------

update elections
set state = 'Telangana'
where pc_name in 
(select pc_name from elections where year = 2014 and state = 'Andhra Pradesh' 
except
select pc_name from elections where year = 2019 and state = 'Andhra Pradesh')

select distinct(pc_name) from elections where state = 'Telangana'

-----------------------------------------------------
update elections
set pc_name = 'Dadra and Nagar Haveli'
where state = 'Dadra & Nagar Haveli'

-----------------------------------------

update elections
set pc_name = 'Bikaner (SC)'
where pc_name = 'Bikaner'

--------------------------------------

update elections
set pc_name = 'Jaynagar'
where pc_name = 'Joynagar'

--------------------------------
update elections
set pc_name = 'Bardhaman Durgapur'
where pc_name = 'Burdwan - durgapur'

--------------------------------------
update elections
set pc_name = 'CHEVELLA'
where pc_name = 'CHELVELLA'

