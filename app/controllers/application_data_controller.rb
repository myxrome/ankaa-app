class ApplicationDataController < ActionController::Base

  def index
    ActiveRecord::Base.establish_connection
    result = ActiveRecord::Base.connection.execute lighting_query(params[:k], params[:u], params[:q])
    render json: result.first['d'].to_s
  end

  private
  def lighting_query(keys, date, quality)
"set work_mem = '16MB';
with tg as (
    select tg.\"id\" as id, tg.\"order\" as o, tg.\"key\" as k, tg.\"name\" as n, tg.\"updated_at\" as u
    from topic_groups tg
    where tg.\"key\" in ('#{keys.join(',')}')
    and tg.\"active\" = true
),
t as (
    select t.\"id\" as id, t.\"topic_group_id\" as _id, t.\"order\" as o, t.\"name\" as n, t.\"updated_at\" as u
    from topics t, tg tg
    where t.\"topic_group_id\" = tg.\"id\"
    and t.\"active\" = true
),
c as (
    select c.\"id\" as id, c.\"topic_id\" as _id, c.\"order\" as o, c.\"name\" as n, c.\"updated_at\" as u
    from categories c, t t
    where c.\"topic_id\" = t.\"id\"
    and c.\"active\" = true
),
_v as (
    select v.\"id\" as id, v.\"category_id\" as _id, v.\"name\" as n, v.\"old_price\" as op, v.\"new_price\" as np,
    v.\"discount\" as ds,
    (select '/content/p/' || p.\"value_id\" || '/' || p.\"id\" || '/' || p.\"file_key\" || 'thumb.jpg'
    from promos p
    where p.\"value_id\" = v.\"id\"
    and p.\"order\" = 1) as t,
    v.\"url\" as l, v.\"updated_at\" as u
    from values v, c c
    where v.\"category_id\" = c.\"id\"
    and v.\"active\" = true
    and v.\"updated_at\" > '#{date}'
),
d as (
    select d.\"id\" as id, d.\"value_id\" as _id, d.\"order\" as o, dt.\"caption\" as c, d.\"text\" as t,
    d.\"red\" as r, d.\"bold\" as b, d.\"updated_at\" as u
    from descriptions d, _v v, description_templates dt
    where d.\"value_id\" = v.\"id\"
    and dt.id = d.description_template_id
),
p as (
    select p.\"id\" as id, p.\"value_id\" as _id, p.\"order\" as o,
    '/content/p/' || p.\"value_id\" || '/' || p.\"id\" || '/' || p.\"file_key\" || '#{quality}' || '.jpg' as l,
    p.\"updated_at\" as u
    from promos p, _v v
    where p.\"value_id\" = v.\"id\"
),
v as (
    select _v.*,
    ( select json_agg(row_to_json((d))) from d d where d.\"_id\" = _v.\"id\" ) as d,
    ( select json_agg(row_to_json((p))) from p p where p.\"_id\" = _v.\"id\" ) as p
    from _v _v
),
ad as (
    select (select coalesce(json_agg(row_to_json((tg))), '[]') from tg where tg.\"u\" > '#{date}') as g,
    (select coalesce(json_agg(row_to_json((t))), '[]') from t where t.\"u\" > '#{date}') as t,
    (select coalesce(json_agg(row_to_json((c))), '[]') from c where c.\"u\" > '#{date}') as c,
    (select coalesce(json_agg(row_to_json((v))), '[]') from v) as v
)
select row_to_json(ad) as d from ad;"
  end

end