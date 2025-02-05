-- source = A
-- destination = B
-- calculate time taken

with source_status as (
select
	id,
	status,
	updated_at
from
	grafana_table
where
	status = 'A'
),

destination_status as (
select
	id,
	status,
	updated_at
from
	grafana_table
where
	status = 'B'
)

select
	source.id as id,
	source.status as source_status,
	destination.status as destination_status,
	(destination.updated_at - source.updated_at) as time_taken
from
	source_status source
inner join destination_status destination
on
	source.id = destination.id

