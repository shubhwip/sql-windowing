create table sankey_charts (
	source_status varchar,
	destination_status varchar,
	time_taken_seconds int
);

with row_rank as (
select
	id,
	status,
	updated_at,
	row_number() over
         (partition by id
order by
	status) as status_row_number
from
	grafana_table gt
)


insert into sankey_charts (source_status, destination_status, time_taken_seconds)
select
	r.status as source_status,
	g.status as destination_status,
	extract(EPOCH
from
	(g.updated_at - r.updated_at)) as time_taken_seconds
from
	row_rank r
cross join grafana_table g
where
	r.id = g.id
	and r.status <> g.status
	and g.updated_at > r.updated_at
	

